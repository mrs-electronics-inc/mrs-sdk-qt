# The kit in use must set the MRS_SDK_QT_TARGET_DEVICE variable. If it's not defined then fail the entire process.
if(NOT DEFINED MRS_SDK_QT_TARGET_DEVICE)
    message(FATAL_ERROR "ERROR: MRS_SDK_QT_TARGET_DEVICE variable must be set!")
endif()

# Export the list of definitions that the SDK target and its consumers share.
set(MRS_SDK_QT_SHARED_DEFINES "")

###########################################################################################################################################
# Add variables based on MRS_SDK_QT_TARGET_DEVICE and MRS_SDK_QT_TARGET_OS.
# These variables come from dedicated toolchain files.
###########################################################################################################################################
set(MRS_SDK_QT_DEVICE_NEURALPLEX FALSE CACHE BOOL "Target device is NeuralPlex" FORCE)
set(MRS_SDK_QT_DEVICE_MCONN FALSE CACHE BOOL "Target device is MConn" FORCE)
set(MRS_SDK_QT_DEVICE_FUSION FALSE CACHE BOOL "Target device is FUSION" FORCE)
set(MRS_SDK_QT_DEVICE_DESKTOP FALSE CACHE BOOL "Target device is desktop" FORCE)

string(TOLOWER "${MRS_SDK_QT_TARGET_DEVICE}" _mrs_sdk_qt_target_device)
string(TOLOWER "${MRS_SDK_QT_TARGET_OS}" _mrs_sdk_qt_target_os)

if(_mrs_sdk_qt_target_device STREQUAL "neuralplex")
    # Buildroot is not a valid OS target for NeuralPlex devices.
    if (_mrs_sdk_qt_target_os STREQUAL "buildroot")
        message(FATAL_ERROR "ERROR: invalid device target: Buildroot OS not supported by NeuralPlex devices.")
    endif()
    if(NOT DEFINED MRS_SDK_QT_EXPECTED_QT_VERSION_NEURALPLEX)
        message(FATAL_ERROR "ERROR: no expected Qt version set for target device ${MRS_SDK_QT_TARGET_DEVICE}.")
    endif()
    set(MRS_SDK_QT_EXPECTED_QT_VERSION ${MRS_SDK_QT_EXPECTED_QT_VERSION_NEURALPLEX} CACHE STRING "expected Qt version")
    set(MRS_SDK_QT_DEVICE_NEURALPLEX TRUE CACHE BOOL "Target device is NeuralPlex" FORCE)

elseif(_mrs_sdk_qt_target_device STREQUAL "mconn")
    if(NOT DEFINED MRS_SDK_QT_EXPECTED_QT_VERSION_MCONN)
        message(FATAL_ERROR "ERROR: no expected Qt version set for target device ${MRS_SDK_QT_TARGET_DEVICE}.")
    endif()
    set(MRS_SDK_QT_EXPECTED_QT_VERSION ${MRS_SDK_QT_EXPECTED_QT_VERSION_MCONN} CACHE STRING "expected Qt version")
    set(MRS_SDK_QT_DEVICE_MCONN TRUE CACHE BOOL "Target device is MConn" FORCE)

elseif(_mrs_sdk_qt_target_device STREQUAL "fusion")
    # Yocto is not a valid OS target for FUSION devices.
    if (_mrs_sdk_qt_target_os STREQUAL "yocto")
        message(FATAL_ERROR "ERROR: invalid device target: Yocto OS not supported by FUSION devices.")
    endif()
    if(NOT DEFINED MRS_SDK_QT_EXPECTED_QT_VERSION_FUSION)
        message(FATAL_ERROR "ERROR: no expected Qt version set for target device ${MRS_SDK_QT_TARGET_DEVICE}.")
    endif()
    set(MRS_SDK_QT_EXPECTED_QT_VERSION ${MRS_SDK_QT_EXPECTED_QT_VERSION_FUSION} CACHE STRING "expected Qt version")
    set(MRS_SDK_QT_DEVICE_FUSION TRUE CACHE BOOL "Target device is FUSION" FORCE)

