---
title: Linux Configuration
---

One of things that comes with using a minimalist window manager, such as [i3],
is having to maintain additional configuration files that a desktop environment
would normally take care of. Most of my configuration files are kept under
[version control], but I have not found a clean way to maintain some of the X11
config files across multiple machines. For the time being, it seems that the
best solution is to simply take notes of how I have configured things.

## Screen Resolution

The screen resolution can be set using the `xrandr` command. For a complicated
multi monitor setup, it can be a lot easier to use a gui tool such as `arandr`
which helps to write `xrandr` scripts.

## High DPI

On both my laptop and desktop setups, I have higher than 1080p resolution. This
usually means on Linux that the scaling is going to be off and everything will
be way too tiny to read. To fix this issue, I modified the dpi setting in the
`~/.Xresources` file. For my laptop, which has a resolution of `2560x1600`, I
doubled the scaling by bumping up `Xft.dpi` from `96` to `192`.

```xorg
# Xft.dpi:       96
# the number 192 is an integer multiple of 96
Xft.dpi:       192 
```

Adjusting the dpi value alone fixes most of the resolution problems, but
certain icons and font sizes do not always scale properly for all programs.
Most of the configuration in the following sections come from the [archwiki],
but some comes from various other places.

### GTK Theme/Icons

Since there are config files scattered around for both GTK2 and GTK3 programs,
it can be a pain to manage. The easiest thing here seems to just use a GUI tool
such as `lxappearance`. `lxappearance` will overwrite the files `~/.gtkrc-2.0`
and `/etc/gtk-2.0/gtkrc` for GTK2 settings and `~/.config/gtk-3.0/settings.ini`
and `/etc/gtk-3.0/settings.ini` for GTK3 settings.

### QT5

Increasing the icon size for a few QT programs was accomplished using the qt5
gui configuration tool which is launched using the `qt5ct` command. For the
configuration tool to work properly, an environmental variable had to be set:

```zsh
export QT_QPA_PLATFORMTHEME="qt5ct"
```


### Tweaks that GUI programs cannot set

- The toolbar icons in programs such as `pcmanfm` were not fixable using
  `lxappearance` and had to be manually set. In order to make these settings
  last and not be overwritten by the GUI tool, the following was saved into
  `~/.gtkrc-2.0.mine`

```sh
gtk-icon-sizes = "panel-menu=48,48:panel=48,48:gtk-menu=48,48\
:gtk-large-toolbar=48,48:gtk-small-toolbar=48,48:gtk-button=48,48"
```

- To automatically adjust qt icons depending on the dpi:

```zsh
export QT_AUTO_SCREEN_SCALE_FACTOR=1
```

## Key remaps

- To set the (useless) caps lock key as a (useful) control key, add the following
to `~/.Xmodmap`.

```sh
clear lock
clear control
keycode 66 = Control_L
add control = Control_L Control_R
```

Note: Every time you plug in an external keyboard you will have to reload this
file using `xmodmap ~/.Xmodmap`. This can be set to a keybinding using i3.

```sh
bindsym $mod+Shift+x exec --no-startup-id "xmodmap $HOME/.Xmodmap"
```

*TODO: explore [xkb] as an alternative to Xresources*


[i3]: https://i3wm.org/
[version control]: https://github.com/erietz/.ewr
[archwiki]: https://wiki.archlinux.org/title/HiDPI
[xkb]: https://wiki.archlinux.org/title/X_keyboard_extension
