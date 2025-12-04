package main

import (
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
	Device   string
	OS       string
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

	color.Green("Building MRS SDK library from source...\n\n")

	configs := getBuildConfigs(sdkRoot)

	for i, config := range configs {
		color.White("[%d/%d] Building SDK (device %s, OS %s)...\n", i+1, len(configs), config.Device, config.OS)
		if err := runBuild(sdkRoot, config); err != nil {
			return fmt.Errorf("build failed for device %s, OS %s: %w", config.Device, config.OS, err)
		}
		color.Green("✓ Build for device %s, OS %s built successfully\n", config.Device, config.OS)
	}

	color.Green("\n✓ All builds completed successfully")
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

// getBuildConfigs returns all build configurations
func getBuildConfigs(sdkRoot string) []BuildConfig {
	configs := []BuildConfig{
		{
			Device: "desktop",
			OS:     "desktop-qt5",
			CmakeCmd: []string{
				"/usr/bin/cmake",
				"-S", filepath.Join(sdkRoot, "lib"),
				"-B", filepath.Join(sdkRoot, "build", "desktop-qt5"),
				"-DCMAKE_GENERATOR:STRING=Ninja",
				"-DCMAKE_CXX_COMPILER:FILEPATH=/usr/lib/ccache/g++",
				"-DCMAKE_PREFIX_PATH:PATH=$HOME/Qt/5.15.0/gcc_64",
				"-DCMAKE_TOOLCHAIN_FILE:STRING=" + filepath.Join(sdkRoot, "lib/cmake/mrs-sdk-qt/toolchains/qt5-desktop.cmake"),
				"-DCMAKE_CXX_FLAGS_INIT:STRING=-DQT_QML_DEBUG",
				"-DMRS_SDK_QT_TARGET_DEVICE:STRING=MConn",
				"-DCMAKE_BUILD_TYPE:STRING=Debug",
			},
		},
		{
			Device: "desktop",
			OS:     "desktop-qt6",
			CmakeCmd: []string{
				"/usr/bin/cmake",
				"-S", filepath.Join(sdkRoot, "lib"),
				"-B", filepath.Join(sdkRoot, "build", "desktop-qt6"),
				"-DCMAKE_GENERATOR:STRING=Ninja",
				"-DCMAKE_CXX_COMPILER:FILEPATH=/usr/lib/ccache/g++-13",
				"-DCMAKE_PREFIX_PATH:PATH=$HOME/Qt/6.8.0/gcc_64",
				"-DCMAKE_TOOLCHAIN_FILE:STRING=" + filepath.Join(sdkRoot, "lib/cmake/mrs-sdk-qt/toolchains/qt6-desktop.cmake"),
				"-DCMAKE_CXX_FLAGS_INIT:STRING=-DQT_QML_DEBUG",
				"-DMRS_SDK_QT_TARGET_DEVICE:STRING=MConn",
				"-DCMAKE_BUILD_TYPE:STRING=Debug",
			},
		},
		{
			Device: "fusion",
			OS:     "buildroot",
			CmakeCmd: []string{
				"/usr/bin/cmake",
				"-S", filepath.Join(sdkRoot, "lib"),
				"-B", filepath.Join(sdkRoot, "build", "fusion-buildroot"),
				"-DCMAKE_GENERATOR:STRING=Ninja",
				"-DCMAKE_CXX_COMPILER:FILEPATH=/home/cpa/buildroot/output/host/usr/bin/arm-buildroot-linux-gnueabihf-g++",
				"-DCMAKE_PREFIX_PATH:PATH=/home/cpa/buildroot/output/host/usr/arm-buildroot-linux-gnueabihf/sysroot/usr",
				"-DCMAKE_TOOLCHAIN_FILE:STRING=" + filepath.Join(sdkRoot, "lib/cmake/mrs-sdk-qt/toolchains/qt5-buildroot.cmake"),
				"-DMRS_SDK_QT_TARGET_DEVICE:STRING=FUSION",
				"-DCMAKE_BUILD_TYPE:STRING=Debug",
			},
		},
		{
			Device: "mconn",
			OS:     "buildroot",
			CmakeCmd: []string{
				"/usr/bin/cmake",
				"-S", filepath.Join(sdkRoot, "lib"),
				"-B", filepath.Join(sdkRoot, "build", "mconn-buildroot"),
				"-DCMAKE_GENERATOR:STRING=Ninja",
				"-DCMAKE_CXX_COMPILER:FILEPATH=/home/cpa/buildroot/output/host/usr/bin/arm-buildroot-linux-gnueabihf-g++",
				"-DCMAKE_PREFIX_PATH:PATH=/home/cpa/buildroot/output/host/usr/arm-buildroot-linux-gnueabihf/sysroot/usr",
				"-DCMAKE_TOOLCHAIN_FILE:STRING=" + filepath.Join(sdkRoot, "lib/cmake/mrs-sdk-qt/toolchains/qt5-buildroot.cmake"),
				"-DMRS_SDK_QT_TARGET_DEVICE:STRING=MConn",
				"-DCMAKE_BUILD_TYPE:STRING=Debug",
			},
		},
		{
			Device: "mconn",
			OS:     "yocto",
			CmakeCmd: []string{
				"/usr/bin/cmake",
				"-S", filepath.Join(sdkRoot, "lib"),
				"-B", filepath.Join(sdkRoot, "build", "mconn-yocto"),
				"-DCMAKE_GENERATOR:STRING=Ninja",
				"-DCMAKE_SYSROOT:PATH=/home/cpa/yocto-5.12.9/sysroots/cortexa9hf-neon-poky-linux-gnueabi",
				"-DCMAKE_CXX_COMPILER:STRING=/home/cpa/yocto-5.12.9/sysroots/x86_64-pokysdk-linux/usr/bin/arm-poky-linux-gnueabi/arm-poky-linux-gnueabi-g++",
				"-DCMAKE_CXX_COMPILER_TARGET:STRING=arm-poky-linux-gnueabi",
				"-DCMAKE_TOOLCHAIN_FILE:STRING=" + filepath.Join(sdkRoot, "lib/cmake/mrs-sdk-qt/toolchains/qt5-yocto.cmake"),
				"-DCMAKE_CXX_FLAGS_INIT:STRING=",
				"-DCMAKE_C_COMPILER_TARGET:STRING=arm-poky-linux-gnueabi",
				"-DMRS_SDK_QT_TARGET_DEVICE:STRING=MConn",
				"-DCMAKE_BUILD_TYPE:STRING=Debug",
			},
		},
	}

	return configs
}

// runBuild executes the CMake configure and build steps for a configuration
func runBuild(sdkRoot string, config BuildConfig) error {
	// For yocto builds, source the environment before running cmake
	if config.OS == "yocto" {
		return runBuildWithEnv(sdkRoot, config)
	}

	// Run CMake configure
	configCmd := exec.Command(config.CmakeCmd[0], config.CmakeCmd[1:]...)
	configCmd.Stdout = io.Discard
	configCmd.Stderr = io.Discard
	configCmd.Dir = sdkRoot

	if err := configCmd.Run(); err != nil {
		return fmt.Errorf("cmake configure failed: %w", err)
	}

	// Run CMake build (extract build directory from config.CmakeCmd)
	// The -B flag is at index 3, so the build directory is at index 4
	buildDir := config.CmakeCmd[4]
	buildCmd := exec.Command("/usr/bin/cmake", "--build", buildDir, "--target", "all")
	buildCmd.Stdout = io.Discard
	buildCmd.Stderr = io.Discard
	buildCmd.Dir = sdkRoot

	if err := buildCmd.Run(); err != nil {
		return fmt.Errorf("cmake build failed: %w", err)
	}

	return nil
}

// runBuildWithEnv runs the build with an environment setup script (for yocto)
func runBuildWithEnv(sdkRoot string, config BuildConfig) error {
	envScript := "/home/cpa/yocto-5.12.9/environment-setup-cortexa9hf-neon-poky-linux-gnueabi"

	// Extract build directory from config.CmakeCmd (the -B flag is at index 3, directory at index 4)
	buildDir := config.CmakeCmd[4]

	// Create a bash command that sources the environment and runs cmake
	bashCmd := fmt.Sprintf("source %s && %s && /usr/bin/cmake --build %s --target all",
		envScript,
		strings.Join(config.CmakeCmd, " "),
		buildDir,
	)

	cmd := exec.Command("/bin/bash", "-c", bashCmd)
	cmd.Stdout = io.Discard
	cmd.Stderr = io.Discard
	cmd.Dir = sdkRoot

	return cmd.Run()
}
