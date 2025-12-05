package main

import (
	"os"

	"github.com/spf13/cobra"
)

func main() {
	if err := rootCmd.Execute(); err != nil {
		os.Exit(1)
	}
}

var rootCmd = &cobra.Command{
	Use:   "mrs-sdk-manager",
	Short: "MRS SDK manager and installer",
	Long:  "mrs-sdk-manager is a tool for managing and installing MRS SDK versions",
}

var setupCmd = &cobra.Command{
	Use:   "setup <sdk-version>",
	Short: "Setup a specific SDK version",
	Long:  "Setup and activate a specific SDK version",
	Args:  cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		return Setup(args[0])
	},
}

var buildLocalCmd = &cobra.Command{
	Use:   "build-local",
	Short: "Build the SDK library from source",
	Long:  "Build the SDK library from source for all supported configurations (MConn/FUSION/desktop across Yocto/Buildroot/desktop OSes)",
	Args:  cobra.NoArgs,
	RunE: func(cmd *cobra.Command, args []string) error {
		if err := BuildLocal(); err != nil {
			return err
		}
		if installFlag {
			sdkRoot, _ := os.Getwd()
			return InstallBuilds(sdkRoot)
		}
		return nil
	},
}

var installFlag bool

func init() {
	rootCmd.AddCommand(setupCmd)
	rootCmd.AddCommand(buildLocalCmd)
	buildLocalCmd.Flags().BoolVarP(&installFlag, "install", "i", false, "Install compiled libraries to ~/mrs-sdk-qt")
}
