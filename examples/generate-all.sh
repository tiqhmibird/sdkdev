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

# Python
echo "✓ Generating Python..."
npm run generate -- generate \
  -i specs/auth/schemas.json \
  -o examples/output/auth.py \
  -l python

# Go
echo "✓ Generating Go..."
npm run generate -- generate \
  -i specs/auth/schemas.json \
  -o examples/output/auth.go \
  -l go \
  -n models

# Dart
echo "✓ Generating Dart..."
npm run generate -- generate \
  -i specs/auth/schemas.json \
  -o examples/output/auth.dart \
  -l dart

# Swift
echo "✓ Generating Swift..."
npm run generate -- generate \
  -i specs/auth/schemas.json \
  -o examples/output/auth.swift \
  -l swift

# Kotlin
echo "✓ Generating Kotlin..."
npm run generate -- generate \
  -i specs/auth/schemas.json \
  -o examples/output/auth.kt \
  -l kotlin \
  -n com.supabase.models

# Rust
echo "✓ Generating Rust..."
npm run generate -- generate \
  -i specs/auth/schemas.json \
  -o examples/output/auth.rs \
  -l rust

echo ""
echo "✓ All code generated successfully!"
echo "Check the examples/output directory for results."
