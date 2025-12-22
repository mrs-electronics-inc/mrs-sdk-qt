# MRS SDK Qt - Virtual Machine Image

Packer configuration for building a VM image with Qt Creator and desktop build kits.

## Overview

Ubuntu 24.04 LTS Server with GNOME Desktop and:

- Qt Creator IDE
- Qt 5 and Qt 6 development kits
- Build tools (gcc, g++, make)
- VMDK output format (compatible with VirtualBox, VMware, and KVM/libvirt)

## Why Server ISO + ubuntu-desktop?

This image uses Ubuntu Server ISO with the `ubuntu-desktop` metapackage installed, rather than the Desktop ISO. Here's why:

- **Server ISO** uses Subiquity, which properly supports unattended autoinstall
- **Desktop ISO** uses a Flutter-based GUI installer that doesn't handle autoinstall well
- The end result is identical - both give you GNOME Desktop with the same applications
- Using Server allows us to fully automate the build process with no interactive prompts

## Building

### Local Build

```bash
cd vm
./scripts/build-vm.sh
```

**Note:** Close unnecessary applications before building. The VM installation runs faster and VNC monitoring stays responsive when your system has available resources.

### Monitoring Build Output

During the build, monitor the serial console output to see what's happening:

```bash
# In another terminal:
tail -f vm/output/vm-serial.log
```

This captures all QEMU serial output including Ubuntu installation logs, cloud-init provisioning, and any errors that occur during the build. The log file is written to in real-time, so you can watch the installation progress without relying on VNC or SSH.

See [examples/successful-build-serial.log](examples/successful-build-serial.log) for an example of a successful build's serial output.

## First Boot & Provisioning

After the VM image is built, boot it in your hypervisor of choice (VirtualBox, VMware, KVM, etc.).

The VM includes a provisioning script at `~/provision.sh` that installs the Qt development environment. To run it:

```bash
./provision.sh
```

**Note:** The script installs:

- GNOME Desktop (ubuntu-desktop)
- Build tools (gcc, g++, make, git)
- Qt Creator IDE
- Qt 5.15.0 LTS and Qt 6.8.0 LTS via aqtinstall
- MRS SDK Qt repository

**Before running provisioning:** Ensure the system clock is synchronized. If you see apt errors about invalid release files, run:

```bash
sudo timedatectl set-ntp true
sudo systemctl restart systemd-timesyncd
```

### Distribution

Pre-built VM images are shared via OneDrive. To download an image, go [here](https://mrselectronics-my.sharepoint.com/:f:/g/personal/addison_emig_mrs-electronics_com/EmT5AxglIxBJnDWp7DWMYTgBqBoZhU_oodHmsWTj_M0EEQ?e=SBnOGw).

## Configuration

Default VM settings:

- Memory: 6144 MB (6 GB)
- CPUs: 2
- Disk: 60 GB

Customize with script options:

```bash
./scripts/build-vm.sh -m 8192 -c 4
```

## Output

Three artifacts are automatically generated in the `output/` directory:

1. **VMDK** (`mrs-sdk-qt.vmdk`) - For VirtualBox, VMware, GNOME Boxes
2. **Raw** (`mrs-sdk-qt.img`) - For KVM, libvirt, QEMU
3. **Manifest** (`manifest.json`) - Build metadata and artifact information
