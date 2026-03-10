# E2E Compilation Tests

This directory contains end-to-end tests that verify generated code actually compiles in each target language.

## Test Scripts

### `quick-test.sh`
Fast local development test that checks TypeScript, Python, and Go (the most common languages).

```bash
npm run test:quick
# or
./tests/e2e/quick-test.sh
```

**Requirements:**
- Node.js with TypeScript
- Python 3
- Go 1.21+

### `compile-tests.sh`
Comprehensive test suite that checks all 7 supported languages.

```bash
npm test
# or
./tests/e2e/compile-tests.sh
```

**Requirements:**
- Node.js with TypeScript
- Python 3 (optionally mypy for type checking)
- Go 1.21+
- Dart SDK
- Swift compiler (swiftc)
- Kotlin compiler (kotlinc)
- Rust toolchain (rustc/cargo)

## What Gets Tested

For each language, the tests:

1. **Generate code** from JSON schemas
2. **Compile/validate** the generated code:
   - TypeScript: `tsc --noEmit --strict`
   - Python: `python -m py_compile` (+ `mypy` if available)
   - Go: `go build`
   - Dart: `dart analyze`
   - Swift: `swiftc -typecheck`
   - Kotlin: `kotlinc`
   - Rust: `cargo check`

3. **Verify** no compilation errors

## Test Schemas

Tests use the real schemas from `specs/`:
- `specs/auth/schemas.json` - Complex auth types with nested objects, arrays, unions
- `specs/functions/schemas.json` - Simple enum types

## CI Integration

Tests run automatically in GitHub Actions:

### Quick Check (Every Commit)
- TypeScript, Python, Go only
- Runs on Ubuntu
- Fast feedback (~2 minutes)

### Full Suite (Main Branch)
- All 7 languages
- Runs on Ubuntu and macOS
- Comprehensive validation (~10 minutes)

## Local Development

### Quick Test (Recommended)
```bash
npm run test:quick
```

Runs in ~10 seconds, tests the 3 most common languages.

### Full Test
```bash
npm test
```

Runs in ~30-60 seconds depending on installed compilers.

### Test Specific Language
```bash
# Generate code
npm run generate -- generate -i specs/auth/schemas.json -o test.ts -l typescript

# Compile manually
npx tsc --noEmit --strict test.ts
```

## Adding New Tests

To test a new schema:

1. Add schema to `specs/`
2. Tests automatically include all schemas in `specs/*/schemas.json`

To add a new language:

1. Add generator to `src/generators/`
2. Add test case to `compile-tests.sh`
3. Update CI workflow with language setup

## Troubleshooting

### Test Fails Locally

**Check compiler is installed:**
```bash
tsc --version  # TypeScript
python3 --version  # Python
go version  # Go
dart --version  # Dart
swiftc --version  # Swift
kotlinc -version  # Kotlin
rustc --version  # Rust
```

**View generated code:**
```bash
ls -la tests/e2e/output/
cat tests/e2e/output/auth.ts
```

**Run compiler manually:**
```bash
npx tsc --noEmit tests/e2e/output/auth.ts
```

### Test Fails in CI

1. Check the test output in GitHub Actions
2. Download test artifacts (generated code)
3. Run locally to reproduce

## Test Output

Generated code is written to `tests/e2e/output/`:
- `auth.ts`, `auth.py`, `auth.go`, etc.
- Automatically cleaned before each test run
- Not committed to git (in `.gitignore`)

## Performance

| Test Suite | Languages | Duration |
|------------|-----------|----------|
| Quick      | 3         | ~10s     |
| Full       | 7         | ~60s     |

## Coverage

Tests verify:
- ✅ Code generation doesn't crash
- ✅ Generated code is syntactically valid
- ✅ Generated code compiles/type-checks
- ✅ All type definitions are valid
- ✅ Imports/dependencies are correct
- ❌ Runtime behavior (not covered)
- ❌ Serialization/deserialization (not covered)

For runtime testing, use language-specific test frameworks in SDK repositories.
