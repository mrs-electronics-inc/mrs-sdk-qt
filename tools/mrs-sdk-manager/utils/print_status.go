package utils

import (
	"fmt"

	"github.com/fatih/color"
)

func PrintTaskStart(message string) {
	color.New(color.FgHiCyan, color.Bold).Printf("===== %s\n", message)
}

func PrintSuccess(message string) {
	color.New(color.FgGreen, color.Bold).Printf("===== ✓ %s\n", message)
}

func PrintError(title, message string) {
	color.New(color.FgRed, color.Bold).Printf("\n===== %s\n", title)
	color.Red(message)
	fmt.Println()
}
