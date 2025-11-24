# The `mrs-sdk-qt` Library

Here are the steps for compiling and installing the library.

NOTE: You will need to have Qt5 installed before you can compile.

1. Open the CMake project in Qt Creator.
2. Compile the project.
3. Install the SDK in the following structure:

```
HOME/
└── mrs-sdk-qt/
    ├── lib/                    # Compiled static library
    |   └── libmrs-sdk-qt.a
    ├── include/                # Header files
    |   └── Application.hpp
    └── builder/                # CMake and QMake configurations
        ├── mrs-sdk-qt.cmake
        └── mrs-sdk-qt.pri
```

At some point we will create a better system for auto-install but we don't have one yet.

## Kit-aware configuration

The SDK exports a few helper files under `lib/cmake/toolchains` for bootstrapping CMake with the right Qt kit:

- `qt-buildroot.cmake`: points to Qt 5.9.1 inside the Buildroot sysroot and marks the target as `buildroot`.
- `qt5-yocto.cmake`: points to Qt 5.12.9 from the Yocto SDK and marks the kit as `yocto`.
- `qt-local.cmake`: uses a desktop Qt 5.15.0 installation and identifies itself as the `local` kit.

Each helper sets cache variables used in `mrs-sdk-qt.cmake` to compute a consistent kit identity. When configuring the SDK, pass the helper via `-DCMAKE_TOOLCHAIN_FILE=lib/cmake/toolchains/qt-yocto.cmake` (or the Buildroot/local equivalent) so that the right Qt paths and ARM flags are applied. This is best done from the Qt kit configuration.

When an application links against the SDK, it also inherits kit metadata from the shared definitions appended by `mrs-sdk-qt.cmake`. Those compile definitions include:

- `MRS_SDK_QT_QT_VERSION`: the Qt release used for the current target.
- `MRS_SDK_QT_TARGET_DEVICE`: the MRS device that runs the current target. One of `NeuralPlex`, `MConn`, or `FUSION`.
  - There are boolean flags defined for each of these: `MRS_SDK_QT_DEVICE_NEURALPLEX`, `MRS_SDK_QT_DEVICE_MCONN`, and `MRS_SDK_QT_DEVICE_FUSION`
- `MRS_SDK_QT_TARGET_OS`: the OS that will run the current target. One of `Yocto`, `Buildroot`, or `local`.
  - There are boolean flags defined for each of these: `MRS_SDK_QT_OS_YOCTO`, `MRS_SDK_QT_OS_BUILDROOT`, and `MRS_SDK_QT_OS_LOCAL`.
- `MRS_SDK_QT_IS_ARM`: `1` when an ARM toolchain is detected.
- `MRS_SDK_QT_IS_CROSSCOMPILING`: `1` when CMake believes it is cross-compiling.

Use these macros like any other compile definition (`#if MRS_SDK_QT_OS_BUILDROOT`) or rely on `MRS_SDK_QT_IS_ARM` when you only care about the processor family. This keeps your downstream projects in sync with the Qt kit actually being used for the SDK build.
