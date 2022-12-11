#!/bin/bash -e

IMAGE=base
if [ "$1" = "final" ]
then
  IMAGE=final
fi

qemu-system-x86_64 \
  -enable-kvm \
  -cpu host \
  -smp 4 \
  -m 8192M \
  -bios /usr/share/edk2-ovmf/x64/OVMF.fd \
  -device virtio-vga-gl \
  -display gtk,gl=on \
  -device virtio-net,netdev=net0 \
  -netdev user,id=net0,hostfwd=tcp::2222-:22 \
  -drive file=dist/$IMAGE/archlinux-workstation,if=virtio
