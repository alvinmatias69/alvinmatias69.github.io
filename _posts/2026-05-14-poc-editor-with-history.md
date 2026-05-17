---
layout: post
author: mat
title: "PoC: Text Editor With History"
excerpt_separator: <!--more-->
---
The other day, I saw a post from someone who's concerned about grading their students assignment.
They are not sure whether their student did their assignment genuinely.
Someone in the reply said that he asked their students to save the draft from time to time just to make sure.
Some had used google docs edit history unfortunately to no avail.
They said that sometimes typed words are detected as a chunk and can't distinguish that with copy-pasted texts.
This intrigued me, as I think this is something that can and maybe already done.
<!--more-->

Before we start, let's have refresher on how the online text editing works. 
One of the commonly used algorithm is Operational Transform (OT).
To put it simply instead of syncing the whole document, OT do it on operational basis (hence the name).


Take a look at example below, cursor position is indicated by `C` (index 3).
```
Hello 
^^^^^
01234
   C
```

Now if we type an input `x`, we'll have the following state.
```
Helxlo
^^^^^^
012345
    C
```

Instead of sending the whole string, OT will instead send the new operation.
```
Add(3, 'x')
```

The notation might be different between each implementation, but the main idea still apply.
It will send the operation name (`Add`), its position (`3`), and the value (`x`).

For deletion, the value won't be sent.
```
Helxlo -> Hello
^^^^^^    ^^^^^
012345    01234
   C        C
   
Payload:
Delete(3)
```

Using those operations, we can easily recreate the text without even knowing the full text data.

> For multiple users OT, timestamp for each operations might be required.
> As multiple users OT will have consistency model to synchronize operations between those users.
> Timestamp is needed for the model to determine which operation should be applied first.
> Multiple users OT are out of scope, but readers are encouraged to explore.

Now, if we take the operational persistent aspect of the OT, we can make a text editor that "remember" their editing history!

# Design

<pre class="mermaid">
    sequenceDiagram
        actor User
        participant Editor
        participant Viewer
        participant Backend

    User->>Editor: Add change to editor
    Editor->>Backend: Save operations request
    Backend-->>Editor: Save operations result
    Editor-->>User: Add change result
    
    User->>Viewer: Get document data
    Viewer->>Backend: Get document operations request
    Backend-->>Viewer: Get document operations result
    Viewer-->>User: Get rendered document data
</pre>

This project is quite simple, users can interact using two interfaces: editor and viewer.
Both interfaces are utilizing html `textarea` as it has (almost) all required elements for our purpose.

## Editor

User can interact using editor to modify documents.
The editor will handle user input, and translate it to operations.
Those operations will be sent to the backend for persistence.

First, we need to take note of the cursor position.
Because we're utilizing `textarea`, this should be trivial

```javascript
// Most of the times, both start and end position will be equal. 
// With the exception when the user is highlighting texts.
function updateCursorPosition() {
    start = document.getElementById("editor").selectionStart;
    end = document.getElementById("editor").selectionEnd;
}
```

We need to hook this to event so we can update our position data accordingly.

```javascript
document.getElementById("editor").addEventListener("keyup", e => {
    updateCursorPosition();
});
```

The idea here is that, after every keystroke the cursor position might change (including typing and arrow key).
Hence, hooking this will guarantee us the latest position.
Note that we're using `keyup` event rather than `keydown`, because we want the cursor position **before** the update was happening (more on this later).

```javascript
document.getElementById("editor").addEventListener("selectionchange", e => {
    updatePosition();
});
```
We also have to consider that the user might click on the document to change the cursor position.
Hence, `selectionchange` event is also needed.
As this event will fired everytime the user change the cursor position using mouse click.

After that, the value of each input is also need to be tracked.
```javascript
document.getElementById("editor").addEventListener("input", e => {
    ...
});
```

The `input` event has `inputType` property, which will indicate the type of change itself (e.g. inserting or deleting).
Each type has their own characteristic, for example the change payload will be one character for `insertText` type and empty for deletion type (e.g. `deleteWordForward`), and so on.
Therefore, proper mapping are required to capture all changes to the text accurately.

