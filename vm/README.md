# MRS SDK Qt - Virtual Machine Image

This directory contains the Packer configuration and provisioning scripts for building a ready-to-use virtual machine image pre-configured with Qt Creator and desktop build kits.

## Overview

The VM image provides a consistent, tested development environment with:
- **Ubuntu 24.04 LTS** base operating system
- **Qt Creator** IDE
- **Qt 5** desktop kit
- **Qt 6** desktop kit

The resulting OVA (Open Virtual Appliance) file is compatible with:
- VirtualBox
- VMware
- GNOME Boxes

## Building Locally

### Prerequisites

- [Packer](https://www.packer.io/downloads) (>= v1.8.0)
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- At least 80GB of free disk space
- 4+ GB of available RAM

### Quick Start

```bash
# Navigate to the vm directory
cd vm

# Initialize Packer (if first time)
packer init .

# Build the VM image
packer build .
```

This will create an OVA file named `mrs-sdk-qt-YYYYMMDD.ova` in the `/work` directory.

### Customization

You can customize the build by editing `variables.pkr.hcl`:

```hcl
variable "vm_name" {
  default = "mrs-sdk-qt"
}

variable "vm_memory" {
  default = 4096  # MB
}

variable "vm_cpus" {
  default = 2
}

variable "disk_size" {
  default = 61440  # MB (60GB)
}
```

Then build with custom variables:

```bash
packer build \
  -var "vm_memory=8192" \
  -var "vm_cpus=4" \
  .
```

## CI/CD Automation

The GitHub Actions workflow (`.github/workflows/vm-build.yml`) automatically builds and uploads OVA images on:
- Manual workflow dispatch
- Tagged releases (e.g., `v1.0.0`)

Artifacts are available as GitHub workflow artifacts for download.

## Directory Structure

```
vm/
├── packer.pkr.hcl              # Main Packer configuration
├── variables.pkr.hcl           # Configurable variables
├── README.md                    # This file
├── provisioning/
│   ├── base-system.sh           # System dependencies and utilities
│   ├── qt-creator.sh            # Qt Creator installation
│   └── qt-desktop-kits.sh       # Qt 5 & Qt 6 desktop kits
└── scripts/
    └── build-vm.sh              # Helper script for local builds
```

## Provisioning Scripts

### `base-system.sh`
Installs system-level dependencies required by Qt and development tools:
- Build essentials and dev tools
- Required libraries (OpenGL, etc.)
- Git, curl, and other utilities
- System cleanup and optimization

### `qt-creator.sh`
Installs Qt Creator IDE and configures it for out-of-the-box usage.

### `qt-desktop-kits.sh`
Installs Qt 5 and Qt 6 desktop build kits with all necessary components.

## Extending for Hardware Kits

To add hardware-specific build kits in the future:

1. Create `provisioning/qt-hardware-kits.sh` with kit installation logic
2. Add a corresponding `install_hardware_kits` provisioner step in `packer.pkr.hcl`
3. Update this README with new kit information

The modular design ensures new kits can be added without affecting existing provisioning scripts.

## Output

The build process generates:
- **OVA File**: `mrs-sdk-qt-YYYYMMDD.ova` (where YYYYMMDD is the build date)
- **Build Artifacts**: Log files and intermediate files in the Packer output directory

## Troubleshooting

### Build Fails with "VirtualBox not found"
Ensure VirtualBox is installed and the `vboxmanage` command is accessible from your PATH.

### Out of Disk Space
The build requires ~80GB of temporary disk space. Check available space with `df -h`.

### Permission Denied on Provisioning Scripts
Packer handles script permissions automatically, but if issues occur, ensure scripts in `provisioning/` are readable.

### Slow Build Times
Build times vary based on system resources and internet speed. First builds typically take 30-60 minutes. Subsequent builds with cached resources may be faster.

## Support

For issues or questions about the VM image, please create an issue in the [MRS SDK Qt GitHub repository](https://github.com/mrs-electronics-inc/mrs-sdk-qt/issues).

## Future Work

- [ ] Hardware kit support (separate issue)
- [ ] Publish OVA files as GitHub releases for easy discovery
- [ ] Additional desktop environment options
- [ ] Automated testing of built images
