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
  iso_url      = var.iso_url
  iso_checksum = var.iso_checksum

  # Boot settings for Ubuntu Desktop ISO with autoinstall
  boot_command = [
    "<wait><wait><wait>c<wait>",
    "linux /casper/vmlinuz autoinstall ds=nocloud-net\\;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ debug systemd.log_level=debug console=tty0 console=ttyS0,115200n8 ---<enter><wait>",
    "initrd /casper/initrd<enter><wait>",
    "boot<enter>"
  ]
  boot_wait = "10s"

  # QEMU specific settings
  accelerator = "kvm"
  headless    = true
  disk_image  = false
  format      = "raw"
  qemuargs = [
    ["-serial", "mon:telnet:127.0.0.1:4444,server,nowait"]
  ]

  # HTTP server for preseed data
  http_directory = "http"

  # SSH configuration for provisioning
  ssh_username     = "ubuntu"
  ssh_password     = "ubuntu"
  ssh_timeout      = "60m"
  ssh_wait_timeout = "60m"

  # Shutdown command
  shutdown_command = "echo 'ubuntu' | sudo -S shutdown -P now"
  shutdown_timeout = "5m"

  # QEMU specific output
  output_directory = "output"
}

build {
  name    = "mrs-sdk-qt-desktop"
  sources = ["source.qemu.ubuntu"]

  # Update system and install base dependencies
  provisioner "shell" {
    script = "${path.root}/provisioning/base-system.sh"
  }

  # Install Qt Creator
  provisioner "shell" {
    script = "${path.root}/provisioning/qt-creator.sh"
  }

  # Install Qt desktop kits (Qt 5 & Qt 6)
  provisioner "shell" {
    script = "${path.root}/provisioning/qt-desktop-kits.sh"
  }

  # Final cleanup and optimization
  provisioner "shell" {
    inline = [
      "echo 'Running final cleanup...'",
      "sudo apt-get autoremove -y",
      "sudo apt-get autoclean -y",
      "sudo apt-get clean -y",
      "sudo rm -rf /tmp/* /var/tmp/*",
      "echo 'Build complete!'",
    ]
  }

  # Convert raw image to VMDK for VirtualBox compatibility
  post-processor "shell-local" {
    inline = [
      "echo 'Converting raw image to VMDK format...'",
      "if ! command -v qemu-img &> /dev/null; then",
      "  echo 'Error: qemu-img not found. Install with: apt-get install qemu-utils'",
      "  exit 1",
      "fi",
      "cd output",
      "if [ -f packer-qemu ]; then",
      "  qemu-img convert -f raw -O vmdk packer-qemu ${var.vm_name}.vmdk",
      "  echo 'VMDK conversion complete'",
      "else",
      "  echo 'Error: raw image (packer-qemu) not found'",
      "  exit 1",
      "fi"
    ]
  }

  # Generate manifest with build metadata
  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}
