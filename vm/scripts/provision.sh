#!/bin/bash
set -e

echo "Starting MRS SDK Qt provisioning..."

# Suppress interactive prompts from needrestart
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

# Install development tools and dependencies
echo "Installing development tools..."
sudo apt-get update
sudo apt-get install -y --no-install-recommends ubuntu-desktop

# Install aqtinstall for Qt LTS versions
echo "Installing aqtinstall..."
pipx install aqtinstall

# Install Qt 5.15.0 LTS
echo "Installing Qt 5.15.0 LTS..."
~/.local/bin/aqt install-qt linux desktop 5.15.0 -m all

# Install Qt 6.8.0 LTS
echo "Installing Qt 6.8.0 LTS..."
~/.local/bin/aqt install-qt linux desktop 6.8.0 -m all

# Clean up apt cache
echo "Cleaning up..."
sudo apt-get autoremove -y
sudo apt-get autoclean -y
sudo apt-get clean -y

# Clone the mrs-sdk-qt repository
mkdir -p ~/repos
echo "Cloning mrs-sdk-qt repository..."
if [ -d ~/repos/mrs-sdk-qt ]; then
    echo "Repository already exists, pulling latest..."
    git -C ~/repos/mrs-sdk-qt pull
else
    git clone https://github.com/mrs-electronics-inc/mrs-sdk-qt ~/repos/mrs-sdk-qt
fi

# TODO: actually install the SDK

echo "Provisioning complete!"
