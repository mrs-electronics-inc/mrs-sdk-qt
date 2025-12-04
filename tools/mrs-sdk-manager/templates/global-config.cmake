# MRS SDK CMake configuration wrapper
# This file reads the KEY=VALUE config file and sets CMake variables

set(_mrs_sdk_qt_config_file "$ENV{HOME}/.config/mrs-sdk-qt/global-config")
if(NOT EXISTS "${_mrs_sdk_qt_config_file}")
    message(FATAL_ERROR "ERROR: MRS SDK global config not found at ${_mrs_sdk_qt_config_file}. Run mrs-sdk-manager to initialize.")
endif()

file(STRINGS "${_mrs_sdk_qt_config_file}" _config_lines)
foreach(_line ${_config_lines})
    if(_line MATCHES "^([^=]+)=(.*)$")
        set(${CMAKE_MATCH_1} "${CMAKE_MATCH_2}")
    endif()
endforeach()

if(NOT DEFINED MRS_SDK_QT_ROOT)
	message(FATAL_ERROR "ERROR: MRS_SDK_QT_ROOT not found in ${_mrs_sdk_qt_config_file}")
endif()

if(NOT DEFINED MRS_SDK_QT_VERSION)
	message(FATAL_ERROR "ERROR: MRS_SDK_QT_VERSION not found in ${_mrs_sdk_qt_config_file}")
endif()
