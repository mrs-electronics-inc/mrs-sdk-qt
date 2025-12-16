# Qt5 Buildroot toolchain helper.

# Set the expected Qt versions based on device target.
MRS_SDK_QT_QT_MAJOR_VERSION = 5
MRS_SDK_QT_EXPECTED_QT_VERSION_MCONN = 5.9.1
MRS_SDK_QT_EXPECTED_QT_VERSION_FUSION = 5.9.1

# Set the OS identifier variables.
MRS_SDK_QT_TARGET_OS = Buildroot
MRS_SDK_QT_OS_BUILDROOT = TRUE
MRS_SDK_QT_OS_YOCTO = FALSE
MRS_SDK_QT_OS_DESKTOP = FALSE

# Buildroot builds target ARM Cortex-A9 devices.
MRS_SDK_QT_SYSTEM_NAME = Linux
MRS_SDK_QT_SYSTEM_PROCESSOR = arm
MRS_SDK_QT_CROSSCOMPILING = TRUE
