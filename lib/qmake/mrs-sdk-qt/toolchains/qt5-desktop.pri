# Qt5 desktop toolchain helper.

# Set the expected Qt versions based on device target.
MRS_SDK_QT_QT_MAJOR_VERSION = 5
MRS_SDK_QT_EXPECTED_QT_VERSION_DESKTOP = 5.15.0

# Set the necessary parameters.
MRS_SDK_QT_TARGET_DEVICE = Desktop
MRS_SDK_QT_TARGET_OS = Desktop
MRS_SDK_QT_OS_DESKTOP = TRUE
MRS_SDK_QT_OS_YOCTO = FALSE
MRS_SDK_QT_OS_BUILDROOT = FALSE

# Desktop builds target the host system.
MRS_SDK_QT_SYSTEM_NAME = Linux
MRS_SDK_QT_SYSTEM_PROCESSOR = x86_64
MRS_SDK_QT_CROSSCOMPILING = FALSE