> As of this writing, there are [46](https://w3c.github.io/input-events/#interface-InputEvent-Attributes) input event types.
> Not all of them are implemented for this proof of concept, only some crucial ones.
> The full event mapping is left as an exercise for the reader.

Additionally, we need to send the operation timestamp.
So, the operations order can be preserved.

```javascript
const EVENT_MAP = {
    "insertText": "INSERT",
    "deleteWordBackward": "DELETE",
    ...
};

let operations = [];

document.getElementById("editor").addEventListener("input", e => {
    const data = {
        value: e.data,
        position_start: start,
        position_end: end,
        operation: EVENT_MAP[e.inputType],
        timestamp: (new Date()).toISOString(),
    };

    operations.push(data);
    debounce();
});
```

To avoid tons of request to our backend for every changes, we use a simple debounce to do batch requests.

```javascript
let timeoutID;

function debounce() {
    clearTimeout(timeoutID);
    timeoutID = setTimeout(() => {
        sendOperations(operations);
    }, 1000);
}
```

## Viewer

User then can view the document later, complete with the changes histories.
Ideally, the viewers also need to be able iterate on the entries, to determine whether the change is legitimate.

When the viewer client open a document, backend will send a list of operations consists on that document.

```json
{
    operations: [
        {
            value: "h",
            position_start: 0,
            position_end: 0,
            operation: "INSERT"
        },
        ...
    ]
}
```

The client then need to build the document by piecing together those operations.

On our PoC, there are two kind of operations: `INSERT` and `DELETE`.
While both are self explanatory, they need each their own handling for creating the final document.

```javascript
function constructEditor(config) {
    let value = document.getElementById("editor").value;
    for (const event of operations) {
        if (event.operation === "INSERT") {
            value = value.slice(0, event.position_start) + event.value + value.slice(event.position_end, value.length);
        }
    }

    document.getElementById("editor").value = value;
}
```

For `INSERT` operation, the logic is straightforward.
We put the payload `value` between two substring based on the payload position.
Notice that we're using `position_start` for the prefix cutoff and `position_end` for the suffix start position.
While, the value will be the same for a simple input operation.
When a user is highlighting multiple characters and then do the typing, practically replacing the highlighted characters, the value will be different based on the highlight start and end position.
By doing this, we ensure that the highlighted text will be removed before we insert the payload value.

```javascript
function constructEditor(config) {
    ...
    for (const event of operations) {
        ...
        if (event.operation === "DELETE") {
            value = value.slice(0, event.position_start) + value.slice(event.position_end, value.length);
        }
    }
    ...
}
```

To handle `DELETE` operation, we can simply modify the `INSERT` logic without inserting the payload `VALUE`.
The catch is that, this logic only works for multiple characters deletion.
For a single character deletion, all it'll do is just combining the substring without resulting in any changes.
Therefore, we need to adjust the deletion logic accordingly.

```javascript
function constructEditor(config) {
    ...
    for (const event of operations) {
        ...
        if (event.operation === "DELETE") {
            const start = event.position_start === event.position_end
                  ? event.position_start - 1
                  : event.position_start;
            value = value.slice(0, start) + value.slice(event.position_end, value.length);
        }
    }
    ...
}
```

Because our goals is to determined whether the content of a document is just a simple copy-paste, we can add a simple logic to catch this.

```javascript
let suspiciousOperations = [];

function constructEditor(config) {
    ...
    for (const event of operations) {
        ...
        if (event.value.length >= 2) {
            suspiciousOperations.push(event);
        } 
    }
    ...
}
```

For a copy-paste payload, the value length will be more than one.
As the `insertFromPaste` input event will have the whole clipboard paste data as the event value.

Then using those simple interfaces, we can build us an editor that can "remember" the editing histories and catch if the content is a simple copy and paste.
You can check the working PoC here: [Editor History](https://editor.matiasalvin.dev)

> Note: the live PoC also has several features not included in this post (e.g. finalized document, single user editor, etc).
> Because those features are both trivial to implement and not related to OT algorithm, their explanations are ommited.
> Reader can refer to the project [repository](https://github.com/alvinmatias69/editor-history) for more informations.

# Closing and Forethought

While this PoC might works to catch copy-paste text content.
This solution is far from perfect, most notably.

- Only support for plain text.
- False positive might arise and polluted the data (e.g. pasting for reference source / article URL).
- Editor can mock their text input using javascript to simulate typing.

Therefore, more extensive security and fine-tuning are needed before it can be production ready.

While this is not a new idea (I think some coding test platforms already implemented this),
general editor with history could be helpful. 
Especially in the academia where the process is as important as the final result itself.

As a final note, I'd say that it's quite refreshing to write some plain javascript after all this time.
The code might be spaghetti and contains lot of bugs (it's only powered by plain javascript and cans of Strong Zero after all). 
But I can assure you that everything on my blog is and always will be 100% made by human.

Thanks for reading, please let me know what do you think!
