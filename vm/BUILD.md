# Build VM Image Locally

If you don't want to use our pre-built VM image, you can build it yourself.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) with Docker Compose
- KVM access (optional but recommended for faster builds)

To check KVM access:

```bash
ls -la /dev/kvm
```

If you don't have KVM (e.g., in CI or on macOS), the build will use TCG emulation, which is significantly slower.

## Build

```bash
cd vm
./build-vm.sh --verbose
```

The script will:

1. Build a Docker image with Packer and QEMU
2. Validate the Packer and cloud-init configuration
3. Run the VM build inside a container
4. Convert the output to VMDK format

**Note:** Close unnecessary applications before building. The VM installation runs faster when your system has available resources.

## Monitoring Build Progress

You can monitor the serial console output during the build to see what's happening. Run the following in separate terminal:

```bash
tail -f vm/output/vm-serial.log
```

This captures all QEMU serial output including Ubuntu installation logs, cloud-init provisioning, and any errors. See [examples/successful-build-serial.log](examples/successful-build-serial.log) for an example.

## Configuration

Default VM settings:

| Setting | Default | Description |
|---------|---------|-------------|
| Memory  | 6144 MB | RAM allocated during build |
| CPUs    | 2       | CPU cores for the VM |
| Disk    | 60 GB   | Virtual disk size |

Customize with script options:

```bash
# More RAM and CPUs for faster builds
./build-vm.sh -m 8192 -c 4

# Larger disk
./build-vm.sh -s 122880

# Use TCG emulation (no KVM required, slower)
./build-vm.sh --var accelerator=tcg

# Validate configuration without building
./build-vm.sh --validate-only

# Enable verbose Packer logging
./build-vm.sh --verbose
```

## Output

Three artifacts are generated in the `output/` directory:

| File | Format | Use Case |
|------|--------|----------|
| `mrs-sdk-qt.vmdk` | VMDK | VirtualBox, VMware, GNOME Boxes, virt-manager |
| `mrs-sdk-qt.img` | Raw | KVM, libvirt, QEMU |
| `manifest.json` | JSON | Build metadata and checksums |

The serial console log is also saved to `output/vm-serial.log`.
