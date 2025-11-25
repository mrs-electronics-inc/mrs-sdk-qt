#!/bin/bash

# Qt Desktop Kits Installation Script for MRS SDK Qt VM
# This script installs Qt 5 and Qt 6 desktop build kits with all necessary components.

set -e  # Exit on error

echo "================================"
echo "Qt Desktop Kits Installation"
echo "================================"

# Install Qt 5 from official Ubuntu repositories
echo "Installing Qt 5 desktop kit..."
sudo apt-get update
sudo apt-get install -y \
    qt5-qmake \
    qt5-default \
    qtbase5-dev \
    qtbase5-dev-tools \
    qttools5-dev \
    qttools5-dev-tools \
    qtdeclarative5-dev \
    libqt5opengl5-dev \
    libqt5svg5-dev \
    libqt5sql5 \
    libqt5network5 \
    libqt5serialport5-dev \
    libqt5websockets5-dev

echo "✓ Qt 5 desktop kit installed"

# Install Qt 6 from the official Qt apt repository
# Using the Qt apt repository provides stable, pre-built packages
echo "Installing Qt 6 desktop kit..."

# Add Qt official repository
echo "Adding Qt official repository..."
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y ppa:beineri/opt-qt-6.7.0-focal 2>/dev/null || true

# Update package list
sudo apt-get update

# Install Qt 6 using apt from the repository
sudo apt-get install -y \
    qt67-meta-full \
    qt67-dev \
    qt67-doc \
    qt67-examples

# Set up environment variables for Qt 6
echo "Configuring Qt 6 environment..."
QT6_ENV_FILE="/etc/profile.d/qt6-env.sh"
cat | sudo tee "$QT6_ENV_FILE" > /dev/null <<'EOF'
# Qt 6 environment setup
export PATH="/opt/qt6/bin:$PATH"
export LD_LIBRARY_PATH="/opt/qt6/lib:$LD_LIBRARY_PATH"
export QT_QPA_PLATFORM_PLUGIN_PATH="/opt/qt6/plugins"

# Alternative: If using apt-installed Qt 6
if [ -d "/opt/qt67" ]; then
    export PATH="/opt/qt67/bin:$PATH"
    export LD_LIBRARY_PATH="/opt/qt67/lib:$LD_LIBRARY_PATH"
fi
EOF

echo "✓ Qt 6 desktop kit installed"

# Verify installations
echo ""
echo "Verifying Qt installations..."

if command -v qmake &> /dev/null; then
    QT5_VERSION=$(qmake -v 2>&1 | grep "Qt version")
    echo "✓ Qt 5: $QT5_VERSION"
else
    echo "✗ Qt 5 qmake not found"
fi

# Qt Creator should be able to auto-detect all installed kits
echo "✓ Qt Creator will auto-detect all installed kits on first launch"

echo ""
echo "================================"
echo "Qt desktop kits setup complete!"
echo "================================"
echo ""
echo "Installed kits:"
echo "  - Qt 5 (via Ubuntu repositories)"
echo "  - Qt 6 (via Qt official repository)"
echo ""
echo "Qt Creator will automatically detect these kits."
echo "Launch Qt Creator with: qtcreator &"
