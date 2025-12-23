packer {
  required_version = ">= 1.8.0"

  required_plugins {
    qemu = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

source "qemu" "ubuntu" {
  # Instance settings
  vm_name   = var.vm_name
  memory    = var.vm_memory
  cpus      = var.vm_cpus
  disk_size = var.disk_size

  # ISO configuration
  iso_url      = "https://releases.ubuntu.com/noble/ubuntu-24.04.3-live-server-amd64.iso"
  iso_checksum = "sha256:c3514bf0056180d09376462a7a1b4f213c1d6e8ea67fae5c25099c6fd3d8274b"

  # Boot settings for Ubuntu Server ISO with autoinstall
  boot_command = [
    "<wait><wait><wait>c<wait>",
    "linux /casper/vmlinuz autoinstall ds=nocloud-net\\;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ console=ttyS0 loglevel=7 ---<enter><wait>",
    "initrd /casper/initrd<enter><wait>",
    "<wait>boot<enter>"
  ]
  boot_wait = "5s"

  # QEMU specific settings
  accelerator = var.accelerator
  headless    = true
  disk_image  = false
  format      = "raw"
  qemuargs = [
    ["-chardev", "stdio,id=char0,logfile=output/vm-serial.log"],
    ["-serial", "chardev:char0"]
  ]

  # HTTP server for preseed data
  http_directory = "http"

  # SSH configuration for provisioning
  ssh_username     = "ubuntu"
  ssh_password     = "ubuntu"
  ssh_timeout      = "120m"
  ssh_wait_timeout = "120m"

  # Shutdown command
  shutdown_command = "echo 'ubuntu' | sudo -S shutdown -P now"
  shutdown_timeout = "5m"

  # QEMU specific output
  output_directory = "output"
}

build {
  name    = "MRS SDK Qt Development"
  sources = ["source.qemu.ubuntu"]

  # Copy provisioning script to VM
  provisioner "file" {
    source      = "scripts/provision.sh"
    destination = "/home/ubuntu/provision.sh"
  }

  # Convert raw image to VMDK for VirtualBox compatibility
  post-processor "shell-local" {
    inline = [
      "echo 'Converting raw image to VMDK format...'",
      "QEMU_IMG_PATH=$(command -v qemu-img || echo '/usr/bin/qemu-img')",
      "if ! [ -x \"$QEMU_IMG_PATH\" ]; then",
      "  echo \"Error: qemu-img not found at $QEMU_IMG_PATH. Install with: apt-get install qemu-utils\"",
      "  exit 1",
      "fi",
      "cd output",
      "if [ -f ${var.vm_name} ]; then",
      "  mv ${var.vm_name} ${var.vm_name}.img",
      "  \"$QEMU_IMG_PATH\" convert -p -f raw -O vmdk ${var.vm_name}.img ${var.vm_name}.vmdk",
      "  echo 'VMDK conversion complete'",
      "else",
      "  echo 'Error: raw image (${var.vm_name}) not found'",
      "  exit 1",
      "fi"
    ]
  }

  # Generate manifest with build metadata
  post-processor "manifest" {
    output     = "output/manifest.json"
    strip_path = true
  }
}
