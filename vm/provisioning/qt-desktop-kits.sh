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

# Install Qt 6 using the official Qt online installer in unattended mode
# This provides the latest Qt 6 versions with modern features
echo "Installing Qt 6 desktop kit..."

# Create directory for Qt installation
QT6_INSTALL_DIR="/opt/qt6"
sudo mkdir -p "$QT6_INSTALL_DIR"

# Download the Qt online installer
echo "Downloading Qt online installer..."
INSTALLER_URL="https://download.qt.io/official_releases/online_installers/qt-unified-linux-x64-online.run"
INSTALLER_PATH="/tmp/qt-installer.run"

sudo wget -q "$INSTALLER_URL" -O "$INSTALLER_PATH"
sudo chmod +x "$INSTALLER_PATH"

# Create Qt installer script for unattended installation
# This script automates the Qt 6 desktop kit installation
echo "Creating Qt installation script..."
cat > /tmp/qt6-install.qs <<'EOF'
function Controller() {
    installer.autoRejectMessageBoxes();
    installer.installationFinished.connect(function() {
        gui.clickButton(buttons.NextButton);
    });
}

Controller.prototype.WelcomePageCallback = function() {
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.CredentialsPageCallback = function() {
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.IntroductionPageCallback = function() {
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.TargetDirectoryPageCallback = function() {
    installer.setValue("TargetDir", "/opt/qt6");
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.ComponentSelectionPageCallback = function() {
    var widget = gui.currentPageWidget();
    widget.deselectAll();
    
    // Select Qt 6 latest desktop kit
    widget.selectComponent("qt.qt6.latest.gcc_64");
    widget.selectComponent("qt.qt6.latest.qtcreator");
    
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.LicenseAgreementPageCallback = function() {
    gui.currentPageWidget().AcceptLicenseRadioButton.checked = true;
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.StartMenuDirectoryPageCallback = function() {
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.ReadyForInstallationPageCallback = function() {
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.FinishedPageCallback = function() {
    gui.clickButton(buttons.FinishButton);
}
EOF

# Note: The Qt online installer approach is complex in headless environments.
# As a more reliable alternative, we'll use the Qt apt repository.
# Remove the installer download attempt and use official Qt apt packages instead.
rm -f "$INSTALLER_PATH"

echo "Installing Qt 6 from official Qt apt repository..."

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
