# Qt5 Yocto toolchain helper.
# NOTE: this helper is only meant to be used with the Qt5 Yocto kit for MConn/FUSION devices.
# Use the qt6-yocto.cmake helper for the NeuralPlex Qt6 kit.

# First, set CMake variables necessary for the Yocto-Qt toolchain.
# We have to start from the included toolchain file and then add some extra stuff that it doesn't do correctly.

# Make sure the toolchain file's location is in the environment.
# There is a setup script in the base of the toolchain that does this.
if (NOT DEFINED ENV{OE_CMAKE_TOOLCHAIN_FILE})
    message(FATAL_ERROR "Please run the Yocto toolchain setup script before configuring the SDK.")
    return()
endif()
# Run the kit's toolchain file.
include($ENV{OE_CMAKE_TOOLCHAIN_FILE})
# These flags don't get set properly, so we do it manually here.
set( CMAKE_C_FLAGS "$ENV{CFLAGS} -mfpu=neon -mfloat-abi=hard -mcpu=cortex-a9" CACHE STRING "" FORCE )
set( CMAKE_CXX_FLAGS "$ENV{CXXFLAGS} -mfpu=neon -mfloat-abi=hard -mcpu=cortex-a9"  CACHE STRING "" FORCE )
set( CMAKE_ASM_FLAGS ${CMAKE_C_FLAGS} CACHE STRING "" FORCE )
set( CMAKE_LDFLAGS_FLAGS ${CMAKE_CXX_FLAGS} CACHE STRING "" FORCE )
# If this isn't set, CMake will try to test the ARM compiler, which fails because the ARM compiler's output will be for ARM and not x86.
# Setting this variable is the solution added by CMake to skip this check when cross-compiling.
set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY" CACHE STRING "Skips cross-compiler checks" FORCE)
set(CMAKE_PREFIX_PATH "$ENV{OECORE_TARGET_SYSROOT}/usr" STRING FORCE)
# In Qt5 Yocto toolchains, this doesn't get parsed properly.
# The OE_QMAKE_PATH_EXTERNAL_HOST_BINS variable needs to be a CMake variable, but the toolchain only sets it as an env variable.
set(OE_QMAKE_PATH_EXTERNAL_HOST_BINS $ENV{OE_QMAKE_PATH_EXTERNAL_HOST_BINS} CACHE STRING "Path to external Qt binaries" FORCE)
# Useful debug output.
set(CMAKE_EXPORT_COMPILE_COMMANDS TRUE BOOL FORCE)

# Set the expected Qt versions based on device target.
set(MRS_SDK_QT_QT_MAJOR_VERSION "5" CACHE STRING "Required Qt toolchain major version" FORCE)
set(MRS_SDK_QT_EXPECTED_QT_VERSION_MCONN "5.12.9" CACHE STRING "Expected MConn Qt version" FORCE)
set(MRS_SDK_QT_EXPECTED_QT_VERSION_FUSION "5.12.9" CACHE STRING "Expected FUSION Qt version" FORCE)

# Set the OS identifier variables.
set(MRS_SDK_QT_TARGET_OS "Yocto" CACHE STRING "Target OS identifier" FORCE)
set(MRS_SDK_QT_OS_YOCTO TRUE CACHE BOOL "Target OS is Yocto" FORCE)
set(MRS_SDK_QT_OS_BUILDROOT FALSE CACHE BOOL "Target OS is Buildroot" FORCE)
set(MRS_SDK_QT_OS_DESKTOP FALSE CACHE BOOL "Target OS is desktop" FORCE)

# Yocto builds target ARM Cortex-A9 devices.
set(CMAKE_SYSTEM_NAME "Linux" CACHE STRING "Target OS" FORCE)
set(CMAKE_SYSTEM_PROCESSOR "arm" CACHE STRING "Target processor" FORCE)
set(CMAKE_CROSSCOMPILING TRUE CACHE BOOL "Cross-compiling" FORCE)
