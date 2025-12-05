package main

import (
	"bytes"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/fatih/color"
)

// BuildConfig represents a single build configuration
type BuildConfig struct {
	Target   BuildTarget
	CmakeCmd []string
}

// BuildLocal builds the SDK library from source for all supported configurations
func BuildLocal() error {
	// Get the current working directory (SDK root)
	sdkRoot, err := os.Getwd()
	if err != nil {
		return fmt.Errorf("failed to get working directory: %w", err)
	}

	// Verify we're in the mrs-sdk-qt repository
	if err := verifyRepoRoot(sdkRoot); err != nil {
		return err
	}

	color.New(color.FgHiCyan, color.Bold).Println("===== Building MRS SDK libraries from source...")
	configs := getBuildConfigs(sdkRoot)
	if err := runAllBuilds(sdkRoot, configs); err != nil {
		return err
	}

	color.New(color.FgGreen, color.Bold).Println("===== ✓ All builds completed successfully")
	return nil
}

// verifyRepoRoot verifies that we're in the mrs-sdk-qt repository root
func verifyRepoRoot(sdkRoot string) error {
	// Get the git repository root
	cmd := exec.Command("git", "rev-parse", "--show-toplevel")
	cmd.Dir = sdkRoot
	output, err := cmd.Output()
	if err != nil {
		return fmt.Errorf("not in a git repository")
	}

	gitRoot := strings.TrimSpace(string(output))

	// Check if we're at the repository root
	if gitRoot != sdkRoot {
		return fmt.Errorf("not at repository root (current: %s, root: %s)", sdkRoot, gitRoot)
	}

	// Verify it's the mrs-sdk-qt repository by checking remote origin URL
	cmd = exec.Command("git", "config", "--get", "remote.origin.url")
	cmd.Dir = sdkRoot
	output, err = cmd.Output()
	if err != nil {
		return fmt.Errorf("failed to get remote origin URL")
	}

	remoteURL := strings.TrimSpace(string(output))
	repoName := filepath.Base(strings.TrimSuffix(remoteURL, ".git"))

	if repoName != "mrs-sdk-qt" {
		return fmt.Errorf("not in the mrs-sdk-qt repository (found: %s)", repoName)
	}

	return nil
}

func runAllBuilds(sdkRoot string, configs []BuildConfig) error {
	maxStatusLen := 0
	var statusMsgs []string
	for i, config := range configs {
		s := fmt.Sprintf("[%d/%d] Building SDK lib for %s", i+1, len(configs), config.Target.BuildDir())
		statusMsgs = append(statusMsgs, s)
		if len(s) > maxStatusLen {
			maxStatusLen = len(s)
		}
	}

	for i, config := range configs {
		s := color.WhiteString(statusMsgs[i])
		// Pad the message to align the success indicators.
		padding := strings.Repeat(" ", maxStatusLen-len(statusMsgs[i])+3)
		fmt.Print(s + padding)

		if err := runBuild(sdkRoot, config); err != nil {
			color.Red("\n%s", err)
			return fmt.Errorf("build failed for %s/%s", config.Target.Device, config.Target.OS)
		}
		color.Green("✓ Success.\n")
	}

	return nil
}

// runBuild executes the CMake configure and build steps for a configuration
func runBuild(sdkRoot string, config BuildConfig) error {
	// Get the setup command if there is one.
	envSetupCmd := config.getBuildEnvSetupCmd()

	// Create the build command.
	// Structure: [setup &&] cmake configure && cmake build
	buildDir := config.CmakeCmd[4]
	fullCmd := fmt.Sprintf("%s && /usr/bin/cmake --build %s --target all",
		strings.Join(config.CmakeCmd, " "),
		buildDir,
	)
	if len(envSetupCmd) > 0 {
		fullCmd = fmt.Sprintf("%s && %s", envSetupCmd, fullCmd)
	}

	// Build!!
	cmd := exec.Command("/bin/bash", "-c", fullCmd)
	cmd.Stdout = io.Discard
	var stderrBuf bytes.Buffer
	cmd.Stderr = &stderrBuf // Full control over error output
	cmd.Dir = sdkRoot

	if err := cmd.Run(); err != nil {
		// color.Red("\n%s", stderrBuf.String())
		// return err
		return fmt.Errorf("%s", stderrBuf.String())
	}
	return nil
}

