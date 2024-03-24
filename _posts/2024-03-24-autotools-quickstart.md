---
layout: post
author: mat
title: Autotools Quickstart
excerpt_separator: <!--more-->
---

On my last post I talked about writing a test generator utilising autotools suite for its build system and packaging.
Since then, I've been writing some software using autotools.
But, everytime I need to reread the reference book or take a peek at my last project before I can start writing.
So, I figure that writing a quickstart of using autotools will be helpful for future me!

<!--more-->

# Requirements

I'll assume that we're using a linux distribution on our machine (as I'm not sure whether the autotools suite support other os than linux).
Autotools suite (and c compiler) should be already included in your linux distro.
We're using `Autoconf 2.71` and `Automake 1.16.1` in this post.
While older or newer version might also works, you should keep this in mind suppose there's a differences.
You can check autotools version using these commands.

```sh
$ autoconf --version
$ automake --version
```

Supposed for some reasons it's not installed on your system, you can head to gnu.org website to download both [autoconf](https://www.gnu.org/software/autoconf/) and [automake](https://www.gnu.org/software/automake/).

# Initialising The Project

Let's start by creating the project structure

```sh
# quickstart is our project name
$ mkdir quickstart
$ cd quickstart
$ mkdir src
$ touch src/main.c
```

The code will resides in `src` directory while autotools related will be placed in the root project directory.
We can of course costumize this and this is not a hard requirement.
But, let's start with the default configuration for now.

```c
// src/main.c

#include <stdio.h>

int main(void) {
    printf("hello world\n");
    return 0;
}
```

# Autotools bootstrap

In autotools projects, there's a filed called `configure.ac`.
This file is the main configuration of the project.
The project dependencies, tools, project information, etc are configured through this file.

Fortunately, autotools comes with tools to help us with that.
Go to the project root directory and execute this.

```sh
$ autoscan
```

Notice that you now have 2 new files in your projects, `autoscan.log` and `configure.scan`.
```
.
├── autoscan.log
├── configure.scan
└── src
    └── main.c
```

Let's take a look at the `configure.scan` file.

```sh
// configure.scan
#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.71])
AC_INIT([FULL-PACKAGE-NAME], [VERSION], [BUG-REPORT-ADDRESS])
AC_CONFIG_SRCDIR([src/main.c])
AC_CONFIG_HEADERS([config.h])

# Checks for programs.
AC_PROG_CC

# Checks for libraries.

# Checks for header files.

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.

AC_OUTPUT
```

The content of this file is auto generated based on the project structure it was run on.
To use it, let's modify its content a bit and rename the file.
```
...
AC_INIT([quickstart], [1.0.0], [report@email.com])
...
```

```sh
$ mv configure.scan configure.ac
```

# Define Automake files

Let's continue to automake files.
Those files will let us define how the project should be built.

```sh
// Makefile.am
SUBDIRS = src
```

```sh
// src/Makefile.am
bin_PROGRAMS = quickstart
quickstart_SOURCES = main.c
```

Here we define 2 automake files.
The one in the root project defines the project subdirectory to be discovered by autoconf later.
While the one in the `src` directory defines the program names and its sources.
Our project structures will now look like this.
```
.
├── autoscan.log
├── configure.ac
├── Makefile.am
└── src
    ├── main.c
    └── Makefile.am
```

Let's adjust our `configure.ac` file so the automake files will be processed by autotools later.
```
// configure.ac
...
AC_CONFIG_HEADERS([config.h])
AM_INIT_AUTOMAKE([foreign])
...
AC_CONFIG_FILES([Makefile
                 src/Makefile])
AC_OUTPUT
```

We're initialising automake using `foreign` parameter.
This means that this project isn't following conventional automake structure and we can skip adding required files (`AUTHORS`, `NEWS`, `ChangeLog`, and `README`).
In a real project, we should add those files for user informations.
For now, we're ommiting those for abbreviation.

Notices that we're listing config files based on the automake files that we created earlier.
Supposed later we want to add more subdirectory to the project, we need to also add it to the config file listing.

Last but not the least, we need to add some adjustment to our source codes.
```c
// src/main.c
#include "config.h"

#include <stdio.h>
...
```

`config.h` is a generated header file that contains information regarding compiler information, library availability, etc.
Whlie it's useless right now, it's always a good practice to add this to the source code anyway.

# Executing Autotools

Now that everything's are ready, we can start executing the autotools.
```sh
$ autoreconf -i
```

Command above will execute required commands to process the project, so we don't need to manually execute them one by one.
The `-i` parameter will automatically create required missing files.

We can then compile the project.
```sh
$ ./configure
$ make
```

The compiled program can then be executed.
```sh
$ ./src/quickstart
# hello world
```

You can install it to your path.
```sh
$ make install # might required root user
```

Or compile it into a distributed package.
```sh
$ make dist
# quickstart-1.0.0.tar.gz
```

# Adding dependencies

Usually while working on a big project, often times we need to use libraries to support the main program.
Let's see how do we add a library to our project.

Let's add [libvslogger](https://github.com/alvinmatias69/libvslogger) (leveled logger library) to our project.
```sh
// configure.ac
...
# Checks for libraries.
AC_SEARCH_LIBS([vslogger_init], [vslogger])

# Checks for header files.
AC_CHECK_HEADERS([libvslogger.h])
...
```

The `AC_CHECK_HEADERS` will check whether the given header is available in the current machine.
The `AC_SEARCH_LIBS` will check and link the given library if available in the current machine.

Now we need to adjust our code to utilise the library.
```c
// src/main.c
#include "config.h"

#include <libvslogger.h>

int main(void) {
    struct vslogger_config config = {
        .level = VSLOGGER_INFO,
        .destination = stdout,
        .enable_date = true,
        .enable_prefix = true,
    };

    vslogger_init(&config);
    vslogger_info("hello info");
    vslogger_clear();
    return 0;
}
```

Because we modify the `configure.ac` file, we need to reconfigure the project first.
```sh
$ autoreconf -i
```

Then, compile the project like we did before.
```sh
$ ./configure
$ make
$ ./src/quickstart
# [INFO][2024-03-24 13:32:55] hello info
```

> Note: If you encountered library not found error while executing the program, you might need to refresh your dynamic library link
> ```
$ ldconfig # might need root access
```
> or add your library path to `LD_LIBRARY_PATH` directly, e.g.
> ```
$ LD_LIBRARY_PATH=/usr/local/lib ./src/quickstart
```

## Optional Dependency

We can't control the user machine, how it's behave or what libraries does it has.
In our case, there's a possibility that our user doesn't have the library that we require.
We can then just simply require them to install it or provides an alternative supposed the library is missing.
Let's take a look at the latter approach.

Supposed our use doesn't have the `libvslogger` library, instead of giving error we will instead use a simple `printf`.
To do this, first we need to adjust our `configure.ac` file.
```sh
// configure.ac
...
AC_SEARCH_LIBS([vslogger_init], [vslogger], [AC_DEFINE([HAVE_VSLOGGER], [1], [Define if vslogger exist])])
```

The additional parameter will set `HAVE_VSLOGGER` variable supposed the library is available.
This variable will be defined in the `config.h` and can be used in our code.
Notice that this is the same file as the one that I mentioned earlier to be included in our source code.

Ideally, we should also check the header for the same and set the variable based on the availability of both the library and the header.
The implementation of that is left as an exercise for the reader.

Then, we can use this variable in our code using some conditional macros.
```c
// src/main.c
#include "config.h"

#ifdef HAVE_VSLOGGER
#include <libvslogger.h>
#else
#include <stdio.h> 
#endif

int main(void) {
#ifdef HAVE_VSLOGGER
    struct vslogger_config config = {
        .level = VSLOGGER_INFO,
        .destination = stdout,
        .enable_date = true,
        .enable_prefix = true,
    };

    vslogger_init(&config);
    vslogger_info("hello info");
    vslogger_clear();
#else
    printf("hello standard\n");
#endif

    return 0;
}
```

# Afterword

Thank you for reading! The full project is available in my github [repository](https://github.com/alvinmatias69/autotools-quickstart).
Again, I'll emphasize that this post is not mean as a complete or exhaustive guide for autotools.
Rather, it's a simple quickstart and usecase if you want to implement autotools in your project.

If you want to learn more about autotools, the gnu [website](https://www.gnu.org/software/automake/faq/autotools-faq.html) has an extensive documentation and tutorial on that topic.
Also, check out [`Autotools, 2nd Edition: A Practitioner's Guide to GNU Autoconf, Automake, and Libtool`](https://www.goodreads.com/book/show/41866149-autotools-2nd-edition) by John Calcote.
I'm not affiliated or sponsored to promote the book, the book just very good at explaining autotools and I totally recommend you to read it if you want to delve deeper.

Again, Thank you for reading this post! Let me know if there's any mistake or anything that I can improve.
See you in the next post!
