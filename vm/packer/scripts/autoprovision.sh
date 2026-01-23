#!/usr/bin/env bash
# This script sets up the VM for Qt and MRS SDK installations.
# We avoid installing Qt in this script because of the size of the Qt libraries...
# Adding them to the VM image doubles the final image size.
# It's better to just have the user install those on first boot.

set -e

echo "Starting MRS SDK Qt auto-provisioning..."

# Create Qt installation directory with ubuntu ownership
echo "Creating Qt installation directory..."
readonly QT_PATH="/opt/Qt"
echo 'ubuntu' | sudo -S mkdir -p "${QT_PATH}"
echo 'ubuntu' | sudo -S chown ubuntu:ubuntu "${QT_PATH}"

# Clone the mrs-sdk-qt repository
echo "Cloning mrs-sdk-qt repository..."
mkdir -p ~/repos
if [[ -d ~/repos/mrs-sdk-qt ]]; then
    echo "Repository already exists, pulling latest..."
    git -C ~/repos/mrs-sdk-qt pull
else
    git clone https://github.com/mrs-electronics-inc/mrs-sdk-qt ~/repos/mrs-sdk-qt
fi

echo "Auto-provisioning complete!"
