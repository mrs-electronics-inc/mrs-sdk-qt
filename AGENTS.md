# AGENTS.md - Development Guidelines

## Build & Development Commands

- **Build tools**: `just tools` (installs mrs-sdk-manager to $GOPATH/bin)
- **Build libs**: `just libs` (runs `mrs-sdk-manager build-local --install`)
- **Format C++**: `just format-cpp` (uses clang-format)
- **Format Go**: `just format-go` (uses gofmt)

## Codebase Structure

- **lib/**: Qt C++ SDK library (include/, src/, CMake-based build)
- **tools/mrs-sdk-manager/**: Go CLI tool for building/installing SDK
- **demos/**: Example Qt applications
- **docs/**: Documentation (Astro-based site)

## Code Style

**C++**: clang-format enforced, 120-column limit. Qt conventions: 4-space indent, braces on new lines, include priority (Qt > system > project). Use EMIT macro for Qt signals.

**Go**: gofmt enforced. Run `go vet` and `go fmt` via pre-commit on tools/mrs-sdk-manager/.

**Shebangs**: Always use `#!/usr/bin/env bash` (not `#!/bin/bash`) for shell scripts. NixOS requires this for portability.

**Commits**: Use conventional commit format (feat:, fix:, docs:, etc.).

## Key Files

- `.clang-format`: C++ style config
- `.pre-commit-config.yaml`: Pre-commit hooks (clang-format, go-vet, format checks)
- `CONTRIBUTING.md`: Full contributor workflow, issue/PR process, branching strategy

## Git Workflow

Trunk-based: branch from `main` as `<issue-num>-<title>`, use conventional commits, create draft PRs early, squash-merge when approved.
