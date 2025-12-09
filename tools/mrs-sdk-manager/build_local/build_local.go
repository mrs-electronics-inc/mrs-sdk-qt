package buildlocal

import (
	"bytes"
	"context"
	"fmt"
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
			// A lot of time could have passed while we were waiting for it.
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
		color.New(color.FgRed, color.Bold).Printf("\n===== Build Error in %s:\n", firstErr.config.Target.BuildDir())
		color.Red("%s", firstErr.err.Error())
		return fmt.Errorf("build failed for %s", firstErr.config.Target.BuildDir())
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
