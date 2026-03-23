---
title: Proxmox 9 Boot Repair Session
categories:
  - linux
  - proxmox
  - homelab
  - debian
---

## Intro

I managed to botch my Proxmox installation in a rather classic way: I tried to upgrade from Debian 12 to 13 while watching *The Pitt* on HBO Max, only half paying attention. Predictably, I missed some critical pre-upgrade warnings, and my system wouldn't boot. This post documents the successful repair procedure for anyone else who might find themselves in a similar situation (distracted or otherwise).

## Background

### What Happened
- Upgraded Proxmox VE 8 (Debian 12/Bookworm) → Proxmox VE 9 (Debian 13/Trixie) on homelab server
- Main Proxmox drive: `nvme2n1` (Samsung 970 EVO Plus 1TB) using LVM
- Second drive with Ubuntu ("sulfur"): `sdc` (465.8GB) — used as rescue OS
- **Upgrade succeeded** — all PVE 9 packages installed correctly
- **Boot failed** — system dropped to BIOS after reboot

### Root Cause
Pre-upgrade warnings were not addressed:
- `systemd-boot` package was installed (incompatible with Proxmox upgrades)
- `grub-efi-amd64` was not installed (needed for UEFI boot)
- EFI boot entry got corrupted/removed during upgrade

### Previous Repair Attempt (from Ubuntu)
1. Mounted Proxmox root (`/dev/mapper/pve-root`)
2. Chrooted into Proxmox
3. Installed `grub-efi-amd64`
4. Ran `grub-install /dev/nvme2n1` and `update-grub`
5. **Result**: System changed from "dropping to BIOS" to showing "Welcome to GRUB" and stopping
6. **Problem**: Chroot was missing critical bind mounts (`/dev/pts`, `/run`, `/sys/firmware/efi/efivars`), so `grub-install` couldn't write proper UEFI boot entries

## Partition Layout

```
Device Start End Sectors Size Type
/dev/nvme2n1p1 34 2047 2014 1007K BIOS boot
/dev/nvme2n1p2 2048 2099199 2097152 1G EFI System
/dev/nvme2n1p3 2099200 1953525134 1951425935 930.5G Linux LVM
```

## Repair Procedure (Successful)

All commands run from Ubuntu on `sdc`.

### Step 1: Activate LVM & Mount Proxmox Root

```bash
sudo vgscan
sudo vgchange -ay
```

Output:
```
Found volume group "pve" using metadata type lvm2
10 logical volume(s) in volume group "pve" now active
```

```bash
sudo mkdir -p /mnt/proxmox
sudo mount /dev/mapper/pve-root /mnt/proxmox
```

Verified contents: `bin boot dev etc home lib lib64 lost+found media mnt opt proc root run sbin srv sys tmp tub usr var`

### Step 2: Mount EFI Partition Inside Chroot Path

**Critical**: Must be at `/mnt/proxmox/boot/efi`, NOT a separate mountpoint.

```bash
sudo mkdir -p /mnt/proxmox/boot/efi
sudo mount /dev/nvme2n1p2 /mnt/proxmox/boot/efi
```

Existing EFI contents: `EFI/BOOT`, `EFI/Dell`, `EFI/proxmox` (from previous attempt)

### Step 3: Set Up ALL Required Bind Mounts

This was the key fix — the previous attempt only had `/dev`, `/proc`, `/sys`.

```bash
sudo mount --bind /dev /mnt/proxmox/dev
sudo mount --bind /dev/pts /mnt/proxmox/dev/pts
sudo mount --bind /proc /mnt/proxmox/proc
sudo mount --bind /sys /mnt/proxmox/sys
sudo mount --bind /run /mnt/proxmox/run
sudo mount --bind /sys/firmware/efi/efivars /mnt/proxmox/sys/firmware/efi/efivars
```

The `efivars` bind mount is **critical** — without it, `grub-install` cannot write UEFI boot variables.

### Step 4: Verify Chroot Environment

