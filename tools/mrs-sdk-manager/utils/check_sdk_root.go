package utils

import (
	"fmt"
	"os"
)

// ResolveSDKInstallRoot validates the configured SDK installation root.
// Local installs must honor MRS_SDK_QT_ROOT so that `build-local --install`
// and generated project wrappers all agree on where the SDK lives on disk.
func ResolveSDKInstallRoot() (string, error) {
	sdkInstallRoot := os.Getenv("MRS_SDK_QT_ROOT")
	if sdkInstallRoot == "" {
		return "", fmt.Errorf("MRS_SDK_QT_ROOT is not set. Export it in your shell profile (e.g., export MRS_SDK_QT_ROOT=<path>)")
	}

	return sdkInstallRoot, nil
}
