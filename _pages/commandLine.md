---
title: Command line Cheat Sheet
---

## Linux System management

### Fix clock

```sh
timedatectl set-ntp true
```

### Bluetooth

```sh
bluetoothctl
agent on
default-agent
power on
scan on
pair 00:12:34:56:78:90
trust 00:12:34:56:78:90   # only required if BT device has no pin
connect 00:12:34:56:78:90
```

## Pacman

### Get fastest mirrors (Manjaro only)

```sh
sudo pacman-mirrors --fasttrack && sudo pacman -Syyu
```

> Tip: Every run of pacman-mirrors requires you to syncronize your database and
update your system. 

### Update all packages on system

```sh
sudo pacman -Syyu
```

### List installed packages

To list all packages and versions
```sh
pacman -Q
```

To list packages explicitly installed 
```sh
pacman -Qe
```

## SSH Port Forwarding

To access what is being served on port 8384 from the remote computer on your
local computer at port 9876
```sh
ssh -L 9876:localhost:8384 user@ipaddr
```
this is useful for example if you already have something running on your local
machine on port 8384 and want to see the remotes port 8384

### Jupyter lab

To access jupyter lab on a raspberry pi from an ipad browser...
```sh
ssh -L localhost:9876:localhost:9876 user@ipaddr
```
then from `user@ipaddr` issue a 
```
jupyter lab --no-browser --port=9876
```
to start the server. A good alias is 
`alias jlremote='jupyter lab --no-browser --port=9876'

