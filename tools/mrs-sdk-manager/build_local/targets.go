package buildlocal

import (
	"fmt"
	"path/filepath"
	"strings"
)

// BuildTarget represents the parameters for a specific build configuration
type BuildTarget struct {
	QtVersion string // "qt5" or "qt6"
	OS        string // "yocto", "buildroot", "desktop"
	System    string // "linux" only
	Processor string // "x86_64", "arm"
	Device    string // "mconn", "fusion", "desktop"
	BuildType string // "debug"
}

func (b *BuildTarget) BuildDir() string {
	return fmt.Sprintf("%s-%s-%s-%s", b.Device, b.OS, b.QtVersion, strings.ToLower(b.BuildType))
}

func (b *BuildTarget) InstTreeDir() string {
	return filepath.Join("lib", b.QtVersion, b.OS, fmt.Sprintf("%s_%s_%s", b.System, b.Processor, b.Device))
}

func AllBuildTargets() []BuildTarget {
	var allTargets []BuildTarget

	for _, target := range validTargets {
		for _, buildType := range validBuildTypes {
			target.BuildType = buildType
			allTargets = append(allTargets, target)
		}
	}

	return allTargets
}

var validBuildTypes = [...]string{
	"debug",
}

// The order of this slice should NOT change!!!
// These are the targets minus build type.
var validTargets = [...]BuildTarget{
	{
		QtVersion: "qt5",
		OS:        "yocto",
		System:    "linux",
		Processor: "x86_64",
		Device:    "mconn",
	},
	{
		QtVersion: "qt5",
		OS:        "buildroot",
		System:    "linux",
		Processor: "arm",
		Device:    "mconn",
	},
	{
		QtVersion: "qt5",
		OS:        "buildroot",
		System:    "linux",
		Processor: "arm",
		Device:    "fusion",
	},
	{
		QtVersion: "qt5",
		OS:        "desktop",
		System:    "linux",
		Processor: "x86_64",
		Device:    "desktop",
	},
	{
		QtVersion: "qt6",
		OS:        "desktop",
		System:    "linux",
		Processor: "x86_64",
		Device:    "desktop",
	},
}
