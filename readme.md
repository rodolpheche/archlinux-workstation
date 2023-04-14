# Archlinux Workstation

Project to setup Archlinux OS on my workstation.

Feel free to fork and custom it for your needs.

## Summary

<!-- TOC -->

- [Summary](#summary)
- [The stack](#the-stack)
- [Getting started](#getting-started)
    - [Requirements](#requirements)
    - [Test on a local qemu VM](#test-on-a-local-qemu-vm)
        - [Build image](#build-image)
        - [Test base image](#test-base-image)
        - [Test final image](#test-final-image)
    - [Provision workstation](#provision-workstation)
        - [Burn USB live iso](#burn-usb-live-iso)
        - [Prepare workstation](#prepare-workstation)
        - [Provision](#provision)
            - [Init](#init)
            - [Setup](#setup)

<!-- /TOC -->

## The stack

- Core
  - kernel: Linux lts
  - crypted partition: LUKS
  - partition: gpt
  - filesystem: ext4
  - boot: uefi
  - boot manager: systemd-boot
  - network: systemd-networkd / systemd-resolved / iwd
  - init: systemd
  - sound: pulseaudio
  - bluetooth: bluez
- Display
  - server: Xorg
  - desktop: i3
  - lock: i3lock
  - menu: rofi
- GUI
  - terminal: alacritty / tmux
  - browser: brave
  - file explorer: thunar
  - image viewer: feh
  - video player: vlc
  - archive manager: file-roller
- Dev
  - git
  - rust
  - nasm
  - jdk11
  - maven
  - nvm / npm / node
  - yarn
  - code
- Ops
  - qemu
  - edk2-ovmf
  - libvirt
  - libguestfs
  - virt-manager
  - virt-viewer
  - qemu
  - packer
  - terraform
  - ansible
  - docker / docker-compose

## Getting started

### Requirements

- packer
- qemu
- qemu-ui-gtk
- edk2-ovmf
- ansible
- sshpass
- python-passlib

### Test on a local qemu VM

#### Build image

This is based on the [qemu](https://www.packer.io/plugins/builders/qemu) Packer builder

If the file `/usr/share/edk2-ovmf/x64/OVMF.fd` doesn't exist on your system, find its right location, then adapt the `firwmare` path in the `kvm.pkr.hcl` file.

Then, build the qcow images with command:

```bash
packer build -force -parallel-builds=1 .
```

> 2 qcow images should be generated at `dist/base/archlinux-workstation` and `dist/final/archlinux-workstation`

#### Test base image

If the file `/usr/share/edk2-ovmf/x64/OVMF.fd` doesn't exist on your system, find its right location, then adapt the `bios` path in the command below.

```bash
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
  -drive file=dist/base/archlinux-workstation,if=virtio
```

> A qemu window should appear

Type `password` to decrypt the root partition.

Then, login:
- Username: `username`
- Password: `password`

> You're on the prompt of the base system !

#### Test final image

If the file `/usr/share/edk2-ovmf/x64/OVMF.fd` doesn't exist on your system, find its right location, then adapt the `bios` path in the command below.

```bash
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
  -drive file=dist/final/archlinux-workstation,if=virtio
```

> A qemu window should appear

Type `password` to decrypt the root partition.

Then, login:
- Username: `username`
- Password: `password`

> You're on i3 desktop !

### Provision workstation

#### Burn USB live iso

Download Archlinux live iso at https://archlinux.org/download/:

```bash
curl https://mir.archlinux.fr/iso/latest/archlinux-`date +%Y.%m`.01-x86_64.iso -o /tmp/archlinux.iso
```

Then, copy it on a USB device with `dd`:

```bash
dd if=/tmp/archlinux.iso of=/dev/sdX bs=4M status=progress # replace /dev/sdX with your USB device
```

> It may take a while

#### Prepare workstation

Boot the USB key in UEFI mode on the workstation you want to install Archlinux to.

> A root shell should appear after a few seconds

Execute these commands to give ssh access to ansible:

```bash
echo "root:root" | chpasswd
```

Checks:
- Internet connection
- Reachable by the machine which will run ansible

Note the workstation IP address for the next:
```bash
ip addr
```

> The workstation is ready to be provisionned

#### Provision

Then, from a system which has access to the workstation, clone this repository:

```bash
git clone https://github.com/rodolpheche/archlinux-workstation.git
```

Now, fill informations in the `inventories/group_vars/all/all.yml` and `inventories/host_vars/remote.yml` files

##### Init

Run this command to install the base system on the workstation:

```bash
ansible-playbook -i inventories/remote init.yml -D
```

> Reboot the workstation, it will load the base system

##### Setup

Once the system is booted, run the following command:

```bash
ansible-playbook -i inventories/remote setup.yml -D
```

> Reboot the workstation, and voila !
