#!/bin/bash

# Quick E2E Test - Tests TypeScript, Python, and Go only
# Useful for local development

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUTPUT_DIR="$PROJECT_ROOT/tests/e2e/output"

echo "===================================="
echo "Quick E2E Test"
echo "Testing: TypeScript, Python, Go"
echo "===================================="
echo ""

# Clean output directory
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

PASSED=0
FAILED=0

test_language() {
    local lang=$1
    local schema=$2
    local output=$3
    local cmd=$4

    echo -n "Testing $lang ($schema)... "

    # Generate
    npm run generate -- generate \
        -i "specs/$schema" \
        -o "$OUTPUT_DIR/$output" \
        -l "$lang" \
        -n "models" > /dev/null 2>&1

    if [ $? -ne 0 ]; then
        echo -e "${RED}FAIL${NC} (generation)"
        FAILED=$((FAILED + 1))
        return 1
    fi

    # Compile/validate
    eval "$cmd" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -e "${RED}FAIL${NC} (compilation)"
        FAILED=$((FAILED + 1))
        return 1
    fi

    echo -e "${GREEN}PASS${NC}"
    PASSED=$((PASSED + 1))
}

# TypeScript
test_language "typescript" "auth/schemas.json" "auth.ts" "npx tsc --noEmit --strict $OUTPUT_DIR/auth.ts"
test_language "typescript" "functions/schemas.json" "functions.ts" "npx tsc --noEmit --strict $OUTPUT_DIR/functions.ts"
test_language "typescript" "storage/schemas.json" "storage.ts" "npx tsc --noEmit --strict $OUTPUT_DIR/storage.ts"
test_language "typescript" "realtime/schemas.json" "realtime.ts" "npx tsc --noEmit --strict $OUTPUT_DIR/realtime.ts"

# Python
if command -v python3 > /dev/null; then
    test_language "python" "auth/schemas.json" "auth.py" "python3 -m py_compile $OUTPUT_DIR/auth.py"
    test_language "python" "functions/schemas.json" "functions.py" "python3 -m py_compile $OUTPUT_DIR/functions.py"
    test_language "python" "storage/schemas.json" "storage.py" "python3 -m py_compile $OUTPUT_DIR/storage.py"
    test_language "python" "realtime/schemas.json" "realtime.py" "python3 -m py_compile $OUTPUT_DIR/realtime.py"
else
    echo "Python 3 not found"
    exit 1
fi

# Go
if command -v go > /dev/null; then
    # Create go.mod
    cd "$OUTPUT_DIR"
    echo "module models" > go.mod
    echo "go 1.21" >> go.mod
    cd "$PROJECT_ROOT"

    test_language "go" "auth/schemas.json" "auth.go" "cd $OUTPUT_DIR && go build auth.go"
    test_language "go" "functions/schemas.json" "functions.go" "cd $OUTPUT_DIR && go build functions.go"
    test_language "go" "storage/schemas.json" "storage.go" "cd $OUTPUT_DIR && go build storage.go"
    test_language "go" "realtime/schemas.json" "realtime.go" "cd $OUTPUT_DIR && go build realtime.go"
else
    echo "Go not found"
    exit 1
fi

echo ""
echo "===================================="
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo "===================================="

if [ $FAILED -gt 0 ]; then
    exit 1
fi

exit 0
