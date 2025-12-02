# Qt5 Yocto toolchain helper.
# NOTE: this helper is only meant to be used with the Qt5 Yocto kit for MConn/FUSION devices.
# Use the qt6-yocto.pri helper for the NeuralPlex Qt6 kit.

# Make sure the toolchain environment is set up.
# There is a setup script in the base of the toolchain that does this.
isEmpty(OE_CMAKE_TOOLCHAIN_FILE) {
    error("Please run the Yocto toolchain setup script before configuring the SDK.")
}

# Set the expected Qt versions based on device target.
MRS_SDK_QT_QT_MAJOR_VERSION = 5
MRS_SDK_QT_EXPECTED_QT_VERSION_MCONN = 5.12.9
MRS_SDK_QT_EXPECTED_QT_VERSION_FUSION = 5.12.9

# Set the OS identifier variables.
MRS_SDK_QT_TARGET_OS = Yocto
MRS_SDK_QT_OS_YOCTO = TRUE
MRS_SDK_QT_OS_BUILDROOT = FALSE
MRS_SDK_QT_OS_DESKTOP = FALSE

# Yocto builds target ARM Cortex-A9 devices.
MRS_SDK_QT_SYSTEM_NAME = Linux
MRS_SDK_QT_SYSTEM_PROCESSOR = arm
MRS_SDK_QT_CROSSCOMPILING = TRUE

# Set compiler flags for ARM Cortex-A9.
QMAKE_CFLAGS += -mfpu=neon -mfloat-abi=hard -mcpu=cortex-a9
QMAKE_CXXFLAGS += -mfpu=neon -mfloat-abi=hard -mcpu=cortex-a9
QMAKE_LFLAGS += -mfpu=neon -mfloat-abi=hard -mcpu=cortex-a9

# Export compile commands for debugging.
CONFIG += debug_and_release
