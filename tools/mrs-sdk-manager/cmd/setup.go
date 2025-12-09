package cmd

import (
	"mrs-sdk-manager/setup"

	"github.com/spf13/cobra"
)

var setupCmd = &cobra.Command{
	Use:   "setup <sdk-version>",
	Short: "Setup a specific SDK version",
	Long:  "Setup and activate a specific SDK version",
	Args:  cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		return setup.Setup(args[0])
	},
}

func init() {
	rootCmd.AddCommand(setupCmd)
}