elseif(_mrs_sdk_qt_target_device STREQUAL "desktop")
    # The only valid OS target for desktop "devices" is, of course, desktop.
    if(NOT _mrs_sdk_qt_target_os STREQUAL "desktop")
        message(FATAL_ERROR "ERROR: invalid device target: ${_mrs_sdk_qt_target_os} OS not supported by desktop devices.")
    endif()
    if(NOT DEFINED MRS_SDK_QT_EXPECTED_QT_VERSION_DESKTOP)
        message(FATAL_ERROR "ERROR: no expected Qt version set for target device ${MRS_SDK_QT_TARGET_DEVICE}.")
    endif()
    set(MRS_SDK_QT_EXPECTED_QT_VERSION ${MRS_SDK_QT_EXPECTED_QT_VERSION_DESKTOP} CACHE STRING "expected Qt version")
    set(MRS_SDK_QT_DEVICE_DESKTOP TRUE CACHE BOOL "Target device is desktop" FORCE)

else()
    message(FATAL_ERROR "ERROR: invalid device target: MRS_SDK_QT_TARGET_DEVICE=${MRS_SDK_QT_TARGET_DEVICE}")
endif()

###########################################################################################################################################
# Check that the expected Qt version, according to the device toolchain, matches what is actually being used.
# Then, determine whether the target is an ARM processor based on the system processor and compiler target.
###########################################################################################################################################
if(Qt5Core_VERSION)
    if(${MRS_SDK_QT_EXPECTED_QT_VERSION} STREQUAL ${Qt5Core_VERSION} AND ${MRS_SDK_QT_QT_MAJOR_VERSION} STREQUAL "5")
        message(NOTICE "Qt version: ${MRS_SDK_QT_EXPECTED_QT_VERSION}")
    else()
        message(FATAL_ERROR "ERROR: invalid Qt version: ${Qt5Core_VERSION}")
    endif()
elseif(Qt6Core_VERSION)
    if(${MRS_SDK_QT_EXPECTED_QT_VERSION} STREQUAL ${Qt6Core_VERSION} AND ${MRS_SDK_QT_QT_MAJOR_VERSION} STREQUAL "6")
        message(NOTICE "Qt version: ${MRS_SDK_QT_EXPECTED_QT_VERSION}")
    else()
        message(FATAL_ERROR "ERROR: invalid Qt version: ${Qt6Core_VERSION}")
    endif()
else()
    message(FATAL_ERROR "ERROR: no valid Qt version found.")
endif()
set(_mrs_sdk_qt_qt_version ${MRS_SDK_QT_EXPECTED_QT_VERSION})

set(_mrs_sdk_qt_is_arm 0)
string(TOLOWER "${CMAKE_SYSTEM_PROCESSOR}" _mrs_sdk_qt_processor_lower)
if(_mrs_sdk_qt_processor_lower MATCHES "arm|aarch64|cortex")
    set(_mrs_sdk_qt_is_arm 1)
endif()

###########################################################################################################################################
# Add all of the definitions taken from the toolchains.
# If there were no environment errors, output the target device and OS.
###########################################################################################################################################
list(APPEND MRS_SDK_QT_SHARED_DEFINES
    "MRS_SDK_QT_QT_MAJOR_VERSION=\"${MRS_SDK_QT_QT_MAJOR_VERSION}\""
    "MRS_SDK_QT_QT_VERSION=\"${_mrs_sdk_qt_qt_version}\""
    "MRS_SDK_QT_TARGET_DEVICE=\"${_mrs_sdk_qt_target_device}\""
    "MRS_SDK_QT_DEVICE_NEURALPLEX=${MRS_SDK_QT_DEVICE_NEURALPLEX}"
    "MRS_SDK_QT_DEVICE_MCONN=${MRS_SDK_QT_DEVICE_MCONN}"
    "MRS_SDK_QT_DEVICE_FUSION=${MRS_SDK_QT_DEVICE_FUSION}"
    "MRS_SDK_QT_TARGET_OS=\"${_mrs_sdk_qt_target_os}\""
    "MRS_SDK_QT_OS_YOCTO=${MRS_SDK_QT_OS_YOCTO}"
    "MRS_SDK_QT_OS_BUILDROOT=${MRS_SDK_QT_OS_BUILDROOT}"
    "MRS_SDK_QT_OS_DESKTOP=${MRS_SDK_QT_OS_DESKTOP}"
    "MRS_SDK_QT_IS_ARM=${_mrs_sdk_qt_is_arm}"
    "MRS_SDK_QT_IS_CROSSCOMPILING=${CMAKE_CROSSCOMPILING}"
)

