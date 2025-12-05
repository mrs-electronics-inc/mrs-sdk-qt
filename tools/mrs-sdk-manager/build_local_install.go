package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/fatih/color"
)

// InstallPaths represents the source and destination paths for a build configuration
type InstallPaths struct {
	QtVersion  string // "qt5" or "qt6"
	OS         string // "buildroot", "yocto", "desktop"
	Processor  string // "linux_x86_64", "linux_arm"
	Device     string // "desktop", "fusion", "mconn"
	BuildDir   string // Path to the build directory
	InstallDir string // Path to the SDK installation directory
}

// InstallBuilds copies all compiled libraries and configuration files to the SDK installation tree
func InstallBuilds(sdkRoot string) error {
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

	// Default to version 0.0.0
	sdkVersion := "0.0.0"

	// Install include files and cmake/qmake files (only once)
	if err := installStaticFiles(sdkRoot, sdkInstallRoot, sdkVersion); err != nil {
		return fmt.Errorf("failed to install static files: %w", err)
	}

	configs := getInstallPaths(sdkRoot, sdkInstallRoot, sdkVersion)
	if err := installAllLibraries(configs); err != nil {
		return fmt.Errorf("failed to install libraries: %w", err)
	}

	color.New(color.FgGreen, color.Bold).Println("===== ✓ All SDK components installed successfully")
	return nil
}

// installStaticFiles copies include and configuration files to the SDK installation
func installStaticFiles(sdkRoot, sdkInstallRoot, sdkVersion string) error {
	sdkVersionDir := filepath.Join(sdkInstallRoot, sdkVersion)

	type fileMapping struct {
		name string
		src  string
		dst  string
	}

	files := []fileMapping{
		{
			name: "includes",
			src:  filepath.Join(sdkRoot, "lib", "include"),
			dst:  filepath.Join(sdkVersionDir, "include"),
		},
		{
			name: "CMake helpers",
			src:  filepath.Join(sdkRoot, "lib", "cmake"),
			dst:  filepath.Join(sdkVersionDir, "lib", "cmake"),
		},
		{
			name: "QMake helpers",
			src:  filepath.Join(sdkRoot, "lib", "qmake"),
			dst:  filepath.Join(sdkVersionDir, "lib", "qmake"),
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

func installAllLibraries(configs []InstallPaths) error {
	// Install library files for each configuration
	color.White("Installing compiled libraries...")
	// Generate status messages.
	// Calculate the maximum status message length for alignment of output.
	maxStatusLen := 0
	var statusMsgs []string
	for i, config := range configs {
		s := fmt.Sprintf("[%d/%d] Copying lib for %s/%s", i+1, len(configs), config.Device, config.OS)
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
		if err := installLibrary(config); err != nil {
			return fmt.Errorf("failed to install %s %s: %w", config.Device, config.OS, err)
		}
		color.Green("✓ Success.\n")
	}

	return nil
}

// installLibrary copies a compiled library to the appropriate installation location
func installLibrary(config InstallPaths) error {
	srcLib := filepath.Join(config.BuildDir, "artifacts", "libmrs-sdk-qt.a")
	dstLibDir := filepath.Join(
		config.InstallDir,
		"lib",
		config.QtVersion,
		config.OS,
		config.Processor+"_"+config.Device,
	)

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

// getInstallPaths returns the install paths for all build configurations
func getInstallPaths(sdkRoot, sdkInstallRoot, sdkVersion string) []InstallPaths {
	sdkVersionDir := filepath.Join(sdkInstallRoot, sdkVersion)

	paths := []InstallPaths{
		{
			QtVersion:  "qt5",
			OS:         "desktop",
			Processor:  "linux_x86_64",
			Device:     "desktop",
			BuildDir:   filepath.Join(sdkRoot, "build", "desktop-qt5"),
			InstallDir: sdkVersionDir,
		},
		{
			QtVersion:  "qt6",
			OS:         "desktop",
			Processor:  "linux_x86_64",
			Device:     "desktop",
			BuildDir:   filepath.Join(sdkRoot, "build", "desktop-qt6"),
			InstallDir: sdkVersionDir,
		},
		{
			QtVersion:  "qt5",
			OS:         "buildroot",
			Processor:  "linux_arm",
			Device:     "fusion",
			BuildDir:   filepath.Join(sdkRoot, "build", "fusion-buildroot"),
			InstallDir: sdkVersionDir,
		},
		{
			QtVersion:  "qt5",
			OS:         "buildroot",
			Processor:  "linux_arm",
			Device:     "mconn",
			BuildDir:   filepath.Join(sdkRoot, "build", "mconn-buildroot"),
			InstallDir: sdkVersionDir,
		},
		{
			QtVersion:  "qt5",
			OS:         "yocto",
			Processor:  "linux_arm",
			Device:     "mconn",
			BuildDir:   filepath.Join(sdkRoot, "build", "mconn-yocto"),
			InstallDir: sdkVersionDir,
		},
	}

	return paths
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
