#!/bin/bash
set -e

echo "Starting MRS SDK Qt provisioning..."

# Install development tools and dependencies
echo "Installing development tools..."
sudo apt-get update
sudo apt-get install -y ubuntu-desktop
sudo apt-get install -y build-essential qtcreator python3-pip pipx git

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
mkdir ~/repos
echo "Cloning mrs-sdk-qt repository..."
git clone https://github.com/mrs-electronics-inc/mrs-sdk-qt ~/repos/mrs-sdk-qt

echo "Provisioning complete!"