message(NOTICE "Environment: target device: ${MRS_SDK_QT_TARGET_DEVICE}")
message(NOTICE "Environment: target processor: ${CMAKE_SYSTEM_PROCESSOR}")
message(NOTICE "Environment: target OS: ${MRS_SDK_QT_TARGET_OS}")

###########################################################################################################################################
# Everything below handles wiring the prebuilt SDK library into consumer projects.
# When a downstream target sets MRS_SDK_QT_CONSUMER_TARGET, we locate the built artifacts,
# publish them via an imported target, and link the consumer target against it.
###########################################################################################################################################
if(DEFINED MRS_SDK_QT_CONSUMER_TARGET)
    # The paths in this section are dependent on the MRS_SDK_QT_ROOT variable.
    # This can be configured from the downstream project. If not configured,
    # the default will be $HOME/mrs-sdk-qt.
    if(NOT DEFINED MRS_SDK_QT_ROOT)
        set(MRS_SDK_QT_ROOT "$ENV{HOME}/mrs-sdk-qt" CACHE PATH "Installation root directory of the MRS SDK Qt")
        message(WARNING "MRS_SDK_QT_ROOT not defined. Defaulting to ${MRS_SDK_QT_ROOT}")
    endif()

    # Verify that the given SDK root actually contains at least one valid SDK version.
    file(GLOB _all_dirs LIST_DIRECTORIES true RELATIVE ${MRS_SDK_QT_ROOT} "*")
    set(_semver_regex "^\\d+\\.\\d+\\.\\d+$")
    list(FILTER _all_sdk_dirs INCLUDE REGEX "${_semver_regex}" _sdk_version_options)
    if(NOT _sdk_version_options)
        message(FATAL_ERROR "No valid SDK versions found in ${MRS_SDK_QT_ROOT}")
    endif()

    # Set the SDK version to the highest available if it was not already defined.
    if(NOT DEFINED MRS_SDK_QT_VERSION)
        list(SORT _sdk_version_options VERSION DESCENDING)
        list(GET _sdk_version_options 0 MRS_SDK_QT_VERSION)
        message(WARNING "MRS_SDK_QT_VERSION not defined. Defaulting to ${MRS_SDK_QT_VERSION}")
    else()
        message(NOTICE "MRS SDK version: ${MRS_SDK_QT_VERSION}")
    endif()

    # Export definitions that should only reach consumer targets via the imported target.
    set(MRS_SDK_QT_CONSUMER_ONLY_DEFINES "")

    # Resolve the canonical library and include paths for the installed SDK.
    set(MRS_SDK_QT_LIBRARY_DIR_BASE "${MRS_SDK_QT_ROOT}/${MRS_SDK_QT_VERSION}/lib")
    set(MRS_SDK_QT_LIB_NAME mrs-sdk-qt)
    set(MRS_SDK_QT_INCLUDE_DIRS "${MRS_SDK_QT_ROOT}/${MRS_SDK_QT_VERSION}/include")

    # The exact path to the static library inside MRS_SDK_QT_LIBRARY_DIR_BASE is defined as follows:
    # <qt-maj-ver>/<os-target>/<sys-name>_<processor-type>_<device-target>/
    # This ensures that all libraries have a unique installation location that can be determined programmatically.
    set(_lib_os_path "${MRS_SDK_QT_LIBRARY_DIR_BASE}/qt${MRS_SDK_QT_QT_MAJOR_VERSION}/${_mrs_sdk_qt_target_os}/")
    string(TOLOWER "${CMAKE_SYSTEM_NAME}" _sys_name)
    set(_lib_target_dirname "${_sys_name}_${_mrs_sdk_qt_processor_lower}_${_mrs_sdk_qt_target_device}")
    set(MRS_SDK_QT_LIBRARY_DIR "${_lib_os_path}/${_lib_target_dirname}")

    if(TARGET ${MRS_SDK_QT_CONSUMER_TARGET})
        message(NOTICE "Configuring MRS SDK for target ${MRS_SDK_QT_CONSUMER_TARGET}...")

        # Find the static library file in the specified location inside the SDK installation tree.
        # Using REQUIRED ensures that the entire script will fail if it is not found.
        find_library(MRS_SDK_QT_LIBS
            NAMES "${MRS_SDK_QT_LIB_NAME}"
            PATHS "${MRS_SDK_QT_LIBRARY_DIR}"
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
