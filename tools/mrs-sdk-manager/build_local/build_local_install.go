package buildlocal

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/fatih/color"
)

// InstallBuilds copies all compiled libraries and configuration files to the SDK installation tree
func InstallBuilds(sdkRepoRoot string) error {
	homeDir, err := os.UserHomeDir()
	if err != nil {
		return fmt.Errorf("failed to get home directory: %w", err)
	}

	sdkInstallRoot := filepath.Join(homeDir, "mrs-sdk-qt")

	color.New(color.FgHiCyan, color.Bold).Printf("===== Installing SDK in %s...\n", sdkInstallRoot)

	// Create SDK root directory if it doesn't exist
	if err := os.MkdirAll(sdkInstallRoot, 0755); err != nil {
		return fmt.Errorf("failed to create SDK root directory: %w", err)
	}

	// Default to version 0.0.0 for local/dev builds
	const sdkVersion = "0.0.0"
	sdkDevVersionRoot := filepath.Join(sdkInstallRoot, sdkVersion)

	// Install include files and CMake/QMake files (only once)
	if err := installStaticFiles(sdkRepoRoot, sdkDevVersionRoot); err != nil {
		return fmt.Errorf("failed to install static files: %w", err)
	}

	if err := installAllLibraries(AllBuildTargets(), sdkRepoRoot, sdkDevVersionRoot); err != nil {
		return fmt.Errorf("failed to install libraries: %w", err)
	}

	color.New(color.FgGreen, color.Bold).Println("===== ✓ All SDK components installed successfully")
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
	return filepath.Walk(src, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		// Get relative path
		relPath, err := filepath.Rel(src, path)
		if err != nil {
			return err
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
