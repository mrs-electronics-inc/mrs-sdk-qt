package cmd

import (
	"fmt"
	"mrs-sdk-manager/env"
	"strings"

	"github.com/spf13/cobra"
)

var envWriteFlag bool

var envCmd = &cobra.Command{
	Use:   "env [-w key=value ...] [key]",
	Short: "Print or modify SDK environment configuration",
	Long:  "View or modify the MRS SDK environment configuration, similar to 'go env'.",
	RunE: func(cmd *cobra.Command, args []string) error {
		if envWriteFlag {
			if len(args) == 0 {
				return fmt.Errorf("env -w requires KEY=VALUE arguments")
			}
			for _, kv := range args {
				key, value, ok := strings.Cut(kv, "=")
				if !ok {
					return fmt.Errorf("invalid format: %s (expected KEY=VALUE)", kv)
				}
				if err := env.Set(key, value); err != nil {
					return err
				}
			}
			return nil
		}

		if len(args) == 0 {
			return env.PrintAll()
		}
		if len(args) == 1 {
			return env.PrintKey(args[0])
		}
		return fmt.Errorf("too many arguments")
	},
}

func init() {
	envCmd.Flags().BoolVarP(&envWriteFlag, "write", "w", false, "Write KEY=VALUE pairs to the configuration")
	rootCmd.AddCommand(envCmd)
}
