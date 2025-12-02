# MRS SDK Qt configuration for QMake.
# This file provides the same configuration capabilities as config.cmake for CMake users.
#
# The kit in use must set the MRS_SDK_QT_TARGET_DEVICE variable. If it's not defined then fail the entire process.
isEmpty(MRS_SDK_QT_TARGET_DEVICE) {
    error("ERROR: MRS_SDK_QT_TARGET_DEVICE variable must be set!")
}

# Export the list of definitions that the SDK target and its consumers share.
MRS_SDK_QT_SHARED_DEFINES =

###########################################################################################################################################
# Add variables based on MRS_SDK_QT_TARGET_DEVICE and MRS_SDK_QT_TARGET_OS.
# These variables come from dedicated toolchain files.
###########################################################################################################################################
MRS_SDK_QT_DEVICE_NEURALPLEX = FALSE
MRS_SDK_QT_DEVICE_MCONN = FALSE
MRS_SDK_QT_DEVICE_FUSION = FALSE
MRS_SDK_QT_DEVICE_DESKTOP = FALSE

# Normalize target device and OS to lowercase for comparison
_mrs_sdk_qt_target_device = $$lower($$MRS_SDK_QT_TARGET_DEVICE)
_mrs_sdk_qt_target_os = $$lower($$MRS_SDK_QT_TARGET_OS)

# Determine if we're ARM-based
_mrs_sdk_qt_is_arm = 0
contains(_mrs_sdk_qt_target_device, "neuralplex") {
    _mrs_sdk_qt_processor = arm64
    _mrs_sdk_qt_is_arm = 1
} else:contains(_mrs_sdk_qt_target_device, "mconn") {
    _mrs_sdk_qt_processor = arm
    _mrs_sdk_qt_is_arm = 1
} else:contains(_mrs_sdk_qt_target_device, "fusion") {
    _mrs_sdk_qt_processor = arm
    _mrs_sdk_qt_is_arm = 1
} else:contains(_mrs_sdk_qt_target_device, "desktop") {
    _mrs_sdk_qt_processor = $$system(uname -m)
}

# Validate device/OS combinations and set device flags
equals(_mrs_sdk_qt_target_device, "neuralplex") {
    # Buildroot is not a valid OS target for NeuralPlex devices.
    equals(_mrs_sdk_qt_target_os, "buildroot") {
        error("ERROR: invalid device target: Buildroot OS not supported by NeuralPlex devices.")
    }
    isEmpty(MRS_SDK_QT_EXPECTED_QT_VERSION_NEURALPLEX) {
        error("ERROR: no expected Qt version set for target device $$MRS_SDK_QT_TARGET_DEVICE.")
    }
    MRS_SDK_QT_EXPECTED_QT_VERSION = $$MRS_SDK_QT_EXPECTED_QT_VERSION_NEURALPLEX
    MRS_SDK_QT_DEVICE_NEURALPLEX = TRUE
} else:equals(_mrs_sdk_qt_target_device, "mconn") {
    isEmpty(MRS_SDK_QT_EXPECTED_QT_VERSION_MCONN) {
        error("ERROR: no expected Qt version set for target device $$MRS_SDK_QT_TARGET_DEVICE.")
    }
    MRS_SDK_QT_EXPECTED_QT_VERSION = $$MRS_SDK_QT_EXPECTED_QT_VERSION_MCONN
    MRS_SDK_QT_DEVICE_MCONN = TRUE
} else:equals(_mrs_sdk_qt_target_device, "fusion") {
    # Yocto is not a valid OS target for FUSION devices.
    equals(_mrs_sdk_qt_target_os, "yocto") {
        error("ERROR: invalid device target: Yocto OS not supported by FUSION devices.")
    }
    isEmpty(MRS_SDK_QT_EXPECTED_QT_VERSION_FUSION) {
        error("ERROR: no expected Qt version set for target device $$MRS_SDK_QT_TARGET_DEVICE.")
    }
    MRS_SDK_QT_EXPECTED_QT_VERSION = $$MRS_SDK_QT_EXPECTED_QT_VERSION_FUSION
    MRS_SDK_QT_DEVICE_FUSION = TRUE
} else:equals(_mrs_sdk_qt_target_device, "desktop") {
    # The only valid OS target for desktop "devices" is, of course, desktop.
    !equals(_mrs_sdk_qt_target_os, "desktop") {
        error("ERROR: invalid device target: $$_mrs_sdk_qt_target_os OS not supported by desktop devices.")
    }
    isEmpty(MRS_SDK_QT_EXPECTED_QT_VERSION_DESKTOP) {
        error("ERROR: no expected Qt version set for target device $$MRS_SDK_QT_TARGET_DEVICE.")
    }
    MRS_SDK_QT_EXPECTED_QT_VERSION = $$MRS_SDK_QT_EXPECTED_QT_VERSION_DESKTOP
    MRS_SDK_QT_DEVICE_DESKTOP = TRUE
} else {
    error("ERROR: invalid device target: MRS_SDK_QT_TARGET_DEVICE=$$MRS_SDK_QT_TARGET_DEVICE")
}

