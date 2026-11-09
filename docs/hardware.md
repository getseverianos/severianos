# Hardware

## Support policy

| area      | supported                                  | not supported                 |
|-----------|--------------------------------------------|-------------------------------|
| CPU       | x86-64 baseline (v1)                        | 32-bit, ARM                   |
| graphics  | AMD and Intel via Mesa                     | Nvidia (proprietary or nouveau) |
| firmware  | UEFI (Secure Boot off), legacy BIOS        | Secure Boot on                |
| memory    | 4 GB recommended (less is untested)        |                               |
| disk      | 12 GB minimum, 20 GB+ recommended          |                               |

Nvidia: Sway and the proprietary driver do not work well together, and we
cannot test it. It may work; we will not promise it.

### Older AMD graphics

AMD GPUs before GCN (TeraScale: Radeon HD 2000–6000, and APUs such as
Trinity/Richland) run on the `radeon` driver with **OpenGL only — no Vulkan**.
Sway does not need Vulkan, so the desktop works fine.

## Tested

| machine | graphics | result | notes |
|---|---|---|---|
| QEMU/KVM, virtio-vga | virtio (llvmpipe) | works | installed: UEFI+ext4, UEFI+btrfs+LUKS2, BIOS+ext4; signed update via `sevupdate` |
| HP desktop, AMD A10-6700 (Richland) | HD 8670D, `radeon` | live medium works | no Vulkan; `k10temp` reports no real temperature, so the bar hides it |
| Lenovo ThinkPad T440p, i5-4300M, 8 GB | Intel HD 4600, `i915` | **installed, everything works** | UEFI+ext4. Wi-Fi, battery, temperature (`coretemp`), Bluetooth, brightness keys, audio, lid → suspend → lock, browser. Under 600 MB RAM after login, 4.3 GB on disk. Firmware: set "UEFI only" and CSM off, otherwise the stick boots in legacy mode. A harmless `usb 1-7 … error -71` appears at boot (an internal USB device). |

Add your machine: model, graphics driver (`sevfetch` shows it), boot mode,
what worked, what did not.
