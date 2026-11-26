# Changelog

## Unreleased (0.5)

- The dropdown terminal drops down: it sits at the top edge across the full
  width of the work area, 45 % of the screen high, and slides in and out
  (ease-out, about 150 ms). Sway animates nothing by itself, so `sevdrop`
  moves the window step by step. `sevdrop --no-anim` turns it off,
  `--height 60` makes it taller, SEVDROP_FRAMES and SEVDROP_DELAY tune it

## Unreleased (0.4)

- Keys: Super+Space is fullscreen (Super+F still works), Super+T opens a
  terminal, Super+Shift+Return a floating one, Super+Tab switches between
  tiled and floating
- Ctrl+Q closes a window and Ctrl+B opens the browser (Super+Shift+Q and
  Super+Shift+B still work). Sway takes both keys before the program sees
  them; `unbindsym` in a `config.d` file gives them back
- Resize without a mode: Super+Ctrl and h j k l or the arrow keys
- Hold Super and drag a window with the mouse to move it, right button to
  resize (tiling_drag)
- Super+Shift+- puts any window away, Super+- brings it back
- Super+Alt+T opens the dropdown terminal (`sevdrop`): one terminal that
  drops in and out with the same key while everything in it keeps running.
  With tmux installed the session even survives closing the window; its
  prefix there is Ctrl+A, because Ctrl+B belongs to the browser
- `sevbench` fixes: the boot time is read again (systemd-analyze ends its
  line with a space, so the old pattern never matched), the version comes
  from os-release, which now carries VERSION_ID, and a reading taken while a
  browser is open is marked as not being the baseline
- `sevhelp` (Super+F1) now reads the Sway config that is really loaded, so
  the list cannot drift from the keys, and your own bindings appear in it

## Unreleased (0.3)

- Careful updates: `sevupdate` clears a lock left by an interrupted update,
  shows new Arch Linux news before updating, and offers fresh mirrors and a
  second try when an update fails
- Snapshots on btrfs installs: `sevupdate` takes one before every update
  (kernel included, newest 3 kept); `sev rollback` returns to one after a
  reboot. /home is not touched. New installs get an @snapshots subvolume
- Mirrors are refreshed weekly (reflector.timer)
- Fix: the weekly mirror refresh no longer ships a file that belongs to
  the reflector package, which made pacman refuse every update
  ("conflicting files"). The settings live in
  /usr/share/severian/reflector.conf now
- Tuning: zram-friendly memory settings, I/O scheduler by disk type
  (bfq for hard disks), journal limited to 200 MB
- Video decoding on older Intel graphics (Haswell and earlier, e.g. ThinkPad
  T440p): libva-intel-driver
- First start: `sevwelcome` opens a short setup (keyboard, Wi-Fi, night light,
  updates, keys) and a hardware check (`sev hw`): acceleration, Vulkan,
  video decoding, battery
- `sevbench` measures RAM, disk and boot time the same way every time
- `build.sh release` checks that every file arrived on GitHub

## Unreleased (0.2)

- The ember: `sev` shows how the system is doing (failed services, full disk,
  pending updates) as a small mascot; `sev menu` / right click on the ember in
  Waybar opens settings, update, doctor, keys and power; `sev mascot off`
- `sev doctor` (system check), `sev clean` (package cache, old logs, unused
  packages), `sev fix` (stale pacman lock), `sev mem` (where the memory goes),
  `sev info` (sevfetch)
- Settings and System Check appear in the app launcher (Super+D)
- On-screen bar for volume and brightness (sevosd, works on the lock screen)
- Clipboard history: Super+Shift+V (sevclip, cliphist)
- Night light: Super+Shift+N, auto 20:00–07:00 or always (sevnight, wlsunset)
- Screen recording: Super+Shift+R starts and stops (sevrec, wf-recorder),
  saved to ~/Videos/Recordings; `sevrec full`, `sevrec audio`
- Displays: Super+Shift+P (sevdisplay) – arrange, resolution, scale, rotate,
  on/off, saved profiles, laptop lid turns the internal screen off
- Packages: Super+Shift+A (sevpkg) – search all packages, see what you
  installed, install and remove; `sevpkg search WORD` in the terminal
- Fix: settings saved by sevsettings no longer break the sway config
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
