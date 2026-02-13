package use

import (
	"embed"
	"errors"
	"fmt"
	"io/fs"
	"mrs-sdk-manager/env"
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

	// Resolve MRS_SDK_QT_ROOT from mrs-sdk-manager env.
	envConfig, err := env.ReadAll()
	if err != nil {
		return fmt.Errorf("failed to read env config: %w", err)
	}
	sdkRoot := envConfig[env.MRS_SDK_QT_ROOT.Key]
	if sdkRoot == "" {
		return fmt.Errorf("MRS_SDK_QT_ROOT is not set. Run: mrs-sdk-manager env -w MRS_SDK_QT_ROOT=<path>")
	}

	// Validate version is installed
	sdkVersionDir := filepath.Join(sdkRoot, version)
	if _, err := os.Stat(sdkVersionDir); err != nil {
		if errors.Is(err, fs.ErrNotExist) {
			return fmt.Errorf("SDK version %s is not installed (expected at %s)", version, sdkVersionDir)
		}
		return fmt.Errorf("failed to check SDK version directory: %w", err)
	}

	cwd, err := os.Getwd()
	if err != nil {
		return fmt.Errorf("failed to get working directory: %w", err)
	}

	// Detect build systems
	hasCMake := fileExists(filepath.Join(cwd, "CMakeLists.txt"))
	hasQMake := hasQMakeProject(cwd)

	if !hasCMake && !hasQMake {
		return fmt.Errorf("no CMakeLists.txt or .pro file found in %s", cwd)
	}

	// Create the mrs-sdk-qt/ directory
	outputDir := filepath.Join(cwd, "mrs-sdk-qt")
	if err := os.MkdirAll(outputDir, 0755); err != nil {
		return fmt.Errorf("failed to create mrs-sdk-qt directory: %w", err)
	}

	data := templateData{Version: version}

	// version.conf is always generated (both build systems read from it)
	configFiles := []string{"version.conf"}

	if hasCMake {
		configFiles = append(configFiles, "toolchain.cmake", "project.cmake")
	}
	if hasQMake {
		configFiles = append(configFiles, "toolchain.pri", "project.pri")
	}

	for _, fileName := range configFiles {
		templateName := "templates/" + fileName
		outputPath := filepath.Join(outputDir, fileName)
		if err := writeTemplateFile(templateName, outputPath, data); err != nil {
			return fmt.Errorf("failed to write %s: %w", fileName, err)
		}
	}

	color.White("  Created mrs-sdk-qt/ configuration directory")

	if hasCMake {
		fmt.Println()
		color.White("  CMake usage:")
		color.White("    1. Set in Qt Creator kit: CMAKE_TOOLCHAIN_FILE = %%{sourceDir}/mrs-sdk-qt/toolchain.cmake")
		color.White("    2. Set in Qt Creator kit: MRS_SDK_QT_TOOLCHAIN_ID = desktop-qt6 (or yocto-qt5, etc.)")
		color.White("    3. In CMakeLists.txt, add:")
		color.Cyan(`       include("mrs-sdk-qt/project.cmake")`)
	}

	if hasQMake {
		fmt.Println()
		color.White("  QMake usage:")
		color.White("    1. Set in Qt Creator kit: MRS_SDK_QT_TOOLCHAIN_ID = desktop-qt6 (or yocto-qt5, etc.)")
		color.White("    2. In your .pro file, add:")
		color.Cyan(`       include("mrs-sdk-qt/toolchain.pri")`)
		color.Cyan(`       include("mrs-sdk-qt/project.pri")`)
	}

	fmt.Println()

	utils.PrintSuccess(fmt.Sprintf("Project configured to use SDK version %s", version))
	return nil
}

func fileExists(path string) bool {
	_, err := os.Stat(path)
	return err == nil
}

func hasQMakeProject(dir string) bool {
	entries, err := os.ReadDir(dir)
	if err != nil {
		return false
	}
	for _, entry := range entries {
		if !entry.IsDir() && filepath.Ext(entry.Name()) == ".pro" {
			return true
		}
	}
	return false
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
