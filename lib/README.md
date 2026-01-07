# The `mrs-sdk-qt` Library

The `mrs-sdk-qt` library is the centerpiece of the Qt SDK.

This table lists some important documentation pages for getting started:

| Topic | Link |
| --- | --- |
| Installation | https://qt.mrs-electronics.dev/get-started/install/ |
| Build from source | https://qt.mrs-electronics.dev/get-started/build-from-source/ |
| Installation tree | https://qt.mrs-electronics.dev/reference/installation-tree/ |
| SDK components | https://qt.mrs-electronics.dev/reference/sdk-components/ |
| Configuring a project | https://qt.mrs-electronics.dev/get-started/configure-project/ |

### Shared Compile Definitions

When an application links against the SDK (via either CMake or QMake), it also inherits kit metadata from the shared definitions. Those compile definitions include:

- `MRS_SDK_QT_QT_MAJOR_VERSION`: the major version of Qt (5 or 6) used for the current target.
- `MRS_SDK_QT_QT_VERSION`: the full Qt release version used for the current target.
- `MRS_SDK_QT_TARGET_DEVICE`: the MRS device that runs the current target. One of `NeuralPlex`, `MConn`, or `FUSION`.
  - There are boolean flags defined for each of these: `MRS_SDK_QT_DEVICE_NEURALPLEX`, `MRS_SDK_QT_DEVICE_MCONN`, and `MRS_SDK_QT_DEVICE_FUSION`
- `MRS_SDK_QT_TARGET_OS`: the OS that will run the current target. One of `Yocto`, `Buildroot`, or `Desktop`.
  - There are boolean flags defined for each of these: `MRS_SDK_QT_OS_YOCTO`, `MRS_SDK_QT_OS_BUILDROOT`, and `MRS_SDK_QT_OS_DESKTOP`.
- `MRS_SDK_QT_IS_ARM`: `1` when an ARM toolchain is detected.
- `MRS_SDK_QT_IS_CROSSCOMPILING`: `1` when cross-compiling is detected.

Use these macros like any other compile definition (`#if MRS_SDK_QT_OS_BUILDROOT`) or rely on `MRS_SDK_QT_IS_ARM` when you only care about the processor family. This keeps your downstream projects in sync with the Qt kit actually being used for the SDK build.
