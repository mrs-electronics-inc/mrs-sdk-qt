package cmd

import (
	"os"

	"github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
	Use:   "mrs-sdk-manager",
	Short: "MRS SDK manager and installer",
	Long:  "mrs-sdk-manager is a tool for managing and installing MRS SDK versions on Debian-based systems.",
}

func Execute() {
	err := rootCmd.Execute()
	if err != nil {
		os.Exit(1)
	}
}
