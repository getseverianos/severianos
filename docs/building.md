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

The finished ISO lands in `OUT_DIR` (default `~/severian/out`) together with
`.sha256` and `.b2` checksums.

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

## Testing

```sh
scripts/vm.sh live            # live medium, UEFI
scripts/vm.sh live bios       # live medium, legacy BIOS
scripts/vm.sh install         # live medium + 20 GB test disk
scripts/vm.sh disk            # boot what you installed
scripts/vm.sh reset           # start over with an empty disk
```

Then on real hardware: write the ISO to a USB stick and boot it.
