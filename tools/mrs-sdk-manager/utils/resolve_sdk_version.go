package utils

import (
	"os/exec"
	"strings"
)

// ResolveSDKVersion returns the latest annotated or lightweight Git tag for
// the repository. If Git metadata is unavailable or the repository has not been
// tagged yet, the function deliberately falls back to the long-standing local
// development version string so installs remain deterministic.
func ResolveSDKVersion(sdkRepoRoot string) string {
	cmd := exec.Command("git", "describe", "--tags", "--abbrev=0")
	cmd.Dir = sdkRepoRoot

	output, err := cmd.Output()
	if err != nil {
		return "0.0.0"
	}

	version := strings.TrimSpace(string(output))
	if version == "" {
		return "0.0.0"
	}

	return version
}
