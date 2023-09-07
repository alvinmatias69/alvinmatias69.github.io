---
layout: post
author: mat
title: "Writing cgentest: Table Test Generator for C"
excerpt_separator: <!--more-->
---

Usually, I use test driven development (TDD) approach when I'm writing a software project.
In golang (language that I used to writes daily) there's this neat library that really helps me to do that, [Gotests](https://github.com/cweill/gotests).
Gotests is a simple library that generates a boilerplate for testing, it really helps me on writing tested go project.

Unfortunately, there's no such libraries in c.
While there's plenty of unit testing libraries, I'm unable to find the one that simply generate a helper boilerplate.
So, I decided to write one myself.
<!--more-->

What I thought to be a simple project that can be done in a month, turns out is a long journey.
It's not that the project is a tall mountain, rather it's a dense forest.
There's so many problems that I didn't understand how to solve.
Safe to say, I had spend maybe 80% of times writing this project learning things.
And I don't regret it, not even a bit!


# Introduction

Writing test considered as chores for most programmers, it's not that uncommon for programmers to skip out on writing test.
But, regardless of that, most of them will agree that test is important.
It's the most quick and certain way to do sanity check on a software project.

There are multiple type of test methodologies available.
One of them is Data-driven / Table-driven testing.
Table-driven testing is a method to write test specifications (input, output, condition, etc) in a "table" entries to later be tested iteratively.
To quote [golang wiki](https://github.com/golang/go/wiki/TableDrivenTests) on Table-driven tests, "Table driven testing is not a tool, package or anything else, it's just a way and perspective to write cleaner tests.".

Personally, I really like Table-driven testing.
It allows me to write simple but detailed tests, while also served as some sort of documentation.
The main drawback is it's mainly tailored for unit testing, so it's not easy if you want to use it for anything else (e.g. integration test).

I'm unable to find any similar tools to generate the boilerplate for C.
As I've mentioned in my previous post, I'm currently learning to writes in C.
And I think that, the existence of this tools will help me greatly on that.
So I write this small tool to solve that problem, [cgentest](https://github.com/alvinmatias69/cgentest).


# Glossaries

Quick summaries of tools referenced in this project.
You can skip this section if you're already familiar with these tools.

## Ctags

`ctags` is a tool to generates an index (or tag) file of language objects found in source files for programming languages. 
This index is then used by text editors or other tools to handle the indexed item.
This project utilize [`universal ctags`](https://ctags.io/) (abbreviated as u-ctags), a maintained implementation of `ctags`.

## Mustache

[`Mustache`](https://mustache.github.io/) is a _logic-less_ template system. It works by expanding tags in a template using values provided.

## JSON
`JavaScript Object Notation` (`JSON`), is a file and data interchange text format consists of key-value pairs and arrays. 
It's mainly used in web applications, but its usage is really broad and aplicable to any software projects.

## Autotools

The [GNU Autotools](https://www.gnu.org/software/automake/faq/autotools-faq.html) (also known as GNU Build System), is a suite of programming tools designed to assist in making portable source code packages in Unix-like systems.


# Writing cgentest

A quick and simple explanation of cgentest process can be described as follows.
1. Read a c file and extract the function metadata (function name, parameters, return type)
2. Map the function data into boilerplate data-driven test of that file, Preferably into a customizable template.
3. Output the generated boilerplate.

![Simple flowchart of cgentest](/assets/images/writing-cgentest/simple_cgentest_flow.png){: width="100%"}

While it looks simple, each of the steps has their own difficulties that has to be solved.


## Extracting C Functions Metadata

At first, I tried to use a finite state machine (fsm) to solve this.
By using fsm, I mean that I start by tokenizing the source file.
Those tokens then will be passed to the fsm to be parsed and relevant data will then extracted.

I quickly realize the flaw of this approach though.
- It's prone to error. 
  Need to make a very detailed fsm to generate an accurate data.
- The scope is too big. 
  It's more like writing parser at this point. 
  Which is not the main objective of this project.

Then, I found universal ctags, which is perfect for this project.
- Its usage fits perfectly for the project requirement.
- Has a c library to read its result ([libreadtags](https://github.com/universal-ctags/libreadtags)), no need to parse too much.

But, it's not that this approach is without a flaw.
- The project is now depend on a third party library.
- ctags binary is required and will be executed by the project.
- Still need to parse from libreadtags, albeit not as much.

After weighing my options, I decided to go with universal ctags.
As it's more aligned with my goals to learning to write C, without delve too deep into technicalities.

![Sequence diagram relations between cgentest, ctags, and libreadtags](/assets/images/writing-cgentest/cgentest_ctags_sequence_diagram.png){: width="100%"}


## Writing the Generated Boilerplate

Outputing the result can be done simply using string formating and some conditionals.
But, this approach has several drawbacks.
- It's hard to make any changes later.
- The code will be cluttered and hard to read.
- More importantly, it's hard to gives option of custom template for user.

Considering my requirements, I decide to use `Mustache` template system.
More specifically, I'm using [mustach](https://gitlab.com/jobol/mustach) a c library for `mustache` template.
- Simple to use
- Still maintained
- Support several json libraries
  - [cJSON](https://github.com/DaveGamble/cJSON)
  - [jansson](https://github.com/akheron/jansson)
  - [json-c](https://github.com/json-c/json-c)

To elaborates on my last point, what does `json` got to do with `mustache`?
Well, it's plenty. You see, `mustache` originally is a web template and usually paired with `json` as its data provider.
`Mustach` itself relies on json libraries to aggregate the data into any `mustache` template.

To utilize `mustach` in a project, we can work in this step.
1. Map the data into a json representation using one of the supported library.
2. Fed the data into mustach with its respective method (e.g. if using jansson, then we will be using `mustach_jansson_file`).

We can simply support one library and be done with it.
But, I decide to support all three libraries.


## Packaging for Release

I do have several experiences on releasing software. 
But, usually I did that through the language package manager (`npm js`, `cargo rust`, `golang mod`).

While C doesn't have a universal package manager, there are several build system that accomodate this.
- `cmake`
- `meson`
- `GNU autotools`
- etc

So, I then decide to use autotools, because:
- No dependency needed (except dependency for the cgentest itself).
- I have used projects that utilize autotools many times in the past. Yet, never know how to use autotools in a project.

The problem is, autotools isn't as easy to use as other modern build system.
There are not many resources to learn it in the internet too.
Most of it only explain the very simple usage or some pretty specific problem.
In hindsight, most of it answered my project use case. But, at the time I still hasn't grasps the concept of autotools yet.

Fortunately, I found a great book that explain things in detail.
The book's name is `Autotools` by John Calcote.
It's a pretty good book, I spent several months reading it until I understand the basic concept of it.
I'm not claiming myself has mastered autotools, but it's good enought to implement it in my project.

You know, people said that the best way to learn something is to learning by doing, so I did just that.
I decide to fully refactor the cgentest project to utilize `Autotools`.
Instead of using git submodule and compile the library together with the core code, I'm using shared linking libraries.
All three json libraries are supported for flexibility and use conditional compilation based on user choice.

![JSON libraries link flow](/assets/images/writing-cgentest/json_lib_diagram.png){: width="25%"}

The order by no means signify anything.
It's just the order of the implementation done in this project.


## Putting it All Together

Now the cgentest is finished, let's take a look at the complete product.
Given a C file with name `example.c`
```c
int simple(bool is_active) {...}
```

Run through cgentest, it will resulting in.
```c
#include "example.c"
#include <stdlib.h>
#include <stdio.h>


void simple_test(void) {
    struct {
        char name[100];
        struct {
            bool is_active;
        } parameters;
        int expected;
    } tests[] = {

    };

    size_t length = sizeof(tests) / sizeof(tests[0]);
    for (size_t idx = 0; idx < length; idx++) {
        printf("Running simple_test: %s\n", tests[idx].name);
        if (tests[idx].expected == simple(tests[idx].parameters.is_active)) {
            printf("\t=== Success ===\n");
        } else {
            printf("\t=== Failure ===\n");
        }
    }
}
```

From there, we can add test case entry in `tests` array. Pretty neat right?
As you can see, cgentest only generate boilerplate.
I've stated it before, but let me reiterate. 
The table-driven tests is a methodoloy, rather than a tool.
It resulting in much more flexibility in testing.

By default, cgentest is using a simple comparison.
But nothing stopping the user to use more sophisticated comparison library like `assert.h`.
The user can even use any unit testing libraries in tandem with cgentest.
In fact, cgentest project utilize `Autotest` for its unit testing library, in collaboration with boilerplate generated by cgentest itself.


# Conclusion

Now the project is finished, I'm very satisfied the result.
In all honesty, the project is far from perfect. 
Now I look back at it again, I can think of several improvements to the project.
- Support for multiple files generation.
- Support for minimal dependencies, it's possible only to depend on `ctags` and `libreadtags`.

While working on cgentest, I've learned so many things.
- How to use autotools suite.
- Utilize shared libraries.
- Debugging c program using gdb.
- Checking memleak using valgrind.

For the next project will try to make something simple and short.
Either make a simple library to "complete" my journey of learning `autotools`.
Or make editor extension for cgentest, especially for emacs.

# Recommended Resources

Below are resources that are very useful through the writing of cgentest. 
I'm not endorsed by any of them.
I just like their content and want to share it with my reader.
- "Autotools, 2nd Edition: A Practitioner's Guide to GNU Autoconf, Automake, and Libtool" book by John Calcote
- autotools gnu web documentation
  - [Automake](https://www.gnu.org/software/automake/)
  - [Autoconf](https://www.gnu.org/software/autoconf/)
  - [Autotest](https://www.gnu.org/software/autoconf/manual/autoconf-2.67/html_node/Using-Autotest.html)
- "How to Debug C Program using gdb in 6 Simple Steps" [blog](https://u.osu.edu/cstutorials/2018/09/28/how-to-debug-c-program-using-gdb-in-6-simple-steps/) by Muhammed Emin Ozturk
