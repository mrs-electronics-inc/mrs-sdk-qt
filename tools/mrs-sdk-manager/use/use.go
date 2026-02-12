package use

import (
	"embed"
	"errors"
	"fmt"
	"io/fs"
	"mrs-sdk-manager/utils"
	"os"
	"path/filepath"
	"text/template"

	"github.com/fatih/color"
)

//go:embed templates/*
var templates embed.FS

type templateData struct {
	Version string
}

// Use generates project-local SDK configuration files that pin a specific SDK version.
func Use(version string) error {
	utils.PrintTaskStart("Configuring project SDK version...")

	homeDir, err := os.UserHomeDir()
	if err != nil {
		return fmt.Errorf("failed to find home directory: %w", err)
	}

	// Validate version is installed
	sdkVersionDir := filepath.Join(homeDir, "mrs-sdk-qt", version)
	if _, err := os.Stat(sdkVersionDir); err != nil {
		if errors.Is(err, fs.ErrNotExist) {
			return fmt.Errorf("SDK version %s is not installed (expected at %s)", version, sdkVersionDir)
		}
		return fmt.Errorf("failed to check SDK version directory: %w", err)
	}

	// Detect build systems in current directory
	cwd, err := os.Getwd()
	if err != nil {
		return fmt.Errorf("failed to get working directory: %w", err)
	}

	hasCMake := fileExists(filepath.Join(cwd, "CMakeLists.txt"))
	hasQMake := hasQMakeProject(cwd)

	if !hasCMake && !hasQMake {
		return fmt.Errorf("no CMakeLists.txt or .pro file found in current directory")
	}

	data := templateData{Version: version}

	if hasCMake {
		outputPath := filepath.Join(cwd, "mrs-sdk-qt.cmake")
		if err := writeTemplateFile("templates/mrs-sdk-qt.cmake", outputPath, data); err != nil {
			return fmt.Errorf("failed to write CMake helper: %w", err)
		}
		color.White("  Created %s", outputPath)
		fmt.Println()
		fmt.Println()
		color.White("  CMake usage:")
		color.White("    Replace your global-config.cmake and config.cmake includes with:")
		color.Cyan(`    include("mrs-sdk-qt.cmake")`)
		fmt.Println()
	}

	if hasQMake {
		outputPath := filepath.Join(cwd, "mrs-sdk-qt.pri")
		if err := writeTemplateFile("templates/mrs-sdk-qt.pri", outputPath, data); err != nil {
			return fmt.Errorf("failed to write QMake helper: %w", err)
		}
		color.White("  Created %s", outputPath)
		fmt.Println()
		fmt.Println()
		color.White("  QMake usage:")
		color.White("    Replace your global-config.pri and config.pri includes with:")
		color.Cyan(`    include("mrs-sdk-qt.pri")`)
		fmt.Println()
	}

	utils.PrintSuccess(fmt.Sprintf("Project configured to use SDK version %s", version))
	return nil
}

func fileExists(path string) bool {
	info, err := os.Stat(path)
	return err == nil && !info.IsDir()
}

func hasQMakeProject(dir string) bool {
	matches, err := filepath.Glob(filepath.Join(dir, "*.pro"))
	return err == nil && len(matches) > 0
}

func writeTemplateFile(templateName, outputPath string, data templateData) error {
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
