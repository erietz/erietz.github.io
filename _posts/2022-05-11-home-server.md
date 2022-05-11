---
title: Home Server Upgrade
categories:
  - linux
  - samba
---

## Background

I have been using a Mac Mini as a home server for the last few years for
network file/printer sharing and Time Machine backups. It is old enough that
the OS cannot be upgraded passed Catalina which will [no longer be receiving
security updates][macos-eol] as of November 2022
(). I decided it was about
time that I was due for another Linux installation and went with Ubuntu Server.
The following information is for how I migrated from this setup

- Mac Mini Server (late 2012) running Catalina
    - Internal Drives
        - 500GB SSD (APFS)
        - 1TB HDD (Mac OS Extended Journaled)
    - External Drives
        - 4TB HDD (Mac OS External Journaled)

To this setup

- Ubuntu Server 22.04
    - Internal Drives
        - 500GB SSD (EXT4)
        - 1TB HDD (EXT4)
    - External Drives
        - 4TB HDD (Still need to figure out how to backup mac laptops to this)
        - 4TB HDD (EXT4 for backup of internal drives)

## Log to GitHub

I have found the easiest thing these days is to just use the [GitHub
CLI][github-cli]

```bash
sudo apt install gh
gh auth login
```

And you are off to the races with your ssh keys automatically imported into
GitHub.


## Install dotfiles

I had already automated this process for an Ubuntu machine using Ansible. [The
source code][ansible] for this part can be found here. All I had to do was to
run `ansible-playbook --ask-become-pass ubuntu.yml`.


## Upgrade Neovim

Since Ubuntu is not a rolling release distro, Neovim is out of date and
I cannot live with that. To install the latest release I simply downloaded the
`.deb` package from the GitHub releases, verified the checksum, and installed
using `apt`.

```bash
wget https://github.com/neovim/neovim/releases/download/v0.7.0/nvim-linux64.deb
wget https://github.com/neovim/neovim/releases/download/v0.7.0/nvim-linux64.deb.sha256sum
sha256sum -c nvim-linux64.deb.sha256sum
sudo apt install ./nvim-linux64.deb
```


## Repartition the drive

Before repartitioning the drive, I checked to see what the devices were using
`lsblk` and `fdisk -l`.

### Before

As we can see here, `snap` is installed by default these days on Ubuntu Server
and is making my block device list messy.


```bash
> lsblk
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
loop0    7:0    0  61.9M  1 loop /snap/core20/1405
loop1    7:1    0  79.9M  1 loop /snap/lxd/22923
loop2    7:2    0  44.7M  1 loop /snap/snapd/15534
loop3    7:3    0  61.9M  1 loop /snap/core20/1434
sda      8:0    0 465.8G  0 disk
├─sda1   8:1    0     1G  0 part /boot/efi
└─sda2   8:2    0 464.7G  0 part /
sdb      8:16   0 931.5G  0 disk
├─sdb1   8:17   0   200M  0 part
├─sdb2   8:18   0 930.7G  0 part
└─sdb3   8:19   0 619.9M  0 part
```

Here we can see my two hard drives. The 500GB solid state drive is named `sda`
and has two partitions. The second internal hard drive is named `sdb` and has
three partitions. I will not be needing these three parititions and I will up
repartitioning this drive to only have one `ext4` partition for storage.

More information about the drives is displayed below using `fdisk -l`.

