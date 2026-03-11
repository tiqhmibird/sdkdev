#!/bin/bash

# Example script showing how to generate code for all supported languages
# Usage: ./examples/generate-all.sh

set -e

echo "Generating code from JSON schemas..."
echo ""

# Create output directory
mkdir -p examples/output

# TypeScript
echo "✓ Generating TypeScript..."
npm run generate -- generate \
  -i specs/auth/schemas.json \
  -o examples/output/auth.ts \
  -l typescript

npm run generate -- generate \
  -i specs/realtime/schemas.json \
  -o examples/output/realtime.ts \
  -l typescript \
  --overrides specs/realtime/overrides.json

# Python
echo "✓ Generating Python..."
npm run generate -- generate \
  -i specs/auth/schemas.json \
  -o examples/output/auth.py \
  -l python

npm run generate -- generate \
  -i specs/realtime/schemas.json \
  -o examples/output/realtime.py \
  -l python \
  --overrides specs/realtime/overrides.json

# Go
echo "✓ Generating Go..."
npm run generate -- generate \
  -i specs/auth/schemas.json \
  -o examples/output/auth.go \
  -l go \
  -n models

npm run generate -- generate \
  -i specs/realtime/schemas.json \
  -o examples/output/realtime.go \
  -l go \
  -n models \
  --overrides specs/realtime/overrides.json

# Dart
echo "✓ Generating Dart..."
npm run generate -- generate \
  -i specs/auth/schemas.json \
  -o examples/output/auth.dart \
  -l dart

npm run generate -- generate \
  -i specs/realtime/schemas.json \
  -o examples/output/realtime.dart \
  -l dart \
  --overrides specs/realtime/overrides.json

# Swift
echo "✓ Generating Swift..."
npm run generate -- generate \
  -i specs/auth/schemas.json \
  -o examples/output/auth.swift \
  -l swift

npm run generate -- generate \
  -i specs/realtime/schemas.json \
  -o examples/output/realtime.swift \
  -l swift \
  -a public \
  --overrides specs/realtime/overrides.json

# Kotlin
echo "✓ Generating Kotlin..."
npm run generate -- generate \
  -i specs/auth/schemas.json \
  -o examples/output/auth.kt \
  -l kotlin \
  -n com.supabase.models

npm run generate -- generate \
  -i specs/realtime/schemas.json \
  -o examples/output/realtime.kt \
  -l kotlin \
  -n com.supabase.models \
  --overrides specs/realtime/overrides.json

# Rust
echo "✓ Generating Rust..."
npm run generate -- generate \
  -i specs/auth/schemas.json \
  -o examples/output/auth.rs \
  -l rust

npm run generate -- generate \
  -i specs/realtime/schemas.json \
  -o examples/output/realtime.rs \
  -l rust \
  --overrides specs/realtime/overrides.json

echo ""
echo "✓ All code generated successfully!"
echo "Check the examples/output directory for results."
