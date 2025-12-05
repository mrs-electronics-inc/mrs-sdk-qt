## mrs-sdk-manager

This page has some useful info about the `mrs-sdk-manager` tool, which is still a work in progress.

### `setup` subcommand

This subcommand makes the following assumptions:

- MRS SDK is installed at `$HOME/mrs-sdk-qt`

### `build-local` subcommand

Right now, this subcommand makes some assumptions that may not be true of your environment setup. It also does not perform all of the requisite checks that it should, such as checking that `cmake` is actually installed.

Eventually these concerns will be addressed, but for now your setup must meet the following preconditions:

- Desktop Qt 5.15.0 and 6.8.0 installations must be located in `$HOME/Qt` (the default location Qt puts things in)
- Qt 5.12.9 toolchain for Yocto must be installed at `/home/cpa/yocto-5.12.9`
- Qt 5.9.1 toolchain for Buildroot must be installed at `/home/cpa/buildroot`

Also note that this subcommand only creates `Debug` builds. It does not do `Release` builds yet.
