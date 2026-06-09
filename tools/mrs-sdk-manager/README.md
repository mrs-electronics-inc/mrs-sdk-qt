## mrs-sdk-manager

This page has some useful info about the `mrs-sdk-manager` tool, which is still a work in progress.

The purpose of the tool is to automate, as much as possible, the process of managing different versions and installations of the SDK.

### `build-local` subcommand

Compiles the SDK libraries from source for all device/OS targets. The built static libraries will be located in `build/<target>/artifacts`.

The command accepts an optional positional target selector:

- `mrs-sdk-manager build-local` or `mrs-sdk-manager build-local all` — build SDK libraries
- `mrs-sdk-manager build-local libs` — build SDK libraries only
- `mrs-sdk-manager build-local demos` — does nothing without `--install`

> NOTE: only `Debug` mode builds are created. We do not yet support `Release` builds because the point of building from source should mostly be for debug purposes.

**Prerequisites:**

- Compiler and toolchain paths must be configured via `mrs-sdk-manager env -w` before building
- `cmake` tool is already installed

#### `--install` flag

Passing the `--install` flag will automatically create an installation tree in `$MRS_SDK_QT_ROOT/<latest-git-tag>`, where `<latest-git-tag>` comes from `git describe --tags --abbrev=0`. If the repository does not have any tags yet, the install falls back to `$MRS_SDK_QT_ROOT/0.0.0`. This installation can be used like any other by running `mrs-sdk-manager use <latest-git-tag>`.

The flag respects the target selector:

- Passing `all` will install libraries and demos
- Passing `libs` will install only libraries
- Passing `demos` will install only demos

### `env` subcommand

View or modify the MRS SDK environment configuration, similar to `go env`. Configuration is stored at `$HOME/.config/mrs-sdk-qt/env`.

- `mrs-sdk-manager env` — print all configuration values
- `mrs-sdk-manager env <key>` — print a single value
- `mrs-sdk-manager env -w KEY=VALUE ...` — write one or more values

### `use` subcommand

Pin a specific SDK version for the current project. Generates project-local helper files for configuring the Qt toolchain, pinning an SDK version, and configuring the SDK.

**Assumptions:**

- MRS SDK is installed at `$MRS_SDK_QT_ROOT`
- Specified version exists at `$MRS_SDK_QT_ROOT/<version>`
- Current directory contains a `CMakeLists.txt` and/or `.pro` file
