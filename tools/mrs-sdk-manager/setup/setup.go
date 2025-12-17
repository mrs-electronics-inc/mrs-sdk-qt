package setup

import (
	"embed"
	"errors"
	"fmt"
	"io/fs"
	"mrs-sdk-manager/utils"
	"os"
	"path/filepath"
	"text/template"
)

//go:embed templates/*
var templates embed.FS

type globalConfigData struct {
	MRS_SDK_QT_ROOT    string
	MRS_SDK_QT_VERSION string
}

// Setup activates a specific SDK version.
//
// Preconditions:
//   - SDK root directory ($HOME/mrs-sdk-qt) must already exist
//   - The specified SDK version directory must exist at $HOME/mrs-sdk-qt/<sdk-version>
//
// Note: The setup command does not create the SDK root directory.
// It is assumed to be created by an external installation process.
// If the root directory does not exist, Setup will return an error.
func Setup(sdkVersion string) error {
	utils.PrintTaskStart("Setting up the MRS SDK...")

	homeDir, err := os.UserHomeDir()
	if err != nil {
		return fmt.Errorf("failed to find home directory: %w", err)
	}

	mrsSdkQtRoot := filepath.Join(homeDir, "mrs-sdk-qt")

	// Phase 1: Validate all preconditions
	if err := validateSetup(mrsSdkQtRoot, sdkVersion); err != nil {
		return err
	}

	configDir := filepath.Join(homeDir, ".config", "mrs-sdk-qt")
	sdkVersionDir := filepath.Join(mrsSdkQtRoot, sdkVersion)

	// Phase 2: Ensure config directory exists
	if err := os.MkdirAll(configDir, 0755); err != nil {
		return fmt.Errorf("failed to create config directory: %w", err)
	}

	// Phase 3: Write/update global-config (always update as it contains version)
	data := globalConfigData{
		MRS_SDK_QT_ROOT:    mrsSdkQtRoot,
		MRS_SDK_QT_VERSION: sdkVersion,
	}
	if err := writeTemplateFile("templates/global-config", filepath.Join(configDir, "global-config"), data); err != nil {
		return fmt.Errorf("failed to write global-config: %w", err)
	}

	// Phase 4: Write static files. Existing files will be overwritten.
	if err := writeStaticFile("templates/global-config.cmake", filepath.Join(configDir, "global-config.cmake")); err != nil {
		return fmt.Errorf("failed to write CMake config: %w", err)
	}

	if err := writeStaticFile("templates/global-config.pri", filepath.Join(configDir, "global-config.pri")); err != nil {
		return fmt.Errorf("failed to write QMake config: %w", err)
	}

	// Phase 5: Update symlink
	if err := updateSymlink(mrsSdkQtRoot, sdkVersionDir); err != nil {
		return err
	}

	utils.PrintSuccess(fmt.Sprintf("SDK config saved in %s", configDir))
	return nil
}

// validateSetup checks all preconditions before making any config changes.
// Note that the SDK should already be installed when this command is run,
// which is why the checks are strict.
func validateSetup(mrsSdkQtRoot, sdkVersion string) error {
	// Check if SDK root exists.
	if _, err := os.Stat(mrsSdkQtRoot); err != nil {
		if errors.Is(err, fs.ErrNotExist) {
			return fmt.Errorf("could not find SDK installation in %s", mrsSdkQtRoot)
		}
		return fmt.Errorf("failed to stat SDK root: %w", err)
	}

	// Check if version directory exists
	sdkVersionDir := filepath.Join(mrsSdkQtRoot, sdkVersion)
	if _, err := os.Stat(sdkVersionDir); err != nil {
		if errors.Is(err, fs.ErrNotExist) {
			return fmt.Errorf("could not find directory %s", sdkVersionDir)
		}
		return fmt.Errorf("failed to stat SDK version directory: %w", err)
	}

	return nil
}

// writeTemplateFile takes global configuration information and puts it into the specified template.
func writeTemplateFile(templateName, outputPath string, data globalConfigData) error {
	content, err := templates.ReadFile(templateName)
	if err != nil {
		return err
	}

	tmpl, err := template.New(filepath.Base(templateName)).Parse(string(content))
	if err != nil {
		return err
	}

	f, err := os.Create(outputPath)
	if err != nil {
		return err
	}
	defer f.Close()

	return tmpl.Execute(f, data)
}

// writeStaticFile reads the file at filePath and writes it to outputPath.
// If a file already exists at outputPath, it will be overwritten.
func writeStaticFile(filePath, outputPath string) error {
	// Read the template file.
	content, err := templates.ReadFile(filePath)
	if err != nil {
		return err
	}

	// Write the template file to the designated location.
	return os.WriteFile(outputPath, content, 0644)
}

// updateSymlink removes the old current symlink and creates a new one pointing to sdkVersionDir.
func updateSymlink(mrsSdkQtRoot, sdkVersionDir string) error {
	// Note that we want to remove current/ even if it's not actually a symlink.
	// This is because current/ should ONLY ever be a symlink.
	// The SDK manager has the authority to remove anything else in current/ as it sees fit.
	currentLink := filepath.Join(mrsSdkQtRoot, "current")
	err := os.Remove(currentLink)
	if err != nil && !errors.Is(err, fs.ErrNotExist) {
		return fmt.Errorf("failed to remove old symlink: %w", err)
	}

	if err := os.Symlink(sdkVersionDir, currentLink); err != nil {
		return fmt.Errorf("failed to create symlink: %w", err)
	}

	return nil
}
