#!/usr/bin/env bash

# MRS SDK Qt VM Build Helper Script
# This script automates local building of the VM image using Packer in Docker.

set -eo pipefail

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Functions
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}| $1${NC}"
}

show_usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Build the MRS SDK Qt virtual machine image using Packer in Docker.

Options:
    -h, --help              Show this help message
    -m, --memory MB         VM RAM in MB (default: 6144)
    -c, --cpus CORES        VM CPU cores (default: 2)
    -s, --disk-size MB      Disk size in MB (default: 61440)
    --timeout MINUTES       Build timeout in minutes (default: 60 with KVM, 120 without)
    --var KEY=VALUE         Pass variable directly to Packer
    --validate-only         Only validate configuration (no build)
    --verbose               Enable Packer debug logging

Examples:
     # Default build
     $(basename "$0")

     # Build with custom memory and CPU
     $(basename "$0") -m 8192 -c 4

     # Use TCG emulation (slower, no KVM required)
     $(basename "$0") --var accelerator=tcg --timeout 240

     # Validate configuration only
     $(basename "$0") --validate-only
EOF
}

# Default values
export VM_MEMORY=6144
export VM_CPUS=2
export DISK_SIZE=61440
export PACKER_LOG=0
declare -a PACKER_VARS
VALIDATE_ONLY=false
USING_KVM=true
BUILD_TIMEOUT=""  # Empty means use default based on accelerator

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -m|--memory)
            export VM_MEMORY="$2"
            shift 2
            ;;
        -c|--cpus)
            export VM_CPUS="$2"
            shift 2
            ;;
        -s|--disk-size)
            export DISK_SIZE="$2"
            shift 2
            ;;
        --timeout)
            BUILD_TIMEOUT="$2"
            shift 2
            ;;
        --validate-only)
            VALIDATE_ONLY=true
            shift
            ;;
        --verbose)
            export PACKER_LOG=1
            shift
            ;;
        --var)
            PACKER_VARS+=(-var "$2")
            if [[ "$2" == accelerator=tcg ]]; then
                USING_KVM=false
            fi
            shift 2
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

print_header "MRS SDK Qt VM Build Helper"

# Check for Docker
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed or not in PATH"
    exit 1
fi
print_success "Docker found"

# Check for docker-compose
if ! docker compose version &> /dev/null; then
    print_error "Docker Compose is not available"
    exit 1
fi
print_success "Docker Compose found"

# Check for KVM access (warn if not available)
if ${USING_KVM} && [[ ! -w /dev/kvm ]]; then
    print_warning "/dev/kvm not writable. Build will be slow without KVM."
    print_info "Use --var accelerator=tcg to suppress this warning, or fix KVM access."
fi

# Set default timeout based on accelerator if not explicitly provided
if [[ -z "${BUILD_TIMEOUT}" ]]; then
    if ${USING_KVM}; then
        BUILD_TIMEOUT=60
    else
        BUILD_TIMEOUT=120
    fi
fi
PACKER_VARS+=(-var "build_timeout=${BUILD_TIMEOUT}m")

# Check required files exist
print_info "Checking project structure..."
for file in packer.pkr.hcl variables.pkr.hcl cloud-init/user-data cloud-init/meta-data scripts/autoprovision.sh scripts/provision.sh; do
    if [[ ! -f "${file}" ]]; then
        print_error "Required file not found: ${file}"
        exit 1
    fi
done
print_success "All required files found"

# Validate Packer configuration
print_info "Validating Packer configuration..."
docker compose run --rm packer validate .
print_success "Packer config is valid"

# Validate cloud-init YAML syntax
print_info "Validating cloud-init configuration..."
if command -v python3 &> /dev/null; then
    if ! python3 -c "import yaml; yaml.safe_load(open('cloud-init/user-data'))" 2>/dev/null; then
        print_error "cloud-init config syntax is invalid"
        python3 -c "import yaml; yaml.safe_load(open('cloud-init/user-data'))"
        exit 1
    fi
    print_success "cloud-init config syntax is valid"
else
    print_warning "python3 not found, skipping cloud-init validation"
fi

# Validate-only mode: exit after validation
if ${VALIDATE_ONLY}; then
	print_success "Validation passed. Configuration is ready to build."
    exit 0
fi

# Build
print_header "Building VM Image"

print_info "Build parameters:"
print_info "  VM Memory: ${VM_MEMORY} MB"
print_info "  VM CPUs: ${VM_CPUS}"
print_info "  Disk Size: ${DISK_SIZE} MB"
print_info "  Build Timeout: ${BUILD_TIMEOUT} minutes"
echo ""

# Initialize packer plugins
print_info "Initializing Packer plugins..."
docker compose run --rm packer init .
print_success "Packer initialized"

# Run build
print_info "Starting build..."
echo ""

declare BUILD_START
BUILD_START=$(date +%s)
readonly BUILD_START

# Filter out noisy SSH retry messages from Packer output
docker compose run --rm packer build -color=false -timestamp-ui "${PACKER_VARS[@]}" . 2>&1 \
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
