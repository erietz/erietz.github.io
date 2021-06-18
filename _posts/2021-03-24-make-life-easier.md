---
title: Make life easier
categories:
  - make
---

I have known about [GNU Make](https://www.gnu.org/software/make/) for quite
some time but never got around to using it. I wish I would have started
`make`ing my life easier much earlier...

## Basic Usage

Lets say you have a complicated directory that looks like this
```
.
└── main.c

0 directories, 1 file
```
and you want to compile your `main.c` file into an executable file, `main`.
You could go to the command line and type `gcc main.c -o main`, but that would
be doing things the hard way. To make life easier, we create a `makefile`.
Now the directory looks like this
```
.
├── main.c
└── makefile

0 directories, 2 files
```
and the makefile contains the following contents
```makefile
main: main.c
	gcc main.c -o main
```

To compile `main.c` into `main`, all one has to do now is to type `make` in the
directory where the `makefile` is. It may appear that this is more work than
compiling the file by hand on the command line, but using the `makefile` has
some advantages. First, now one only needs to type `make` to compile the
program. Second the **target** `main` will only be built if the **dependency**
`main.c` has changed. If `main.c` has changed, then the command `gcc main.c -o
main` will be run producing `main`.

The above code can be shortened using [Automatic
Varibles](https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html)
and have the exact same functionality.
```makefile
main: main.c
	gcc $^ -o $@
```

Here `$^` represents all of the prerequisites (i.e. `main.c`) and `$@`
represents the target, `main`.

In the next section, I will go over a more complicated example.

## Pandoc Example

Now, assume we have a directory full of markdown files and we want to convert
all of them to html files in a separate directory. Lets `make` it happen. Gone
are the days of shell scripts. The directory of markdown files looks like this:
```
.
├── css
│   └── pandoc.css
├── html_version
├── makefile
└── src
    ├── index.md
    ├── notes
    │   ├── 2021-03-01.md
    │   ├── 2021-03-02.md
    │   ├── 2021-03-03.md
    │   ├── 2021-03-04.md
    │   ├── 2021-03-05.md
    │   ├── 2021-03-06.md
    │   ├── 2021-03-07.md
    │   ├── 2021-03-08.md
    │   ├── 2021-03-09.md
    │   ├── 2021-03-10.md
    │   ├── 2021-03-11.md
    │   ├── 2021-03-12.md
    │   ├── 2021-03-13.md
    │   ├── 2021-03-14.md
    │   ├── 2021-03-15.md
    │   ├── 2021-03-16.md
    │   ├── 2021-03-17.md
    │   ├── 2021-03-18.md
    │   ├── 2021-03-19.md
    │   ├── 2021-03-20.md
    │   ├── 2021-03-21.md
    │   ├── 2021-03-22.md
    │   ├── 2021-03-23.md
    │   └── 2021-03-24.md
    └── recipes
        ├── beans.md
        ├── dip.md
        ├── nachos.md
        └── salsa.md

5 directories, 31 files
```
The folder `html_version` is currently empty and we want it to contain a replica
of every `.md` file in `src` except with a `.html` extension. Luckily, we have
written a nice `makefile` at the root of out project folder that contains the 
following.

```makefile
MD_FILES := $(shell find src -type f -name '*.md')
MD_DIRS := $(shell find src -type d)
HTML_DIRS := $(addprefix html_version/,$(MD_DIRS))
HTML_FILES := $(MD_FILES:.md=.html)
HTML_FILES := $(addprefix html_version/,$(HTML_FILES))

PD_FLAGS = -s --toc -c /css/pandoc.css --metadata title="$(notdir $@)"

all: html_dirs $(HTML_FILES)
	sed -i.bak 's/\(href=".*\).md">/\1.html">/' html_version/src/index.html
	rm html_version/src/index.html.bak

html_version/%.html: %.md
	pandoc $(PD_FLAGS) $^ -o $@

html_dirs: $(MD_DIRS)
	@mkdir -p $(HTML_DIRS)

clean:
	rm -rf ./html_version
	mkdir -p html_version/src
	cp -r ./css html_version/src/

serve:
	@echo Serving at http://127.0.0.1:8000/
	python3 -m http.server --directory ./html_version/src
```

This makefile does it all and an explanation of this makefile is soon to
come...

The directory now looks like this

```
.
├── css
│   └── pandoc.css
├── html_version
│   └── src
│       ├── index.html
│       ├── notes
│       │   ├── 2021-03-01.html
│       │   ├── 2021-03-02.html
│       │   ├── 2021-03-03.html
│       │   ├── 2021-03-04.html
│       │   ├── 2021-03-05.html
│       │   ├── 2021-03-06.html
│       │   ├── 2021-03-07.html
│       │   ├── 2021-03-08.html
│       │   ├── 2021-03-09.html
│       │   ├── 2021-03-10.html
│       │   ├── 2021-03-11.html
│       │   ├── 2021-03-12.html
│       │   ├── 2021-03-13.html
│       │   ├── 2021-03-14.html
│       │   ├── 2021-03-15.html
│       │   ├── 2021-03-16.html
│       │   ├── 2021-03-17.html
│       │   ├── 2021-03-18.html
│       │   ├── 2021-03-19.html
│       │   ├── 2021-03-20.html
│       │   ├── 2021-03-21.html
│       │   ├── 2021-03-22.html
│       │   ├── 2021-03-23.html
│       │   └── 2021-03-24.html
│       └── recipes
│           ├── beans.html
│           ├── dip.html
│           ├── nachos.html
│           └── salsa.html
├── makefile
└── src
    ├── index.md
    ├── notes
    │   ├── 2021-03-01.md
    │   ├── 2021-03-02.md
    │   ├── 2021-03-03.md
    │   ├── 2021-03-04.md
    │   ├── 2021-03-05.md
    │   ├── 2021-03-06.md
    │   ├── 2021-03-07.md
    │   ├── 2021-03-08.md
    │   ├── 2021-03-09.md
    │   ├── 2021-03-10.md
    │   ├── 2021-03-11.md
    │   ├── 2021-03-12.md
    │   ├── 2021-03-13.md
    │   ├── 2021-03-14.md
    │   ├── 2021-03-15.md
    │   ├── 2021-03-16.md
    │   ├── 2021-03-17.md
    │   ├── 2021-03-18.md
    │   ├── 2021-03-19.md
    │   ├── 2021-03-20.md
    │   ├── 2021-03-21.md
    │   ├── 2021-03-22.md
    │   ├── 2021-03-23.md
    │   └── 2021-03-24.md
    └── recipes
        ├── beans.md
        ├── dip.md
        ├── nachos.md
        └── salsa.md

8 directories, 60 files
```

## More Complicated Makefile

Of course, `make` can do a ton of things... [Linux
Makefile](https://github.com/torvalds/linux/blob/master/Makefile)
