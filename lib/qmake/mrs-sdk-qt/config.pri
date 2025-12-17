###########################################################################################################################################
# Check that all necessary variables are defined. These should come from a combination of the Qt kit and toolchain helpers.
# If any are not defined then we need to halt the build immediately.
###########################################################################################################################################

# The kit in use must set the MRS_SDK_QT_TARGET_DEVICE variable. If it's not defined then fail the entire process.
# Note that for QMake, this may be done via environment variables, which is why we check those.
# For desktop builds this is set by the toolchain helper, but for cross-compile builds this will be set in the Qt kit
# to the device that kit is meant to compile for. If it's not defined then the kit is configured incorrectly.
# All other variables should be set by the toolchain helper.

_required_vars = \
    MRS_SDK_QT_TARGET_DEVICE \
    MRS_SDK_QT_TARGET_OS \
    MRS_SDK_QT_OS_BUILDROOT \
    MRS_SDK_QT_OS_YOCTO \
    MRS_SDK_QT_OS_DESKTOP \
    MRS_SDK_QT_QT_MAJOR_VERSION

for(_var, _required_vars) {
    !defined($$_var, var) {
        # Check for an environment variable.
        _val = $$getenv($$_var)
        isEmpty(_val) {
            error($$_var variable must be set!)
        }
        $$_var = $$_val
    }
}

###########################################################################################################################################
# Add variables based on MRS_SDK_QT_TARGET_DEVICE and MRS_SDK_QT_TARGET_OS.
# These variables come from dedicated toolchain files.
###########################################################################################################################################
MRS_SDK_QT_DEVICE_NEURALPLEX = FALSE
MRS_SDK_QT_DEVICE_MCONN = FALSE
MRS_SDK_QT_DEVICE_FUSION = FALSE
MRS_SDK_QT_DEVICE_DESKTOP = FALSE

_mrs_sdk_qt_target_device = $$lower($$MRS_SDK_QT_TARGET_DEVICE)
_mrs_sdk_qt_target_os = $$lower($$MRS_SDK_QT_TARGET_OS)

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
# Check that the expected Qt version matches what is being used.
###########################################################################################################################################
equals(MRS_SDK_QT_QT_MAJOR_VERSION, 5) {
    equals(QT_MAJOR_VERSION, 5) {
        equals(MRS_SDK_QT_EXPECTED_QT_VERSION, $$QT_VERSION) {
            message("Qt version: $$MRS_SDK_QT_EXPECTED_QT_VERSION")
        } else {
            error("ERROR: invalid Qt version: $$QT_VERSION")
        }
    } else {
        error("ERROR: no valid Qt version found.")
    }
} else:equals(MRS_SDK_QT_QT_MAJOR_VERSION, 6) {
    equals(QT_MAJOR_VERSION, 6) {
        equals(MRS_SDK_QT_EXPECTED_QT_VERSION, $$QT_VERSION) {
            message("Qt version: $$MRS_SDK_QT_EXPECTED_QT_VERSION")
        } else {
            error("ERROR: invalid Qt version: $$QT_VERSION")
        }
    } else {
        error("ERROR: no valid Qt version found.")
    }
}
_mrs_sdk_qt_qt_version = $$MRS_SDK_QT_EXPECTED_QT_VERSION

###########################################################################################################################################
# Determine whether the target is an ARM processor based on the system processor and compiler target.
###########################################################################################################################################
_mrs_sdk_qt_is_arm = 0
_mrs_sdk_qt_processor_lower = $$lower($$MRS_SDK_QT_SYSTEM_PROCESSOR)
contains(_mrs_sdk_qt_processor_lower, "arm") {
    _mrs_sdk_qt_is_arm = 1
}

###########################################################################################################################################
# Add all of the definitions that will be shared by the SDK and its consumers.
# If there were no environment errors, output the target device and OS.
###########################################################################################################################################
MRS_SDK_QT_SHARED_DEFINES = # List of defs shared by both SDK target and its consumers
MRS_SDK_QT_SHARED_DEFINES += \
    MRS_SDK_QT_QT_MAJOR_VERSION=\\\"$$MRS_SDK_QT_QT_MAJOR_VERSION\\\" \
    MRS_SDK_QT_QT_VERSION=\\\"$$_mrs_sdk_qt_qt_version\\\" \
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
message("Environment: target processor: $$MRS_SDK_QT_SYSTEM_PROCESSOR")
message("Environment: target OS: $$MRS_SDK_QT_TARGET_OS")

###########################################################################################################################################
# Everything below handles linking consumer projects against the prebuilt SDK library.
# When a downstream target is created, we locate the built artifacts and link against them.
###########################################################################################################################################
!isEmpty(MRS_SDK_QT_CONSUMER_TARGET) {
    # Resolve the canonical library and include paths for the installed SDK.
    MRS_SDK_QT_LIBRARY_DIR_BASE = $$MRS_SDK_QT_ROOT/$${MRS_SDK_QT_VERSION}/lib
    MRS_SDK_QT_LIB_NAME = mrs-sdk-qt
    MRS_SDK_QT_INCLUDE_DIRS = $$MRS_SDK_QT_ROOT/$${MRS_SDK_QT_VERSION}/include

    # The exact path to the static library inside MRS_SDK_QT_LIBRARY_DIR_BASE is defined as follows:
    # <qt-maj-ver>/<os-target>/<sys-name>_<processor-type>_<device-target>/
    # This ensures that all libraries have a unique installation location that can be determined programmatically.
    _lib_os_path = $$MRS_SDK_QT_LIBRARY_DIR_BASE/qt$${MRS_SDK_QT_QT_MAJOR_VERSION}/$${_mrs_sdk_qt_target_os}
    _sys_name = $$lower($$MRS_SDK_QT_SYSTEM_NAME)
    _lib_target_dirname = $${_sys_name}_$${_mrs_sdk_qt_processor_lower}_$$_mrs_sdk_qt_target_device

    MRS_SDK_QT_LIBRARY_DIR = $$_lib_os_path/$$_lib_target_dirname

    # Add the SDK's compiled libraries and include paths.
    LIBS += -L$$MRS_SDK_QT_LIBRARY_DIR -l$$MRS_SDK_QT_LIB_NAME
    INCLUDEPATH += $$MRS_SDK_QT_INCLUDE_DIRS
    DEPENDPATH += $$MRS_SDK_QT_INCLUDE_DIRS

    message("Configuring MRS SDK for target $${MRS_SDK_QT_CONSUMER_TARGET}...")
}
