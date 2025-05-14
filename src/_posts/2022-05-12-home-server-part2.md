---
title: Home Server Upgrade (Part 2)
categories:
  - linux
  - wifi
---

## Hostname Resolution

Today I figured out that I need to install [Avahi][avahi]. Avahi basically
provides DNS on your local network so that you can ssh into your machine using
`hostname.local` rather than its IP address. With zero configuration,
installing avahi also made it so that my Samba Server is advertised as an
available machine for other computers on the local network. All I had to do was

```bash
sudo apt install avahi-daemon
sudo systemctl enable avahi-daemon
sudo systemctl start avahi-daemon
```

## Connecting to Wi-Fi

To connect to the network wirelessly, I first installed [Network
Manger][network-manager].

```bash
sudo apt install network-manager
```

Installing network manager apparently also enabled and started the systemd
service as well as it showed that is was running from `systemctl status
NetworkManager.service`.

I then tried to list the available networks using `nmcli`. When I ran `nmcli
device wifi list`, there was no output at all. I search around google and
confirmed that I had [wpa_supplicant][wpa-supplicant] running via `systemctl
status wpa_supplicant`. I then did some checks to see what wifi card I had in
the Mac Mini.

### Checking Hardware

If you run `nmcli` with no arguments, it displays information about the
available devices.

```bash
> nmcli
enp1s0f0: unmanaged
        "Broadcom and subsidiaries NetXtreme BCM57766"
        ethernet (tg3), 68:5B:35:99:BD:B8, hw, mtu 1500

lo: unmanaged
        "lo"
        loopback (unknown), 00:00:00:00:00:00, sw, mtu 65536

Use "nmcli device show" to get complete information about known devices and
"nmcli connection show" to get an overview on active connection profiles.

Consult nmcli(1) and nmcli-examples(7) manual pages for complete usage details.
```

Here it only shows the Ethernet device `enp1s0f0` as available.

I then used [lspci][lspci] to find information about other PCI devices on my
machine.


```bash
> lspci -v | grep Network
02:00.0 Network controller: Broadcom Inc. and subsidiaries BCM4331 802.11a/b/g/n (rev 02)
```

This showed me that I have a Broadcom wireless card which is model BCM4331.
There is a community maintained list of articles for wireless card
compatibility [here][wireless-cards]. According to their information about my
specific [Broadcom card][broadcom-driver], the driver does not work out of the
box. However, I searched `apt` for the `wl` driver for `bcm` model, installed
the one that matched, and so far it appears to work out of the box. Fingers
crossed...

```bash
> apt search bcm wl
Sorting... Done
Full Text Search... Done
bcmwl-kernel-source/jammy 6.30.223.271+bdcom-0ubuntu8 amd64
  Broadcom 802.11 Linux STA wireless driver source

broadcom-sta-dkms/jammy 6.30.223.271-17 all
  dkms source for the Broadcom STA Wireless driver

broadcom-sta-source/jammy 6.30.223.271-17 all
  Source for the Broadcom STA Wireless driver
```

I just ran a `sudo apt install bcmwl-kernel-source` and then my wireless card
was detected as an available option to network manager. It shows as device
`wlp2s0`.

```bash
> nmcli
wlp2s0: disconnected
        "Broadcom and subsidiaries BCM4331"
        wifi (wl), A8:86:DD:A1:F1:F7, hw, mtu 1500

enp1s0f0: unmanaged
        "Broadcom and subsidiaries NetXtreme BCM57766"
        ethernet (tg3), 68:5B:35:99:BD:B8, hw, mtu 1500

lo: unmanaged
        "lo"
        loopback (unknown), 00:00:00:00:00:00, sw, mtu 65536

Use "nmcli device show" to get complete information about known devices and
"nmcli connection show" to get an overview on active connection profiles.

Consult nmcli(1) and nmcli-examples(7) manual pages for complete usage details.
```

### Connecting to Wi-Fi

Finally, to actually connect to the internet, I ran

```bash
sudo nmcli device wifi list
```

to find my network. Then I ran

```bash
sudo nmcli device wifi connect <SSID or BSSID> password <PASSWORD>
```

Where `<SSID or BSSID>` is the name of your network or the mac address listed by
`nmcli device wifi list` and `<PASSWORD>` is the network password.

Now the server automatically connects to my network without the ethernet cord
after rebooting.

## TODO

Backups are next on the list.



[avahi]: https://wiki.archlinux.org/title/avahi
[network-manager]: https://wiki.archlinux.org/title/NetworkManager
[wpa-supplicant]: https://wiki.archlinux.org/title/wpa_supplicant
[lspci]: https://man.archlinux.org/man/lspci.8.en
[wireless-cards]: https://help.ubuntu.com/community/WifiDocs/WirelessCardsSupported
[broadcom-driver]: https://help.ubuntu.com/community/HardwareSupportComponentsWirelessNetworkCardsBroadcom
