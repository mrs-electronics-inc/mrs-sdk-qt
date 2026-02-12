## mrs-sdk-manager

This page has some useful info about the `mrs-sdk-manager` tool, which is still a work in progress.

The purpose of the tool is to automate, as much as possible, the process of managing different versions and installations of the SDK.

### `build-local` subcommand

Compiles the SDK libraries from source for all device/OS targets. The built static libraries will be located in `build/<target>/artifacts`.

> NOTE: only `Debug` mode builds are created. We do not yet support `Release` builds because the point of building from source should mostly be for debug purposes.

**Prerequisites:**

- Compiler and toolchain paths must be configured via `mrs-sdk-manager env -w` before building
- `cmake` tool is already installed

#### `--install` flag

Passing the `--install` flag will automatically create an installation tree in `$HOME/mrs-sdk-qt/0.0.0`. This "development" installation can be used in projects by running `mrs-sdk-manager use 0.0.0`.

### `env` subcommand

View or modify the MRS SDK environment configuration, similar to `go env`. Configuration is stored at `$HOME/.config/mrs-sdk-qt/env`.

- `mrs-sdk-manager env` — print all configuration values
- `mrs-sdk-manager env <key>` — print a single value
- `mrs-sdk-manager env -w KEY=VALUE ...` — write one or more values

### `use` subcommand

Pin a specific SDK version for the current project. Generates project-local helper files (`mrs-sdk-qt.cmake` and/or `mrs-sdk-qt.pri`) that set the version and include the SDK configuration.

**Assumptions:**

- MRS SDK is installed at `$HOME/mrs-sdk-qt`
- Specified version exists at `$HOME/mrs-sdk-qt/<version>`
- Current directory contains a `CMakeLists.txt` and/or `.pro` file
