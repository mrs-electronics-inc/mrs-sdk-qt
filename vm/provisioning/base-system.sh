#!/bin/bash

# Base System Provisioning Script for MRS SDK Qt VM
# This script installs system-level dependencies and utilities required by Qt
# and development tools. It runs with sudo privileges.

set -eo pipefail

echo "================================"
echo "MRS SDK Qt - Base System Setup"
echo "================================"

# Update package manager
export DEBIAN_FRONTEND=noninteractive
echo "Updating package manager..."
sudo apt-get update
sudo apt-get upgrade -y

# Install essential build tools and development headers
echo "Installing build essentials..."
sudo apt-get install -y \
    build-essential \
    cmake \
    git \
    curl \
    wget \
    pkg-config \
    autoconf \
    automake \
    libtool \
    make \
    ninja-build

# Install libraries required by Qt
echo "Installing Qt dependencies..."
sudo apt-get install -y \
    libgl1-mesa-dev \
    libx11-dev \
    libx11-xcb-dev \
    libxext-dev \
    libxfixes-dev \
    libxi-dev \
    libxrender-dev \
    libxcb1-dev \
    libxcb-glx0-dev \
    libxcb-util-dev \
    libxkbcommon-dev \
    libxkbcommon-x11-dev \
    libdbus-1-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libharfbuzz-dev \
    libjpeg-dev \
    libpng-dev \
    libsqlite3-dev \
    libssl-dev \
    libz-dev \
    libicu-dev

# Install additional development tools
echo "Installing additional development tools..."
sudo apt-get install -y \
    openssh-client \
    openssh-server \
    nano \
    vim \
    less \
    man-db \
    gdb \
    valgrind \
    htop \
    tmux \
    unzip \
    p7zip-full

# Install Python and common utilities
echo "Installing Python and utilities..."
sudo apt-get install -y \
    python3 \
    python3-dev \
    python3-pip

# Install optional but useful tools
echo "Installing optional development tools..."
sudo apt-get install -y \
    clang \
    clang-format \
    lldb \
    doxygen \
    graphviz

# Enable SSH server for remote access
echo "Enabling SSH server..."
sudo systemctl enable ssh
sudo systemctl start ssh

# Create a user-friendly message of the day
echo "Creating welcome message..."
cat | sudo tee /etc/motd > /dev/null <<'EOF'
╔═══════════════════════════════════════════════════════════════╗
║                   MRS SDK Qt Development VM                   ║
║                                                               ║
║  Qt Creator and Desktop Build Kits (Qt 5 & Qt 6) installed.  ║
║                                                               ║
║  To launch Qt Creator:                                        ║
║    $ qtcreator &                                              ║
║                                                               ║
║  For more information, visit:                                 ║
║    https://qt.mrs-electronics.dev                             ║
╚═══════════════════════════════════════════════════════════════╝
EOF

# Clean up package manager cache to save space
echo "Cleaning up package manager cache..."
sudo apt-get autoremove -y
sudo apt-get autoclean -y
sudo apt-get clean -y

echo ""
echo "================================"
echo "Base system setup complete!"
echo "================================"