```bash
> sudo fdisk -l
Disk /dev/loop0: 61.89 MiB, 64901120 bytes, 126760 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/loop1: 79.95 MiB, 83832832 bytes, 163736 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/loop2: 44.68 MiB, 46845952 bytes, 91496 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/loop3: 61.9 MiB, 64909312 bytes, 126776 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sdb: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
Disk model: APPLE HDD ST1000
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disklabel type: gpt
Disk identifier: 836857F7-4F20-47E2-BB79-F8C1EFCDBAFD

Device          Start        End    Sectors   Size Type
/dev/sdb1          40     409639     409600   200M EFI System
/dev/sdb2      409640 1952255591 1951845952 930.7G Apple HFS/HFS+
/dev/sdb3  1952255592 1953525127    1269536 619.9M Apple boot


Disk /dev/sda: 465.76 GiB, 500107862016 bytes, 976773168 sectors
Disk model: Samsung SSD 860
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 89968A95-CDFD-4253-9017-59C8711C0D0F

Device       Start       End   Sectors   Size Type
/dev/sda1     2048   2203647   2201600     1G EFI System
/dev/sda2  2203648 976771071 974567424 464.7G Linux filesystem
```


### Running `fdisk`

Repartitioning the drive is very straight forward using `fdisk`.

```bash
> sudo fdisk /dev/sdb

Welcome to fdisk (util-linux 2.37.2).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.


Command (m for help): m

Help:

  GPT
   M   enter protective/hybrid MBR

  Generic
   d   delete a partition
   F   list free unpartitioned space
   l   list known partition types
   n   add a new partition
   p   print the partition table
   t   change a partition type
   v   verify the partition table
   i   print information about a partition

  Misc
   m   print this menu
   x   extra functionality (experts only)

  Script
   I   load disk layout from sfdisk script file
   O   dump disk layout to sfdisk script file

  Save & Exit
   w   write table to disk and exit
   q   quit without saving changes

  Create a new label
   g   create a new empty GPT partition table
   G   create a new empty SGI (IRIX) partition table
   o   create a new empty DOS partition table
   s   create a new empty Sun partition table


Command (m for help): p
Disk /dev/sdb: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
Disk model: APPLE HDD ST1000
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disklabel type: gpt
Disk identifier: 836857F7-4F20-47E2-BB79-F8C1EFCDBAFD

Device          Start        End    Sectors   Size Type
/dev/sdb1          40     409639     409600   200M EFI System
/dev/sdb2      409640 1952255591 1951845952 930.7G Apple HFS/HFS+
/dev/sdb3  1952255592 1953525127    1269536 619.9M Apple boot

Command (m for help): d
Partition number (1-3, default 3): 3

Partition 3 has been deleted.

Command (m for help): d
Partition number (1,2, default 2): 2

Partition 2 has been deleted.

Command (m for help): d
Selected partition 1
Partition 1 has been deleted.

Command (m for help): p
Disk /dev/sdb: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
Disk model: APPLE HDD ST1000
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disklabel type: gpt
Disk identifier: 836857F7-4F20-47E2-BB79-F8C1EFCDBAFD

Command (m for help): n
Partition number (1-128, default 1):
First sector (34-1953525134, default 2048):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-1953525134, default 1953525134):

Created a new partition 1 of type 'Linux filesystem' and of size 931.5 GiB.

Command (m for help): p
Disk /dev/sdb: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
Disk model: APPLE HDD ST1000
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disklabel type: gpt
Disk identifier: 836857F7-4F20-47E2-BB79-F8C1EFCDBAFD

Device     Start        End    Sectors   Size Type
/dev/sdb1   2048 1953525134 1953523087 931.5G Linux filesystem

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

### After

This is what the same commands show after writing the changes from `fdisk`.

```bash
> lsblk
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
loop0    7:0    0  61.9M  1 loop /snap/core20/1405
loop1    7:1    0  79.9M  1 loop /snap/lxd/22923
loop2    7:2    0  44.7M  1 loop /snap/snapd/15534
loop3    7:3    0  61.9M  1 loop /snap/core20/1434
sda      8:0    0 465.8G  0 disk
├─sda1   8:1    0     1G  0 part /boot/efi
└─sda2   8:2    0 464.7G  0 part /
sdb      8:16   0 931.5G  0 disk
└─sdb1   8:17   0 931.5G  0 part
```

Now we only have one partition for drive `sdb`.

## Format the drive as ext4

After partitioning using `fdisk`, we use `mkfs` to format the partition on the
drive.

```bash
> sudo mkfs -t ext4 /dev/sdb1
mke2fs 1.46.5 (30-Dec-2021)
Creating filesystem with 244190385 4k blocks and 61054976 inodes
Filesystem UUID: 1427af59-def0-4380-b0ce-92555e7dcec0
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208,
        4096000, 7962624, 11239424, 20480000, 23887872, 71663616, 78675968,
        102400000, 214990848

