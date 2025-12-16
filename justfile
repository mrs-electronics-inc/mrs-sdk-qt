libs: tools
    mrs-sdk-manager build-local --install

tools: deps
    cd tools/mrs-sdk-manager && go install

# This uses the APT package manager, which means it only works on Debian-based systems.
deps:
    @command -v cmake >/dev/null || sudo apt install cmake
