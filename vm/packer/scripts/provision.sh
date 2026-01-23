#!/usr/bin/env bash
# This script automates the process of installing all of the required Qt toolchains for developing with the SDK.

set -e

echo "Starting MRS SDK Qt provisioning..."

# Install aqtinstall for downloading Qt LTS versions.
echo "Installing aqtinstall..."
pipx install aqtinstall

# Verify Qt installation directory
readonly QT_PATH="/opt/Qt"
echo "Verifying Qt installation directory ${QT_PATH}..."
if [[ ! -d "${QT_PATH}" ]]; then
	echo "${QT_PATH} does not exist."
	exit 1
fi
declare qt_path_owner
qt_path_owner="$(stat -c '%U:%G' "${QT_PATH}")"
readonly qt_path_owner
declare current_user current_group expected_owner
current_user="$(id -un)" || exit 1
current_group="$(id -gn)" || exit 1
expected_owner="${current_user}:${current_group}"
readonly expected_owner
if [[ "${qt_path_owner}" != "${expected_owner}" ]]; then
	echo "${QT_PATH} has invalid permissions."
	exit 1
fi

# Install Qt 5.15.0 LTS
echo "Installing Qt 5.15.0 LTS..."
~/.local/bin/aqt install-qt linux desktop 5.15.0 -m all -O "${QT_PATH}"

# Install Qt 6.8.0 LTS
echo "Installing Qt 6.8.0 LTS..."
~/.local/bin/aqt install-qt linux desktop 6.8.0 -m all -O "${QT_PATH}"

# TODO: install other necessary Qt toolchains

# TODO: actually install the MRS SDK

echo "Provisioning complete!"
