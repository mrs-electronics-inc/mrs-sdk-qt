#!/usr/bin/env python3
"""Format C and C++ files with clang-format."""

from __future__ import annotations

import argparse
from pathlib import Path
import subprocess
import sys


CPP_EXTS = {".c", ".cpp", ".h", ".hpp"}


def build_parser() -> argparse.ArgumentParser:
    """Build the command-line parser."""
    parser = argparse.ArgumentParser(description="Format C and C++ files with clang-format.")
    parser.add_argument("paths", nargs="*", help="Files or directories to scan for C/C++ sources")
    parser.add_argument(
        "--check",
        action="store_true",
        help="Check-only mode; do not write files",
    )
    return parser


def is_git_tracked(path: Path) -> bool:
    """Return True when path is tracked by git, False otherwise."""
    result = subprocess.run(
        ["git", "ls-files", "--error-unmatch", str(path)],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False,
    )
    return result.returncode == 0


def collect_files(paths: list[str]) -> list[Path]:
    """Collect C/C++ files from the provided files and directories."""
    files: set[Path] = set()

    for raw_path in paths:
        if raw_path.strip() == "":
            continue
        path = Path(raw_path)
        if not path.exists():
            raise ValueError(f"Path does not exist: {path}")

        if path.is_file():
            if path.suffix in CPP_EXTS and is_git_tracked(path):
                files.add(path)
            continue

        for candidate in path.rglob("*"):
            if candidate.is_file() and candidate.suffix in CPP_EXTS and is_git_tracked(candidate):
                files.add(candidate)

    return sorted(files)


def main(argv: list[str]) -> int:
    """Run clang-format on any matching files and skip empty inputs."""
    parser = build_parser()
    args = parser.parse_args(argv)

    if not args.paths:
        parser.print_usage()
        return 1

    try:
        files = collect_files(args.paths)
    except ValueError as exc:
        print(f"\033[31m✘ {exc}\033[0m")
        return 1

    if not files:
        return 0

    command = ["clang-format", "--dry-run", "-Werror"] if args.check else ["clang-format", "-i"]
    command.extend(str(path) for path in files)

    result = subprocess.run(command, check=False)
    if result.returncode == 0:
        print("\033[32m✔ C/C++ formatting is OK.\033[0m")
    return result.returncode


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
