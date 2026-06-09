#!/usr/bin/env bash
# This script performs all the steps required for building and install the SDK from source.
# Usage: install_from_source.sh [all|tools|libs]

set -euo pipefail

SCRIPT_DIR="$(realpath "$(dirname "$0")")"
REPO_ROOT_DIR="$(realpath "$(git rev-parse --show-toplevel)")"

# Check environment.
check_env() {
	bash "$SCRIPT_DIR/check_local_env.sh"
	mkdir -p "$MRS_SDK_QT_ROOT"
}

# Install all tools from the tools/ directory.
install_tooling() {
	mkdir -p "$MRS_SDK_QT_ROOT/tools"
	echo "Installing tools..."
	TOOLS=(
		"mrs-sdk-manager"
	)
	for tool in "${TOOLS[@]}"; do
		(
			cd "$REPO_ROOT_DIR/tools/$tool"
			go build -o "$MRS_SDK_QT_ROOT/tools/$tool"
			echo "Installed $tool"
		)
	done
	echo "Add the following to your shell profile (.bashrc, .zshrc, etc.):"
	echo "  export PATH=\"\$PATH:$MRS_SDK_QT_ROOT/tools\""
}

# Build and install SDK libraries using mrs-sdk-manager.
install_libs() {
	local -r mgr="$MRS_SDK_QT_ROOT/tools/mrs-sdk-manager"
	command -v "$mgr" >/dev/null || {
		echo "ERROR: could not find mrs-sdk-manager at $mgr." >&2
		return 1
	}

	"$mgr" build-local libs --install
}

# Install source code for the demo apps.
# This is useful for allowing customers to verify kit setups and test out hardware.
install_demos() {
	local -r mgr="$MRS_SDK_QT_ROOT/tools/mrs-sdk-manager"
	command -v "$mgr" >/dev/null || {
		echo "ERROR: could not find mrs-sdk-manager at $mgr." >&2
		return 1
	}

	"$mgr" build-local demos --install
}

# Parse out the installation target.
target="all"
if [[ "$#" -gt 0 ]]; then
	target="$1"
fi

case "$target" in
	"all")
	    check_env
		# Install tooling first because it is used for installing libs.
		install_tooling
		install_libs
		install_demos
		;;
	"tools")
		check_env
		install_tooling
		;;
	"libs")
		check_env
		install_libs
		;;
	"demos")
		check_env
		install_demos
		;;
	"--help")
		echo "Usage: $0 [all|tools|libs]"
		;;
	*)
		echo "Usage: $0 [all|tools|libs]" >&2
		exit 1
		;;
esac
