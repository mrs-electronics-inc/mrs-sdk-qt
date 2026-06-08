#!/usr/bin/env bash
# Script to format all C++ source files using clang-format
# Usage: ./format_cpp.sh [--check]
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

# Find all tracked C/C++ source files (respects .gitignore)
SOURCES=$(git ls-files | grep -E '\.(h|hpp|c|cpp)$' || true)

# Check if clang-format is available
if ! command -v clang-format &> /dev/null; then
  echo "Error: clang-format is not installed"
  exit 1
fi

if [[ "${CHECK_ONLY}" -eq 1 ]]; then
  echo "Checking C++ formatting..."
  if echo "${SOURCES}" | xargs clang-format --dry-run -Werror; then
    echo "✓ All files are properly formatted."
  else
    echo "✗ Some files are not properly formatted."
    exit 1
  fi
else
  echo "Formatting C++ files..."
  echo "${SOURCES}" | xargs clang-format -i
  echo "Done! Formatted files:"
  echo "${SOURCES}" | nl
fi
