package buildlocal

import (
	"strings"
	"testing"
)

// TestGetBuildConfigsPassesYoctoSetupScript verifies that repo-local Yocto
// builds pass the already-resolved setup script path into CMake explicitly.
// This prevents the toolchain helper from depending on an installed manager
// binary during bootstrap.
func TestGetBuildConfigsPassesYoctoSetupScript(t *testing.T) {
	t.Setenv("MRS_SDK_QT_ROOT", "/tmp/mrs-sdk-root")

	configs := getBuildConfigs("/tmp/mrs-sdk-qt", map[string]string{
		"YOCTO_QT5_SYSROOT":          "/tmp/yocto/sysroot",
		"YOCTO_QT5_CXX_COMPILER":     "/tmp/yocto/bin/arm-g++",
		"YOCTO_QT5_ENV_SETUP_SCRIPT": "/tmp/yocto/environment-setup",
		"BUILDROOT_QT5_SYSROOT":      "/tmp/buildroot/sysroot",
		"BUILDROOT_QT5_CXX_COMPILER": "/tmp/buildroot/bin/arm-g++",
		"DESKTOP_CXX_COMPILER":       "/usr/bin/g++",
		"DESKTOP_QT5_PREFIX":         "/opt/Qt/5",
		"DESKTOP_QT6_PREFIX":         "/opt/Qt/6",
	})

	var yoctoConfig *BuildConfig
	for i := range configs {
		if configs[i].Target.OS == "yocto" {
			yoctoConfig = &configs[i]
			break
		}
	}
	if yoctoConfig == nil {
		t.Fatal("expected a Yocto build configuration")
	}

	expectedArg := "-DYOCTO_QT5_ENV_SETUP_SCRIPT:FILEPATH=/tmp/yocto/environment-setup"
	for _, arg := range yoctoConfig.CmakeCmd {
		if arg == expectedArg {
			return
		}
	}

	t.Fatalf("expected Yocto configure args to include %q, got %s", expectedArg, strings.Join(yoctoConfig.CmakeCmd, " "))
}
