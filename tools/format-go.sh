#!/usr/bin/env bash
# Script to format all Go source files using gofmt
# Usage: ./format-go.sh [--check]
#   --check: perform a dry-run check instead of formatting

set -e

# Get the repository root
REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "${REPO_ROOT}"

# Parse arguments
CHECK_ONLY=0
if [[ "$1" == "--check" ]]; then
  CHECK_ONLY=1
fi

# Check if gofmt is available
if ! command -v gofmt &> /dev/null; then
  echo "Error: gofmt is not installed"
  exit 1
fi

if [[ "${CHECK_ONLY}" -eq 1 ]]; then
  echo "Checking Go formatting..."
  UNFORMATTED="$(gofmt -l tools/)"
  if [[ -n "${UNFORMATTED}" ]]; then
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
