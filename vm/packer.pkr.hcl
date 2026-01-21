# Packer configuration block
# Specifies Packer version requirements and required plugins
packer {
  required_version = ">= 1.8.0"

  required_plugins {
    # QEMU plugin for building VM images using QEMU/KVM
    qemu = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

# QEMU source block - defines the VM configuration for building
# Documentation: https://developer.hashicorp.com/packer/integrations/hashicorp/qemu
source "qemu" "ubuntu" {
  # Instance settings (see variables.pkr.hcl for definitions)
  vm_name   = var.vm_name
  memory    = var.vm_memory
  cpus      = var.vm_cpus
  disk_size = var.disk_size

  # Ubuntu Desktop 24.04.3 LTS (Noble Numbat) ISO
  iso_url      = "https://releases.ubuntu.com/noble/ubuntu-24.04.3-desktop-amd64.iso"
  iso_checksum = "file:https://releases.ubuntu.com/noble/SHA256SUMS"

  # GRUB boot commands to trigger Ubuntu autoinstall
  # 1. Wait for GRUB, press 'c' to enter command line
  # 2. Load kernel with autoinstall pointing to Packer's HTTP server
  # 3. Load initrd and boot
  boot_command = [
    "<wait><wait><wait>c<wait>",
    "linux /casper/vmlinuz autoinstall ds=nocloud-net\\;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ console=ttyS0 loglevel=7 ---<enter><wait>",
    "initrd /casper/initrd<enter><wait>",
    "<wait>boot<enter>"
  ]
  boot_wait = "5s" # Wait for GRUB menu before sending keys

  # QEMU virtualization settings
  accelerator = var.accelerator # kvm (fast) or tcg (slow, no KVM needed)
  headless    = true            # No GUI window (use VNC if needed)
  disk_image  = false           # Create new disk, don't use existing image
  format      = "raw"           # Output format (converted to VMDK in post-processor)

  # Extra QEMU arguments for serial console logging and RTC config
  qemuargs = [
    ["-chardev", "stdio,id=char0,logfile=output/vm-serial.log"],
    ["-serial", "chardev:char0"],
    ["-rtc", "base=utc,clock=host"]
  ]

  # Packer serves cloud-init/user-data and cloud-init/meta-data via HTTP
  http_directory = "cloud-init"

  # SSH settings for connecting to VM after install (matches cloud-init identity)
  ssh_username     = "ubuntu"
  ssh_password     = "ubuntu"
  ssh_timeout      = "120m" # Max time to wait for SSH to become available
  ssh_wait_timeout = "120m"

  # Graceful shutdown after provisioning completes
  shutdown_command = "echo 'ubuntu' | sudo -S shutdown -P now"
  shutdown_timeout = "5m"

  output_directory = "output"
}

# The configuration for the Packer builder to run.
# Documentation: https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/build.
build {
  name    = "mrs-sdk-qt"
  sources = ["source.qemu.ubuntu"]

  # Run auto-provisioning script to set up VM for Qt/MRS SDK installations
  provisioner "shell" {
    script = "scripts/autoprovision.sh"
  }

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
