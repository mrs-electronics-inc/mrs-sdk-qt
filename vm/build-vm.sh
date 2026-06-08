#!/usr/bin/env bash

# MRS SDK Qt VM Build Helper Script
# This script automates local building of the VM image using Packer in Docker.
# All validation and build steps run inside the container for maximum portability.

set -eo pipefail

source ./utils/logging.sh

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

     # Use TCG emulation (much slower, no KVM required)
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
export VALIDATE_ONLY=false
declare -a PACKER_VARS
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
            export VALIDATE_ONLY=true
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

print_header "MRS SDK Qt VM Builder"

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
    print_warning "/dev/kvm not writable. Build will be very slow without KVM."
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
export BUILD_TIMEOUT="${BUILD_TIMEOUT}m"

# Make sure all old build artifacts are removed before starting a new build.
# Packer will flag this on its own, but the error message is a bit hard to understand,
# so this check makes it more obvious to the user what needs to happen.
if [[ -d "packer/output" ]]; then
	print_error "Please remove outdated build artifacts before starting a new build."
	print_info "Run 'sudo rm -rf packer/output' or 'moon run vm:clean' to clean out artifacts."
	exit 1
fi

# Run build or validation via Docker entrypoint
# Pass PACKER_VARS as arguments only if not in validate-only mode
if ${VALIDATE_ONLY}; then
    docker compose run --build --rm packer-validate
else
    docker compose run --build --rm packer "${PACKER_VARS[@]}"
fi
