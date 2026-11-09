# Getting started

## The first minute

| key                     | does                         |
|-------------------------|------------------------------|
| Super + Enter           | terminal                     |
| Super + D               | apps                         |
| Super + Shift + B       | browser                      |
| Super + F1              | all shortcuts                |
| Super + Shift + E       | lock · log out · reboot · power off |

The bar at the top is clickable: `eth`/`wlan` opens the network settings,
`bt` the Bluetooth manager, `vol` mutes (right-click: mixer), the layout code
(e.g. `de`) switches the keyboard, the ember on the left opens the app menu.

## Wi-Fi and Bluetooth

- **Wi-Fi:** click `wlan` or `offline` in the bar, or run `nmtui`.
- **Bluetooth:** click `bt`, or run `bluetui`. Pair with `p`, connect with Enter.

## Updates

```sh
sevupdate
```

When updates are waiting, the bar shows `upd N` — click it. Updates come from
Arch Linux and from the signed SeverianOS repository. Reboot after a kernel
update; `sevupdate` tells you when.

After an update, `sevupdate` may say that some of your configs differ from the
new defaults. That only means you (or an older version) changed them:

```sh
sevconfig status          # which configs differ
sevconfig diff waybar     # how
sevconfig reset waybar    # take the new default (yours is backed up)
```

## Make it yours

Your own Sway settings belong in **`~/.config/sway/config.d/*.conf`**. Those
files load last, override the defaults and survive `sevconfig reset sway`.

```sh
nano ~/.config/sway/config.d/my-keys.conf
```

```
# browser on Super+W
bindsym Mod4+w exec sevbrowser
# file manager on Super+E
bindsym Mod4+e exec thunar
# remove a default binding
unbindsym Mod4+Shift+b
```

Reload with **Super + Shift + C**.

- **Keyboard layout:** Super+F2 (remembered). For the console and the login
  screen: `sudo localectl set-keymap de-latin1`.
- **Wallpaper:** `output * bg /path/to/image.png fill` in a `config.d` file.
- **Default apps:** `~/.config/mimeapps.list`.

## Screenshots

| key                     | does                                   |
|-------------------------|----------------------------------------|
| Print                   | region → clipboard                     |
| Shift + Print           | whole screen → clipboard               |
| Super + Print           | region → `~/Pictures/Screenshots/`     |
| Super + Shift + Print   | whole screen → `~/Pictures/Screenshots/` |

## Software

SeverianOS is Arch Linux underneath: `sudo pacman -S <package>` installs
anything from the Arch repositories. Search with `pacman -Ss <word>`.

A long-term-support kernel as a fallback: `sudo pacman -S linux-lts`, then add
a boot entry in `/boot/loader/entries/` (copy `severian.conf`, change
`vmlinuz-linux` / `initramfs-linux.img` to the `-lts` names).

## When something goes wrong

- **Desktop does not start:** switch to another console (Ctrl+Alt+F2), log in,
  and read `journalctl -b -t sway`.
- **A service failed:** `systemctl --failed`.
- **Installer problems:** the log is in `/var/log/sevinstall.log` on the
  installed system.
- **Ask / report:** GitHub issues of SeverianOS — not the Arch forums.
