package buildlocal

import "testing"

// TestParseBuildScopeDefaultsToAll verifies that omitting the optional target
// argument preserves the current broad behavior instead of forcing callers to
// spell out the default explicitly.
func TestParseBuildScopeDefaultsToAll(t *testing.T) {
	scope, err := ParseBuildScope("")
	if err != nil {
		t.Fatalf("expected empty scope to default successfully, got error: %v", err)
	}
	if scope != BuildScopeAll {
		t.Fatalf("expected empty scope to default to %q, got %q", BuildScopeAll, scope)
	}
}

// TestParseBuildScopeAcceptsSupportedTargets verifies that the user-facing CLI
// contract accepts each documented target selector.
func TestParseBuildScopeAcceptsSupportedTargets(t *testing.T) {
	testCases := []BuildScope{
		BuildScopeAll,
		BuildScopeLibs,
		BuildScopeDemos,
	}

	for _, testCase := range testCases {
		scope, err := ParseBuildScope(string(testCase))
		if err != nil {
			t.Fatalf("expected scope %q to parse successfully, got error: %v", testCase, err)
		}
		if scope != testCase {
			t.Fatalf("expected scope %q to round-trip, got %q", testCase, scope)
		}
	}
}

// TestParseBuildScopeRejectsUnsupportedTargets verifies that typos and
// undocumented selectors fail fast with a validation error instead of silently
// changing the build behavior.
func TestParseBuildScopeRejectsUnsupportedTargets(t *testing.T) {
	if _, err := ParseBuildScope("widgets"); err == nil {
		t.Fatal("expected unsupported scope to return an error")
	}
}
