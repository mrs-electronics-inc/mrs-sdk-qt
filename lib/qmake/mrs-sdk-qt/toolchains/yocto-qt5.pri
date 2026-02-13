# Qt5 Yocto toolchain helper.
# NOTE: this helper is only meant to be used with the Qt5 Yocto kit for MConn devices.
# Use the yocto-qt6.pri helper for the NeuralPlex Qt6 kit.

# Automatically source the Yocto toolchain setup script if the environment is not already set up.
# Auto-sourcing is not typically recommended, but it is desirable for our use case because
# we don't want to put extra burden on less experienced users.
OE_CMAKE_TOOLCHAIN_FILE = $$(OE_CMAKE_TOOLCHAIN_FILE)
isEmpty(OE_CMAKE_TOOLCHAIN_FILE) {
    message("Yocto environment not found. Auto-sourcing environment...")

    YOCTO_QT5_ENV_SETUP_SCRIPT = $$system($$MRS_SDK_QT_ROOT/tools/mrs-sdk-manager env YOCTO_QT5_ENV_SETUP_SCRIPT)
    isEmpty(YOCTO_QT5_ENV_SETUP_SCRIPT) {
        error("Could not determine Yocto setup script path. Set it with: mrs-sdk-manager env -w YOCTO_QT5_ENV_SETUP_SCRIPT=/path/to/setup-script")
    }
    # Source the setup script and extract required variables.
    OECORE_TARGET_SYSROOT = $$system(. "$$YOCTO_QT5_ENV_SETUP_SCRIPT" && printf "%s" "$OECORE_TARGET_SYSROOT")
    OE_QMAKE_PATH_EXTERNAL_HOST_BINS = $$system(. "$$YOCTO_QT5_ENV_SETUP_SCRIPT" && printf "%s" "$OE_QMAKE_PATH_EXTERNAL_HOST_BINS")
}
# Set compiler flags for ARM Cortex-A9.
QMAKE_CFLAGS += -mfpu=neon -mfloat-abi=hard -mcpu=cortex-a9
QMAKE_CXXFLAGS += -mfpu=neon -mfloat-abi=hard -mcpu=cortex-a9
QMAKE_LFLAGS += -mfpu=neon -mfloat-abi=hard -mcpu=cortex-a9

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
