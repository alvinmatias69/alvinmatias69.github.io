---
layout: post
author: mat
title: "Writing cgentest: Table Test Generator for C"
excerpt_separator: <!--more-->
---

Usually, I use the test-driven development (TDD) approach when I'm writing a software project.
In Golang (the language that I used to write daily) there's this neat library that helps me to do that, [Gotests](https://github.com/cweill/gotests).
Gotests is a simple tool that generates a table-driven test boilerplate, it helps me on writing tests on my past project.

Unfortunately, I can't find such a tool in C.
While there are plenty of unit testing libraries, I'm unable to find the one that simply generates a Table-driven testing boilerplate.
So, I decided to write one myself.
<!--more-->

What I thought to be a simple project that can be done in some weeks, turns into a long journey.
It's not that the project is a tall mountain, rather it's a dense forest.
There are so many problems that I wasn't even aware of.
Safe to say, I had spent maybe 80% of my time in this project learning things.
And I don't regret it, not even a bit!


# Introduction

Writing tests is considered a chore for most programmers, it's not that uncommon for them to skip out on writing tests.
But, regardless of that, most of them will agree that test is important.
It's the quickest and most convenient way to do a sanity check on a software project.

There are multiple ways and methods to write tests.
One of them is Table-driven / Data-driven testing.
Table-driven testing is a method to write test specifications (input, output, condition, etc.) in "table" entries to later be tested iteratively.
To quote [Golang Wiki](https://github.com/golang/go/wiki/TableDrivenTests) on Table-driven tests, "Table driven testing is not a tool, package or anything else, it's just a way and perspective to write cleaner tests.".

I like Table-driven testing.
It allows me to write simple but detailed tests, while also serving as code documentation.
The main drawback is it's mainly tailored for unit testing, so it's not easy if you want to use it for anything else (e.g. integration test).

I'm unable to find any similar tools to generate the boilerplate for C.
As I've mentioned in my previous post, I'm currently learning to write C projects.
And I think that the existence of this tool will help me greatly on that.
So I am writing this small tool to solve that problem, [cgentest](https://github.com/alvinmatias69/cgentest).


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
`JavaScript Object Notation` (`JSON`), is a file and data interchange text format consisting of key-value pairs and arrays. 
It's mainly used in web applications, but its usage is really broad and applicable to any software project.

## Autotools

The [GNU Autotools](https://www.gnu.org/software/automake/faq/autotools-faq.html) (also known as GNU Build System), is a suite of programming tools designed to assist in making portable source code packages in Unix-like systems.


# Writing cgentest

A quick and simple explanation of the cgentest process can be described as follows.
1. Read a C file and extract the function metadata (function name, parameters, return type)
2. Map the function data into a boilerplate table-driven test of that file, Preferably into a customizable template.
3. Output the generated boilerplate.

![Simple flowchart of cgentest](/assets/images/writing-cgentest/simple_cgentest_flow.png){: width="100%"}

While it looks simple, each of the steps has its difficulties that have to be solved.


## Extracting C Functions Metadata

At first, I tried to use a finite state machine (FSM) to solve this.
Initially, I plan to tokenize the source file.
Those tokens then will be passed to the FSM to be parsed and relevant data is extracted.

I quickly realised the flaw of this approach though.
- It's prone to error. 
  Need to make a very detailed FSM to generate accurate data.
- The scope is too big. 
  It's more like writing a parser at this point. 
  Which is not the main objective of this project.

Then, I found `universal ctags`, which are perfect for this project.
- Its usage fits perfectly for the project requirement.
- Has a c library to read its result ([libreadtags](https://github.com/universal-ctags/libreadtags)), no need to parse too much.

But, it's not that this approach is without a weakness.
- The project now depends on a third-party library.
- ctags binary is required and will be executed by the project.
- The parsed result from `libreadtags` is not as clean, still needs to parse a bit.

After weighing my options, I decided to go with `universal ctags`.
It's more aligned with my goals of learning to write C, without delving too deep into technicalities.

![Sequence diagram relations between cgentest, ctags, and libreadtags](/assets/images/writing-cgentest/cgentest_ctags_sequence_diagram.png){: width="100%"}


## Writing the Generated Boilerplate

Outputing the result can be done simply using string formatting and some conditionals.
However, this approach has several drawbacks.
- It's hard to make any changes later.
- The code will be cluttered and hard to read.
- More importantly, it's hard to give the option of a custom template for the user.

Considering my requirements, I decided to use the `Mustache` template system.
More specifically, I'm using [mustach](https://gitlab.com/jobol/mustach) a C library for the `mustache` template.
- Simple to use
- Still maintained
- Support several JSON libraries
  - [cJSON](https://github.com/DaveGamble/cJSON)
  - [jansson](https://github.com/akheron/jansson)
  - [json-c](https://github.com/json-c/json-c)

To elaborate on my last point, what does `JSON` get to do with `mustache`?
Well, it's plenty. You see, `mustache` originally is a web template and usually paired with `JSON` as its data provider.
`Mustach` itself relies on JSON libraries to aggregate the data into any `mustache` template.

To utilize `mustach` in a project, we can work in this step.
1. Map the data into a JSON representation using one of the supported libraries.
2. Fed the data into mustach with its respective method (e.g. if using jansson, then we will be using `mustach_jansson_file`).

We can simply support one library and be done with it.
But, I decided to support all three libraries.


## Packaging for Release

I do have several experiences in releasing software. 
But, usually, I did that through the language package manager (`npm js`, `cargo rust`, `Golang mod`).

While C doesn't have a universal package manager, several build systems can accommodate this.
- `cmake`
- `meson`
- `GNU autotools`
- etc

So, I then decided to use Autotools, because:
- No dependency is needed (except dependency for the cgentest itself).
- I have used projects that utilize autotools many times in the past. Yet, never know how to use autotools in a project.

The problem is, that autotools isn't as easy to use as other modern build system.
There are not many resources to learn it on the internet too.
Most of it only explains the very simple usage or some pretty specific problem.
Although, in hindsight, most of it answered my project use case. 
But, at the time I still haven't grasped the concept of autotools yet.

Fortunately, I found a great book that explains things in detail.
The book's name is `Autotools` by John Calcote.
It's a pretty good book, I spent several months reading it until I understood the basic concept of it.
I'm not claiming that I have mastered autotools, but it's good enough to implement it in my project.

You know, people said that the best way to learn something is to learn by doing, so I did just that.
I decide to fully refactor the cgentest project to utilize `Autotools`.
Instead of using the git submodule and compiling the library together with the core code, I'm using shared linking libraries.
All three JSON libraries are supported for flexibility and use conditional compilation based on user choice.

![JSON libraries link flow](/assets/images/writing-cgentest/json_lib_diagram.png){: width="25%"}

The order by no means signifies anything.
It's just the order of the implementation done in this project.


## Putting it All Together

Now that the cgentest is finished, let's take a look at the complete product.
Given a C file with name `example.c`
```c
int simple(bool is_active) {...}
```

Run through cgentest, it will produce this result.
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

From there, we can add test case entres in the `tests` array. Pretty neat right?
As you can see, cgentest only generates a boilerplate.
I've stated it before, but let me reiterate. 
The table-driven test is a methodology, rather than a tool.
It helps to write flexible testing.

By default, cgentest uses a simple comparison.
But nothing stops a user from using a more sophisticated assertion library like `assert.h`.
It can even be used with any unit testing libraries.
Cgentest project utilizes `Autotest` for its unit testing library while using boilerplate generated by cgentest.
Here, [check it out yourself](https://github.com/alvinmatias69/cgentest/blob/master/tests/suites/util_test.c).


# Conclusion

Now that the cgentest is finished, I'm very satisfied with the result.
In all honesty, the project is far from perfect. 
Now I look back at it again, I can think of several improvements that can be made.
- Support for multiple file generation.
- Support for minimal dependencies, it's possible only to depend on `ctags` and `libreadtags`.

While working on cgentest, I've learned so many things.
- How to use autotools suite.
- Utilize shared libraries.
- Debugging a C program using gdb.
- Checking memory leak using valgrind.

For the next project will try to make something simple and short.
Either make a simple library to "complete" my journey of learning `Autotools`.
Or make an editor extension for cgentest, especially for emacs.

# Recommended Resources

Below are resources that are very useful through the writing of cgentest. 
- "Autotools, 2nd Edition: A Practitioner's Guide to GNU Autoconf, Automake, and Libtool" book by John Calcote
- autotools gnu web documentation
  - [Automake](https://www.gnu.org/software/automake/)
  - [Autoconf](https://www.gnu.org/software/autoconf/)
  - [Autotest](https://www.gnu.org/software/autoconf/manual/autoconf-2.67/html_node/Using-Autotest.html)
- "How to Debug C Program using gdb in 6 Simple Steps" [blog](https://u.osu.edu/cstutorials/2018/09/28/how-to-debug-c-program-using-gdb-in-6-simple-steps/) by Muhammed Emin Ozturk
