# The `mrs-sdk-qt` Library

Here are the steps for compiling and installing the library.

NOTE: You will need to have Qt5/Qt6 installed before you can compile.

1. Open the CMake project in Qt Creator.
2. Compile the project.
3. Install the SDK in the following structure:

```
HOME/mrs-sdk-qt/
├── bin/            # Top-level tools: version/installation manager, anything else that's not version-specific
|   └── mrs-sdk-manager
├── current/        # Symlink to the SDK version currently in use
└── <version>/      # A specific installed version of the SDK, including all libraries, headers, documentation, and other files necessary for use
    ├── bin/
    ├── docs/
    ├── demos/
    ├── include/
    └── lib/
        ├── cmake/                  # CMake configuration files for setting up toolchains and SDK libraries
        |   └── mrs-sdk-qt/
        |       ├── toolchains/
        |       └── config.cmake
        ├── qmake/                  # QMake configuration files for setting up toolchains and SDK libraries
        |   └── mrs-sdk-qt/
        |       └── config.pri
        ├── qt5/
        │   ├── buildroot/
        │   │   ├── linux_arm_mconn/
        │   │   │   └── libmrs-sdk-qt.a
        │   │   └── linux_arm_fusion/
        │   │       └── libmrs-sdk-qt.a
        │   ├── yocto/
        │   │   └── linux_arm_mconn/
        │   │       └── libmrs-sdk-qt.a
        │   └── desktop/
        │       └── linux_x86_64_desktop/
        │           └── libmrs-sdk-qt.a
        └── qt6/
            ├── yocto/
            │   ├── linux_arm_neuralplex/
            │   │   └── libmrs-sdk-qt.a
            └── desktop/
                └── linux_x86_64_desktop/
                    └── libmrs-sdk-qt.a
```

At some point we will create a better system for auto-install but we don't have one yet.

## Kit-aware configuration

The SDK exports a few helper files under `lib/cmake/mrs-sdk-qt/toolchains` for bootstrapping CMake with the right Qt kit:

- `qt5-buildroot.cmake`: points to Qt 5.9.1 inside the Buildroot sysroot and marks the target as `buildroot`.
- `qt5-yocto.cmake`: points to Qt 5.12.9 from the Yocto SDK and marks the kit as `yocto`.
- `qt5-desktop.cmake`: uses a desktop Qt 5.15.0 installation and identifies itself as the `desktop` kit.
- `qt6-desktop.cmake`: uses a desktop Qt 6.8.0 installation and identifies itself as the `desktop` kit.

Each helper sets cache variables used in `config.cmake` to compute a consistent kit identity. When configuring the SDK, pass the helper via `-DCMAKE_TOOLCHAIN_FILE=lib/cmake/mrs-sdk-qt/toolchains/qt5-yocto.cmake` (or the Buildroot/desktop equivalent) so that the right Qt paths and ARM flags are applied. This is best done from the Qt kit configuration.

### QMake

The SDK also exports QMake configuration files under `lib/qmake/mrs-sdk-qt/toolchains` for projects using QMake:

- `qt5-buildroot.pri`: points to Qt 5.9.1 inside the Buildroot sysroot and marks the target as `buildroot`.
- `qt5-yocto.pri`: points to Qt 5.12.9 from the Yocto SDK and marks the kit as `yocto`.
- `qt5-desktop.pri`: uses a desktop Qt 5.15.0 installation and identifies itself as the `desktop` kit.
- `qt6-desktop.pri`: uses a desktop Qt 6.8.0 installation and identifies itself as the `desktop` kit.

Each helper sets QMake variables used in `config.pri` to compute a consistent kit identity. Include the appropriate toolchain file in your QMake project before including `config.pri`:

```qmake
include($${MRS_SDK_QT_ROOT}/lib/qmake/mrs-sdk-qt/toolchains/qt5-yocto.pri)
include($${MRS_SDK_QT_ROOT}/lib/qmake/mrs-sdk-qt/config.pri)
```

This ensures the right Qt paths and ARM flags are applied for your target kit.

### Shared Compile Definitions

When an application links against the SDK (via either CMake or QMake), it also inherits kit metadata from the shared definitions. Those compile definitions include:

- `MRS_SDK_QT_QT_VERSION`: the Qt release used for the current target.
- `MRS_SDK_QT_TARGET_DEVICE`: the MRS device that runs the current target. One of `NeuralPlex`, `MConn`, or `FUSION`.
  - There are boolean flags defined for each of these: `MRS_SDK_QT_DEVICE_NEURALPLEX`, `MRS_SDK_QT_DEVICE_MCONN`, and `MRS_SDK_QT_DEVICE_FUSION`
- `MRS_SDK_QT_TARGET_OS`: the OS that will run the current target. One of `Yocto`, `Buildroot`, or `Desktop`.
  - There are boolean flags defined for each of these: `MRS_SDK_QT_OS_YOCTO`, `MRS_SDK_QT_OS_BUILDROOT`, and `MRS_SDK_QT_OS_DESKTOP`.
- `MRS_SDK_QT_IS_ARM`: `1` when an ARM toolchain is detected.
- `MRS_SDK_QT_IS_CROSSCOMPILING`: `1` when cross-compiling is detected.

Use these macros like any other compile definition (`#if MRS_SDK_QT_OS_BUILDROOT`) or rely on `MRS_SDK_QT_IS_ARM` when you only care about the processor family. This keeps your downstream projects in sync with the Qt kit actually being used for the SDK build.
