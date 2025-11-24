# Local toolchain helper.

# Set the expected Qt versions based on device target.
set(MRS_SDK_QT_EXPECTED_QT_VERSION_NEURALPLEX "6.8.0" CACHE STRING "Expected NeuralPlex Qt version" FORCE)
set(MRS_SDK_QT_EXPECTED_QT_VERSION_MCONN "5.15.0" CACHE STRING "Expected MConn Qt version" FORCE)
set(MRS_SDK_QT_EXPECTED_QT_VERSION_FUSION "5.15.0" CACHE STRING "Expected FUSION Qt version" FORCE)

# Set the necessary parameters.
set(MRS_SDK_QT_TARGET_OS "Local" CACHE STRING "Target OS identifier" FORCE)
set(MRS_SDK_QT_OS_LOCAL TRUE CACHE BOOL "Target OS is local" FORCE)
set(MRS_SDK_QT_OS_YOCTO FALSE CACHE BOOL "Target OS is Yocto" FORCE)
set(MRS_SDK_QT_OS_BUILDROOT FALSE CACHE BOOL "Target OS is Buildroot" FORCE)

# Local builds target the host system.
set(CMAKE_CROSSCOMPILING FALSE CACHE BOOL "Cross-compiling" FORCE)
