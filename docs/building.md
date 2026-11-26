# Building SeverianOS

## Requirements

An Arch-based build machine with:

```sh
sudo pacman -S --needed archiso base-devel
sudo pacman -S --needed qemu-desktop edk2-ovmf   # for testing
```

About 10 GB of free space. Never build in `/tmp` (it is RAM on most systems).

## One command

```sh
./build.sh all
```

| step       | what happens                                                      |
|------------|-------------------------------------------------------------------|
| `check`    | every dependency of every package exists in the Arch repos        |
| `packages` | `makepkg` builds each folder in `packages/` into `build/repo/`    |
| `repo`     | `repo-add` creates the `[severian]` repo database                 |
| `iso`      | copies `iso/` to `build/profile/`, wires in the repo, runs `mkarchiso` |
| `publish`  | uploads the signed repo to github.com/getseverianos/packages      |
| `release`  | tags `v$(cat VERSION)` and creates a draft GitHub release with the ISO |

The finished ISO (`severianos-<VERSION>-x86_64.iso`) lands in `OUT_DIR`
(default `~/severian/out`) with `.sha256`, `.b2` and – when signing – `.sig`.

### How the repo reaches the ISO

- **At build time** `build/profile/pacman.conf` gets `[severian]` pointing at
  `build/repo/`, so `packages.x86_64` can list `severian-desktop`.
- **On the live medium** the repo is copied to `/opt/severian/repo` and the live
  `/etc/pacman.conf` points there, so `sevinstall` can install SeverianOS
  packages onto the target disk.
- **On installed systems** `[severian]` is only added once `REPO_URL` in
  `config.sh` is set (see [publishing.md](publishing.md)).

## Changing things

| you want to change …          | edit …                                              |
|-------------------------------|-----------------------------------------------------|
| desktop defaults              | `packages/severian-config/files/etc/skel/.config/`  |
| a tool                        | `packages/severian-tools/files/usr/bin/`            |
| browser policies, start page  | `packages/severian-browser/files/`                  |
| what the desktop installs     | `depends` in `packages/severian-desktop/PKGBUILD`   |
| the installer                 | `packages/severian-installer/files/usr/bin/sevinstall` |
| logo, wallpaper, os-release   | `packages/severian-branding/files/`                 |
| boot menu                     | `iso/syslinux/`, `iso/efiboot/`                     |
| live-only behaviour           | `iso/airootfs/`, `iso/packages.x86_64`              |

After changing a package, **raise `pkgrel`** (or `pkgver` for features) in its
PKGBUILD. Installed systems only update when the version goes up.

Rule of thumb: anything an installed system needs goes into a **package**.
`iso/airootfs/` is only for the live medium (live user, autologin, keyboard).

## Before publishing

```sh
./build.sh verify
```

`publish` runs this by itself; run it on its own while you are still working.
It refuses to let three mistakes out of the door:

- **a file another package owns.** This is what broke 0.3.1: we shipped
  `/etc/xdg/reflector/reflector.conf`, which belongs to `reflector`, and every
  `pacman -Syu` stopped with "conflicting files". Put our settings in
  `/usr/share/severian/` and point the service at them with a drop-in in
  `/usr/lib/systemd/system/<unit>.d/`.
- **a file in two severian packages.** pacman refuses that too.
- **a script that does not parse** (`bash -n` on every `*.install` and
  everything in `files/usr/bin/`).

The ownership check needs the pacman file database and refreshes it with
`sudo pacman -Fy` when it is older than two days. It tests itself against a
known file first, so a clean result means the check really ran. If a shared
path is ever deliberate, list it in `packages/.verify-allow` — and write down
why.

## Testing

```sh
scripts/vm.sh live            # live medium, UEFI
scripts/vm.sh live bios       # live medium, legacy BIOS
scripts/vm.sh install         # live medium + 20 GB test disk
scripts/vm.sh disk            # boot what you installed
scripts/vm.sh reset           # start over with an empty disk
```

Then on real hardware: write the ISO to a USB stick and boot it.
