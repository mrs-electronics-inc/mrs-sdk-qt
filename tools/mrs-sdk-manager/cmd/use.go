package cmd

import (
	"mrs-sdk-manager/use"

	"github.com/spf13/cobra"
)

var useCmd = &cobra.Command{
	Use:   "use <sdk-version>",
	Short: "Pin an SDK version for the current project",
	Long:  "Generate project-local configuration files that pin a specific SDK version for CMake and/or QMake projects.",
	Args:  cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		return use.Use(args[0])
	},
}

func init() {
	rootCmd.AddCommand(useCmd)
}
