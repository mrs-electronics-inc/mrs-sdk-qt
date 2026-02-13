# List all recipes, including in subdirs
default:
    @echo "Top-level recipes:"
    @JUST_LIST_HEADING="" just --list
    @echo "Tools recipes:"
    @cd tools/ && JUST_LIST_HEADING="" just --list --list-prefix "    tools/"
    @echo "VM recipes:"
    @cd vm/ && JUST_LIST_HEADING="" just --list --list-prefix "    vm/"
    @echo "Docs recipes:"
    @cd docs/ && JUST_LIST_HEADING="" just --list --list-prefix "    docs/"

format-cpp *args:
    ./tools/format-cpp.sh {{ args }}

format-go *args:
    ./tools/format-go.sh {{ args }}

lint-go *args:
    ./tools/lint-go.sh {{ args }}

# Install a locally built version of the SDK, including tooling
install:
    mkdir -p $HOME/mrs-sdk-qt
    just tools/install
    mrs-sdk-manager build-local --install

# Uninstall the SDK
uninstall:
    rm -rf "$MRS_SDK_QT_ROOT"

# Create a fresh local SDK installation
dev: uninstall install

# Set up the local dev environment
setup:
    #!/usr/bin/env bash
    echo "Installing pre-commit hooks..."
    pre-commit install
    echo "Installing dev dependencies..."
    # This uses the APT package manager, which means it only works on Debian-based systems.
    command -v cmake >/dev/null || sudo apt install cmake
