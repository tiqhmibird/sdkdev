# Quick Start Guide

Get started with `@supabase/sdkdev` in under 5 minutes.

## Installation

```bash
# Clone and install
cd /Users/guilherme/src/github.com/supabase/sdkdev
npm install
```

## Basic Usage

### 1. Generate TypeScript Types

```bash
npm run generate -- generate \
  -i specs/auth/schemas.json \
  -o auth.ts \
  -l typescript
```

### 2. Generate Python Types

```bash
npm run generate -- generate \
  -i specs/auth/schemas.json \
  -o auth.py \
  -l python
```

### 3. Generate All Languages

```bash
./examples/generate-all.sh
```

This generates types for all 7 supported languages:
- TypeScript → `examples/output/auth.ts`
- Python → `examples/output/auth.py`
- Go → `examples/output/auth.go`
- Dart → `examples/output/auth.dart`
- Swift → `examples/output/auth.swift`
- Kotlin → `examples/output/auth.kt`
- Rust → `examples/output/auth.rs`

## Supported Languages

| Language   | Output Extension | Package/Namespace Support |
|------------|------------------|---------------------------|
| TypeScript | `.ts`            | No                        |
| Python     | `.py`            | No                        |
| Go         | `.go`            | Yes (`-n` flag)           |
| Dart       | `.dart`          | No                        |
| Swift      | `.swift`         | No                        |
| Kotlin     | `.kt`            | Yes (`-n` flag)           |
| Rust       | `.rs`            | No                        |

## Command Options

```bash
npm run generate -- generate [options]

Options:
  -i, --input <path>      Input JSON schema file (required)
  -o, --output <path>     Output file path (required)
  -l, --language <lang>   Target language (required)
  -n, --namespace <name>  Package/module name (optional)
  -h, --help              Display help
```

## Example Outputs

### TypeScript
```typescript
export interface User {
  id: string
  email?: string
  phone?: string
}
```

### Python
```python
class User(TypedDict):
    id: str
    email: Optional[str]
    phone: Optional[str]
```

### Go
```go
type User struct {
    ID    string  `json:"id"`
    Email *string `json:"email,omitempty"`
    Phone *string `json:"phone,omitempty"`
}
```

## Next Steps

1. **Create Your Own Schema**: Add JSON schema files to `specs/`
2. **Extend the Tool**: Add new language generators in `src/generators/`
3. **Build for Production**: Run `npm run build` to compile TypeScript
4. **Use as CLI**: After building, use `node dist/cli.js generate ...`

## Troubleshooting

### Command not found
Make sure you're in the project directory and have run `npm install`.

### Invalid schema
Ensure your JSON schema has a `definitions` section with type definitions.

### Language not supported
Check the list of supported languages with `--help`. To add a new language, see [README.md](./README.md#extending-with-new-languages).

## Resources

- [Full Documentation](./README.md)
- [JSON Schema Specification](https://json-schema.org/specification.html)
- [Example Schemas](./specs/)