###########################################################################################################################################
# Check that the expected Qt version matches what is being used, and determine processor info
###########################################################################################################################################
# Get the Qt major version from the project
equals(QT_MAJOR_VERSION, 5) {
    !equals(MRS_SDK_QT_EXPECTED_QT_VERSION, 5.*) {
        error("ERROR: invalid Qt version. Expected 5.*, got $$MRS_SDK_QT_EXPECTED_QT_VERSION")
    }
    MRS_SDK_QT_QT_MAJOR_VERSION = 5
} else:equals(QT_MAJOR_VERSION, 6) {
    !equals(MRS_SDK_QT_EXPECTED_QT_VERSION, 6.*) {
        error("ERROR: invalid Qt version. Expected 6.*, got $$MRS_SDK_QT_EXPECTED_QT_VERSION")
    }
    MRS_SDK_QT_QT_MAJOR_VERSION = 6
} else {
    error("ERROR: no valid Qt version found. Please define QT_MAJOR_VERSION in your project.")
}

message("Qt version: $$MRS_SDK_QT_EXPECTED_QT_VERSION")

###########################################################################################################################################
# Add all of the definitions that will be shared by the SDK and its consumers.
# If there were no environment errors, output the target device and OS.
###########################################################################################################################################
MRS_SDK_QT_SHARED_DEFINES += \
    MRS_SDK_QT_QT_MAJOR_VERSION=\\\"$$MRS_SDK_QT_QT_MAJOR_VERSION\\\" \
    MRS_SDK_QT_QT_VERSION=\\\"$$MRS_SDK_QT_EXPECTED_QT_VERSION\\\" \
    MRS_SDK_QT_TARGET_DEVICE=\\\"$$_mrs_sdk_qt_target_device\\\" \
    MRS_SDK_QT_DEVICE_NEURALPLEX=$$MRS_SDK_QT_DEVICE_NEURALPLEX \
    MRS_SDK_QT_DEVICE_MCONN=$$MRS_SDK_QT_DEVICE_MCONN \
    MRS_SDK_QT_DEVICE_FUSION=$$MRS_SDK_QT_DEVICE_FUSION \
    MRS_SDK_QT_TARGET_OS=\\\"$$_mrs_sdk_qt_target_os\\\" \
    MRS_SDK_QT_OS_YOCTO=$$MRS_SDK_QT_OS_YOCTO \
    MRS_SDK_QT_OS_BUILDROOT=$$MRS_SDK_QT_OS_BUILDROOT \
    MRS_SDK_QT_OS_DESKTOP=$$MRS_SDK_QT_OS_DESKTOP \
    MRS_SDK_QT_IS_ARM=$$_mrs_sdk_qt_is_arm \
    MRS_SDK_QT_IS_CROSSCOMPILING=$$MRS_SDK_QT_CROSSCOMPILING

DEFINES += $$MRS_SDK_QT_SHARED_DEFINES

message("Environment: target device: $$MRS_SDK_QT_TARGET_DEVICE")
message("Environment: target processor: $$_mrs_sdk_qt_processor")
message("Environment: target OS: $$MRS_SDK_QT_TARGET_OS")

###########################################################################################################################################
# Everything below handles linking consumer projects against the prebuilt SDK library.
# When a downstream target is created, we locate the built artifacts and link against them.
###########################################################################################################################################
contains(TEMPLATE, app) {
    # The paths in this section are dependent on the MRS_SDK_QT_ROOT variable.
    # This can be configured from the downstream project. If not configured,
    # the default will be $HOME/mrs-sdk-qt.
    isEmpty(MRS_SDK_QT_ROOT) {
        MRS_SDK_QT_ROOT = $$(HOME)/mrs-sdk-qt
        message("WARNING: MRS_SDK_QT_ROOT not defined. Defaulting to $$MRS_SDK_QT_ROOT")
    }

    # Resolve the canonical library and include paths for the installed SDK.
    MRS_SDK_QT_LIBRARY_DIR_BASE = $$MRS_SDK_QT_ROOT/$${MRS_SDK_QT_VERSION}/lib
    MRS_SDK_QT_LIB_NAME = mrs-sdk-qt
    MRS_SDK_QT_INCLUDE_DIRS = $$MRS_SDK_QT_ROOT/$${MRS_SDK_QT_VERSION}/include

    # The exact path to the static library inside MRS_SDK_QT_LIBRARY_DIR_BASE is defined as follows:
    # <qt-maj-ver>/<os-target>/<sys-name>_<processor-type>_<device-target>/
    # This ensures that all libraries have a unique installation location that can be determined programmatically.
    _lib_os_path = $$MRS_SDK_QT_LIBRARY_DIR_BASE/qt$$MRS_SDK_QT_QT_MAJOR_VERSION/$$_mrs_sdk_qt_target_os
    _lib_target_dirname = $${_sys_name}_$$_mrs_sdk_qt_processor$$_mrs_sdk_qt_target_device

    MRS_SDK_QT_LIBRARY_DIR = $$_lib_os_path/$$_lib_target_dirname

    # Add the SDK's compiled libraries and include paths.
    LIBS += -L$$MRS_SDK_QT_LIBRARY_DIR -l$$MRS_SDK_QT_LIB_NAME
    INCLUDEPATH += $$MRS_SDK_QT_INCLUDE_DIRS
    DEPENDPATH += $$MRS_SDK_QT_INCLUDE_DIRS

    message("Configuring MRS SDK for target in $$MRS_SDK_QT_LIBRARY_DIR")
}
