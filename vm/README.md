# MRS SDK Qt - Virtual Machine Image

Packer configuration for building a VM image with Qt Creator and desktop build kits.

## Overview

Ubuntu 24.04 LTS Server with GNOME Desktop and:
- Qt Creator IDE
- Qt 5 development kit
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

### CI/CD

GitHub Actions automatically builds on:
- Push to main branch
- Tagged releases

Artifacts uploaded as workflow artifacts.

## Configuration

Default VM settings:
- Memory: 4096 MB
- CPUs: 2
- Disk: 60 GB

Customize with script options:
```bash
./scripts/build-vm.sh -m 8192 -c 4
```

## Output

Two formats are automatically generated in the `output/` directory:

1. **VMDK** (`mrs-sdk-qt.vmdk`) - For VirtualBox, VMware, GNOME Boxes
2. **Raw** (`packer-qemu`) - For KVM, libvirt, QEMU

### Using with VirtualBox

Import the VMDK file:
```bash
# GUI: File → Import Appliance → select mrs-sdk-qt.vmdk
# Or CLI:
VBoxManage createvm --name mrs-sdk-qt --ostype Ubuntu_64 --register
VBoxManage createmedium disk --filename output/mrs-sdk-qt.vmdk --format VMDK
VBoxManage storageattach mrs-sdk-qt --storagectl SATA --port 0 --device 0 --type hdd --medium output/mrs-sdk-qt.vmdk
```

### Using with GNOME Boxes

1. Open GNOME Boxes
2. Click "+" → "Create Virtual Machine"
3. Select "Import local disk image" and choose the VMDK file

### Using with KVM/libvirt

Use the raw disk image:
```bash
# Launch virt-manager
virt-manager &

# Or create a new domain via CLI
virt-install --name mrs-sdk-qt \
  --memory 4096 --vcpus 2 \
  --disk path=output/packer-qemu,format=raw \
  --graphics spice \
  --import
```
