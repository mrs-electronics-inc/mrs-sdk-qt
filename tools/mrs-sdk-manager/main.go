package main

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"
)

func main() {
	flag.Parse()

	args := flag.Args()
	if len(args) != 1 {
		fmt.Fprintf(os.Stderr, "Usage: mrs-sdk-manager <sdk-version>\n")
		os.Exit(1)
	}

	sdkVersion := args[0]

	if err := run(sdkVersion); err != nil {
		fmt.Fprintf(os.Stderr, "ERROR: %v\n", err)
		os.Exit(1)
	}

	fmt.Println("SUCCESS.")
}

func run(sdkVersion string) error {
	fmt.Println("Setting up the MRS SDK...")

	homeDir, err := os.UserHomeDir()
	if err != nil {
		return fmt.Errorf("failed to get home directory: %w", err)
	}

	mrsSdkQtRoot := filepath.Join(homeDir, "mrs-sdk-qt")
	sdkVersionDir := filepath.Join(mrsSdkQtRoot, sdkVersion)

	// Check if SDK root exists
	if _, err := os.Stat(mrsSdkQtRoot); err != nil {
		if os.IsNotExist(err) {
			return fmt.Errorf("could not find SDK installation in %s", mrsSdkQtRoot)
		}
		return err
	}

	// Check if version directory exists
	if _, err := os.Stat(sdkVersionDir); err != nil {
		if os.IsNotExist(err) {
			return fmt.Errorf("could not find directory %s", sdkVersionDir)
		}
		return err
	}

	// Remove old symlink and create new one
	currentLink := filepath.Join(mrsSdkQtRoot, "current")
	if err := os.Remove(currentLink); err != nil && !os.IsNotExist(err) {
		return fmt.Errorf("failed to remove old symlink: %w", err)
	}

	if err := os.Symlink(sdkVersionDir, currentLink); err != nil {
		return fmt.Errorf("failed to create symlink: %w", err)
	}

	// Create config directory
	configDir := filepath.Join(homeDir, ".config", "mrs-sdk-qt")
	if err := os.RemoveAll(configDir); err != nil {
		return fmt.Errorf("failed to clear config directory: %w", err)
	}

	if err := os.MkdirAll(configDir, 0755); err != nil {
		return fmt.Errorf("failed to create config directory: %w", err)
	}

	// Write global-config file
	configFile := filepath.Join(configDir, "global-config")
	configContent := fmt.Sprintf("MRS_SDK_QT_ROOT=%s\nMRS_SDK_QT_VERSION=%s\n", mrsSdkQtRoot, sdkVersion)
	if err := os.WriteFile(configFile, []byte(configContent), 0644); err != nil {
		return fmt.Errorf("failed to write config file: %w", err)
	}

	// Write CMake wrapper
	cmakeFile := filepath.Join(configDir, "global-config.cmake")
	cmakeContent := generateCMakeConfig()
	if err := os.WriteFile(cmakeFile, []byte(cmakeContent), 0644); err != nil {
		return fmt.Errorf("failed to write CMake config: %w", err)
	}

	// Write QMake wrapper
	qmakeFile := filepath.Join(configDir, "global-config.pri")
	qmakeContent := generateQMakeConfig()
	if err := os.WriteFile(qmakeFile, []byte(qmakeContent), 0644); err != nil {
		return fmt.Errorf("failed to write QMake config: %w", err)
	}

	return nil
}

func generateCMakeConfig() string {
	return `# MRS SDK CMake configuration wrapper
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
`
}

func generateQMakeConfig() string {
	return `# MRS SDK QMake configuration wrapper
# This file reads the KEY=VALUE config file and sets QMake variables

_mrs_sdk_qt_config_file = "$$(HOME)/.config/mrs-sdk-qt/global-config"
!exists($$_mrs_sdk_qt_config_file) {
    error("ERROR: MRS SDK global config not found at $$_mrs_sdk_qt_config_file. Run mrs-sdk-manager to initialize.")
}

include($$_mrs_sdk_qt_config_file)

isEmpty(MRS_SDK_QT_ROOT) {
    error("ERROR: MRS_SDK_QT_ROOT not found in $$_mrs_sdk_qt_config_file")
}
isEmpty(MRS_SDK_QT_VERSION) {
    error("ERROR: MRS_SDK_QT_VERSION not found in $$_mrs_sdk_qt_config_file")
}
`
}
