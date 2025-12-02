# Qt5 desktop toolchain helper.

# Set the expected Qt versions based on device target.
set(MRS_SDK_QT_QT_MAJOR_VERSION "5" CACHE STRING "Required Qt toolchain major version" FORCE)
set(MRS_SDK_QT_EXPECTED_QT_VERSION_MCONN "5.15.0" CACHE STRING "Expected MConn Qt version" FORCE)
set(MRS_SDK_QT_EXPECTED_QT_VERSION_FUSION "5.15.0" CACHE STRING "Expected FUSION Qt version" FORCE)

# Set the necessary parameters.
set(MRS_SDK_QT_TARGET_OS "Desktop" CACHE STRING "Target OS identifier" FORCE)
set(MRS_SDK_QT_OS_DESKTOP TRUE CACHE BOOL "Target OS is desktop" FORCE)
set(MRS_SDK_QT_OS_YOCTO FALSE CACHE BOOL "Target OS is Yocto" FORCE)
set(MRS_SDK_QT_OS_BUILDROOT FALSE CACHE BOOL "Target OS is Buildroot" FORCE)

# Desktop builds target the host system.
set(CMAKE_CROSSCOMPILING FALSE CACHE BOOL "Cross-compiling" FORCE)
