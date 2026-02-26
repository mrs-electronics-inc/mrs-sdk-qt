# Qt5 Yocto toolchain helper.
# NOTE: this helper is only meant to be used with the Qt5 Yocto kit for MConn/FUSION devices.
# Use the yocto-qt6.cmake helper for the NeuralPlex Qt6 kit.

# First, set CMake variables necessary for the Yocto-Qt toolchain.
# We have to start from the included toolchain file and then add some extra stuff that it doesn't do correctly.

# Automatically source the Yocto toolchain setup script using mrs-sdk-manager.
# Auto-sourcing is not typically recommended, but it is desirable for our use case because
# we don't want to put extra burden on less experienced users.
if (NOT DEFINED ENV{OE_CMAKE_TOOLCHAIN_FILE})
    message(NOTICE "Yocto environment not found. Auto-sourcing environment...")

    # Get the setup script path from mrs-sdk-manager.
    # Intentionally use the manager installed under MRS_SDK_QT_ROOT/tools:
    # this is the canonical SDK layout for both local installs and packaged SDK installs,
    # and avoids accidentally picking up a different manager binary from PATH.
    execute_process(
        COMMAND "${MRS_SDK_QT_ROOT}/tools/mrs-sdk-manager" "env" "YOCTO_QT5_ENV_SETUP_SCRIPT"
        OUTPUT_VARIABLE _yocto_qt5_env_setup_script
        OUTPUT_STRIP_TRAILING_WHITESPACE
        RESULT_VARIABLE _mrs_env_result
    )
    if (NOT _mrs_env_result EQUAL 0 OR _yocto_qt5_env_setup_script STREQUAL "")
        message(FATAL_ERROR
            "Could not determine Yocto setup script path.\n"
            "Set it with: mrs-sdk-manager env -w YOCTO_QT5_ENV_SETUP_SCRIPT=/path/to/setup-script"
        )
    endif()

    # Source the setup script in a subshell and capture the resulting environment.
    execute_process(
        COMMAND bash -c "source \"${_yocto_qt5_env_setup_script}\" && env"
        OUTPUT_VARIABLE _yocto_qt5_env_output
        RESULT_VARIABLE _yocto_qt5_env_source_result
    )
    if (NOT _yocto_qt5_env_source_result EQUAL 0)
        message(FATAL_ERROR "Failed to source Yocto setup script: ${_yocto_qt5_env_setup_script}")
    endif()

    # Parse and import only the required environment variables.
    string(REPLACE "\n" ";" _yocto_qt5_env_lines "${_yocto_qt5_env_output}")
    foreach(_LINE IN LISTS _yocto_qt5_env_lines)
        if (_LINE MATCHES "^(OE_CMAKE_TOOLCHAIN_FILE|OECORE_TARGET_SYSROOT|OE_QMAKE_PATH_EXTERNAL_HOST_BINS)=(.*)$")
            set(ENV{${CMAKE_MATCH_1}} "${CMAKE_MATCH_2}")
        endif()
    endforeach()

    # Make sure all of the necessary environment variables were defined.
    if (NOT DEFINED ENV{OE_CMAKE_TOOLCHAIN_FILE} OR "$ENV{OE_CMAKE_TOOLCHAIN_FILE}" STREQUAL "")
        message(FATAL_ERROR "Failed to read OE_CMAKE_TOOLCHAIN_FILE from Yocto setup script: ${_yocto_qt5_env_setup_script}")
    endif()
    if (NOT DEFINED ENV{OECORE_TARGET_SYSROOT} OR "$ENV{OECORE_TARGET_SYSROOT}" STREQUAL "")
        message(FATAL_ERROR "Failed to read OECORE_TARGET_SYSROOT from Yocto setup script: ${_yocto_qt5_env_setup_script}")
    endif()
    if (NOT DEFINED ENV{OE_QMAKE_PATH_EXTERNAL_HOST_BINS} OR "$ENV{OE_QMAKE_PATH_EXTERNAL_HOST_BINS}" STREQUAL "")
        message(FATAL_ERROR "Failed to read OE_QMAKE_PATH_EXTERNAL_HOST_BINS from Yocto setup script: ${_yocto_qt5_env_setup_script}")
    endif()
endif()

# Run the kit's toolchain file.
include($ENV{OE_CMAKE_TOOLCHAIN_FILE})

# These flags don't get set properly, so we do it manually here.
set(CMAKE_C_FLAGS "$ENV{CFLAGS} -mfpu=neon -mfloat-abi=hard -mcpu=cortex-a9" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS "$ENV{CXXFLAGS} -mfpu=neon -mfloat-abi=hard -mcpu=cortex-a9"  CACHE STRING "" FORCE)
set(CMAKE_ASM_FLAGS ${CMAKE_C_FLAGS} CACHE STRING "" FORCE)
set(CMAKE_LDFLAGS ${CMAKE_CXX_FLAGS} CACHE STRING "" FORCE)
# If this isn't set, CMake will try to test the ARM compiler, which fails because the ARM compiler's output will be for ARM and not x86.
# Setting this variable is the solution added by CMake to skip this check when cross-compiling.
set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY" CACHE STRING "Skips cross-compiler checks" FORCE)
set(CMAKE_PREFIX_PATH "$ENV{OECORE_TARGET_SYSROOT}/usr" CACHE PATH "" FORCE)
# In Qt5 Yocto toolchains, this doesn't get parsed properly.
# The OE_QMAKE_PATH_EXTERNAL_HOST_BINS variable needs to be a CMake variable, but the toolchain only sets it as an env variable.
set(OE_QMAKE_PATH_EXTERNAL_HOST_BINS $ENV{OE_QMAKE_PATH_EXTERNAL_HOST_BINS} CACHE STRING "Path to external Qt binaries" FORCE)
# Useful debug output.
set(CMAKE_EXPORT_COMPILE_COMMANDS TRUE CACHE BOOL "" FORCE)

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
