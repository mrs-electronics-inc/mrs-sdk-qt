packer {
  required_version = ">= 1.8.0"

  required_plugins {
    virtualbox = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/virtualbox"
    }
  }
}

source "virtualbox-iso" "ubuntu" {
  # Instance settings
  vm_name          = var.vm_name
  memory           = var.vm_memory
  cpus             = var.vm_cpus
  disk_size        = var.disk_size
  
  # ISO configuration
  iso_url          = var.iso_url
  iso_checksum     = var.iso_checksum
  
  # Boot settings
  boot_command = [
    "<wait>c<wait>",
    "linux /casper/vmlinuz --- quiet<enter>",
    "<wait3>",
    "initrd /casper/initrd<enter>",
    "<wait3>",
    "boot<enter>",
  ]
  boot_wait = "5s"
  
  # Headless mode (comment out if you want to see the VM window during build)
  headless = true
  
  # VirtualBox specific settings
  format                  = "ova"
  guest_os_type           = "Ubuntu_64"
  vboxmanage              = [["modifyvm", "{{ .Name }}", "--nested-hw-virt", "on"]]
  
  # SSH configuration for provisioning
  ssh_username = "ubuntu"
  ssh_password = "ubuntu"
  ssh_timeout  = "20m"
  
  # Shutdown command
  shutdown_command = "echo 'ubuntu' | sudo -S shutdown -P now"
  shutdown_timeout = "5m"
}

build {
  name            = "mrs-sdk-qt-desktop"
  sources         = ["source.virtualbox-iso.ubuntu"]
  
  # Wait for cloud-init to complete
  provisioner "shell" {
    inline = [
      "echo 'Waiting for cloud-init to finish...'",
      "cloud-init status --wait",
      "echo 'Cloud-init completed'"
    ]
  }
  
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
  
  # Generate output OVA with date-based naming
  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
    custom_data = {
      build_date = local.build_date
      output_ova = local.output_filename
    }
  }
}
