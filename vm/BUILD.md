# Build VM Image Locally

If you don't want to use our pre-built VM image, you can build it yourself.

## Local Build

Be sure that you have [Packer](https://developer.hashicorp.com/packer/install) installed.

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
