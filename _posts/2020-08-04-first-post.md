---
title: How its `maked`
categories:
  - web
  - make
---

## About this site

This is version 2.0 of my personal website. I made version 1.0 using 
[Jekyll](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/about-github-pages-and-jekyll),
a static site generator, and a fork of 
[Minimal Mistakes](https://github.com/mmistakes/minimal-mistakes),
a Jekyll theme. The idea of this approach is that it is "easy" to get a good
looking site up and running with little configuration (a single `yaml` file),
and you can write blog posts in markdown rather than html. My experience with
Jekyll and the Minimal Mistakes theme was that it actually made things more
complicated, it was not easily customizable, and it was not made by me.

For example, trying to get Mathjax to work on the Jekyll site was a pain and
required Jekyll's custom liquid markup language. I had to create a folder
`_includes/head` with a file `custom.html` with the following content.

``` html
{% if page.mathjax %}
<script type="text/javascript" async
  src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-MML-AM_CHTML">
</script>
{% endif %}

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({
    extensions: ["tex2jax.js"],
    jax: ["input/TeX", "output/HTML-CSS"],
    tex2jax: {
      inlineMath: [ ['$','$'], ["\\(","\\)"] ],
      displayMath: [ ['$$','$$'], ["\\[","\\]"] ],
      processEscapes: true
    },
    "HTML-CSS": { availableFonts: ["TeX"] }
  });
</script> 
```

and add the `yaml` front matter `mathjax: true` to each of the markdown files
to get $\LaTeX$ to work. I also found the `gem` dependencies to be difficult to
manage/install and the site could take 20 minutes to update after being pushed
to GitHub.

Version 2.0 is made without the bloat using `make`, `pandoc`, and some `css`.

## How this site is made

I am still able to write blog posts and pages using markdown by the help of
a short makefile.

```makefile
SRC_DIRS := _posts _projects _pages
MD_FILES := $(shell find $(SRC_DIRS) -type f -name '*.md')
HTML_FILES :=  $(patsubst _%.md,%.html,$(MD_FILES))

PD_FLAGS = --standalone --toc --mathjax \
					 -c /assets/css/master.css \
					 -c "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css" \
					 --include-before-body ./assets/navigation.html \
					 --include-after-body ./assets/footer.html \
					 --highlight-style breezedark

all: $(HTML_FILES) index makefile

posts/%.html: _posts/%.md
	pandoc $(PD_FLAGS) $^ -o $@

projects/%.html: _projects/%.md
	pandoc $(PD_FLAGS) $^ -o $@

pages/%.html: _pages/%.md
	pandoc $(PD_FLAGS) $^ -o $@

index:
	python ./assets/python/generate_posts_index.py
	pandoc $(PD_FLAGS) _posts/index.md -o posts/index.html
	sed -i.bak 's/\(href=".*\).md">/\1.html">/' ./posts/index.html
	rm ./posts/index.html.bak

clean:
	rm $(HTML_FILES)

serve:
	echo Serving the site at http://127.0.0.1:8000/
	python3 -m http.server
```

This makefile will convert any markdown file in `_posts`, `_projects`, or
`_pages` to a corresponding html file `posts`, `projects`, or `pages`.

The basic directory structure of the site then look like this:

```sh
.
├── index.html
├── makefile
├── _pages
│   └── command_line.md
├── pages
│   ├── about.html
│   ├── command_line.html
│   └── links.html
├── _posts
│   ├── 2020-08-04-first-post.md
│   ├── 2021-05-26-wsl.md
│   └── index.md
├── posts
│   ├── 2020-08-04-first-post.html
│   ├── 2021-05-26-wsl.html
│   ├── index.html
├── _projects
│   ├── vim-terminator.md
└── projects
    ├── index.html
    ├── vim-terminator.html
```

The cool thing about this approach is that the `.html` files are generated only
when the corresponding `.md` file has changed. This makes it incredibly fast to
build and preview the website offline. All I have to do is type `make`. This
directory layout also allows the `.html` and `.md` files to link to other files
in the project without issues from the conversion process.

The `posts/index.html` file is automatically generated from a simple python
script that I whipped together. It even allows for tagging of posts using
`yaml` front matter in the same way the complicated Jekyll site did. The code
to produce the index file is below:

```python
#!/usr/bin/env python3

from pathlib import Path
import yaml

FILES = sorted(Path('./_posts/').glob('*.md'), reverse=True)
FILES = [f for f in FILES if 'index.md' not in f.name]
INDEX = Path('./_posts/index.md')

def parse_frontmatter(file):
    with open(file, 'r') as f:
        line = next(f)
        if line != '---\n':
            return
        frontmatter = ''
        line = next(f)
        while line != '---\n':
            frontmatter += line
            line = next(f)
        return yaml.safe_load(frontmatter)

with open(INDEX, 'w') as f:
    f.write('---\n')
    f.write('title: Posts\n')
    f.write('---\n')
    f.write('\n')

    f.write('|     |       |      |      |\n')
    f.write('|:--- | :---- | :--- | :--- |\n')
    for file in FILES:
        frontmatter = parse_frontmatter(file)
        title = frontmatter.get('title')
        categories = frontmatter.get('categories')
        if categories is None:
            categories = ''
        else:
            categories = ', '.join(categories)

        date = file.name[:10]
        f.write(f'| Ɣ | {date} | [{title}]({str(file.name)}) | *{categories}* | \n')
```
