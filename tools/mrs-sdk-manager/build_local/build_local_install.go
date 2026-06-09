package buildlocal

import (
	"fmt"
	"mrs-sdk-manager/utils"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/fatih/color"
)

// InstallBuilds copies all compiled libraries and configuration files to the SDK installation tree
func InstallBuilds(sdkRepoRoot string) error {
	// Resolve the installation root from the same environment variable that
	// consumer projects already use. This keeps tool and SDK installation paths consistent
	// across local development workflows.
	sdkInstallRoot, err := utils.ResolveSDKInstallRoot()
	if err != nil {
		return err
	}

	utils.PrintTaskStart(fmt.Sprintf("Installing SDK in %s...", sdkInstallRoot))

	// Create SDK root directory if it doesn't exist
	if err := os.MkdirAll(sdkInstallRoot, 0755); err != nil {
		return fmt.Errorf("failed to create SDK root directory: %w", err)
	}

	// Mirror the versioning strategy used by the library CMake build so that a
	// repo-local `build-local --install` produces an installation tree under the
	// same version label that the compiled artifacts report internally. The
	// historical 0.0.0 fallback remains in place for untagged development clones.
	sdkVersion := utils.ResolveSDKVersion(sdkRepoRoot)
	sdkDevVersionRoot := filepath.Join(sdkInstallRoot, sdkVersion)

	// Install include files and CMake/QMake files (only once)
	if err := installStaticFiles(sdkRepoRoot, sdkDevVersionRoot); err != nil {
		return fmt.Errorf("failed to install static files: %w", err)
	}

	if err := installAllLibraries(AllBuildTargets(), sdkRepoRoot, sdkDevVersionRoot); err != nil {
		return fmt.Errorf("failed to install libraries: %w", err)
	}

	utils.PrintSuccess("All SDK components installed successfully")
	return nil
}

// InstallDemoSources copies the repository demo source tree into the
// versioned SDK installation so consumers can check out example projects
// without needing generated wrapper files tracked in Git.
func InstallDemoSources(sdkRepoRoot string) error {
	sdkInstallRoot, err := utils.ResolveSDKInstallRoot()
	if err != nil {
		return err
	}

	sdkVersion := utils.ResolveSDKVersion(sdkRepoRoot)
	demoInstallRoot := filepath.Join(sdkInstallRoot, sdkVersion, "demos")
	demoSourceRoot := filepath.Join(sdkRepoRoot, "demos")

	utils.PrintTaskStart(fmt.Sprintf("Installing demo sources in %s...", demoInstallRoot))

	if err := copyDirectory(demoSourceRoot, demoInstallRoot); err != nil {
		return fmt.Errorf("failed to copy demo sources: %w", err)
	}

	utils.PrintSuccess("All demo sources installed successfully")
	return nil
}

// installStaticFiles copies include and configuration files to the SDK installation
func installStaticFiles(sdkRepoRoot, sdkDevVersionRoot string) error {

	type fileMapping struct {
		name string
		src  string
		dst  string
	}

	files := []fileMapping{
		{
			name: "includes",
			src:  filepath.Join(sdkRepoRoot, "lib", "include"),
			dst:  filepath.Join(sdkDevVersionRoot, "include"),
		},
		{
			name: "CMake helpers",
			src:  filepath.Join(sdkRepoRoot, "lib", "cmake"),
			dst:  filepath.Join(sdkDevVersionRoot, "lib", "cmake"),
		},
		{
			name: "QMake helpers",
			src:  filepath.Join(sdkRepoRoot, "lib", "qmake"),
			dst:  filepath.Join(sdkDevVersionRoot, "lib", "qmake"),
		},
	}

	color.White("Installing static files...")

	// Generate status messages.
	// Calculate the maximum status message length for alignment of output.
	maxStatusLen := 0
	var statusMsgs []string
	for i, file := range files {
		s := fmt.Sprintf("[%d/%d] Copying %s", i+1, len(files), file.name)
		statusMsgs = append(statusMsgs, s)
		if len(s) > maxStatusLen {
			maxStatusLen = len(s)
		}
	}

	for i, file := range files {
		s := color.WhiteString(statusMsgs[i])
		// Pad the message to align the success indicators.
		padding := strings.Repeat(" ", maxStatusLen-len(statusMsgs[i])+3)
		fmt.Print(s + padding)
		if err := copyDirectory(file.src, file.dst); err != nil {
			return fmt.Errorf("failed to copy directory: %w", err)
		}
		color.Green("✓ Success.\n")
	}

	return nil
}

