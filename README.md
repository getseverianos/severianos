# SeverianOS

**A quiet Sway desktop, based on Arch Linux.**

SeverianOS is a minimal, deliberate tiling system. It boots into a finished
Sway desktop with one consistent look — *Fuligin*, a near-black palette with a
single ember accent — from the boot menu to the shell prompt. It aims to run
well on as many machines as possible, from a ten-year-old desktop to a current
laptop.

> SeverianOS is not affiliated with or endorsed by Arch Linux.
> Please report SeverianOS issues here, not on the Arch forums or bug tracker.

## What you get

- **Sway** with Waybar, foot, fuzzel, mako, swaylock, swayidle — preconfigured
- **Fuligin** theme across boot menu, console, desktop, GTK apps and terminal
- **greetd + tuigreet** login, **PipeWire** audio, **NetworkManager** (iwd backend), **Bluetooth**
- **sevbrowser** — Firefox with telemetry, studies, Pocket and sponsored content switched off,
  a local start page and lean defaults for older hardware (check: `about:policies`)
- **zram** swap and **systemd-oomd**, so low-memory machines stay responsive
- **systemd-boot** on UEFI, GRUB on legacy BIOS
- Own small tools:

  | tool          | does                                                   |
  |---------------|--------------------------------------------------------|
  | `sevinstall`  | the installer (ext4 or btrfs, optional encryption)     |
  | `sevbrowser`  | the browser (Super+Shift+B)                            |
  | `sevupdate`   | update the system; the bar shows pending updates       |
  | `sevconfig`   | compare your configs with the defaults, restore them   |
  | `sevkeyboard` | pick a keyboard layout (Super+F2)                      |
  | `sevhelp`     | all shortcuts (Super+F1)                               |
  | `sevpower`    | lock · log out · reboot · power off (Super+Shift+E)    |
  | `sevfetch`    | system info                                            |
  | `sevtemp`     | CPU temperature for the bar, hides implausible sensors |

## Hardware

- **CPU:** any x86-64 (baseline v1 — no AVX2 needed)
- **Graphics:** AMD and Intel via Mesa. **Nvidia is not supported.**
- **Firmware:** UEFI (recommended) or legacy BIOS
- **Memory:** 4 GB recommended (less is untested)
- Details and tested machines: [docs/hardware.md](docs/hardware.md)

## Install

1. Write the ISO to a USB stick:
   `sudo dd if=severianos-*.iso of=/dev/sdX bs=4M conv=fsync oflag=direct status=progress`
2. Boot from it. The live desktop starts by itself.
3. Open the menu (Super+D) → **Install SeverianOS**, or run `sudo sevinstall`.

Try the installer without touching anything: `sevinstall --dry-run`.

## Build it yourself

On an Arch-based system with `archiso` and `base-devel`:

```sh
./build.sh all          # packages → local repo → ISO
scripts/vm.sh live      # boot it in QEMU
```

See [docs/building.md](docs/building.md).

## Layout

```
packages/   PKGBUILDs: severian-branding, -config, -tools, -browser, -desktop, -installer
iso/        archiso profile of the live medium
docs/       building, hardware, design, publishing
scripts/    vm.sh – test in QEMU/KVM
build.sh    one script for everything
config.sh   signing key, repo URL, output paths
```

## License

Code: GPL-3.0-or-later (see [LICENSE](LICENSE)).
Artwork (logo, wallpaper, boot splash): CC-BY-SA-4.0 (see [LICENSE-ASSETS.md](LICENSE-ASSETS.md)).
The name and the Fuligin palette nod to Gene Wolfe's *The Book of the New Sun*.
