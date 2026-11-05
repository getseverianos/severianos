# Changelog

## 0.1.0 — unreleased

First version of SeverianOS as a real distribution.

- Own packages: `severian-branding`, `severian-config`, `severian-tools`,
  `severian-desktop` (meta), `severian-installer`
- Local `[severian]` repo, built into the live medium
- Installer `sevinstall`: UEFI (systemd-boot) and BIOS (GRUB), ext4 or btrfs,
  optional LUKS2, timezone/locale/keyboard, greetd + tuigreet, dry-run mode
- Fuligin theme: boot menu, console colours, Sway, Waybar, foot, fuzzel, mako,
  swaylock, swaynag, GTK, imv, mpv, shell prompt
- Tools: sevfetch, sevhelp, sevupdate, sevconfig, sevkeyboard, sevpower,
  sevtemp, sevwelcome, severian-session
- System: NetworkManager with iwd, zram (zstd), systemd-oomd, paccache.timer,
  fstrim.timer
- Live medium in English with US keyboard (Super+F2 to change)
- sevbrowser (`severian-browser`): Firefox with SeverianOS policies – no
  telemetry, no studies, no Pocket, no sponsored content, local Fuligin start
  page, fewer content processes; default for web links and PDFs
- Bluetooth: bluez + bluetui, Waybar module (hidden without a controller)
- polkit agent (polkit-gnome), power-profiles-daemon
- sevidle: no screen lock on the live medium (no password there)
- Installer: EFI partition mounted as vfat explicitly, visible download
  progress, stray gpg-agent no longer blocks unmounting, window stays open
- First successful install: QEMU/KVM, UEFI, ext4
- Tested: QEMU/KVM, AMD A10-6700 (radeon)
