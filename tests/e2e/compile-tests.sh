#!/bin/bash

# End-to-End Compilation Tests
# This script generates code for all supported languages and verifies it compiles

# Don't exit on error - we want to collect all test results
set +e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUTPUT_DIR="$PROJECT_ROOT/tests/e2e/output"
SCHEMAS_DIR="$PROJECT_ROOT/specs"

# Change to project root to run npm commands
cd "$PROJECT_ROOT"

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
    local overrides_flag=${5:-""}
    local test_name="$language ($schema)"

    echo -n "Testing $test_name... "

    # Generate code
    npm run generate -- generate \
        -i "$SCHEMAS_DIR/$schema" \
        -o "$OUTPUT_DIR/$output_file" \
        -l "$language" \
        -n "test_models" \
        $overrides_flag > /dev/null 2>&1

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
    run_test "typescript" "storage/schemas.json" "storage.ts" "npx tsc --noEmit --strict $OUTPUT_DIR/storage.ts"
    run_test "typescript" "realtime/schemas.json" "realtime.ts" "npx tsc --noEmit --strict $OUTPUT_DIR/realtime.ts" "--overrides specs/realtime/overrides.json"
else
    echo -e "${YELLOW}SKIP${NC} (tsc not found)"
    SKIPPED=$((SKIPPED + 4))
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
    run_test "python" "storage/schemas.json" "storage.py" "python3 -m py_compile $OUTPUT_DIR/storage.py"
    run_test "python" "realtime/schemas.json" "realtime.py" "python3 -m py_compile $OUTPUT_DIR/realtime.py" "--overrides specs/realtime/overrides.json"

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
    SKIPPED=$((SKIPPED + 4))
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
    run_test "go" "storage/schemas.json" "storage.go" "cd $OUTPUT_DIR && go build storage.go"
    run_test "go" "realtime/schemas.json" "realtime.go" "cd $OUTPUT_DIR && go build realtime.go" "--overrides specs/realtime/overrides.json"
else
    echo -e "${YELLOW}SKIP${NC} (go not found)"
    SKIPPED=$((SKIPPED + 4))
fi

echo ""

# Dart Tests
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Dart"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if command_exists dart; then
    run_test "dart" "auth/schemas.json" "auth.dart" "dart analyze $OUTPUT_DIR/auth.dart"
    run_test "dart" "functions/schemas.json" "functions.dart" "dart analyze $OUTPUT_DIR/functions.dart"
    run_test "dart" "storage/schemas.json" "storage.dart" "dart analyze $OUTPUT_DIR/storage.dart"
    run_test "dart" "realtime/schemas.json" "realtime.dart" "dart analyze $OUTPUT_DIR/realtime.dart" "--overrides specs/realtime/overrides.json"
else
    echo -e "${YELLOW}SKIP${NC} (dart not found)"
    SKIPPED=$((SKIPPED + 4))
fi

echo ""

# Swift Tests
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Swift"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if command_exists swiftc; then
    run_test "swift" "auth/schemas.json" "auth.swift" "swiftc -typecheck $OUTPUT_DIR/auth.swift"
    run_test "swift" "functions/schemas.json" "functions.swift" "swiftc -typecheck $OUTPUT_DIR/functions.swift"
    run_test "swift" "storage/schemas.json" "storage.swift" "swiftc -typecheck $OUTPUT_DIR/storage.swift"
    run_test "swift" "realtime/schemas.json" "realtime.swift" "swiftc -typecheck $OUTPUT_DIR/realtime.swift" "--overrides specs/realtime/overrides.json"
else
    echo -e "${YELLOW}SKIP${NC} (swiftc not found)"
    SKIPPED=$((SKIPPED + 4))
fi

echo ""

# Kotlin Tests
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Kotlin"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if command_exists kotlinc; then
    # Download kotlinx-serialization dependencies if not present
    KOTLIN_LIBS_DIR="$OUTPUT_DIR/kotlin_libs"
    mkdir -p "$KOTLIN_LIBS_DIR"

    SERIALIZATION_CORE_JAR="$KOTLIN_LIBS_DIR/kotlinx-serialization-core-jvm-1.6.2.jar"
    SERIALIZATION_JSON_JAR="$KOTLIN_LIBS_DIR/kotlinx-serialization-json-jvm-1.6.2.jar"

    if [ ! -f "$SERIALIZATION_CORE_JAR" ]; then
        curl -sL "https://repo1.maven.org/maven2/org/jetbrains/kotlinx/kotlinx-serialization-core-jvm/1.6.2/kotlinx-serialization-core-jvm-1.6.2.jar" -o "$SERIALIZATION_CORE_JAR" 2>/dev/null
    fi

    if [ ! -f "$SERIALIZATION_JSON_JAR" ]; then
        curl -sL "https://repo1.maven.org/maven2/org/jetbrains/kotlinx/kotlinx-serialization-json-jvm/1.6.2/kotlinx-serialization-json-jvm-1.6.2.jar" -o "$SERIALIZATION_JSON_JAR" 2>/dev/null
    fi

    KOTLIN_CLASSPATH="$SERIALIZATION_CORE_JAR:$SERIALIZATION_JSON_JAR"

    # Compile with classpath (annotations will be available, plugin not required for basic compilation)
    run_test "kotlin" "auth/schemas.json" "auth.kt" "kotlinc -classpath $KOTLIN_CLASSPATH $OUTPUT_DIR/auth.kt -d $OUTPUT_DIR/auth.jar"
    run_test "kotlin" "functions/schemas.json" "functions.kt" "kotlinc -classpath $KOTLIN_CLASSPATH $OUTPUT_DIR/functions.kt -d $OUTPUT_DIR/functions.jar"
    run_test "kotlin" "storage/schemas.json" "storage.kt" "kotlinc -classpath $KOTLIN_CLASSPATH $OUTPUT_DIR/storage.kt -d $OUTPUT_DIR/storage.jar"
    run_test "kotlin" "realtime/schemas.json" "realtime.kt" "kotlinc -classpath $KOTLIN_CLASSPATH $OUTPUT_DIR/realtime.kt -d $OUTPUT_DIR/realtime.jar" "--overrides specs/realtime/overrides.json"
else
    echo -e "${YELLOW}SKIP${NC} (kotlinc not found)"
    SKIPPED=$((SKIPPED + 4))
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

    # Generate and test storage
    npm run generate -- generate \
        -i "$SCHEMAS_DIR/storage/schemas.json" \
        -o "$RUST_TEST_DIR/src/lib.rs" \
        -l rust > /dev/null 2>&1

    echo -n "Testing rust (storage/schemas.json)... "
    cd "$RUST_TEST_DIR" && cargo check > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}PASS${NC}"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}FAIL${NC}"
        FAILED=$((FAILED + 1))
    fi
    cd "$PROJECT_ROOT"

    # Generate and test realtime
    npm run generate -- generate \
        -i "$SCHEMAS_DIR/realtime/schemas.json" \
        -o "$RUST_TEST_DIR/src/lib.rs" \
        -l rust \
        --overrides "$SCHEMAS_DIR/realtime/overrides.json" > /dev/null 2>&1

    echo -n "Testing rust (realtime/schemas.json)... "
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
    SKIPPED=$((SKIPPED + 4))
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
