#!/bin/bash

# Qt Creator Installation Script for MRS SDK Qt VM
# This script installs Qt Creator IDE and configures it for out-of-the-box usage.

set -e  # Exit on error

echo "================================"
echo "Qt Creator Installation"
echo "================================"

# Install Qt Creator from official Ubuntu repositories
# This provides a stable, pre-compiled version
echo "Installing Qt Creator..."
sudo apt-get update
sudo apt-get install -y qtcreator

# Qt Creator should now be available as 'qtcreator' command
# Verify installation
echo "Verifying Qt Creator installation..."
if command -v qtcreator &> /dev/null; then
    QTCREATOR_VERSION=$(qtcreator --version 2>&1 | head -n1)
    echo "✓ Qt Creator installed successfully: $QTCREATOR_VERSION"
else
    echo "✗ Qt Creator installation verification failed!"
    exit 1
fi

# Create default Qt Creator configuration directory
echo "Setting up Qt Creator configuration..."
TARGET_USER="${SUDO_USER:-$USER}"
QT_CONFIG_DIR="$(eval echo ~$TARGET_USER)/.config/QtProject"
mkdir -p "$QT_CONFIG_DIR"
mkdir -p "$QT_CONFIG_DIR"

# Qt Creator will auto-detect available kits after we install them
# Additional configuration can be done here if needed

echo ""
echo "================================"
echo "Qt Creator setup complete!"
echo "================================"
