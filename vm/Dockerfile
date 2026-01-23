# Stage 1: Extract packer from the official image
FROM hashicorp/packer:light-1.14.3 AS packer-base

# Stage 2: Build our image with packer + tools
FROM alpine:latest

# Copy packer binary from the official image
COPY --from=packer-base /bin/packer /usr/local/bin/packer

# Install QEMU utilities (qemu-img for VMDK conversion) and yq (for cloud-init validation)
RUN apk add --no-cache \
    # QEMU utilities needed for VMDK conversion
    qemu-system-x86_64 \
    qemu-img \
    # Used for validating YAML in cloud-init config
    yq \
    # Used to run the builder script
    bash

# Copy shared logging utilities
COPY utils/logging.sh /usr/local/lib/logging.sh
