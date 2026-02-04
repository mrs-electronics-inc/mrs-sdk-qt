default:
    @just --list

format-cpp *args:
    ./tools/format-cpp.sh {{ args }}

format-go *args:
    ./tools/format-go.sh {{ args }}

lint-go *args:
    ./tools/lint-go.sh {{ args }}

install-libs: install-tools
    mrs-sdk-manager build-local --install

# You may have to do some manual setup to get the Go bin directory in your path for using mrs-sdk-manager.
# Here is a basic sample BASH command to add to your .bashrc:
# [[ -n "$(go env GOPATH)" ]] && PATH="$(go env GOPATH)/bin:$PATH"
install-tools: deps
    go -C tools/mrs-sdk-manager install

docs-dev:
    cd docs && npm run dev

# This uses the APT package manager, which means it only works on Debian-based systems.
deps:
	@command -v cmake >/dev/null || sudo apt install cmake

# Run docs locally at http://localhost:4321
docs:
	npm -C docs run dev
