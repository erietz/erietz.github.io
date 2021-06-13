---
title: Vim Terminator
mathjax: true
---

There are vim plugins for nearly everything, but when it comes to actually
running your code in vim the options are rather limited. Hence, I created
[vim-terminator](https://github.com/erietz/vim-terminator), an asynchronous
code running plugin for vim (version 8 and above) and neovim.

![Async code running](https://raw.githubusercontent.com/erietz/vim-terminator/main/media/resizing.gif)

# Life without the terminator 

Before creating this plugin, I ran my code in several ways, each of which had
its shortcomings.

## Option 1: The vim command line

Commands can be executed in a shell by using command mode in vim and prefixing
with an exclamation mark. For example `:!echo "hello"` will run the command
`echo "hello"` and the result will appear in a temporary window (which vanishes
after pressing any key). 

I used this for a while and set up some key bindings to run my file using
things such as `nnoremap <leader>r :!python3 %<CR>` to run the current file
using python. This is the worst solution. You have to wait for the entire
process to finish before being able to see your editor again, and the second
you press a key you can no longer view the output.

## Option 2: Putting vim in the background

By pressing `ctrl-z`, the vim process is put in the background. Then you can
run your code in the terminal vim is running in. To get vim back you can just
type the command `fg`. This may or may not be an improvement from the vim
command line.

## Option 3: Tmux

Tmux is pretty amazing. For a while I had vim in a tmux split and a terminal in
the other pane. Then you can switch between vim and the terminal to run the
code. My complaint with this solution is that you have one more set of key
bindings to keep track of, and tmux can add a layer of complexity that does not
need to exist. I ran into issues with python virtual environments not starting
correctly and terminal colors not being properly displayed.

## Option 4: Built in vim terminal 

In vim8 or neovim there is a built in terminal! The terminal emulator inside of
vim is pretty good as compared to my experience with emacs... My one complaint
with the built-in vim terminal is having to navigate to and from it. To get out
of insert mode inside the terminal, you must press the key combination
`<c-\><c-n>`. Then of course you can navigate back to your current buffer from
normal mode using shortcuts such as `<c-^>`, but this becomes clumsy.

Vim-terminator makes the terminal experience inside of vim more pleasant by
allowing you to send text to the terminal rather than having to manually type
it!

## Option 5: Dispatch

I was a big fan of Tim Pope's vim-dispatch plugin, and I still supplement my
vim-terminator experience with dispatch. The two features I like about dispatch
are that it is asynchronous and it puts errors into the quickfix window. 

> I first found the quickfix window when using the
> [vimtex](https://github.com/lervag/vimtex) plugin for editing $\LaTeX$. It puts
> the errors and warnings from the compiler log into a small (quickfix) window
> which allows you to conveniently jump to them regardless of the file they are
> in.

In short, vim-dispatch basically makes an asynchronous version of the built in
`:make` command. The `:make` command along with `:compiler`, `:makeprg`, and
`errorformat` may take a decade to understand entirely. The key takeaway is
that you can usually just set `:compiler` to one of the compilers provided by
vim and the `:makeprg` to the command you want to run and everything works
nicely. The other nice feature is that `:Make` allows you to use a Makefile if
your build is more complicated than just compiling your current file.

Vim-dispatch is great when you do not want to wait for a process to finish and
you only want to see the output if there are errors. This works well for
compiling programs and for runnings tests. Often times when writing code, I
want to quickly run my current file (asynchronously) and **see the output
immediately**. Trying to accomplish this with dispatch for a language like
python is impossible for all practical purposes. For instance, to keep the
quickfix window open after running a python program with dispatch, one needs to
make the file executable and run it with a command like `:Dispatch ./%` such
that there is not an `errorformat` hiding the quickfix window at the end of the
job. The quickfix window was not designed to be used in this way.

# Life with the terminator

For me, vim-terminator fixes all of these problems. It runs asynchronously, it
puts the output of your code in an output buffer that always opens, it
automatically sets the command to run for you based on file type, and it puts
the errors in the quickfix window. Plus it has many additional features for
working with the vim terminal, which is where the plugin gets its name.

One final interesting observation is that vim-terminator can actually run code
faster than in the terminal or using vim-dispatch given that there is a
non-trivial amount of STDOUT. This has to do with scrolling. As a simple test,
the following code was run in the output buffer, the vim terminal, and in the
quickfix window using dispatch.

```python
#!/usr/bin/env python3

for i in range(1000000):
    print('test', i)
```


## Output buffer speed test

The command `<leader> rf` was used (which runs `python test.py`) and
resulted in:

`[Done] in 8.222829 seconds`

## Vim terminal speed test

The command `time ./test.py` was used and resulted in:

`./test.py  4.64s user 3.01s system 55% cpu 13.835 total`

## Quickfix speed test

The command `:Dispatch time ./test.py` was used and resulted in:

`./test.py  4.41s user 3.07s system 53% cpu 13.888 total`

## Summary

| Location      | Run Time (s) |
| ---           | ---          |
| Output Buffer | 8.2          |
| Terminal      | 13.8         |
| Quickfix      | 13.9         |


