default:
    @just --list

format-cpp *args:
    ./tools/format-cpp.sh {{ args }}

format-go *args:
    ./tools/format-go.sh {{ args }}

lint-go *args:
    ./tools/lint-go.sh {{ args }}

libs: tools
    mrs-sdk-manager build-local --install

# You may have to do some manual setup to get the Go bin directory in your path for using mrs-sdk-manager.
# Here is a basic sample BASH command to add to your .bashrc:
# [[ -n "$(go env GOPATH)" ]] && PATH="$(go env GOPATH)/bin:$PATH"
tools: deps
    go -C tools/mrs-sdk-manager install

# This uses the APT package manager, which means it only works on Debian-based systems.
deps:
	@command -v cmake >/dev/null || sudo apt install cmake

# Run docs locally at http://localhost:4321
docs:
	npm -C docs run dev

# Build the VM image locally using Packer in Docker
vm-build *args:
	cd vm/ && ./build-vm.sh {{ args }}

# Validate Packer config
vm-validate:
    cd vm/ && ./build-vm.sh --validate-only

# Watch the QEMU serial output during a local VM build
vm-serial:
    [ -f vm/output/vm-serial.log ] && tail -f vm/output/vm-serial.log
