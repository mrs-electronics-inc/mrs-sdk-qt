---
title: VM Setup Guide
description: Get started with the ready-to-use MRS SDK Qt virtual machine image
---

The MRS SDK Qt project provides a ready-to-use virtual machine image with Qt Creator and pre-configured Qt desktop build kits. This guide walks you through obtaining, importing, and using the VM.

## Quick Start

1. **Download** the OVA image
2. **Import** it into your virtualization platform
3. **Launch** and start developing

## Obtaining the VM Image

### Option 1: Download from GitHub Releases

Pre-built OVA images are available on the [GitHub Releases page](https://github.com/mrs-electronics-inc/mrs-sdk-qt/releases).

1. Navigate to the latest release
2. Download the `mrs-sdk-qt-*.ova` file
3. Follow the import instructions below

### Option 2: Download from GitHub Actions

Recent builds are available as artifacts from the [vm-build workflow](https://github.com/mrs-electronics-inc/mrs-sdk-qt/actions/workflows/vm-build.yml):

1. Open the most recent successful build
2. Download the `mrs-sdk-qt-ova` artifact
3. Extract and follow the import instructions

### Option 3: Build Locally

To build the VM image on your machine:

**Prerequisites:**
- [Packer](https://www.packer.io/downloads) (>= v1.8.0)
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- 80GB free disk space
- 4+ GB available RAM

**Build steps:**

```bash
cd vm
packer init .
packer build .
```

The OVA file will be created in the `output/` directory.

For detailed build instructions, see the [VM README](/repo/vm/README.md).

## Importing the VM

### VirtualBox

1. Open VirtualBox
2. Go to **File** → **Import Appliance**
3. Select the `mrs-sdk-qt-*.ova` file
4. Configure settings (memory, CPU, disk allocation)
   - Recommended: 4GB RAM, 2 CPUs, 60GB disk
5. Click **Import**
6. Once complete, select the VM and click **Start**

### VMware

1. Open VMware (Workstation, Fusion, or Player)
2. Go to **File** → **Open**
3. Select the `mrs-sdk-qt-*.ova` file
4. Follow the import wizard
5. Adjust resource allocation as desired
6. Start the VM

### GNOME Boxes

1. Open GNOME Boxes
2. Click the **+** button to create a new machine
3. Select **Import from file**
4. Choose the `mrs-sdk-qt-*.ova` file
5. Configure VM settings
6. Click **Create** and start

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

### Check Qt 5

```bash
qmake -v
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
- GCC/Clang compilers
- CMake and Ninja build systems
- Git version control
- GDB debugger
- SSH client/server
- Python 3 and development headers

### File Transfer

Transfer files to/from the host system:

**VirtualBox:**
- Use **Shared Folders** (Devices → Shared Folders)
- Or use SSH: `scp file ubuntu@<vm-ip>:/path/to/destination`

**VMware:**
- Drag and drop (if supported)
- Or use SSH file transfer

**GNOME Boxes:**
- Use SSH file transfer

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

Create VM snapshots before making significant changes:

**VirtualBox:**
- Machine → **Take Snapshot**
- Restore from Snapshots menu

**VMware:**
- VM → **Snapshot** → **Take Snapshot**

**GNOME Boxes:**
- Right-click VM → **Take a screenshot** (limited functionality)

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

- Ensure VM has adequate RAM allocated (4GB minimum)
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

For advanced users who want to understand or modify the VM build process, see the [VM README](/repo/vm/README.md).

The Packer configuration in `/vm` is fully open-source and can be customized to add additional software or hardware kits.

## Next Steps

- [Installation Guide](/guides/installation) - Set up the SDK from the VM
- [Getting Started](/docs) - Start developing with Qt
