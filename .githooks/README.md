# Git Hooks

## Pre-commit Hook

Automatically runs quick e2e tests before each commit to ensure generated code compiles.

### Install

```bash
# From project root
ln -s ../../.githooks/pre-commit .git/hooks/pre-commit
```

Or use git config:
```bash
git config core.hooksPath .githooks
```

### What It Does

- Runs `npm run test:quick` before each commit
- Tests TypeScript, Python, and Go generation
- Takes ~10 seconds
- Aborts commit if tests fail

### Skip Hook

To commit without running tests (not recommended):

```bash
git commit --no-verify -m "message"
```

### Uninstall

```bash
rm .git/hooks/pre-commit
# or
git config --unset core.hooksPath
```