Allocating group tables: done
Writing inode tables: done
Creating journal (262144 blocks): done
Writing superblocks and filesystem accounting information: done
```

## Automount drive on login

First make sure that the drive is not mounted.

```bash
sudo umount /mnt/hd2
```

Check for the UUID using `blkid`. We will use the UUID instead of the device
name `sdb` when editing `/etc/fstab`.

```bash
> sudo blkid
/dev/sda2: UUID="e6bff312-28be-4d23-a1e2-f2f10afbf9e6" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="0beea851-f2bb-4b6d-9f76-9745563d1b1d"
/dev/sda1: UUID="EA75-47A4" BLOCK_SIZE="512" TYPE="vfat" PARTUUID="8f73a2aa-afd7-46a6-8c12-12a1d2044802"
/dev/loop1: TYPE="squashfs"
/dev/sdb1: UUID="1427af59-def0-4380-b0ce-92555e7dcec0" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="ace85f13-56dd-ce4d-a930-de12c1743881"
/dev/loop2: TYPE="squashfs"
/dev/loop0: TYPE="squashfs"
/dev/loop3: TYPE="squashfs"
```

Very carefully edit the `fstab` file

```bash
> sudoedit /etc/fstab
[ethan@rietz ~]
> cat /etc/fstab
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
# / was on /dev/sda2 during curtin installation
/dev/disk/by-uuid/e6bff312-28be-4d23-a1e2-f2f10afbf9e6 / ext4 defaults 0 1
# /boot/efi was on /dev/sda1 during curtin installation
/dev/disk/by-uuid/EA75-47A4 /boot/efi vfat defaults 0 1
/swap.img       none    swap    sw      0       0

# ADDED BY ETHAN BELOW HERE
UUID=1427af59-def0-4380-b0ce-92555e7dcec0   /mnt/hd2    ext4    defaults    0   2
```

Now we can mount the hard drive at the mount directory automatically since the
fstab file knows what is supposed to be mounted there.

```
[ethan@rietz ~]
> ls /mnt/hd2
[ethan@rietz ~]
> sudo mount /mnt/hd2
[ethan@rietz ~]
> ls /mnt/hd2
lost+found
[ethan@rietz ~]
```

We can see that the drive has correctly been mounted and has a `lost+found`
directory.

## Create a new user

```bash
sudo useradd --create-home yaneli
sudo passwd yaneli
```

## Change owner (user and group) of folder on second drive

```bash
sudo chown ethan:ethan /mnt/hd2/ethan
sudo chown yaneli:yaneli /mnt/hd2/yaneli
```

## Copy files from external drive to second drive

To copy files I used `rsync` rather than `cp` for better feedback of the
progress.

`rcp: aliased to rsync --progress --verbose --recursive`

```bash
> rcp /media/flashdrive/Docs /mnt/hd2/ethan
```


## Samba Config

### Create a samba user

A linux user account must exist before you can create a "Samba" user. All we
have to do is just configure a password (can be different from unix password)
for the samba user.

```bash
sudo smbpasswd -a ethan
sudo smbpasswd -a yaneli
```

### Create samba shares for the two users

I added the following to `/etc/samba/smb.conf`.

```bash
[ethan]
    comment = Ethan's directory on the second internal harddrive
    path = /mnt/hd2/ethan
    valid users = ethan
    public = no
    writeable = yes

    create mask = 0644
    force create mode = 0644
    directory mask = 0775
    force directory mode = 0775

