# SeverianOS

**A quiet Sway desktop, based on Arch Linux.**

SeverianOS is a minimal, deliberate tiling system. It boots into a finished
Sway desktop with one consistent look — *Fuligin*, a near-black palette with a
single ember accent — from the boot menu to the shell prompt. It aims to run
well on as many machines as possible, from a ten-year-old desktop to a current
laptop.

It is small on purpose:

| measured on a ThinkPad T440p (i5-4300M, 8 GB) | |
|---|---|
| memory after login (`free`, one terminal open) | **under 600 MB** |
| disk after installation | **4.3 GB** |

Every new feature has to justify its weight against these numbers.

<!-- screenshots: docs/screenshots/desktop.png, docs/screenshots/apps.png -->

> SeverianOS is not affiliated with or endorsed by Arch Linux.
> Please report SeverianOS issues here, not on the Arch forums or bug tracker.

## What you get

- **Sway** with Waybar, foot, fuzzel, mako, swaylock, swayidle — preconfigured
- **Fuligin** theme across boot menu, console, login, desktop, GTK apps and terminal
- **sevbrowser** — Firefox with telemetry, studies, Pocket and sponsored content
  switched off, a local start page and lean defaults (check: `about:policies`)
- **greetd + tuigreet** login, **PipeWire** audio, **NetworkManager** (iwd),
  **Bluetooth**, **power profiles**
- **zram** swap and **systemd-oomd**, so low-memory machines stay responsive
- **systemd-boot** on UEFI, GRUB on legacy BIOS, optional full-disk encryption
- **Signed updates** from the SeverianOS repository, on top of Arch Linux
- Small tools of its own:

  | tool          | does                                                   |
  |---------------|--------------------------------------------------------|
  | `sevinstall`  | the installer (ext4 or btrfs, optional encryption)     |
  | `sevupdate`   | update the system; the bar shows pending updates       |
  | `sevconfig`   | compare your configs with the defaults, restore them   |
  | `sevbrowser`  | the browser (Super+Shift+B)                            |
  | `sevkeyboard` | pick a keyboard layout (Super+F2)                      |
  | `sevhelp`     | all shortcuts (Super+F1)                               |
  | `sevpower`    | lock · log out · reboot · power off (Super+Shift+E)    |
  | `sevshot`     | screenshots to ~/Pictures/Screenshots (Super+Print)    |
  | `sevbattery`  | warns at 10 % and 5 % battery                          |
  | `sevfetch`    | system info                                            |
  | `sevtemp`     | CPU temperature for the bar, hides implausible sensors |

## Hardware

- **CPU:** any x86-64 (baseline v1 — no AVX2 needed)
- **Graphics:** AMD and Intel via Mesa. **Nvidia is not supported.**
- **Firmware:** UEFI recommended (Secure Boot off), legacy BIOS works
- **Memory:** 4 GB recommended · **Disk:** 12 GB minimum, 20 GB+ recommended
- Tested machines and details: [docs/hardware.md](docs/hardware.md)
- Before you install, read [docs/known-issues.md](docs/known-issues.md)

## Install

1. Download the ISO from the releases page and check it
   (`sha256sum -c severianos-*.iso.sha256`).
2. Write it to a USB stick (all data on the stick is lost):
   `sudo dd if=severianos-*.iso of=/dev/sdX bs=4M conv=fsync oflag=direct status=progress`
3. In the firmware setup: **Secure Boot off**, boot mode **UEFI only**.
4. Boot from the stick. The live desktop starts by itself.
5. Super+D → **Install SeverianOS**. The installer erases the whole disk you pick.

Try the installer without touching anything: `sevinstall --dry-run`.
First steps after installing: [docs/getting-started.md](docs/getting-started.md).

## Build it yourself

On an Arch-based system with `archiso` and `base-devel`:

```sh
./build.sh all          # packages → local repo → ISO
scripts/vm.sh live      # boot it in QEMU
```

See [docs/building.md](docs/building.md) and [docs/publishing.md](docs/publishing.md).

## Layout

```
packages/   PKGBUILDs: severian-keyring, -branding, -config, -tools,
            -browser, -desktop, -installer
iso/        archiso profile of the live medium
docs/       getting started, known issues, hardware, design, building, publishing
scripts/    vm.sh – test in QEMU/KVM
build.sh    one script for everything
config.sh   signing key, repo URL, output paths
VERSION     the release version
```

## Security

Packages, the repository and the ISO are signed with
`614E5176E3257EA92972F3D41CC2187B6745B29E` (SeverianOS Build Key).
How to report a vulnerability: [SECURITY.md](SECURITY.md).

## License

Code: GPL-3.0-or-later (see [LICENSE](LICENSE)).
Artwork (logo, wallpaper, boot splash): CC-BY-SA-4.0 (see [LICENSE-ASSETS.md](LICENSE-ASSETS.md)).
The name and the Fuligin palette nod to Gene Wolfe's *The Book of the New Sun*.
