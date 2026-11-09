# Known issues and limits (0.1)

SeverianOS 0.1 is a public preview. Things it does not do yet — read this
before you install.

## Installation

- **The installer always uses a whole disk.** No dual boot next to Windows or
  another Linux, no manual partitioning. Use a separate disk, or install by
  hand with the Arch tools on the live medium.
- **Secure Boot must be off.** SeverianOS is not signed for Secure Boot.
- **Legacy BIOS works, UEFI is better.** Disk encryption is only offered on
  UEFI. Many computers boot USB sticks in legacy mode by default — set
  "UEFI only" (CSM off) in the firmware setup. The installer tells you when it
  started in BIOS mode.
- **The live medium needs a network** for installing (packages are downloaded).
- **The live medium starts with a US keyboard.** The installer asks for your
  layout first and switches to it before you type any password.

## Hardware

- **Nvidia:** not supported, not tested.
- **AMD graphics before GCN** (Radeon HD 2000–6000, APUs like the A10-6700):
  the `radeon` driver has **no Vulkan**. The desktop works (OpenGL); some games
  and apps that need Vulkan will not.
- **Temperature:** some sensors report nonsense (e.g. `k10temp` on AMD
  Trinity/Richland). `sevtemp` hides values outside 20–120 °C, so the bar may
  show no temperature on those machines.
- **Fingerprint readers, webcams:** not configured. They may or may not work.

## Desktop

- **No snapshots / rollback** yet, even on btrfs.
- **Window corners are square.** Plain Sway cannot round them (SwayFX can; it
  may become an option later).
- **`sevhelp` shows the default shortcuts,** not your own changes.
- **Firefox theme:** uses Firefox's built-in dark theme; a Fuligin theme will
  follow once it is signed by Mozilla.

## Updates

- Updates of the SeverianOS packages need the SeverianOS repository, which
  `sevinstall` sets up. Systems installed by hand do not get them.
- The signing key expires on **2028-11-04** and will be extended before; the
  new key arrives through `severian-keyring` like any update.
