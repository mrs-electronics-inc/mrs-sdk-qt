---
title: VM Setup Guide
description: Get started with the ready-to-use MRS SDK Qt virtual machine image
---

The MRS SDK Qt project provides a ready-to-use virtual machine image with Qt Creator and pre-configured Qt 5 and Qt 6 desktop build kits. This guide walks you through obtaining, importing, and using the VM.

## Quick Start

1. **Download** the VMDK image
2. **Import** it into your virtualization platform
3. **Launch** and start developing

## Obtaining the VM Image

### Option 1: Download from GitHub Actions

Recent builds are available as artifacts from the [vm-build workflow](https://github.com/mrs-electronics-inc/mrs-sdk-qt/actions/workflows/vm-build.yml):

1. Open the most recent successful build
2. Download the `mrs-sdk-qt-vm-images` artifact
3. Extract the `mrs-sdk-qt.vmdk` file and follow the import instructions below

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

For detailed build instructions, see the [VM README](../../vm/README.md).

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

## Verifying the Installation

Once logged in, verify all components are properly installed:

### Check Qt Creator

```bash
qtcreator --version
```

### Check Qt 5 and Qt 6

```bash
qt5-qmake --version
qt6-qmake --version
```

### Launch Qt Creator

```bash
qtcreator &
```

In Qt Creator, go to **Help** → **About Qt Creator** → **Registered Kits** to see the detected Qt kits.

## Using the VM

### Starting Qt Creator

Open a terminal and run:

```bash
qtcreator &
```

Or select it from the applications menu.

### Creating a New Project

1. Launch Qt Creator
2. File → **New Project** → Select your desired project type
3. Qt Creator will display available build kits (Qt 5 and Qt 6)
4. Choose your target kit and proceed

### Included Build Kits

- **Qt 5** - Stable, widely-compatible desktop framework
- **Qt 6** - Latest Qt version with modern features

### System Tools

The VM includes common development tools:
- GCC compiler and build-essential toolkit
- Git version control
- SSH client/server
- Curl and Wget

### File Transfer

Transfer files using SSH:
```bash
scp file ubuntu@<vm-ip>:/path/to/destination
```

Get the VM's IP address:
```bash
ip addr show
```

## Network Access

The VM is configured with NAT networking by default. To access services running on the VM from the host:

1. Configure port forwarding in your virtualization platform
2. Or switch to Bridged mode for direct network access

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

For advanced users who want to understand or modify the VM build process, see the [VM README](../../vm/README.md).

The Packer configuration in the `vm/` directory is fully open-source and can be customized to add additional software or hardware kits.

## Next Steps

- [Installation Guide](/guides/installation) - Set up the SDK from the VM
- [Getting Started](/docs) - Start developing with Qt
