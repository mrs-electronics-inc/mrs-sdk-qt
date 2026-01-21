FROM hashicorp/packer:full-1.14.3

# Add necessary QEMU utilities.
# The packer:full image already has packer-plugin-qemu, but we need these packages
# for creating the VMDK-formatted output at the end of the build.
RUN apk add --no-cache qemu-system-x86_64 qemu-img
