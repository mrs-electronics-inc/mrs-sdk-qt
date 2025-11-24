# The kit in use must set the MRS_SDK_QT_TARGET_DEVICE variable. If it's not defined then fail the entire process.
if(NOT DEFINED MRS_SDK_QT_TARGET_DEVICE)
    message(FATAL_ERROR "ERROR: MRS_SDK_QT_TARGET_DEVICE variable must be set!")
endif()
# if (NOT DEFINED MRS_SDK_QT_EXPECTED_QT_VERSION)
#     message(FATAL_ERROR "ERROR: MRS_SDK_QT_EXPECTED_QT_VERSION variable must be set!")
# endif()

# The paths in this file are dependent on the MRS_SDK_QT_ROOT variable.
# This can be configured from the downstream project. If not configured,
# the default will be $HOME/mrs-sdk-qt.
if(NOT DEFINED MRS_SDK_QT_ROOT)
    set(MRS_SDK_QT_ROOT "$ENV{HOME}/mrs-sdk-qt" CACHE PATH "Installation root directory of the MRS SDK Qt")
    message(WARNING "MRS_SDK_QT_ROOT not defined. Defaulting to ${MRS_SDK_QT_ROOT}")
endif()

# Export the list of definitions that the SDK target and its consumers share.
set(MRS_SDK_QT_SHARED_DEFINES "")
# Export definitions that should only reach consumer targets via the imported target.
set(MRS_SDK_QT_CONSUMER_ONLY_DEFINES "")

# Add variables based on MRS_SDK_QT_TARGET_DEVICE and MRS_SDK_QT_TARGET_OS.
# These environment variables come from dedicated toolchain files.
string(TOLOWER "${MRS_SDK_QT_TARGET_DEVICE}" _mrs_sdk_qt_target_device)
string(TOLOWER "${MRS_SDK_QT_TARGET_OS}" _mrs_sdk_qt_target_os)
set(MRS_SDK_QT_DEVICE_NEURALPLEX FALSE CACHE BOOL "Target device identifier" FORCE)
set(MRS_SDK_QT_DEVICE_MCONN FALSE CACHE BOOL "Target device identifier" FORCE)
set(MRS_SDK_QT_DEVICE_FUSION FALSE CACHE BOOL "Target device identifier" FORCE)
if(_mrs_sdk_qt_target_device STREQUAL "neuralplex")
    if (_mrs_sdk_qt_target_os STREQUAL "buildroot")
        message(FATAL_ERROR "ERROR: invalid device target: cannot run Buildroot OS on NeuralPlex device.")
    endif()
    if(NOT DEFINED MRS_SDK_QT_EXPECTED_QT_VERSION_NEURALPLEX)
        message(FATAL_ERROR "ERROR: no expected Qt version set for target device ${MRS_SDK_QT_TARGET_DEVICE}.")
    endif()
    set(MRS_SDK_QT_EXPECTED_QT_VERSION ${MRS_SDK_QT_EXPECTED_QT_VERSION_NEURALPLEX} CACHE STRING "expected Qt version")
    set(MRS_SDK_QT_DEVICE_NEURALPLEX TRUE CACHE BOOL "Target device identifier" FORCE)
elseif(_mrs_sdk_qt_target_device STREQUAL "mconn")
    if(NOT DEFINED MRS_SDK_QT_EXPECTED_QT_VERSION_MCONN)
        message(FATAL_ERROR "ERROR: no expected Qt version set for target device ${MRS_SDK_QT_TARGET_DEVICE}.")
    endif()
    set(MRS_SDK_QT_EXPECTED_QT_VERSION ${MRS_SDK_QT_EXPECTED_QT_VERSION_MCONN} CACHE STRING "expected Qt version")
    set(MRS_SDK_QT_DEVICE_MCONN TRUE CACHE BOOL "Target device identifier" FORCE)
elseif(_mrs_sdk_qt_target_device STREQUAL "fusion")
    if(NOT DEFINED MRS_SDK_QT_EXPECTED_QT_VERSION_FUSION)
        message(FATAL_ERROR "ERROR: no expected Qt version set for target device ${MRS_SDK_QT_TARGET_DEVICE}.")
    endif()
    set(MRS_SDK_QT_EXPECTED_QT_VERSION ${MRS_SDK_QT_EXPECTED_QT_VERSION_FUSION} CACHE STRING "expected Qt version")
    set(MRS_SDK_QT_DEVICE_FUSION TRUE CACHE BOOL "Target device identifier" FORCE)
else()
    message(FATAL_ERROR "ERROR: invalid device target: MRS_SDK_QT_TARGET_DEVICE=${MRS_SDK_QT_TARGET_DEVICE}")
endif()

# Check that the expected Qt version, according to the device toolchain, matches what is actually being used.
if(Qt5Core_VERSION)
    if(${MRS_SDK_QT_EXPECTED_QT_VERSION} STREQUAL ${Qt5Core_VERSION})
        message(NOTICE "Qt version: ${MRS_SDK_QT_EXPECTED_QT_VERSION}")
    else()
        message(FATAL_ERROR "ERROR: invalid Qt version: ${Qt5Core_VERSION}")
    endif()
elseif(Qt6Core_VERSION)
    if(${MRS_SDK_QT_EXPECTED_QT_VERSION} STREQUAL ${Qt6Core_VERSION})
        message(NOTICE "Qt version: ${MRS_SDK_QT_EXPECTED_QT_VERSION}")
    else()
        message(FATAL_ERROR "ERROR: invalid Qt version: ${Qt6Core_VERSION}")
    endif()
