# Changelog

## Unreleased (0.2)

- The ember: `sev` shows how the system is doing (failed services, full disk,
  pending updates) as a small mascot; `sev menu` / right click on the ember in
  Waybar opens settings, update, doctor, keys and power; `sev mascot off`
- `sevsettings` (Super+Comma, middle click on the ember): one menu for network,
  Bluetooth, sound, displays, keyboard, touchpad, power profile, default apps,
  the ember, update, system info and reset
- Always in English: the installer asks only for the region (units, paper
  size); dates in English with a 24-hour clock. Existing installs switch once
  on upgrade. sevbrowser requests en-US

## 0.1.0 — 2026-11-09

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
- 6 px rounded corners for the launcher, notifications, tooltips and the
  start page (window corners stay square – plain Sway cannot round them)
- Firefox uses its built-in dark theme; on first login GTK and portal-aware
  apps are told to prefer dark (gsettings)
- Start page no longer clips or overlaps in small windows
- Installer asks for the keyboard layout first and switches the live
  session to it, so passwords are typed exactly as they will be at boot
- Signed packages: `severian-keyring` ships the SeverianOS key
  (614E5176E3257EA92972F3D41CC2187B6745B29E); installed systems use
  `SigLevel = Required` for `[severian]`
- `./build.sh publish` uploads the signed repo to
  github.com/getseverianos/packages (release `x86_64`)
- sevfetch shows the SeverianOS release
- Installer removes the sync databases of the live medium, so the first
  update on the new system fetches a matching, signed database
- First update delivered through the signed [severian] repo
- `sevbattery`: notifications at 10 % and 5 % battery
- `sevshot`: Super+Print saves screenshots to ~/Pictures/Screenshots
- `sevconfig` no longer reports the installer's clock-language line as a change
- Installer explains legacy BIOS mode and how to switch to UEFI
- Versioned ISO (`severianos-0.1.0-x86_64.iso`), `./build.sh release`
- Docs: getting started, known issues, SECURITY.md, hardware results
- Tested: QEMU/KVM (all install paths), AMD A10-6700 (live, radeon),
  ThinkPad T440p (installed, all hardware working; under 600 MB RAM,
  4.3 GB disk)
