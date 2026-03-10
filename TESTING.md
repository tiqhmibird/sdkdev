# Testing Strategy

Comprehensive e2e testing to ensure generated code compiles in all target languages.

## Overview

```
┌─────────────────────────────────────────────────────┐
│                  Code Generation                     │
│  JSON Schema → Generator → Source Code              │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│               E2E Compilation Tests                  │
│  Verify generated code actually compiles            │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│                  CI/CD Pipeline                      │
│  Automated testing on every commit                  │
└─────────────────────────────────────────────────────┘
```

## Test Levels

### 1. Quick Tests (Local Development)
**Duration:** ~10 seconds
**Languages:** TypeScript, Python, Go

```bash
npm run test:quick
```

**When to use:**
- Before committing code
- During active development
- In pre-commit hooks
- Quick validation

### 2. Full E2E Tests (Pre-merge)
**Duration:** ~60 seconds
**Languages:** All 7 (TS, Python, Go, Dart, Swift, Kotlin, Rust)

```bash
npm test
```

**When to use:**
- Before creating PR
- Before merging to main
- Release validation
- Full verification

### 3. CI Pipeline (Automated)

**Quick Check (Every Commit):**
- Runs on all PRs
- Ubuntu only
- TS, Python, Go
- ~2 minutes

**Full Suite (Main Branch):**
- Runs on main/master
- Ubuntu + macOS
- All 7 languages
- ~10 minutes

## What We Test

### ✅ Tested

- **Syntax Validity**: Code parses without errors
- **Type Correctness**: Type checking passes (where applicable)
- **Compilation**: Code compiles to bytecode/binary
- **Import Resolution**: All dependencies resolve correctly
- **Type Definitions**: All types are valid in target language
- **Schema Coverage**: All schema features generate valid code

### ❌ Not Tested (By Design)

- **Runtime Behavior**: Execution semantics
- **Serialization**: JSON encode/decode
- **API Compatibility**: Actual API integration
- **Performance**: Generation or execution speed

These are tested in SDK-specific test suites.

## Test Compilers

| Language   | Compiler/Tool | Version | Check Type |
|------------|---------------|---------|------------|
| TypeScript | `tsc`         | 5.3+    | Type check |
| Python     | `py_compile`  | 3.11+   | Syntax     |
| Python     | `mypy`        | latest  | Type check |
| Go         | `go build`    | 1.21+   | Compile    |
| Dart       | `dart analyze`| stable  | Analysis   |
| Swift      | `swiftc`      | 5.9+    | Type check |
| Kotlin     | `kotlinc`     | 1.9+    | Compile    |
| Rust       | `cargo check` | 1.70+   | Check      |

## Test Scenarios

### Basic Types
```json
{
  "properties": {
    "name": { "type": "string" },
    "age": { "type": "integer" },
    "active": { "type": "boolean" }
  }
}
```
✅ Generates correct primitive types

### Optional Fields
```json
{
  "properties": {
    "email": { "type": "string" }
  },
  "required": ["email"]
}
```
✅ Generates required vs optional correctly

### Nested Objects
```json
{
  "properties": {
    "user": {
      "$ref": "#/definitions/User"
    }
  }
}
```
✅ Resolves references correctly

### Arrays
```json
{
  "properties": {
    "items": {
      "type": "array",
      "items": { "$ref": "#/definitions/Item" }
    }
  }
}
```
✅ Generates array types correctly

### Enums
```json
{
  "type": "string",
  "enum": ["us-east-1", "us-west-2"]
}
```
✅ Generates enums correctly (language-specific)

### Unions (oneOf)
```json
{
  "oneOf": [
    { "type": "string" },
    { "type": "number" }
  ]
}
```
✅ Generates union types correctly

### Date/Time Formats
```json
{
  "type": "string",
  "format": "date-time"
}
```
✅ Maps to language-specific date types

## CI Workflow

### Pull Request Flow
```
PR Created
    ↓
Quick Check (TS, Python, Go)
    ↓
Status Check: ✅ Required
    ↓
Merge to Main
    ↓
Full Suite (All Languages)
    ↓
Status Check: ℹ️ Informational
```

### Branch Protection

Recommended branch protection rules:
- ✅ Require status checks: "Quick Check"
- ✅ Require branches to be up to date
- ❌ Don't require: "Full Suite" (too slow)

## Local Setup

### Minimal Setup (Quick Tests)
```bash
# Install compilers
brew install node python go  # macOS
apt install nodejs python3 golang-go  # Linux

# Install dependencies
npm install

# Run tests
npm run test:quick
```

### Full Setup (All Languages)
```bash
# macOS
brew install node python go dart swift kotlin rust

# Install dependencies
npm install

# Run tests
npm test
```

### Docker Setup (Optional)
```bash
# Use multi-language Docker image
docker run -v $(pwd):/app -w /app node:20 bash -c "
  apt-get update && \
  apt-get install -y python3 golang dart && \
  npm install && \
  npm test
"
```

## Pre-commit Hook

Install to run tests automatically before commits:

```bash
git config core.hooksPath .githooks
```

Or manually:
```bash
ln -s ../../.githooks/pre-commit .git/hooks/pre-commit
```

## Debugging Test Failures

### 1. Check Generated Code
```bash
ls -la tests/e2e/output/
cat tests/e2e/output/auth.ts
```

### 2. Run Compiler Manually
```bash
npx tsc --noEmit tests/e2e/output/auth.ts
python3 -m py_compile tests/e2e/output/auth.py
go build tests/e2e/output/auth.go
```

### 3. Check Compiler Version
```bash
tsc --version
python3 --version
go version
```

### 4. View Full Test Output
```bash
./tests/e2e/quick-test.sh 2>&1 | tee test-output.log
```

### 5. Test in Clean Environment
```bash
rm -rf node_modules tests/e2e/output
npm ci
npm test
```

## Continuous Improvement

### Adding New Test Cases

1. Add schema to `specs/new-schema/schemas.json`
2. Tests automatically pick it up
3. Verify with `npm test`

### Fixing Generator Issues

1. Run `npm test` to identify issue
2. Fix generator in `src/generators/`
3. Verify with `npm test`
4. Commit with passing tests

### Performance Optimization

Current benchmarks:
- Generation: ~50ms per schema
- TypeScript check: ~1s per file
- Go compile: ~2s per file
- Full suite: ~60s total

Goals:
- Keep quick tests under 15s
- Keep full suite under 2 minutes

## FAQ

**Q: Why test compilation instead of unit tests?**
A: Compilation tests verify the generated code is valid without needing language-specific test frameworks. It's a universal validation method.

**Q: What if I don't have all compilers installed?**
A: Use `npm run test:quick` which only needs TS, Python, and Go.

**Q: Can I skip tests?**
A: Yes, with `git commit --no-verify`, but not recommended.

**Q: Why are Kotlin tests slow?**
A: Kotlin compiler has significant startup overhead. We use it sparingly.

**Q: Do tests check runtime behavior?**
A: No, only compilation. Runtime tests belong in SDK repositories.

**Q: How do I add a new language?**
A: 1) Add generator, 2) Add test case, 3) Update CI workflow.

## References

- [Test Scripts](./tests/README.md)
- [Git Hooks](./.githooks/README.md)
- [CI Workflow](./.github/workflows/ci.yml)
- [Contributing Guidelines](./CONTRIBUTING.md)
