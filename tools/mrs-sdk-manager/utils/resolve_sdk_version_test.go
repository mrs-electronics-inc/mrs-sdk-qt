package utils

import (
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"
)

// TestResolveSDKVersionUsesLatestGitTag verifies that local development
// installs track the latest repository tag instead of always collapsing into a
// synthetic 0.0.0 version. This keeps repo-local installs aligned with the
// version metadata embedded into the built library itself.
func TestResolveSDKVersionUsesLatestGitTag(t *testing.T) {
	repoRoot := t.TempDir()

	runGit(t, repoRoot, "init")
	runGit(t, repoRoot, "config", "user.name", "Test User")
	runGit(t, repoRoot, "config", "user.email", "test@example.com")
	writeTestFile(t, filepath.Join(repoRoot, "README.md"), "initial")
	runGit(t, repoRoot, "add", "README.md")
	runGit(t, repoRoot, "commit", "-m", "initial commit")
	runGit(t, repoRoot, "tag", "1.2.3")

	version := ResolveSDKVersion(repoRoot)
	if version != "1.2.3" {
		t.Fatalf("expected latest git tag to be used as SDK version, got %q", version)
	}
}

// TestResolveSDKVersionFallsBackWithoutGitTag verifies that local installs keep
// the historical development fallback when the repository has no tag metadata.
// That preserves a deterministic installation location for brand-new clones and
// detached test fixtures.
func TestResolveSDKVersionFallsBackWithoutGitTag(t *testing.T) {
	repoRoot := t.TempDir()

	version := ResolveSDKVersion(repoRoot)
	if version != "0.0.0" {
		t.Fatalf("expected untagged repositories to fall back to 0.0.0, got %q", version)
	}
}

// runGit executes a Git command in the test repository and fails the test with
// the full command output if Git refuses the operation. Keeping the helper here
// avoids repetitive boilerplate in individual version-resolution tests while
// still surfacing the exact failing subprocess invocation.
func runGit(t *testing.T, repoRoot string, args ...string) {
	t.Helper()

	cmd := exec.Command("git", args...)
	cmd.Dir = repoRoot
	output, err := cmd.CombinedOutput()
	if err != nil {
		t.Fatalf("git %s failed: %v\n%s", strings.Join(args, " "), err, output)
	}
}

// writeTestFile creates a file and any missing parent directories so the test
// fixtures stay focused on behavior instead of repetitive setup boilerplate.
func writeTestFile(t *testing.T, path, content string) {
	t.Helper()

	if err := os.MkdirAll(filepath.Dir(path), 0755); err != nil {
		t.Fatalf("failed to create directory for %s: %v", path, err)
	}
	if err := os.WriteFile(path, []byte(content), 0644); err != nil {
		t.Fatalf("failed to write %s: %v", path, err)
	}
}
