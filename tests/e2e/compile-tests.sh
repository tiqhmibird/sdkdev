#!/bin/bash

# End-to-End Compilation Tests
# This script generates code for all supported languages and verifies it compiles

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUTPUT_DIR="$PROJECT_ROOT/tests/e2e/output"
SCHEMAS_DIR="$PROJECT_ROOT/specs"

echo "===================================="
echo "E2E Compilation Tests"
echo "===================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track results
PASSED=0
FAILED=0
SKIPPED=0

# Clean and create output directory
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Function to run a test
run_test() {
    local language=$1
    local schema=$2
    local output_file=$3
    local compile_cmd=$4
    local test_name="$language ($schema)"

    echo -n "Testing $test_name... "

    # Generate code
    npm run generate -- generate \
        -i "$SCHEMAS_DIR/$schema" \
        -o "$OUTPUT_DIR/$output_file" \
        -l "$language" \
        -n "test_models" > /dev/null 2>&1

    if [ $? -ne 0 ]; then
        echo -e "${RED}FAIL${NC} (generation failed)"
        FAILED=$((FAILED + 1))
        return 1
    fi

    # Check if file was created
    if [ ! -f "$OUTPUT_DIR/$output_file" ]; then
        echo -e "${RED}FAIL${NC} (file not created)"
        FAILED=$((FAILED + 1))
        return 1
    fi

    # Run compilation/validation command
    if [ -n "$compile_cmd" ]; then
        eval "$compile_cmd" > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo -e "${RED}FAIL${NC} (compilation failed)"
            FAILED=$((FAILED + 1))
            return 1
        fi
    fi

    echo -e "${GREEN}PASS${NC}"
    PASSED=$((PASSED + 1))
    return 0
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# TypeScript Tests
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "TypeScript"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if command_exists tsc; then
    run_test "typescript" "auth/schemas.json" "auth.ts" "npx tsc --noEmit --strict $OUTPUT_DIR/auth.ts"
    run_test "typescript" "functions/schemas.json" "functions.ts" "npx tsc --noEmit --strict $OUTPUT_DIR/functions.ts"
else
    echo -e "${YELLOW}SKIP${NC} (tsc not found)"
    SKIPPED=$((SKIPPED + 2))
fi

echo ""

# Python Tests
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Python"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if command_exists python3; then
    # Check syntax
    run_test "python" "auth/schemas.json" "auth.py" "python3 -m py_compile $OUTPUT_DIR/auth.py"
    run_test "python" "functions/schemas.json" "functions.py" "python3 -m py_compile $OUTPUT_DIR/functions.py"

    # Type check with mypy if available
    if command_exists mypy; then
        echo -n "Running mypy on auth.py... "
        mypy --strict --no-error-summary "$OUTPUT_DIR/auth.py" > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}PASS${NC}"
        else
            echo -e "${YELLOW}WARN${NC} (mypy found issues)"
        fi
    fi
else
    echo -e "${YELLOW}SKIP${NC} (python3 not found)"
    SKIPPED=$((SKIPPED + 2))
fi

echo ""

# Go Tests
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Go"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if command_exists go; then
    # Create go.mod for tests
    cd "$OUTPUT_DIR"
    cat > go.mod << EOF
module test_models

go 1.21
EOF
    cd "$PROJECT_ROOT"

    run_test "go" "auth/schemas.json" "auth.go" "cd $OUTPUT_DIR && go build auth.go"
    run_test "go" "functions/schemas.json" "functions.go" "cd $OUTPUT_DIR && go build functions.go"
else
    echo -e "${YELLOW}SKIP${NC} (go not found)"
    SKIPPED=$((SKIPPED + 2))
fi

echo ""

# Dart Tests
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Dart"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if command_exists dart; then
    run_test "dart" "auth/schemas.json" "auth.dart" "dart analyze $OUTPUT_DIR/auth.dart"
    run_test "dart" "functions/schemas.json" "functions.dart" "dart analyze $OUTPUT_DIR/functions.dart"
else
    echo -e "${YELLOW}SKIP${NC} (dart not found)"
    SKIPPED=$((SKIPPED + 2))
fi

echo ""

# Swift Tests
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Swift"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if command_exists swiftc; then
    run_test "swift" "auth/schemas.json" "auth.swift" "swiftc -typecheck $OUTPUT_DIR/auth.swift"
    run_test "swift" "functions/schemas.json" "functions.swift" "swiftc -typecheck $OUTPUT_DIR/functions.swift"
else
    echo -e "${YELLOW}SKIP${NC} (swiftc not found)"
    SKIPPED=$((SKIPPED + 2))
fi

echo ""

# Kotlin Tests
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Kotlin"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if command_exists kotlinc; then
    # Kotlin compilation is slow, so we just check syntax
    run_test "kotlin" "auth/schemas.json" "auth.kt" "kotlinc -Werror $OUTPUT_DIR/auth.kt -d $OUTPUT_DIR/auth.jar"
    run_test "kotlin" "functions/schemas.json" "functions.kt" "kotlinc -Werror $OUTPUT_DIR/functions.kt -d $OUTPUT_DIR/functions.jar"
else
    echo -e "${YELLOW}SKIP${NC} (kotlinc not found)"
    SKIPPED=$((SKIPPED + 2))
fi

echo ""

# Rust Tests
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Rust"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if command_exists rustc; then
    # Create a temporary Cargo project for Rust tests
    RUST_TEST_DIR="$OUTPUT_DIR/rust_test"
    mkdir -p "$RUST_TEST_DIR/src"

    cat > "$RUST_TEST_DIR/Cargo.toml" << EOF
[package]
name = "test_models"
version = "0.1.0"
edition = "2021"

[dependencies]
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
chrono = { version = "0.4", features = ["serde"] }
EOF

    # Generate and test auth
    npm run generate -- generate \
        -i "$SCHEMAS_DIR/auth/schemas.json" \
        -o "$RUST_TEST_DIR/src/lib.rs" \
        -l rust > /dev/null 2>&1

    echo -n "Testing rust (auth/schemas.json)... "
    cd "$RUST_TEST_DIR" && cargo check > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}PASS${NC}"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}FAIL${NC}"
        FAILED=$((FAILED + 1))
    fi
    cd "$PROJECT_ROOT"

    # Generate and test functions
    npm run generate -- generate \
        -i "$SCHEMAS_DIR/functions/schemas.json" \
        -o "$RUST_TEST_DIR/src/lib.rs" \
        -l rust > /dev/null 2>&1

    echo -n "Testing rust (functions/schemas.json)... "
    cd "$RUST_TEST_DIR" && cargo check > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}PASS${NC}"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}FAIL${NC}"
        FAILED=$((FAILED + 1))
    fi
    cd "$PROJECT_ROOT"
else
    echo -e "${YELLOW}SKIP${NC} (rustc not found)"
    SKIPPED=$((SKIPPED + 2))
fi

echo ""
echo "===================================="
echo "Test Summary"
echo "===================================="
echo -e "${GREEN}Passed:${NC}  $PASSED"
echo -e "${RED}Failed:${NC}  $FAILED"
echo -e "${YELLOW}Skipped:${NC} $SKIPPED"
echo ""

if [ $FAILED -gt 0 ]; then
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
else
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
fi