```bash
sudo chroot /mnt/proxmox /bin/bash -c '
cat /etc/debian_version
ls /boot/efi/EFI/
ls /boot/vmlinuz-*
ls /sys/firmware/efi/efivars/ | head -3
dpkg -l proxmox-ve | tail -1
dpkg -l grub-efi-amd64 | tail -1
'
```

Results:
- Debian version: **13.4** (Trixie)
- Proxmox VE: **9.1.0**
- grub-efi-amd64: **2.12-9+pmx2**
- Kernels available: `6.17.13-2-pve` (newest), `6.8.12-20-pve`, and 10 others
- efivars: **accessible** ✓

### Step 5: Reinstall GRUB EFI

```bash
sudo chroot /mnt/proxmox /bin/bash -c '
apt install --reinstall grub-efi-amd64 -y
'
```

Output:
```
Installing for x86_64-efi platform.
Installation finished. No error reported.
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-6.17.13-2-pve
Found initrd image: /boot/initrd.img-6.17.13-2-pve
[... 12 kernels total ...]
Found memtest86+ 64bit EFI image: /boot/memtest86+x64.efi
Adding boot menu entry for UEFI Firmware Settings ...
done
```

Then explicitly ran `grub-install` with proper flags:

```bash
sudo chroot /mnt/proxmox /bin/bash -c '
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=proxmox --recheck
update-grub
'
```

Both commands: **Exit code 0**, no errors.

### Step 6: Verify Installation

```bash
sudo chroot /mnt/proxmox /bin/bash -c '
ls -la /boot/efi/EFI/proxmox/
grep -m3 "menuentry" /boot/grub/grub.cfg
efibootmgr -v
blkid /dev/mapper/pve-root
'
```

Results:
- `grubx64.efi` — freshly rebuilt (Mar 20 09:10)
- **UEFI Boot Entries**:
 ```
 BootCurrent: 0002
 Timeout: 1 seconds
 BootOrder: 0000,0001,0002
 Boot0000* proxmox HD(2,GPT,...)/File(\EFI\proxmox\grubx64.efi)
 Boot0001* UEFI OS HD(2,GPT,...)/File(\EFI\BOOT\BOOTX64.EFI)
 Boot0002* ubuntu HD(1,GPT,...)/File(\EFI\ubuntu\shimx64.efi)
 ```
- "proxmox" is **first** in boot order ✓
- `grub.cfg` uses `lvmid` to reference root volume ✓
- Root FS: `/dev/mapper/pve-root` UUID=`7b271119-e217-44ce-a1eb-3e98bc88e7fa` ext4 ✓

### Step 7: Cleanup & Unmount

```bash
sudo umount /mnt/proxmox/sys/firmware/efi/efivars
sudo umount /mnt/proxmox/run
sudo umount /mnt/proxmox/sys
sudo umount /mnt/proxmox/proc
sudo umount /mnt/proxmox/dev/pts
sudo umount /mnt/proxmox/dev
sudo umount /mnt/proxmox/boot/efi
sudo umount /mnt/proxmox
```

All unmounted successfully.

## Key Takeaway

The fix was ensuring the chroot had **all 6 bind mounts**, especially:
- `/dev/pts` — pseudo-terminal devices
- `/run` — runtime data needed by GRUB scripts
- `/sys/firmware/efi/efivars` — **the critical one** — allows `grub-install` to write UEFI NVRAM boot entries via the kernel's EFI variable interface

Without `efivars`, `grub-install` installs the binary to the EFI partition but **cannot register a boot entry** in the UEFI firmware, and the EFI binary may have an incorrect embedded prefix path, causing the "Welcome to GRUB" hang.

## Post-Repair

After reboot, the system should:
1. UEFI firmware loads `\EFI\proxmox\grubx64.efi` from nvme2n1p2
2. GRUB displays menu with Proxmox VE 6.17.13-2-pve as default
3. Boots into Proxmox VE 9.1.0 (Debian 13 Trixie)
4. All VMs and data on LVM volumes should be intact
