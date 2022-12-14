---
title: Home Server Upgrade (Part 3)
categories:
  - linux
  - backups
---

I wanted to feel confident that my system backups were working as I expected so
I decided to [roll my own
solution](https://github.com/erietz/incremental-backups) using rsync.

## Rsync

> rsync - a fast, versatile, remote (and local) file-copying tool

If you have never heard of `rsync`, it is basically `scp` but better and more
efficient. It uses a delta-transfer algorithm that is able to copy only the
parts of the files that have changed between the source and existing files.
This reduces the amount of data that is sent over a network.

## Shell script vs. Python

I saw some example incremental backup bash scripts online but to me they looked
way too messy. For my own peace of mind, I decided to write a wrapper over
`rsync` in python. This allowed me to write tests to verify that files were
being backed up correctly and abstract the logic from declaring which files
were being backed up.

### Config File

The config file is just a python script that imports the wrapper. I have mine
located at `/home/ethan/incremental-backups/run_backups.py` and it looks like
this.

```python
from rsync.config import Config
from rsync.backup import backup


LOG_FILE = "/home/ethan/.local/share/backup/rsync-backups.log"

# will need to be root to run rsync for a different user
HOME_DIRECTORIES = Config(
    source_dir="/home/",
    destination_dir="/media/backup_drive_linux/home_directory_backups/",
    exclude_file_patterns=[
        "/home/*/.cache/",          # no need for cached files
        "/home/*/.local/",          # nvim plugins and python packages are huge
        "/home/*/.npm/",            # what is the crap in here?
        "**/node_modules/",         # yikes
    ],
    log_file=LOG_FILE
)

LARGE_HARDDRIVE = Config(
    source_dir="/mnt/hd2",
    destination_dir="/media/backup_drive_linux/hd2_backups/",
    log_file=LOG_FILE
)

backup(HOME_DIRECTORIES)
backup(LARGE_HARDDRIVE)
```

Here I declare two `Config` objects, one for the home directories on the system
and one for a second hard drive on the machine. These two `Config`s are backed
up separately. Personally, I think this is much cleaner than a shell script
with all of the bizarre quoting rules.

## Cronjob

I set up a cron job to run the script every night at midnight. As I am backing
up multiple home directories where I am not necessarily the owner of the files,
the cronjob must be run as root. To edit the system crontab, use `sudo crontab
-e` versus just `crontab -e` for your user crontab.

```bash
MAILTO=ewrietz@gmail.com

# min   hour    day(mo)         month   day(we)         [user]  command
0 0 * * * /usr/bin/python3 /home/ethan/incremental-backups/run_backups.py
```

One problem that I ran into was the location of the log file that is defined in
the config file. Initially, I had used
`Path.home()/incremental-backups/run_backups.py` in the config, however as the
cronjob was being run as root, the log file was ending up at
`/root/.local/share/backup/rsync-backups.log`. As I wanted the log file to end
up in my user's home directory, simply using an absolute path in the config
file solved the issue.

## Log file

The cronjob has been running without at hitch since 06/08/2022. This is what
the tail of the log file looks like for the job that ran this morning.

```bash
INFO    12/13/2022 12:00:01 AM  Starting incremental backup from /media/backup_drive_linux/home_directory_backups/2022-12-12-00-00-02
INFO    12/13/2022 12:00:01 AM  Running ['rsync', '--delete', '--archive', '--acls', '--xattrs', '--verbose', '--link-dest=/media/backup_drive_linux/home_directory_backups/latest', '--exclude=/home/*/.cache/', '--exclude=/home/*/.local/', '--exclude=/home/*/.npm/', '--exclude=**/node_modules/', '/home', '/media/backup_drive_linux/home_directory_backups/2022-12-13-00-00-01']
INFO    12/13/2022 12:00:03 AM  Time elapsed 1.1290129330009222 seconds
INFO    12/13/2022 12:00:03 AM  Finished backup successfully
INFO    12/13/2022 12:00:03 AM  Symlink created from /media/backup_drive_linux/home_directory_backups/latest to /media/backup_drive_linux/home_directory_backups/2022-12-13-00-00-01
INFO    12/13/2022 12:00:03 AM  Starting incremental backup from /media/backup_drive_linux/hd2_backups/2022-12-12-00-00-03
INFO    12/13/2022 12:00:03 AM  Running ['rsync', '--delete', '--archive', '--acls', '--xattrs', '--verbose', '--link-dest=/media/backup_drive_linux/hd2_backups/latest', '/mnt/hd2', '/media/backup_drive_linux/hd2_backups/2022-12-13-00-00-03']
INFO    12/13/2022 12:00:04 AM  Time elapsed 1.6626670630066656 seconds
INFO    12/13/2022 12:00:04 AM  Finished backup successfully
INFO    12/13/2022 12:00:04 AM  Symlink created from /media/backup_drive_linux/hd2_backups/latest to /media/backup_drive_linux/hd2_backups/2022-12-13-00-00-03
```

## Backup Directory Structure

The output directory contains a folder for each backup named using the date and
time that the backup occurred.

```bash
[ethan@rietz /media/backup_drive_linux/home_directory_backups]
~ ls | tail
2022-12-05-00-00-01
2022-12-06-00-00-01
2022-12-07-00-00-01
2022-12-08-00-00-01
2022-12-09-00-00-01
2022-12-10-00-00-06
2022-12-11-00-00-01
2022-12-12-00-00-02
2022-12-13-00-00-01
latest
```

There is one additional directory called `latest` which is a symbolic link to
the latest backup directory. The `latest` directory is used by `rsync`. If a
file is not changed since the last backup, a hard link is created to that file
in the `latest` directory.

As of today, I have 165 backups.

```bash
[ethan@rietz /media/backup_drive_linux/home_directory_backups]
~ ls | wc -l
166
```

If we do an `ls -l`, it displays the number of reference counts, or hard links,
to that inode.

```bash
[ethan@rietz /media/backup_drive_linux/home_directory_backups]
~ ls -al 2022-05-24-21-50-17/home/ethan
total 68
drwxr-x---   8 ethan ethan 4096 May 14  2022 .
drwxr-xr-x   4 root  root  4096 May 10  2022 ..
drwxrwxr-x   3 ethan ethan 4096 May  9  2022 .ansible
-rw------- 165 ethan ethan  846 May  9  2022 .bash_history
-rw-r--r-- 165 ethan ethan  220 Jan  6  2022 .bash_logout
-rw-r--r-- 165 ethan ethan 3771 Jan  6  2022 .bashrc
drwxrwx--x   7 ethan ethan 4096 May 14  2022 .config
drwxrwxr-x   6 ethan ethan 4096 May  9  2022 .dotfiles
drwxrwxr-x   5 ethan ethan 4096 May 24  2022 git
-rw------- 165 ethan ethan   20 May  9  2022 .lesshst
-rw-rw-r--   9 ethan ethan 2769 May 13  2022 logs.txt
-rw-r--r-- 165 ethan ethan  807 Jan  6  2022 .profile
-rw-r--r--   9 ethan ethan  787 May 10  2022 server.md
drwx------   2 ethan ethan 4096 May  9  2022 .ssh
-rw-r--r-- 165 ethan ethan    0 May  9  2022 .sudo_as_admin_successful
drwxr-xr-x   6 ethan ethan 4096 May 15  2022 Sync
-rw------- 165 ethan ethan 2050 May  9  2022 .viminfo
-rw-rw-r-- 150 ethan ethan  165 May 10  2022 .wget-hsts
lrwxrwxrwx 165 ethan ethan   24 May  9  2022 .xinitrc -> .dotfiles/linux/.xinitrc
lrwxrwxrwx 165 ethan ethan   24 May  9  2022 .Xmodmap -> .dotfiles/linux/.Xmodmap
lrwxrwxrwx 165 ethan ethan   25 May  9  2022 .xprofile -> .dotfiles/linux/.xprofile
lrwxrwxrwx 165 ethan ethan   27 May  9  2022 .Xresources -> .dotfiles/linux/.Xresources
lrwxrwxrwx 165 ethan ethan   25 May  9  2022 .xsession -> .dotfiles/linux/.xsession
lrwxrwxrwx 165 ethan ethan   22 May  9  2022 .zshenv -> .dotfiles/unix/.zshenv
```

We can see that the files that were there in the first backup have 165 hard
links. There is a file system dependent upper limit on the number of inode
references that can exist. On an ext4 formatted hard drive, that upper limit is
the max value for a 16 bit number (65535). As long as I only do one backup per
day, I should be good for the next 179 years.
