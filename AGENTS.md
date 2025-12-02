# Agent Guidelines for MRS SDK Qt

## Git Commits

Always use **Conventional Commits** format:

```
<type>(<scope>): <subject>

<body>
```

### Commit Types

- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that don't affect code meaning (formatting, missing semicolons, etc)
- `refactor`: A code change that neither fixes a bug nor adds a feature
- `perf`: A code change that improves performance
- `test`: Adding missing tests or correcting existing tests
- `chore`: Changes to build process, dependencies, or tooling
- `ci`: Changes to CI/CD configuration

### Scope Examples

- `vm`: Virtual machine / Packer build
- `cmake`: CMake build system
- `docs`: Documentation
- `ci`: CI/CD workflows
- `deps`: Dependencies

### Examples

```
feat(vm): add serial console logging for build monitoring
fix(cmake): correct Qt6 include path
docs(vm): update build instructions
chore(deps): update packer version requirement
```

## File Structure

Follow the existing directory structure:
- `vm/` - VM build configuration (Packer)
- `lib/` - Libraries and source code
- `docs/` - Documentation
- `demos/` - Example applications
- `.github/` - GitHub workflows and configuration

## Other Guidelines

- Use descriptive branch names: `feature/description` or `fix/description`
- Update documentation when adding features
- Run existing scripts/tests before committing
