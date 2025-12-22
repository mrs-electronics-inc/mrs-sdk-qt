## mrs-sdk-manager

This page has some useful info about the `mrs-sdk-manager` tool, which is still a work in progress.

The purpose of the tool is to automate, as much as possible, the process of managing different versions and installations of the SDK.

### `build-local` subcommand

Compiles the SDK libraries from source for all device/OS targets. The built static libraries will be located in `build/<target>/artifacts`.

> NOTE: only `Debug` mode builds are created. We do not yet support `Release` builds because the point of building from source should mostly be for debug purposes.

**Assumptions:**

- Desktop Qt 5.15.0 and 6.8.0 installations must be located in `$HOME/Qt` (the default location Qt puts things in)
- Qt 5.12.9 toolchain for Yocto must be installed at `/home/cpa/yocto-5.12.9`
- Qt 5.9.1 toolchain for Buildroot must be installed at `/home/cpa/buildroot`
- `cmake` tool is already installed

You can override these hardcoded paths by creating symlinks from the corresponding paths in your filesystem.

#### `--install` flag

Passing the `--install` flag will automatically create an installation tree in `$HOME/mrs-sdk-qt/0.0.0`. This "development" installation can be used in projects by running `mrs-sdk-manager setup 0.0.0`.

### `setup` subcommand

Writes the global configuration files that tell consumer projects which version of the SDK to use.

**Assumptions:**

- MRS SDK is [installed](#install-flag) at `$HOME/mrs-sdk-qt`
- Specified version exists at `$HOME/mrs-sdk-qt/<version>`
