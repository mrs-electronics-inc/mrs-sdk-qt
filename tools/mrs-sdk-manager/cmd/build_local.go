package cmd

import (
	buildLocal "mrs-sdk-manager/build_local"
	"os"

	"github.com/spf13/cobra"
)

var buildLocalCmd = &cobra.Command{
	Use:   "build-local",
	Short: "Build the SDK library from source",
	Long:  "Build the SDK library from source for all supported configurations (MConn/FUSION/desktop across Yocto/Buildroot/desktop OSes)",
	Args:  cobra.NoArgs,
	RunE: func(cmd *cobra.Command, args []string) error {
		if err := buildLocal.Build(); err != nil {
			return err
		}
		installFlag, err := cmd.Flags().GetBool("install")
		if err != nil {
			return err
		}
		if installFlag {
			sdkRoot, err := os.Getwd()
			if err != nil {
				return err
			}
			return buildLocal.InstallBuilds(sdkRoot)
		}
		return nil
	},
}

func init() {
	buildLocalCmd.Flags().BoolP("install", "i", false, "Install compiled libraries to ~/mrs-sdk-qt")
	rootCmd.AddCommand(buildLocalCmd)
}
