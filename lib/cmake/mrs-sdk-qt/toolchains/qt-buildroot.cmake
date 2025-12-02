# Buildroot toolchain helper.

# Set the expected Qt versions based on device target.
set(MRS_SDK_QT_QT_MAJOR_VERSION "5" CACHE STRING "Required Qt toolchain major version" FORCE)
set(MRS_SDK_QT_EXPECTED_QT_VERSION_MCONN "5.9.1" CACHE STRING "Expected MConn Qt version" FORCE)
set(MRS_SDK_QT_EXPECTED_QT_VERSION_FUSION "5.9.1" CACHE STRING "Expected FUSION Qt version" FORCE)

# Set the OS identifier variables.
set(MRS_SDK_QT_TARGET_OS "Buildroot" CACHE STRING "Target OS identifier" FORCE)
set(MRS_SDK_QT_OS_BUILDROOT TRUE CACHE BOOL "Target OS is Buildroot" FORCE)
set(MRS_SDK_QT_OS_YOCTO FALSE CACHE BOOL "Target OS is Yocto" FORCE)
set(MRS_SDK_QT_OS_DESKTOP FALSE CACHE BOOL "Target OS is desktop" FORCE)

# Buildroot builds target ARM Cortex-A9 devices.
set(CMAKE_SYSTEM_NAME "Linux" CACHE STRING "Target OS" FORCE)
set(CMAKE_SYSTEM_PROCESSOR "arm" CACHE STRING "Target processor" FORCE)
set(CMAKE_CROSSCOMPILING TRUE CACHE BOOL "Cross-compiling" FORCE)
