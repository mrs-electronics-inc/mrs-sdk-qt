package buildlocal

import (
	"bytes"
	"context"
	"fmt"
	"mrs-sdk-manager/env"
	"mrs-sdk-manager/utils"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"sync"

	"github.com/fatih/color"
)

// BuildConfig represents a single build configuration
type BuildConfig struct {
	Target   BuildTarget
	CmakeCmd []string
}

// Build builds the SDK library from source for all supported configurations
func Build() error {
	// Get the current working directory (SDK root)
	sdkRoot, err := os.Getwd()
	if err != nil {
		return fmt.Errorf("failed to get working directory: %w", err)
	}

	// Verify we're in the mrs-sdk-qt repository
	if err := verifyRepoRoot(sdkRoot); err != nil {
		return err
	}

	// Read environment config
	envConfig, err := env.ReadAll()
	if err != nil {
		return fmt.Errorf("failed to read environment config: %w", err)
	}

	// Validate all required keys are set
	requiredKeys := []env.EnvVar{
		env.YOCTO_QT5_SYSROOT,
		env.YOCTO_QT5_CXX_COMPILER,
		env.YOCTO_QT5_ENV_SETUP_SCRIPT,
		env.BUILDROOT_QT5_SYSROOT,
		env.BUILDROOT_QT5_CXX_COMPILER,
		env.DESKTOP_CXX_COMPILER,
		env.DESKTOP_QT5_PREFIX,
		env.DESKTOP_QT6_PREFIX,
	}
	var missingKeys []string
	for _, k := range requiredKeys {
		if envConfig[k.Key] == "" {
			missingKeys = append(missingKeys, k.Key)
		}
	}
	if len(missingKeys) > 0 {
		return fmt.Errorf("missing required environment config: %s\nRun 'mrs-sdk-manager env -w KEY=VALUE' to set them", strings.Join(missingKeys, ", "))
	}

	utils.PrintTaskStart("Building MRS SDK libraries from source...")
	configs := getBuildConfigs(sdkRoot, envConfig)
	if err := runAllBuilds(sdkRoot, configs); err != nil {
		return err
	}

	utils.PrintSuccess("All builds completed successfully")
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

type buildError struct {
	config BuildConfig
	err    error
}

func runAllBuilds(sdkRoot string, configs []BuildConfig) error {
	const maxConcurrency = 4
	semaphore := make(chan struct{}, maxConcurrency)
	var wg sync.WaitGroup
	var mu sync.Mutex

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	var firstErr buildError

	numConfigs := len(configs)

	// Pre-calculate all status messages and find max length for column alignment
	statusMsgs := make([]string, numConfigs)
	maxMsgLen := 0
	for i, config := range configs {
		statusMsgs[i] = fmt.Sprintf("[%d/%d] Building SDK lib for %s", i+1, numConfigs, config.Target.BuildDir())
		if len(statusMsgs[i]) > maxMsgLen {
			maxMsgLen = len(statusMsgs[i])
		}
	}

	// Print initial status lines with padding
	for i := range configs {
		padding := strings.Repeat(" ", maxMsgLen-len(statusMsgs[i])+3)
		fmt.Println(color.WhiteString(statusMsgs[i]) + padding + " " + color.YellowString("Pending"))
	}

	for i, config := range configs {
		wg.Add(1)
		go func(i int, config BuildConfig) {
			defer wg.Done()

			// Check if build was cancelled
			if ctx.Err() != nil {
				return
			}

			// Acquire semaphore slot
			semaphore <- struct{}{}
			defer func() { <-semaphore }()

			// Check again after acquiring semaphore.
			// It's possible cancel() was called during the time we were waiting.
			if ctx.Err() != nil {
				return
			}

			// This function handles updating the outputted status of a build.
			updateStatusFunc := func(status string) {
				// Figure out how many lines to move.
				// The cursor is always at the bottom to start.
				linesToMove := numConfigs - i
				padding := strings.Repeat(" ", maxMsgLen-len(statusMsgs[i])+3)
				// Move up to the line for this build using ANSI code.
				fmt.Printf("\033[%dA", linesToMove)
				// Clear the line using ANSI code.
				fmt.Print("\r" + "\033[K")
				// Print the new status line.
				fmt.Println(color.WhiteString(statusMsgs[i]) + padding + " " + status)
				// Move the cursor back down to the bottom using ANSI code.
				fmt.Printf("\033[%dB", linesToMove)
			}

			// Run the build.
			if err := runBuild(sdkRoot, config); err != nil {
				// If an error occurs, and it's the first build to error out,
				// then we need to save it and cancel all the other builds.
				// The mutex is locked immediately to prevent a race for setting the error and cancelling.
				mu.Lock()
				if firstErr.err == nil {
					firstErr.err = err
					firstErr.config = config
					cancel()
				}
				updateStatusFunc(color.RedString("✗ Failed"))
				mu.Unlock()
			} else {
				mu.Lock()
				updateStatusFunc(color.GreenString("✓ Success"))
				mu.Unlock()
			}
		}(i, config)
	}

	wg.Wait()

	// Display first error if one occurred.
	if firstErr.err != nil {
		utils.PrintError(fmt.Sprintf("Build Error in %s:", firstErr.config.Target.BuildDir()), firstErr.err.Error())
		return fmt.Errorf("build failed for %s", firstErr.config.Target.BuildDir())
	}

	return nil
}

// runBuild executes the CMake configure and build steps for a configuration
func runBuild(sdkRoot string, config BuildConfig) error {
	// Create the build command.
	// Structure: [env-setup &&] cmake configure && cmake build
	// The build directory is the value of -B flag (4th index in the cmake command array).
	buildDirArg := config.CmakeCmd[4]
	fullCmd := fmt.Sprintf("%s && /usr/bin/cmake --build %s --target all",
		strings.Join(config.CmakeCmd, " "),
		buildDirArg,
	)

	// Build!!
	cmd := exec.Command("/bin/bash", "-c", fullCmd)
	// Save all output so that we can use it later.
	var outputBuf bytes.Buffer
	cmd.Stdout = &outputBuf
	cmd.Stderr = &outputBuf
	cmd.Dir = sdkRoot

	if err := cmd.Run(); err != nil {
		return fmt.Errorf("%s", outputBuf.String())
	}
	return nil
}

// getBuildConfigs returns all build configurations
func getBuildConfigs(sdkRoot string, envConfig map[string]string) []BuildConfig {
	cmakeCmdBuilder := func(b BuildTarget) []string {
		cmd := []string{
			"/usr/bin/cmake",
			"-S", filepath.Join(sdkRoot, "lib"),
			"-B", filepath.Join(sdkRoot, "build", b.BuildDir()),
			"-DCMAKE_GENERATOR:STRING=Ninja",
		}
		switch b.OS {
		case "yocto":
			cmd = append(cmd, "-DCMAKE_SYSROOT:PATH="+envConfig["YOCTO_QT5_SYSROOT"],
				"-DCMAKE_CXX_COMPILER:STRING="+envConfig["YOCTO_QT5_CXX_COMPILER"],
				"-DCMAKE_CXX_COMPILER_TARGET:STRING=arm-poky-linux-gnueabi",
				"-DCMAKE_TOOLCHAIN_FILE:STRING="+filepath.Join(sdkRoot, "lib/cmake/mrs-sdk-qt/toolchains/yocto-qt5.cmake"),
				"-DCMAKE_CXX_FLAGS_INIT:STRING=",
				"-DCMAKE_C_COMPILER_TARGET:STRING=arm-poky-linux-gnueabi")
		case "buildroot":
			cmd = append(cmd, "-DCMAKE_CXX_COMPILER:FILEPATH="+envConfig["BUILDROOT_QT5_CXX_COMPILER"],
				"-DCMAKE_PREFIX_PATH:PATH="+envConfig["BUILDROOT_QT5_SYSROOT"],
				"-DCMAKE_TOOLCHAIN_FILE:STRING="+filepath.Join(sdkRoot, "lib/cmake/mrs-sdk-qt/toolchains/buildroot-qt5.cmake"))
		case "desktop":
			cmd = append(cmd, "-DCMAKE_CXX_COMPILER:FILEPATH="+envConfig["DESKTOP_CXX_COMPILER"])
			if b.QtVersion == "qt5" {
				cmd = append(cmd, "-DCMAKE_PREFIX_PATH:PATH="+envConfig["DESKTOP_QT5_PREFIX"],
					"-DCMAKE_TOOLCHAIN_FILE:STRING="+filepath.Join(sdkRoot, "lib/cmake/mrs-sdk-qt/toolchains/desktop-qt5.cmake"))
			} else {
				cmd = append(cmd, "-DCMAKE_PREFIX_PATH:PATH="+envConfig["DESKTOP_QT6_PREFIX"],
					"-DCMAKE_TOOLCHAIN_FILE:STRING="+filepath.Join(sdkRoot, "lib/cmake/mrs-sdk-qt/toolchains/desktop-qt6.cmake"))
			}
			cmd = append(cmd, "-DCMAKE_CXX_FLAGS_INIT:STRING=-DQT_QML_DEBUG")
		}
		cmd = append(cmd, "-DMRS_SDK_QT_ROOT:STRING="+os.Getenv("MRS_SDK_QT_ROOT"),
			"-DMRS_SDK_QT_TARGET_DEVICE:STRING="+b.Device,
			"-DCMAKE_BUILD_TYPE:STRING="+b.BuildType)
		return cmd
	}

	var configs []BuildConfig
	for _, target := range AllBuildTargets() {
		config := BuildConfig{
			Target:   target,
			CmakeCmd: cmakeCmdBuilder(target),
		}
		configs = append(configs, config)
	}

	return configs
}
