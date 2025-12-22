#!/usr/bin/env bash
# Script to format all Go source files using gofmt
# Usage: ./format-go.sh [--check]
#   --check: perform a dry-run check instead of formatting

set -e

# Get the repository root
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# Parse arguments
CHECK_ONLY=false
if [[ "$1" == "--check" ]]; then
  CHECK_ONLY=true
fi

# Check if gofmt is available
if ! command -v gofmt &> /dev/null; then
  echo "Error: gofmt is not installed"
  exit 1
fi

if [ "$CHECK_ONLY" = true ]; then
  echo "Checking Go formatting..."
  if [ -n "$(gofmt -l tools/)" ]; then
    echo "Go formatting issues found:"
    gofmt -d tools/
    echo "✗ Some files are not properly formatted. Run 'just format-go' to fix."
    exit 1
  fi
  echo "✓ All Go files are properly formatted"
else
  echo "Formatting Go files..."
  gofmt -w tools/
  echo "Done!"
fi