else()
    message(FATAL_ERROR "ERROR: no valid Qt version found.")
endif()
set(_mrs_sdk_qt_qt_version ${MRS_SDK_QT_EXPECTED_QT_VERSION})

# If there were no environment errors, output the target device and OS.
message(NOTICE "Environment: target device: ${MRS_SDK_QT_TARGET_DEVICE}")
message(NOTICE "Environment: target OS: ${MRS_SDK_QT_TARGET_OS}")

# Determine whether the target is an ARM processor based on processor and compiler target.
set(_mrs_sdk_qt_is_arm 0)
string(TOLOWER "${CMAKE_SYSTEM_PROCESSOR}" _mrs_sdk_qt_processor_lower)
if(_mrs_sdk_qt_processor_lower MATCHES "arm|aarch64|cortex")
    set(_mrs_sdk_qt_is_arm 1)
elseif(DEFINED CMAKE_CXX_COMPILER_TARGET)
    string(TOLOWER "${CMAKE_CXX_COMPILER_TARGET}" _mrs_sdk_qt_compiler_target_lower)
    if(_mrs_sdk_qt_compiler_target_lower MATCHES "arm|aarch64|cortex")
        set(_mrs_sdk_qt_is_arm 1)
    endif()
endif()

# Add all of the definitions taken from the toolchains.
list(APPEND MRS_SDK_QT_SHARED_DEFINES
    "MRS_SDK_QT_QT_VERSION=\"${_mrs_sdk_qt_qt_version}\""
    "MRS_SDK_QT_TARGET_DEVICE=\"${_mrs_sdk_qt_target_device}\""
    "MRS_SDK_QT_DEVICE_NEURALPLEX=${MRS_SDK_QT_DEVICE_NEURALPLEX}"
    "MRS_SDK_QT_DEVICE_MCONN=${MRS_SDK_QT_DEVICE_MCONN}"
    "MRS_SDK_QT_DEVICE_FUSION=${MRS_SDK_QT_DEVICE_FUSION}"
    "MRS_SDK_QT_TARGET_OS=\"${_mrs_sdk_qt_target_os}\""
    "MRS_SDK_QT_OS_YOCTO=${MRS_SDK_QT_OS_YOCTO}"
    "MRS_SDK_QT_OS_BUILDROOT=${MRS_SDK_QT_OS_BUILDROOT}"
    "MRS_SDK_QT_OS_LOCAL=${MRS_SDK_QT_OS_LOCAL}"
    "MRS_SDK_QT_IS_ARM=${_mrs_sdk_qt_is_arm}"
    "MRS_SDK_QT_IS_CROSSCOMPILING=${CMAKE_CROSSCOMPILING}"
)

# Everything below handles wiring the prebuilt SDK library into consumer projects.
# When a downstream target sets MRS_SDK_QT_CONSUMER_TARGET, we locate the built artifacts,
# publish them via an imported target, and link the consumer target against it.
if(DEFINED MRS_SDK_QT_CONSUMER_TARGET)
    # Resolve the canonical library and include paths for the installed SDK.
    set(MRS_SDK_QT_LIBRARY_DIRS "${MRS_SDK_QT_ROOT}/lib")
    set(MRS_SDK_QT_LIB_NAME mrs-sdk-qt)
    set(MRS_SDK_QT_INCLUDE_DIRS "${MRS_SDK_QT_ROOT}/include")

    if(TARGET ${MRS_SDK_QT_CONSUMER_TARGET})
        message(NOTICE "Configuring MRS SDK for target ${MRS_SDK_QT_CONSUMER_TARGET}...")
        find_library(MRS_SDK_QT_LIBS
            NAMES "${MRS_SDK_QT_LIB_NAME}-${_mrs_sdk_qt_target_device}"
            PATHS "${MRS_SDK_QT_LIBRARY_DIRS}/${_mrs_sdk_qt_target_os}"
            NO_DEFAULT_PATH
            NO_CMAKE_FIND_ROOT_PATH
            REQUIRED
        )
        if(MRS_SDK_QT_LIBS)
            # Create or configure an imported target pointing at the installed library.
            if(NOT TARGET ${MRS_SDK_QT_LIB_NAME})
                add_library(${MRS_SDK_QT_LIB_NAME} UNKNOWN IMPORTED)
            endif()
            set_target_properties(${MRS_SDK_QT_LIB_NAME} PROPERTIES
                IMPORTED_LOCATION ${MRS_SDK_QT_LIBS}
                INTERFACE_INCLUDE_DIRECTORIES ${MRS_SDK_QT_INCLUDE_DIRS}
            )
            if(MRS_SDK_QT_SHARED_DEFINES)
                set_property(TARGET ${MRS_SDK_QT_LIB_NAME} APPEND PROPERTY INTERFACE_COMPILE_DEFINITIONS ${MRS_SDK_QT_SHARED_DEFINES})
            endif()
            if(MRS_SDK_QT_CONSUMER_ONLY_DEFINES)
                set_property(TARGET ${MRS_SDK_QT_LIB_NAME} APPEND PROPERTY INTERFACE_COMPILE_DEFINITIONS ${MRS_SDK_QT_CONSUMER_ONLY_DEFINES})
            endif()
            target_link_libraries(${MRS_SDK_QT_CONSUMER_TARGET} PRIVATE ${MRS_SDK_QT_LIB_NAME})
        endif()
    endif()
endif()
