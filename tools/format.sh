#!/bin/bash
# Script to format all C++ source files using clang-format

set -e

# Get the repository root
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# Find all C++ source files, excluding generated files and build directories
SOURCES=$(find . \
  -type f \
  \( -name "*.cpp" -o -name "*.hpp" -o -name "*.h" -o -name "*.cc" \) \
  -not -path "./build/*" \
  -not -path "./CMakeFiles/*" \
  -not -path "./.git/*" \
  -not -path "./docs/node_modules/*" \
  -not -path "./lib/generated_files/*" \
  -not -path "./.bots/*")

# Check if clang-format is available
if ! command -v clang-format &> /dev/null; then
  echo "Error: clang-format is not installed"
  exit 1
fi

echo "Formatting C++ files..."
echo "$SOURCES" | xargs clang-format -i

echo "Done! Formatted files:"
echo "$SOURCES" | nl