// getBuildConfigs returns all build configurations
func getBuildConfigs(sdkRoot string) []BuildConfig {
	cmakeCmdBuilder := func(b BuildTarget) []string {
		cmd := []string{
			"/usr/bin/cmake",
			"-S", filepath.Join(sdkRoot, "lib"),
			"-B", filepath.Join(sdkRoot, "build", b.BuildDir()),
			"-DCMAKE_GENERATOR:STRING=Ninja",
		}
		switch b.OS {
		case "yocto":
			cmd = append(cmd, "-DCMAKE_SYSROOT:PATH=/home/cpa/yocto-5.12.9/sysroots/cortexa9hf-neon-poky-linux-gnueabi",
				"-DCMAKE_CXX_COMPILER:STRING=/home/cpa/yocto-5.12.9/sysroots/x86_64-pokysdk-linux/usr/bin/arm-poky-linux-gnueabi/arm-poky-linux-gnueabi-g++",
				"-DCMAKE_CXX_COMPILER_TARGET:STRING=arm-poky-linux-gnueabi",
				"-DCMAKE_TOOLCHAIN_FILE:STRING="+filepath.Join(sdkRoot, "lib/cmake/mrs-sdk-qt/toolchains/qt5-yocto.cmake"),
				"-DCMAKE_CXX_FLAGS_INIT:STRING=",
				"-DCMAKE_C_COMPILER_TARGET:STRING=arm-poky-linux-gnueabi")
		case "buildroot":
			cmd = append(cmd, "-DCMAKE_CXX_COMPILER:FILEPATH=/home/cpa/buildroot/output/host/usr/bin/arm-buildroot-linux-gnueabihf-g++",
				"-DCMAKE_PREFIX_PATH:PATH=/home/cpa/buildroot/output/host/usr/arm-buildroot-linux-gnueabihf/sysroot/usr",
				"-DCMAKE_TOOLCHAIN_FILE:STRING="+filepath.Join(sdkRoot, "lib/cmake/mrs-sdk-qt/toolchains/qt5-buildroot.cmake"))
		case "desktop":
			cmd = append(cmd, "-DCMAKE_CXX_COMPILER:FILEPATH=/usr/lib/ccache/g++")
			if b.QtVersion == "qt5" {
				cmd = append(cmd, "-DCMAKE_PREFIX_PATH:PATH=$HOME/Qt/5.15.0/gcc_64",
					"-DCMAKE_TOOLCHAIN_FILE:STRING="+filepath.Join(sdkRoot, "lib/cmake/mrs-sdk-qt/toolchains/qt5-desktop.cmake"))
			} else {
				cmd = append(cmd, "-DCMAKE_PREFIX_PATH:PATH=$HOME/Qt/6.8.0/gcc_64",
					"-DCMAKE_TOOLCHAIN_FILE:STRING="+filepath.Join(sdkRoot, "lib/cmake/mrs-sdk-qt/toolchains/qt6-desktop.cmake"))
			}
			cmd = append(cmd, "-DCMAKE_CXX_FLAGS_INIT:STRING=-DQT_QML_DEBUG")
		}
		cmd = append(cmd, "-DMRS_SDK_QT_TARGET_DEVICE:STRING="+b.Device,
			"-DCMAKE_BUILD_TYPE:STRING="+b.BuildType)
		return cmd
	}

	var configs []BuildConfig
	for _, target := range AllBuildTargets() {
		configs = append(configs, BuildConfig{
			Target:   target,
			CmakeCmd: cmakeCmdBuilder(target),
		})
	}

	return configs
}

func (b *BuildConfig) getBuildEnvSetupCmd() string {
	if b.Target.OS == "yocto" {
		return "source /home/cpa/yocto-5.12.9/environment-setup-cortexa9hf-neon-poky-linux-gnueabi"
	}

	return ""
}
