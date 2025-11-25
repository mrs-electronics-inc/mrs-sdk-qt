#!/bin/bash

# MRS SDK Qt VM Build Helper Script
# This script automates local building of the VM image using Packer.
# It handles dependency checks and provides helpful output.

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'  # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VM_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$VM_DIR")"

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
    echo -e "${BLUE}ℹ $1${NC}"
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        print_error "$1 is not installed or not in PATH"
        return 1
    fi
    print_success "$1 found"
    return 0
}

check_directory() {
    if [ ! -d "$1" ]; then
        print_error "Directory not found: $1"
        return 1
    fi
    print_success "Directory found: $1"
    return 0
}

check_file() {
    if [ ! -f "$1" ]; then
        print_error "File not found: $1"
        return 1
    fi
    print_success "File found: $1"
    return 0
}

show_usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Build the MRS SDK Qt virtual machine image using Packer.

Options:
    -h, --help              Show this help message
    -m, --memory MB         VM RAM in MB (default: 4096)
    -c, --cpus CORES        VM CPU cores (default: 2)
    -s, --disk-size MB      Disk size in MB (default: 61440)
    --headless              Run VirtualBox in headless mode (default: true)
    --gui                   Show VirtualBox GUI during build
    --validate-only         Only validate Packer configuration
    --format-only           Only format Packer configuration
    --debug                 Enable Packer debug output

Examples:
    # Default build with auto-generated date
    $(basename "$0")

    # Build with custom memory and CPU
    $(basename "$0") -m 8192 -c 4

    # Build with specific date
    $(basename "$0") -d 20250125

    # Validate configuration only
    $(basename "$0") --validate-only
EOF
}

# Parse command line arguments
PACKER_VARS=""
PACKER_DEBUG=""
VALIDATE_ONLY=false
FORMAT_ONLY=false
HEADLESS="true"
NON_INTERACTIVE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -m|--memory)
            PACKER_VARS="$PACKER_VARS -var \"vm_memory=$2\""
            shift 2
            ;;
        -c|--cpus)
            PACKER_VARS="$PACKER_VARS -var \"vm_cpus=$2\""
            shift 2
            ;;
        -s|--disk-size)
            PACKER_VARS="$PACKER_VARS -var \"disk_size=$2\""
            shift 2
            ;;
        --headless)
            HEADLESS="true"
            shift
            ;;
        --gui)
            HEADLESS="false"
            shift
            ;;
        --validate-only)
            VALIDATE_ONLY=true
            shift
            ;;
        --format-only)
            FORMAT_ONLY=true
            shift
            ;;
        --debug)
            PACKER_DEBUG="-debug"
            shift
            ;;
        --non-interactive)
            NON_INTERACTIVE=true
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

print_header "MRS SDK Qt VM Build Helper"

# Check prerequisites
print_info "Checking prerequisites..."

MISSING_DEPS=false

if ! check_command "packer"; then
    print_error "Packer not found. Install from: https://www.packer.io/downloads"
    MISSING_DEPS=true
else
    PACKER_VERSION=$(packer version | head -n1)
    print_info "Packer version: $PACKER_VERSION"
fi

if ! check_command "vboxmanage"; then
    print_error "VirtualBox not found. Install from: https://www.virtualbox.org/wiki/Downloads"
    MISSING_DEPS=true
fi

if [ "$MISSING_DEPS" = true ]; then
    print_error "Missing required dependencies. Cannot proceed."
    exit 1
fi

# Check project structure
print_info "Checking project structure..."

if ! check_directory "$VM_DIR"; then
    exit 1
fi

if ! check_file "$VM_DIR/packer.pkr.hcl"; then
    exit 1
fi

if ! check_file "$VM_DIR/variables.pkr.hcl"; then
    exit 1
fi

if ! check_file "$VM_DIR/provisioning/base-system.sh"; then
    exit 1
fi

if ! check_file "$VM_DIR/provisioning/qt-creator.sh"; then
    exit 1
fi

if ! check_file "$VM_DIR/provisioning/qt-desktop-kits.sh"; then
    exit 1
fi

print_success "All required files found"

# Change to VM directory
cd "$VM_DIR"

# Initialize Packer plugins if needed
if [ ! -d ".packer.d" ] && [ ! -f ".packer-manifest.json" ]; then
    print_info "Initializing Packer plugins..."
    packer init . || {
        print_error "Packer initialization failed"
        exit 1
    }
    print_success "Packer initialized"
fi

# Format check
if [ "$FORMAT_ONLY" = true ]; then
    print_info "Checking Packer HCL format..."
    packer fmt -check . && print_success "Format check passed" || print_error "Format check failed"
    exit $?
fi

# Validate configuration
print_info "Validating Packer configuration..."
if ! packer validate . > /dev/null; then
    print_error "Packer validation failed"
    packer validate .
    exit 1
fi
print_success "Configuration validated"

if [ "$VALIDATE_ONLY" = true ]; then
    print_success "Validation passed. Configuration is ready to build."
    exit 0
fi

# Format before building
print_info "Formatting Packer configuration..."
packer fmt . > /dev/null
print_success "Configuration formatted"

# Build
print_header "Building VM Image"

print_info "Build parameters:"
print_info "  VM Memory: 4096 MB (use -m to override)"
print_info "  VM CPUs: 2 (use -c to override)"
print_info "  Disk Size: 61440 MB / 60GB (use -s to override)"
print_info "  Headless: $HEADLESS"
echo ""

print_warning "This build will take 30-60 minutes depending on your system."
print_warning "A stable internet connection is required."
echo ""

if [ "$NON_INTERACTIVE" = false ]; then
    read -p "Continue with build? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Build cancelled by user"
        exit 0
    fi
else
    print_info "Running in non-interactive mode - starting build..."
fi

# Enable/disable headless mode in Packer
if [ "$HEADLESS" = "false" ]; then
    # Temporarily modify packer config to show GUI
    print_info "Running VirtualBox in GUI mode"
else
    print_info "Running VirtualBox in headless mode"
fi

# Run Packer build
BUILD_START=$(date +%s)

eval "packer build \
    -color=false \
    -timestamp-ui \
    $PACKER_DEBUG \
    $PACKER_VARS \
    ." || {
    print_error "Build failed"
    exit 1
}

BUILD_END=$(date +%s)
BUILD_DURATION=$((BUILD_END - BUILD_START))

print_header "Build Complete"

print_success "VM image built successfully"
print_info "Build time: $((BUILD_DURATION / 60)) minutes $((BUILD_DURATION % 60)) seconds"

# Find output OVA
OVA_FILE=$(find output -name "*.ova" -type f 2>/dev/null | head -1)

if [ -n "$OVA_FILE" ]; then
    OVA_SIZE=$(du -h "$OVA_FILE" | cut -f1)
    print_success "OVA file created: $OVA_FILE ($OVA_SIZE)"
else
    print_warning "OVA file not found in output directory"
fi

print_info ""
print_info "Next steps:"
print_info "1. Download the OVA file from the output directory"
print_info "2. Import it into VirtualBox, VMware, or GNOME Boxes"
print_info "3. Start the VM and log in (ubuntu/ubuntu)"
print_info ""
print_info "For detailed instructions, see: docs/src/content/docs/guides/vm-setup.md"
