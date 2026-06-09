package cmd

import (
	buildLocal "mrs-sdk-manager/build_local"

	"github.com/spf13/cobra"
)

var buildLocalCmd = &cobra.Command{
	Use:   "build-local [TARGET]",
	Short: "Build SDK libraries and/or demo projects from source",
	Long:  "Build SDK libraries and/or demo projects from source. TARGET may be one of: all, libs, demos. Defaults to all.",
	Args:  cobra.MaximumNArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		targetArg := ""
		if len(args) == 1 {
			targetArg = args[0]
		}

		scope, err := buildLocal.ParseBuildScope(targetArg)
		if err != nil {
			return err
		}

		installFlag, err := cmd.Flags().GetBool("install")
		if err != nil {
			return err
		}

		return buildLocal.Run(scope, installFlag)
	},
}

func init() {
	buildLocalCmd.Flags().BoolP("install", "i", false, "Install compiled libraries to $MRS_SDK_QT_ROOT")
	rootCmd.AddCommand(buildLocalCmd)
}
