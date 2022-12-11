locals {
  firmware = "/usr/share/edk2-ovmf/x64/OVMF.fd"
  iso_url = "https://mir.archlinux.fr/iso/2022.12.01/archlinux-2022.12.01-x86_64.iso"
  iso_checksum = "de301b9f18973e5902b47bb00380732af38d8ca70084b573ae7cf36a818eb84c"
  headless = true
  crypt_passphrase = "password"
  ssh_root_username = "root"
  ssh_root_password = "root"
  ssh_user_username = "username"
  ssh_user_password = "password"
}

source "qemu" "kvm-init" {
  vm_name = "archlinux-workstation"
  headless = "${local.headless}"
  cpus = "6"
  memory = "8192"
  disk_size = 20000
  firmware = "${local.firmware}"
  iso_url = "${local.iso_url}"
  iso_checksum = "${local.iso_checksum}"
  ssh_password = "${local.ssh_root_password}"
  ssh_username = "${local.ssh_root_username}"
  ssh_wait_timeout = "60m"
  boot_wait = "3s"
  boot_command = [
    "<enter><wait40>",
    "echo ${local.ssh_root_username}:${local.ssh_root_password} | chpasswd<enter>"
  ]
  shutdown_command = "shutdown -P now"
  output_directory = "dist/base"
}

source "qemu" "kvm-setup" {
  vm_name = "archlinux-workstation"
  headless = "${local.headless}"
  cpus = "6"
  memory = "8192"
  disk_size = 20000
  disk_image = true
  firmware = "${local.firmware}"
  iso_url = "dist/base/archlinux-workstation"
  iso_checksum = "none"
  ssh_password = "${local.ssh_user_password}"
  ssh_username = "${local.ssh_user_username}"
  ssh_wait_timeout = "60m"
  boot_wait = "3s"
  boot_command = [
    "<wait10>",
    "${local.crypt_passphrase}<enter>"
  ]
  shutdown_command = "sudo shutdown -P now"
  output_directory = "dist/final"
}

build {
  sources = ["source.qemu.kvm-init"]

  provisioner "ansible" {
    playbook_file = "init.yml"
    inventory_file = "inventories/packer"
    ansible_env_vars = ["ANSIBLE_FORCE_COLOR=1"]
    extra_arguments = [
      #"-vvv",
      "-D",
      "-e ansible_host=localhost",
      "-e ansible_port=${build.Port}",
      "-e ansible_user=${local.ssh_root_username}",
      "-e ansible_ssh_pass=${local.ssh_root_password}",
      "-e crypt_passphrase=${local.crypt_passphrase}",
      "-e unix_username=${local.ssh_user_username}",
      "-e unix_password=${local.ssh_user_password}"
    ]
  }

  provisioner "shell-local" {
    inline = ["echo '==> Test this image with: ./kvm-run.sh'"]
  }
}

build {
  sources = ["source.qemu.kvm-setup"]

  provisioner "ansible" {
    playbook_file = "setup.yml"
    inventory_file = "inventories/packer"
    ansible_env_vars = ["ANSIBLE_FORCE_COLOR=1"]
    extra_arguments = [
      #"-vvv",
      "-D",
      "-e ansible_host=localhost",
      "-e ansible_port=${build.Port}",
      "-e ansible_user=${local.ssh_user_username}",
      "-e ansible_ssh_pass=${local.ssh_user_password}",
      "-e unix_username=${local.ssh_user_username}"
    ]
  }

  provisioner "shell-local" {
    inline = ["echo '==> Test this image with: ./kvm-run.sh final'"]
  }
}
