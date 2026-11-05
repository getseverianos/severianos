#!/usr/bin/env bash
# Test SeverianOS in QEMU/KVM
#
#   scripts/vm.sh live [bios]      boot the newest ISO, no disk
#   scripts/vm.sh install [bios]   boot the newest ISO with the test disk attached
#   scripts/vm.sh disk [bios]      boot the installed test disk
#   scripts/vm.sh reset            delete the test disk and UEFI variables
#
# Default firmware is UEFI; add "bios" to test legacy boot.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
# shellcheck source=config.sh
. "$ROOT/config.sh"
OUT=${OUT_DIR:-$ROOT/out}
VM=${VM_DIR:-$ROOT/vm}
DISK=$VM/test.qcow2
VARS=$VM/OVMF_VARS.4m.fd
CODE=/usr/share/edk2/x64/OVMF_CODE.4m.fd

mode=${1:-live}
fw=${2:-uefi}
case $mode in live|install|disk|reset) ;; *) sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'; exit 1 ;; esac
case $fw in uefi|bios) ;; *) echo "firmware must be uefi or bios"; exit 1 ;; esac
mkdir -p "$VM"

if [[ $mode == reset ]]; then
    rm -f "$DISK" "$VARS"
    echo "test disk and UEFI variables removed"
    exit 0
fi

pkill -f "qemu-system-x86_64.*severian-vm" 2>/dev/null && sleep 1 || true

# shellcheck disable=SC2054  # commas are part of qemu options
args=(
    -name severian-vm
    -enable-kvm -machine q35 -cpu host -smp 2 -m 3072
    -device virtio-vga -display gtk
    -nic user,model=virtio-net-pci
    -device qemu-xhci -device usb-tablet
)

if [[ $fw == uefi ]]; then
    [[ -f $CODE ]] || { echo "edk2-ovmf missing: sudo pacman -S edk2-ovmf"; exit 1; }
    [[ -f $VARS ]] || cp /usr/share/edk2/x64/OVMF_VARS.4m.fd "$VARS"
    args+=(-drive "if=pflash,format=raw,unit=0,readonly=on,file=$CODE"
           -drive "if=pflash,format=raw,unit=1,file=$VARS")
fi

iso() { find "$OUT" -maxdepth 1 -name 'severianos-*.iso' -printf '%T@ %p\n' | sort -n | tail -1 | cut -d' ' -f2-; }

case $mode in
    live)
        ISO=$(iso); [[ -n $ISO ]] || { echo "no ISO in $OUT – ./build.sh"; exit 1; }
        args+=(-cdrom "$ISO" -boot d) ;;
    install)
        ISO=$(iso); [[ -n $ISO ]] || { echo "no ISO in $OUT – ./build.sh"; exit 1; }
        [[ -f $DISK ]] || qemu-img create -q -f qcow2 "$DISK" 20G
        args+=(-drive "file=$DISK,if=virtio,format=qcow2" -cdrom "$ISO" -boot d) ;;
    disk)
        [[ -f $DISK ]] || { echo "no test disk – run: scripts/vm.sh install"; exit 1; }
        args+=(-drive "file=$DISK,if=virtio,format=qcow2" -boot c) ;;
    *)
        sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'; exit 1 ;;
esac

echo "starting VM ($mode, $fw) – close the window to stop it"
exec qemu-system-x86_64 "${args[@]}"
