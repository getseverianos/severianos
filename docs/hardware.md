# Hardware

## Support policy

| area      | supported                                  | not supported                 |
|-----------|--------------------------------------------|-------------------------------|
| CPU       | x86-64 baseline (v1)                        | 32-bit, ARM                   |
| graphics  | AMD and Intel via Mesa                     | Nvidia (proprietary or nouveau) |
| firmware  | UEFI, legacy BIOS                          |                               |
| memory    | 4 GB recommended (less is untested)        |                               |

Nvidia: Sway and the proprietary driver do not work well together, and we
cannot test it. It may work; we will not promise it.

### Older AMD graphics

AMD GPUs before GCN (TeraScale: Radeon HD 2000–6000, and APUs such as
Trinity/Richland) run on the `radeon` driver with **OpenGL only — no Vulkan**.
Sway does not need Vulkan, so the desktop works fine.

## Tested

| machine                          | graphics                   | result | notes |
|----------------------------------|----------------------------|--------|-------|
| QEMU/KVM, virtio-vga             | virtio (llvmpipe)          | works  | UEFI and BIOS boot |
| HP desktop, AMD A10-6700 (Richland) | HD 8670D, `radeon`      | works  | no Vulkan; `k10temp` reports no real temperature, so the bar hides it |
| Lenovo ThinkPad T440p            | Intel HD 4600              | pending | Wi-Fi, battery, brightness to test |

Add your machine: model, graphics driver (`sevfetch` shows it), what worked,
what did not.
