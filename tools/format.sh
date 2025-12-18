#!/usr/bin/env bash
# Script to format all C++ source files using clang-format
# Usage: ./format.sh [--check]
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

# Find all tracked C++ source files (respects .gitignore)
SOURCES=$(git ls-files | grep -E '\.(cpp|hpp|h|cc)$')

# Check if clang-format is available
if ! command -v clang-format &> /dev/null; then
  echo "Error: clang-format is not installed"
  exit 1
fi

if [ "$CHECK_ONLY" = true ]; then
  echo "Checking C++ formatting..."
  clang-format --dry-run -Werror $SOURCES
  if [ $? -eq 0 ]; then
    echo "✓ All files are properly formatted"
  else
    echo "✗ Some files are not properly formatted. Run 'just format' to fix."
    exit 1
  fi
else
  echo "Formatting C++ files..."
  echo "$SOURCES" | xargs clang-format -i
  echo "Done! Formatted files:"
  echo "$SOURCES" | nl
fi
