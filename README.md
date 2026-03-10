# @supabase/sdkdev

[![CI](https://github.com/supabase/sdkdev/actions/workflows/ci.yml/badge.svg)](https://github.com/supabase/sdkdev/actions/workflows/ci.yml)

SDK development tools for generating types from JSON schemas across multiple programming languages.

## Features

- Generate type definitions from JSON Schema
- Support for 7 programming languages:
  - TypeScript - Interfaces with JSDoc
  - Python - TypedDict with type hints
  - Go - Structs with JSON tags
  - Dart - Classes with fromJson/toJson
  - Swift - Structs with Codable (enums as RawRepresentable structs)
  - Kotlin - Data classes with serialization
  - Rust - Structs with Serde
- **Access Control** - Control visibility with `public`, `private`, `internal`, etc.
- Preserves documentation and metadata
- Handles complex types (enums, unions, nested objects)
- Language-specific best practices (e.g., Swift enum structs for API flexibility)
- Easy to extend with new languages

## Installation

```bash
npm install
npm run build
```

Or use directly with tsx:

```bash
npm install
```

## Usage

### CLI

```bash
# Using npm script (recommended for development)
npm run generate -- generate -i specs/auth/schemas.json -o output/auth.ts -l typescript

# Using built CLI (after running npm run build)
node dist/cli.js generate -i specs/auth/schemas.json -o output/auth.ts -l typescript

# Using tsx directly
npx tsx src/cli.ts generate -i specs/auth/schemas.json -o output/auth.py -l python -n supabase.models
```

### Options

- `-i, --input <path>` - Input JSON schema file (required)
- `-o, --output <path>` - Output file path (required)
- `-l, --language <lang>` - Target language (required)
  - Supported: `typescript`, `python`, `go`, `dart`, `swift`, `kotlin`, `rust`
- `-n, --namespace <name>` - Namespace/module name for generated code (optional)
- `-a, --access <control>` - Access control modifier (optional)
  - Options: `public`, `private`, `internal`, `protected`, `package`
  - See [Access Control Guide](./docs/ACCESS_CONTROL.md) for details

## Examples

### TypeScript

```bash
npm run generate -- generate \
  -i specs/auth/schemas.json \
  -o src/types/auth.ts \
  -l typescript
```

Output:
```typescript
export interface User {
  id: string
  email?: string
  phone?: string
  // ... more fields
}
```

### Python

```bash
npm run generate -- generate \
  -i specs/auth/schemas.json \
  -o src/models/auth.py \
  -l python \
  -n supabase.auth
```

Output:
```python
from typing import Optional, List, Dict

class User(TypedDict):
    """User account information"""
    id: str
    email: Optional[str]
    phone: Optional[str]
```

### Go

```bash
npm run generate -- generate \
  -i specs/auth/schemas.json \
  -o pkg/models/auth.go \
  -l go \
  -n models
```

Output:
```go
package models

type User struct {
    ID    string  `json:"id"`
    Email *string `json:"email,omitempty"`
    Phone *string `json:"phone,omitempty"`
}
```

### Dart

```bash
npm run generate -- generate \
  -i specs/auth/schemas.json \
  -o lib/models/auth.dart \
  -l dart
```

Output:
```dart
class User {
  final String id;
  final String? email;
  final String? phone;

  User({required this.id, this.email, this.phone});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}
```

### Swift

```bash
npm run generate -- generate \
  -i specs/auth/schemas.json \
  -o Sources/Models/Auth.swift \
  -l swift \
  -a public
```

Output:
```swift
public struct User: Codable {
    public let id: String
    public let email: String?
    public let phone: String?
}

// Enums are generated as RawRepresentable structs with static let values
public struct FunctionRegion: RawRepresentable, Codable, Equatable, Hashable, ExpressibleByStringLiteral {
    public let rawValue: String

    public static let any = FunctionRegion(rawValue: "any")
    public static let usEast1 = FunctionRegion(rawValue: "us-east-1")

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
        self.rawValue = value
    }
}

// Usage examples:
let region1: FunctionRegion = .usEast1        // Static constant
let region2: FunctionRegion = "us-west-2"     // String literal
let region3 = FunctionRegion(rawValue: "any") // Initializer
```

**Access Control:**
- `-a public` - Public types for library/framework (default)
- `-a internal` - Internal types (module-private)
- `-a private` - Private types (file-private)

### Kotlin

```bash
npm run generate -- generate \
  -i specs/auth/schemas.json \
  -o src/main/kotlin/models/Auth.kt \
  -l kotlin \
  -n com.supabase.models
```

Output:
```kotlin
@Serializable
data class User(
    val id: String,
    val email: String? = null,
    val phone: String? = null
)
```

### Rust

```bash
npm run generate -- generate \
  -i specs/auth/schemas.json \
  -o src/models/auth.rs \
  -l rust
```

Output:
```rust
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct User {
    pub id: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub email: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub phone: Option<String>,
}
```

## JSON Schema Format

The tool expects JSON Schema (Draft 7) with a `definitions` section:

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "definitions": {
    "User": {
      "type": "object",
      "description": "User account information",
      "properties": {
        "id": {
          "type": "string",
          "format": "uuid"
        },
        "email": {
          "type": "string",
          "format": "email"
        }
      },
      "required": ["id"]
    }
  }
}
```

## Extending with New Languages

To add support for a new language:

1. Create a new generator in `src/generators/yourlang.ts`
2. Implement the `CodeGenerator` interface
3. Add your generator to `src/generators/index.ts`

Example:

```typescript
import { CodeGenerator, JSONSchema, SchemaDefinition } from '../types.js'

export class YourLangGenerator implements CodeGenerator {
  generate(schema: JSONSchema, options?: GeneratorOptions): string {
    // Implementation
  }

  generateType(name: string, definition: SchemaDefinition): string {
    // Implementation
  }
}
```

## Development

```bash
# Install dependencies
npm install

# Build
npm run build

# Watch mode
npm run dev

# Run tests
npm test              # Full e2e compilation tests
npm run test:quick    # Quick test (TS, Python, Go only)

# Test generation
npm run generate -- generate -i specs/auth/schemas.json -o test.ts -l typescript
```

## Testing

The project includes comprehensive e2e tests that verify generated code actually compiles:

```bash
# Quick test (TypeScript, Python, Go)
npm run test:quick

# Full test suite (all 7 languages)
npm test
```

Tests automatically run in CI for every commit. See [`tests/README.md`](./tests/README.md) for details.

### Requirements for Testing

**Quick tests:**
- Node.js + TypeScript
- Python 3
- Go 1.21+

**Full tests:** All of the above plus:
- Dart SDK
- Swift compiler
- Kotlin compiler
- Rust toolchain

## Project Structure

```
sdkdev/
├── src/
│   ├── cli.ts              # CLI entry point
│   ├── types.ts            # TypeScript interfaces
│   └── generators/
│       ├── index.ts        # Generator registry
│       ├── typescript.ts   # TypeScript generator
│       ├── python.ts       # Python generator
│       ├── go.ts           # Go generator
│       ├── dart.ts         # Dart generator
│       ├── swift.ts        # Swift generator
│       ├── kotlin.ts       # Kotlin generator
│       └── rust.ts         # Rust generator
├── specs/
│   ├── auth/
│   │   └── schemas.json    # Auth schemas
│   └── functions/
│       └── schemas.json    # Functions schemas
├── package.json
├── tsconfig.json
└── README.md
```

## License

MIT
