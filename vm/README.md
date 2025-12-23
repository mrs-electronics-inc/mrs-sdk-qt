# MRS SDK Qt - Virtual Machine Image

We provide a pre-built VM image optimized for developing applications with `mrs-sdk-qt`.

## Overview

Ubuntu 24.04 LTS Server with GNOME Desktop and:

- Qt Creator IDE
- Qt 5 and Qt 6 development kits
- Build tools (gcc, g++, make)
- MRS Qt SDK

## Why Server ISO + ubuntu-desktop?

This image uses Ubuntu Server ISO with the `ubuntu-desktop` metapackage installed, rather than the Desktop ISO. Here's why:

- **Server ISO** uses Subiquity, which properly supports unattended autoinstall
- **Desktop ISO** uses a Flutter-based GUI installer that doesn't handle autoinstall well
- The end result is identical - both give you GNOME Desktop with the same applications
- Using Server allows us to fully automate the build process with no interactive prompts

## VM Image

### Download

Pre-built VM images are shared via OneDrive. To download an image, see [here](https://mrselectronics-my.sharepoint.com/:f:/g/personal/addison_emig_mrs-electronics_com/EmT5AxglIxBJnDWp7DWMYTgBqBoZhU_oodHmsWTj_M0EEQ?e=SBnOGw).

### Build

If you would like to build the VM image yourself, see the [build instructions](./BUILD.md).

## First Boot

After you have BLANK the VM image, create a new VM with it in your hypervisor of choice (VirtualBox, VMware, KVM, etc.).

The default username and password are `ubuntu`.

## Provisioning

After the VM boots, you will need to run the provisioning script to finish setting things up.

To run it:

```bash
./provision.sh
```

**Note:** The script installs:

- GNOME Desktop (ubuntu-desktop)
- Build tools (gcc, g++, make, git)
- Qt Creator IDE
- Qt 5.15.0 LTS and Qt 6.8.0 LTS via aqtinstall, with all their modules
- MRS Qt SDK

### Troubleshooting

If you see apt errors about invalid release files, run:

```bash
sudo timedatectl set-ntp true
sudo systemctl restart systemd-timesyncd
```

It should always be safe to try re-running the provisioning script if it exits with errors.

If re-running the provisioning script fails, try rebooting the VM and re-running the script.
