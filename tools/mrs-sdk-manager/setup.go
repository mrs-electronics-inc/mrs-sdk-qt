package main

import (
	"embed"
	"fmt"
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

func Setup(sdkVersion string) error {
	fmt.Println("Setting up the MRS SDK...")

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

	// Phase 4: Write static files only if they don't exist
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

	fmt.Printf("SUCCESS. SDK config saved in %s\n", configDir)
	return nil
}

// validateSetup checks all preconditions before making any changes
func validateSetup(mrsSdkQtRoot, sdkVersion string) error {
	// Check if SDK root exists
	if _, err := os.Stat(mrsSdkQtRoot); err != nil {
		if os.IsNotExist(err) {
			return fmt.Errorf("could not find SDK installation in %s", mrsSdkQtRoot)
		}
		return fmt.Errorf("failed to stat SDK root: %w", err)
	}

	// Check if version directory exists
	sdkVersionDir := filepath.Join(mrsSdkQtRoot, sdkVersion)
	if _, err := os.Stat(sdkVersionDir); err != nil {
		if os.IsNotExist(err) {
			return fmt.Errorf("could not find directory %s", sdkVersionDir)
		}
		return fmt.Errorf("failed to stat SDK version directory: %w", err)
	}

	return nil
}

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

func writeStaticFile(filePath, outputPath string) error {
	if _, err := os.Stat(outputPath); !os.IsNotExist(err) {
		// File exists, skip writing
		return nil
	}

	content, err := templates.ReadFile(filePath)
	if err != nil {
		return err
	}

	return os.WriteFile(outputPath, content, 0644)
}

// updateSymlink removes the old current symlink and creates a new one pointing to sdkVersionDir
func updateSymlink(mrsSdkQtRoot, sdkVersionDir string) error {
	currentLink := filepath.Join(mrsSdkQtRoot, "current")
	if err := os.Remove(currentLink); err != nil && !os.IsNotExist(err) {
		return fmt.Errorf("failed to remove old symlink: %w", err)
	}

	if err := os.Symlink(sdkVersionDir, currentLink); err != nil {
		return fmt.Errorf("failed to create symlink: %w", err)
	}

	return nil
}
