libs: tools
    mrs-sdk-manager build-local --install

tools: deps
    cd tools/mrs-sdk-manager && go install

deps:
    @command -v cmake >/dev/null || sudo apt install cmake
