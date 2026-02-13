package env

import (
	"bufio"
	"fmt"
	"os"
	"path/filepath"
	"slices"
	"sort"
	"strings"
)

func configFilePath() (string, error) {
	homeDir, err := os.UserHomeDir()
	if err != nil {
		return "", fmt.Errorf("failed to find home directory: %w", err)
	}
	return filepath.Join(homeDir, ".config", "mrs-sdk-qt", "env"), nil
}

// ReadAll reads all config values from the env file.
func ReadAll() (map[string]string, error) {
	path, err := configFilePath()
	if err != nil {
		return nil, err
	}

	config := make(map[string]string)

	f, err := os.Open(path)
	if err != nil {
		if os.IsNotExist(err) {
			return config, nil
		}
		return nil, fmt.Errorf("failed to open config file: %w", err)
	}
	defer f.Close()

	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}
		key, value, ok := strings.Cut(line, "=")
		if ok {
			config[key] = value
		}
	}

	return config, scanner.Err()
}

// Set writes a key-value pair to the config file.
func Set(key, value string) error {
	if !slices.Contains(ValidEnvKeys, key) {
		return fmt.Errorf("unknown key: %s", key)
	}

	config, err := ReadAll()
	if err != nil {
		return err
	}

	config[key] = value
	return writeAll(config)
}

func writeAll(config map[string]string) error {
	path, err := configFilePath()
	if err != nil {
		return err
	}

	if err := os.MkdirAll(filepath.Dir(path), 0755); err != nil {
		return fmt.Errorf("failed to create config directory: %w", err)
	}

	// Sort keys for deterministic output
	keys := make([]string, 0, len(config))
	for k := range config {
		keys = append(keys, k)
	}
	sort.Strings(keys)

	f, err := os.Create(path)
	if err != nil {
		return fmt.Errorf("failed to write config file: %w", err)
	}
	defer f.Close()

	for _, k := range keys {
		fmt.Fprintf(f, "%s=%s\n", k, config[k])
	}

	return nil
}

// PrintAll prints all valid keys and their values.
func PrintAll() error {
	config, err := ReadAll()
	if err != nil {
		return err
	}

	keys := sortedValidKeys()
	for _, k := range keys {
		fmt.Printf("%s=%s\n", k, config[k])
	}

	return nil
}

// PrintKey prints the value of a single key.
func PrintKey(key string) error {
	if !slices.Contains(ValidEnvKeys, key) {
		return fmt.Errorf("unknown key: %s", key)
	}

	config, err := ReadAll()
	if err != nil {
		return err
	}

	fmt.Println(config[key])
	return nil
}

func sortedValidKeys() []string {
	keys := make([]string, 0, len(ValidEnvKeys))
	keys = append(keys, ValidEnvKeys...)
	sort.Strings(keys)
	return keys
}
