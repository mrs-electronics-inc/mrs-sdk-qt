package buildlocal

import "fmt"

// BuildScope is the user-facing selector for which portions of the local
// source tree should be built by the build-local command.
type BuildScope string

const (
	BuildScopeAll   BuildScope = "all"
	BuildScopeLibs  BuildScope = "libs"
	BuildScopeDemos BuildScope = "demos"
)

// ParseBuildScope validates the optional positional target argument accepted by
// `mrs-sdk-manager build-local`. An empty argument intentionally preserves the
// documented default of `all`.
func ParseBuildScope(raw string) (BuildScope, error) {
	if raw == "" {
		return BuildScopeAll, nil
	}

	scope := BuildScope(raw)
	switch scope {
	case BuildScopeAll, BuildScopeLibs, BuildScopeDemos:
		return scope, nil
	default:
		return "", fmt.Errorf("invalid build target %q (expected one of: all, libs, demos)", raw)
	}
}

// IncludesLibs reports whether the selected scope should build the SDK
// libraries.
func (scope BuildScope) IncludesLibs() bool {
	return scope == BuildScopeAll || scope == BuildScopeLibs
}

// IncludesDemos reports whether the selected scope should build the demo
// applications.
func (scope BuildScope) IncludesDemos() bool {
	return scope == BuildScopeAll || scope == BuildScopeDemos
}