[yaneli]
    comment = Yaneli's directory on the second internal harddrive
    path = /mnt/hd2/yaneli
    valid users = yaneli
    public = no
    writeable = yes

    create mask = 0644
    force create mode = 0644
    directory mask = 0775
    force directory mode = 0775
```


### Create a shared public folder for any registered user

- First create a new group called "smbgroup"

```bash
sudo groupadd --system smbgroup
```

- Then create a new system user named "smbuser" who is a member of group
  "smbgroup". The user has an invalid shell so they cannot ssh in.

```bash
sudo useradd --system --no-create-home --group smbgroup -s /bin/false smbuser
```

- Change the ownership of the public shared directory.

```bash
sudo chown -R smbuser:smbgroup /mnt/hd2/public
```

- Add a new share in /etc/samba/smb.conf 

```conf
[public]
    comment = A shared directory on the second internal harddrive
    path = /mnt/hd2/public
    public = no
    browseable = yes
    writeable = yes
    force user = smbuser
    force group = smbgroup

    create mask = 0644
    force create mode = 0644
    directory mask = 0775
    force directory mode = 0775
```

### Check smb.conf file for errors

Here is the what the final samba config file looked like below without
comments.

```bash
> testparm
Load smb config files from /etc/samba/smb.conf
Loaded services file OK.
Weak crypto is allowed

Server role: ROLE_STANDALONE

Press enter to see a dump of your service definitions

# Global parameters
[global]
        client min protocol = SMB2
        log file = /var/log/samba/log.%m
        logging = file
        map to guest = Bad User
        max log size = 1000
        obey pam restrictions = Yes
        pam password change = Yes
        panic action = /usr/share/samba/panic-action %d
        passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .
        passwd program = /usr/bin/passwd %u
        server role = standalone server
        server string = %h server (Samba, Ubuntu)
        unix password sync = Yes
        usershare allow guests = Yes
        idmap config * : backend = tdb


[printers]
        browseable = No
        comment = All Printers
        create mask = 0700
        path = /var/spool/samba
        printable = Yes


[print$]
        comment = Printer Drivers
        path = /var/lib/samba/printers


[ethan]
        comment = Ethan's directory on the second internal harddrive
        create mask = 0644
        directory mask = 0775
        force create mode = 0644
        force directory mode = 0775
        path = /mnt/hd2/ethan
        read only = No
        valid users = ethan


[yaneli]
        comment = Yaneli's directory on the second internal harddrive
        create mask = 0644
        directory mask = 0775
        force create mode = 0644
        force directory mode = 0775
        path = /mnt/hd2/yaneli
        read only = No
        valid users = yaneli


[public]
        comment = A shared directory on the second internal harddrive
        create mask = 0644
        directory mask = 0775
        force create mode = 0644
        force directory mode = 0775
        force group = smbgroup
        force user = smbuser
        path = /mnt/hd2/public
        read only = No
```

### Mounting samba from a client

```bash
sudo mount -t cifs -o user=ethan,uid=ethan,gid=ethan,dir_mode=0755,file_mode=0644 //192.168.0.160/public /mnt/samba
```

For some reason I cannot use the server by name and I must use the IP address.

Also the `uid` and `gid` parameters are necessary because without them the share is
mounted as root and I cannot create files without using `sudo`. The `dir_mode` and
`file_mode` parameters must be added by default when connecting from pcmanfm but
they are necessary to create files with the correct permissions when mounted
from the cli.


## TODO

In the next post I will describe how I will setup the backups and other
software. I also need to figure out how to login using the hostname rather than
the IP address of the machine. I would like to leave the server connected via
Ethernet to the network for performance/stability reasons, but since I live in
a tiny apartment I need to figure out how to connect it to wifi so I can
physically move the machine :).


[macos-eol]: https://computing.cs.cmu.edu/desktop/os-lifecycle
[github-cli]: https://cli.github.com/
[ansible]: https://github.com/erietz/machine-setup
