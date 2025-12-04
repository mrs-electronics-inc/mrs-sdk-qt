---
title: Virtual Machine Setup
description: Get started with the ready-to-use MRS SDK Qt virtual machine image
---

The MRS SDK Qt project provides a ready-to-use virtual machine image with Qt Creator and pre-configured build kits. This guide walks you through obtaining, importing, and using the VM.

## Quick Start

1. **Download** the VMDK image
2. **Import** it into your virtualization platform
3. **Launch** and start developing

## Obtaining the VM Image

### Option 1: Download from OneDrive

Pre-built VM images are available for download:

1. Visit the [MRS SDK Qt VM Images OneDrive folder](https://mrselectronics-my.sharepoint.com/:f:/g/personal/addison_emig_mrs-electronics_com/EmT5AxglIxBJnDWp7DWMYTgBqBoZhU_oodHmsWTj_M0EEQ?e=SBnOGw)
2. Download the latest `mrs-sdk-qt.vmdk` file
3. Follow the [import instructions](#importing-the-vm) below

### Option 2: Build Locally

To build the VM image on your machine:

**Prerequisites:**

- [Packer](https://www.packer.io/downloads) (>= v1.8.0)
- [QEMU](https://www.qemu.org/) (and KVM for local acceleration)
- 80GB free disk space
- 6+ GB available RAM

**Build steps:**

```bash
cd vm
./scripts/build-vm.sh
```

The VMDK file will be created in the `output/` directory.

For detailed build instructions, see the [VM README](https://github.com/mrs-electronics-inc/mrs-sdk-qt/tree/main/docs/vm/README.md).

## Importing the VM

Import the VMDK file using your preferred virtualization platform (VirtualBox, VMware, GNOME Boxes, etc.):

1. Open your virtualization software
2. Import the `mrs-sdk-qt.vmdk` file
3. Configure settings (recommended: 6GB RAM, 2 CPUs, 60GB disk)
4. Start the VM

## First Login

**Default Credentials:**

- **Username:** `ubuntu`
- **Password:** `ubuntu`

**Security Recommendation:** Change the password on first login.

```bash
passwd
```

## Using the VM

The MRS SDK Qt repository is pre-cloned in your home directory at `~/mrs-sdk-qt/`. You can start developing immediately without needing to clone it.

### Starting Qt Creator

Select Qt Creator from the application menu or open a terminal and run:

```bash
qtcreator &
```

### Creating a New Project

1. Launch Qt Creator
2. **File** → **New Project** → Select your desired project type
3. Qt Creator will display available build kits
4. Choose your target kit and proceed

### Included Build Kits

- **Desktop Qt 5**
- **Desktop Qt 6**

### System Tools

The VM includes common development tools:

- GCC compiler and build-essential toolkit
- Git version control
- SSH client/server
- Curl and wget

## Customization

### Increasing VM Resources

If you need more processing power:

1. **Stop the VM**
2. In your virtualization platform's settings:
   - Increase allocated RAM
   - Increase CPU cores
   - Increase disk size (may require filesystem expansion)
3. **Restart the VM**

### Installing Additional Software

Use the standard Ubuntu package manager:

```bash
sudo apt-get update
sudo apt-get install <package-name>
```

### Installing Additional Qt Modules

Inside the VM, you can install additional Qt modules using apt:

```bash
# Search for Qt packages
apt-cache search qt5

# Install additional modules
sudo apt-get install qt5<module-name>
```

## Snapshots and Backups

Create VM snapshots before making significant changes using your virtualization platform's snapshot feature.

## Troubleshooting

### Qt Creator Won't Start

1. Verify installation:

   ```bash
   which qtcreator
   ```

2. Try launching with verbose output:

   ```bash
   qtcreator -d
   ```

3. Check system logs:
   ```bash
   journalctl -e
   ```

### Slow Performance

- Ensure VM has adequate RAM allocated (6GB recommended)
- Check host system resource availability
- Disable 3D acceleration if causing issues

### Network Issues

- Verify networking is enabled in VM settings
- Check network adapter status: `ip link show`
- Test connectivity: `ping google.com`

### Low Disk Space

Check available space:

```bash
df -h
```

If running low, you can clean up apt cache:

```bash
sudo apt-get clean
sudo apt-get autoclean
```

## Getting Help

- **Documentation:** https://qt.mrs-electronics.dev
- **Issues:** [GitHub Issues](https://github.com/mrs-electronics-inc/mrs-sdk-qt/issues)
- **Discussions:** [GitHub Discussions](https://github.com/mrs-electronics-inc/mrs-sdk-qt/discussions)
- **Contact:** info@mrs-electronics.com

## Building VM Images from Source

For advanced users who want to understand or modify the VM build process, see the [VM README](https://github.com/mrs-electronics-inc/mrs-sdk-qt/tree/main/docs/vm/README.md).
