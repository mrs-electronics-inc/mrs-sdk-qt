# MRS SDK QMake configuration wrapper
# This file reads the KEY=VALUE config file and sets QMake variables

_mrs_sdk_qt_global_config_file = "$$(HOME)/.config/mrs-sdk-qt/global-config"
!exists($$_mrs_sdk_qt_global_config_file) {
    error("ERROR: MRS SDK global config not found at $$_mrs_sdk_qt_global_config_file. Run mrs-sdk-manager to initialize.")
}

include($$_mrs_sdk_qt_global_config_file)

isEmpty(MRS_SDK_QT_ROOT) {
    error("ERROR: MRS_SDK_QT_ROOT not found in $$_mrs_sdk_qt_global_config_file")
}
isEmpty(MRS_SDK_QT_VERSION) {
    error("ERROR: MRS_SDK_QT_VERSION not found in $$_mrs_sdk_qt_global_config_file")
}