func installAllLibraries(installTargets []BuildTarget, sdkRepoRoot, sdkDevVersionRoot string) error {
	// Install library files for each configuration
	color.White("Installing compiled libraries...")
	// Generate status messages.
	// Calculate the maximum status message length for alignment of output.
	maxStatusLen := 0
	var statusMsgs []string
	for i, target := range installTargets {
		s := fmt.Sprintf("[%d/%d] Copying lib from %s", i+1, len(installTargets), target.BuildDir())
		statusMsgs = append(statusMsgs, s)
		if len(s) > maxStatusLen {
			maxStatusLen = len(s)
		}
	}
	for i, target := range installTargets {
		s := color.WhiteString(statusMsgs[i])
		// Pad the message to align the success indicators.
		padding := strings.Repeat(" ", maxStatusLen-len(statusMsgs[i])+3)
		fmt.Print(s + padding)
		if err := installLibrary(target, sdkRepoRoot, sdkDevVersionRoot); err != nil {
			fmt.Println()
			return fmt.Errorf("failed to install %s: %w", target.BuildDir(), err)
		}
		color.Green("✓ Success.\n")
	}

	return nil
}

// installLibrary copies a compiled library to the appropriate installation location
func installLibrary(target BuildTarget, sdkRepoRoot, sdkDevVersionRoot string) error {
	srcLib := filepath.Join(sdkRepoRoot, "build", target.BuildDir(), "artifacts", "libmrs-sdk-qt.a")
	var dstLibDir = filepath.Join(sdkDevVersionRoot, target.InstTreeDir())

	// Create the destination directory
	if err := os.MkdirAll(dstLibDir, 0755); err != nil {
		return fmt.Errorf("failed to create directory %s: %w", dstLibDir, err)
	}

	// Copy the library file
	dstLib := filepath.Join(dstLibDir, "libmrs-sdk-qt.a")
	if err := copyFile(srcLib, dstLib); err != nil {
		return fmt.Errorf("failed to copy library: %w", err)
	}

	return nil
}

// copyFile copies a single file from src to dst
func copyFile(src, dst string) error {
	data, err := os.ReadFile(src)
	if err != nil {
		return err
	}
	return os.WriteFile(dst, data, 0644)
}

// copyDirectory recursively copies a directory from src to dst
func copyDirectory(src, dst string) error {
	trackedFiles, trackedDirs, err := trackedPathsForDirectory(src)
	if err != nil {
		return err
	}

	return filepath.Walk(src, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		// Get relative path
		relPath, err := filepath.Rel(src, path)
		if err != nil {
			return err
		}

		if relPath != "." {
			if info.IsDir() {
				if _, ok := trackedDirs[relPath]; !ok {
					return filepath.SkipDir
				}
			} else if _, ok := trackedFiles[relPath]; !ok {
				return nil
			}
		}

		dstPath := filepath.Join(dst, relPath)

		if info.IsDir() {
			// Create directory
			return os.MkdirAll(dstPath, info.Mode().Perm())
		} else {
			// Copy file
			data, err := os.ReadFile(path)
			if err != nil {
				return err
			}
			return os.WriteFile(dstPath, data, info.Mode().Perm())
		}
	})
}

func trackedPathsForDirectory(src string) (map[string]struct{}, map[string]struct{}, error) {
	gitRootOutput, err := exec.Command("git", "-C", src, "rev-parse", "--show-toplevel").Output()
	if err != nil {
		return nil, nil, fmt.Errorf("failed to resolve git root for %s: %w", src, err)
	}

	gitRoot := strings.TrimSpace(string(gitRootOutput))
	srcRelToGitRoot, err := filepath.Rel(gitRoot, src)
	if err != nil {
		return nil, nil, fmt.Errorf("failed to resolve %s relative to git root %s: %w", src, gitRoot, err)
	}

	lsFilesCmd := exec.Command("git", "-C", src, "ls-files", "--full-name", "--", ".")
	lsFilesOutput, err := lsFilesCmd.Output()
	if err != nil {
		return nil, nil, fmt.Errorf("failed to list tracked files for %s: %w", src, err)
	}

	trackedFiles := map[string]struct{}{}
	trackedDirs := map[string]struct{}{
		".": {},
	}

	for _, line := range strings.Split(strings.TrimSpace(string(lsFilesOutput)), "\n") {
		if strings.TrimSpace(line) == "" {
			continue
		}

		trackedRelPath, err := filepath.Rel(srcRelToGitRoot, filepath.FromSlash(line))
		if err != nil {
			return nil, nil, fmt.Errorf("failed to resolve tracked path %s relative to %s: %w", line, src, err)
		}

		if trackedRelPath == "." || strings.HasPrefix(trackedRelPath, "..") {
			continue
		}

		trackedRelPath = filepath.Clean(trackedRelPath)
		trackedFiles[trackedRelPath] = struct{}{}

		parent := filepath.Dir(trackedRelPath)
		for parent != "." && parent != string(filepath.Separator) {
			trackedDirs[parent] = struct{}{}
			parent = filepath.Dir(parent)
		}
	}

	return trackedFiles, trackedDirs, nil
}
