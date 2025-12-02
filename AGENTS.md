# Agent Guidelines for MRS SDK Qt

All contributions must follow the project's development workflow outlined in [CONTRIBUTING.md](CONTRIBUTING.md).

## Key Requirements

**Always use Conventional Commits** as described in [CONTRIBUTING.md#writing-new-code](CONTRIBUTING.md). Commit format:

```
<type>(<scope>): <subject>
```

Common scopes:
- `vm` - Virtual machine / Packer build
- `cmake` - CMake build system
- `docs` - Documentation
- `ci` - CI/CD workflows
- `deps` - Dependencies

Example: `fix(vm): add serial console logging for build monitoring`

For full details on git workflow, issue management, and code review, see [CONTRIBUTING.md](CONTRIBUTING.md).
