#!/usr/bin/env bash

# Docker entrypoint script for Packer build orchestration
# This script runs inside the container and handles all validation and build steps

set -eo pipefail

source /usr/local/lib/logging.sh

# Export Packer variables from plain environment variables
# (Packer reads PKR_VAR_* prefixed environment variables)
export PKR_VAR_vm_memory="${VM_MEMORY}"
export PKR_VAR_vm_cpus="${VM_CPUS}"
export PKR_VAR_disk_size="${DISK_SIZE}"

# Collect all -var arguments passed to packer build
# Docker Compose will pass them as regular arguments if invoked properly
declare -a PACKER_VARS=()
for arg in "$@"; do
    PACKER_VARS+=("${arg}")
done

# Check required files exist
print_info "Checking project structure..."
for file in packer.pkr.hcl variables.pkr.hcl cloud-init/user-data cloud-init/meta-data scripts/autoprovision.sh scripts/provision.sh; do
    if [[ ! -f "${file}" ]]; then
        print_error "Required file not found: ${file}"
        exit 1
    fi
done
print_success "All required files found"

# Validate cloud-init YAML syntax
print_info "Validating cloud-init configuration..."
if ! yq eval '.' cloud-init/* >/dev/null 2>&1; then
    print_error "cloud-init config syntax is invalid"
    yq eval '.' cloud-init/*
    exit 1
fi
print_success "cloud-init config syntax is valid"

# Initialize packer plugins
print_info "Initializing Packer plugins..."
packer init .
print_success "Packer initialized"

# Validate Packer configuration
print_info "Validating Packer configuration..."
packer validate . >/dev/null
print_success "Packer config is valid"

# Exit early if validate-only mode
if [[ "${VALIDATE_ONLY:-false}" == "true" ]]; then
    print_success "Validation passed. Configuration is ready to build."
    exit 0
fi

# Build
echo ""
print_header "Building VM Image"
print_info "Build parameters:"
print_info "  VM Memory: ${VM_MEMORY} MB"
print_info "  VM CPUs: ${VM_CPUS}"
print_info "  Disk Size: ${DISK_SIZE} MB"
print_info "  Build Timeout: ${BUILD_TIMEOUT}"
print_info "  Additional settings: ${PACKER_VARS[*]}"
echo ""

print_info "Starting build..."
echo ""

declare BUILD_START
BUILD_START=$(date +%s)
readonly BUILD_START

# Filter out noisy SSH retry messages from Packer output
packer build -color=false "${PACKER_VARS[@]}" . 2>&1 \
    | grep -v -E "Attempting SSH connection to|reconnecting to TCP connection for SSH|handshaking with SSH|SSH handshake err: ssh: handshake failed"

declare BUILD_END
BUILD_END=$(date +%s)
readonly BUILD_END
readonly BUILD_DURATION=$((BUILD_END - BUILD_START))

print_header "Build Complete"

print_success "VM image built successfully"
print_info "Build time: $((BUILD_DURATION / 60)) minutes $((BUILD_DURATION % 60)) seconds"

# Find output images
if [[ -f "output/mrs-sdk-qt.img" ]]; then
    RAW_SIZE=$(du -h "output/mrs-sdk-qt.img" | cut -f1) || true
    print_success "Raw disk image: output/mrs-sdk-qt.img (${RAW_SIZE})"
fi

if [[ -f "output/mrs-sdk-qt.vmdk" ]]; then
    VMDK_SIZE=$(du -h "output/mrs-sdk-qt.vmdk" | cut -f1) || true
    print_success "VMDK image: output/mrs-sdk-qt.vmdk (${VMDK_SIZE})"
fi

echo ""
print_info "Default login: ubuntu / ubuntu"
print_info "For detailed instructions, see: vm/README.md"
