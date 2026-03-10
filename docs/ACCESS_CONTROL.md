# Access Control

Control the visibility of generated types using the `-a` or `--access` flag.

## Overview

Different programming languages have different access control mechanisms. The generator adapts the `--access` flag to each language's conventions.

## Usage

```bash
npm run generate -- generate \
  -i specs/auth/schemas.json \
  -o output.ts \
  -l typescript \
  -a public
```

## Supported Access Levels

| Flag       | TypeScript | Go         | Swift     | Kotlin    | Rust     | Dart      | Python |
|------------|------------|------------|-----------|-----------|----------|-----------|--------|
| `public`   | `export`   | Exported   | `public`  | `public`  | `pub`    | Public    | N/A    |
| `private`  | No export  | N/A        | `private` | `private` | Private  | `_prefix` | N/A    |
| `internal` | N/A        | N/A        | `internal`| `internal`| N/A      | N/A       | N/A    |
| `protected`| N/A        | N/A        | N/A       | `protected`| N/A     | N/A       | N/A    |
| `package`  | N/A        | Unexported | N/A       | N/A       | N/A      | N/A       | N/A    |

## Language-Specific Behavior

### TypeScript

**`public` (default):**
```typescript
export interface User {
  id: string
}

export type Status = 'active' | 'inactive'
```

**`private`:**
```typescript
interface User {
  id: string
}

type Status = 'active' | 'inactive'
```

Use `private` when generating types for internal use within a single module.

### Go

**Default (Exported):**
```go
type User struct {
    ID string `json:"id"`
}

type FunctionRegion string
```

**`package` (Unexported):**
```go
type user struct {
    ID string `json:"id"`
}

type functionRegion string
```

Go's convention: Uppercase = exported (public), lowercase = unexported (package-private).

### Swift

**`public` (recommended for libraries):**
```swift
public struct User: Codable {
    public let id: String
    public let email: String?
}

public struct FunctionRegion: RawRepresentable {
    public let rawValue: String
    public static let usEast1 = FunctionRegion(rawValue: "us-east-1")
}
```

**`internal` (default in Swift):**
```swift
internal struct User: Codable {
    internal let id: String
    internal let email: String?
}
```

**`private` (module-private):**
```swift
private struct User: Codable {
    private let id: String
    private let email: String?
}
```

### Kotlin

**Default/`public`:**
```kotlin
data class User(
    val id: String,
    val email: String? = null
)

enum class Status(val value: String) {
    ACTIVE("active")
}
```

**`internal` (module-private):**
```kotlin
internal data class User(
    val id: String,
    val email: String? = null
)
```

**`private`:**
```kotlin
private data class User(
    val id: String,
    val email: String? = null
)
```

### Rust

**`public` (default for library code):**
```rust
pub struct User {
    pub id: String,
    pub email: Option<String>,
}

pub enum Status {
    Active,
    Inactive,
}
```

**`private` (module-private):**
```rust
struct User {
    id: String,
    email: Option<String>,
}

enum Status {
    Active,
    Inactive,
}
```

### Dart

**Default (public):**
```dart
class User {
  final String id;
  final String? email;
}

enum Status {
  active,
  inactive,
}
```

**`private` (library-private):**
```dart
class _User {
  final String id;
  final String? email;
}

enum _Status {
  active,
  inactive,
}
```

Dart convention: Prefix with `_` for library-private.

### Python

Python doesn't enforce access control at the language level. All generated types are public by convention.

## When to Use Each Level

### `public` - Library/SDK Code
Use when generating types for:
- Public APIs
- SDK client libraries
- Shared type definitions
- Published packages

**Example:**
```bash
# Generate public Swift types for an SDK
npm run generate -- generate \
  -i specs/auth/schemas.json \
  -o Sources/SupabaseAuth/Models.swift \
  -l swift \
  -a public
```

### `private` - Internal Implementation
Use when generating types for:
- Internal implementation details
- Test fixtures
- Private helper types
- Non-exported utilities

**Example:**
```bash
# Generate private TypeScript types for internal use
npm run generate -- generate \
  -i specs/internal/schemas.json \
  -o src/internal/types.ts \
  -l typescript \
  -a private
```

### `internal` - Module-Level Visibility
Use when generating types for:
- Module-internal types (Swift, Kotlin)
- Cross-file but not cross-module access
- Framework internal APIs

**Example:**
```bash
# Generate internal Swift types for a framework
npm run generate -- generate \
  -i specs/models/schemas.json \
  -o Sources/Core/Internal.swift \
  -l swift \
  -a internal
```

### `package` - Package-Private (Go)
Use when generating types for:
- Go package-internal types
- Implementation details
- Types that shouldn't be exported

**Example:**
```bash
# Generate package-private Go types
npm run generate -- generate \
  -i specs/internal/schemas.json \
  -o internal/models/types.go \
  -l go \
  -a package \
  -n models
```

## Default Behavior

When no `--access` flag is specified:

| Language   | Default    | Rationale                              |
|------------|------------|----------------------------------------|
| TypeScript | `export`   | Library code convention                |
| Go         | Exported   | Public API convention                  |
| Swift      | `public`   | Library/framework convention           |
| Kotlin     | `public`   | Language default                       |
| Rust       | `pub`      | Library crate convention               |
| Dart       | Public     | Library convention                     |
| Python     | Public     | No enforcement                         |

## Examples

### TypeScript SDK

**Public API:**
```bash
npm run generate -- generate \
  -i specs/auth/schemas.json \
  -o src/types/auth.ts \
  -l typescript \
  -a public
```

**Internal types:**
```bash
npm run generate -- generate \
  -i specs/internal.json \
  -o src/internal/types.ts \
  -l typescript \
  -a private
```

### Swift Framework

**Public framework API:**
```bash
npm run generate -- generate \
  -i specs/public-api.json \
  -o Sources/MyFramework/PublicTypes.swift \
  -l swift \
  -a public
```

**Internal framework types:**
```bash
npm run generate -- generate \
  -i specs/internal.json \
  -o Sources/MyFramework/InternalTypes.swift \
  -l swift \
  -a internal
```

### Go Package

**Public package API:**
```bash
npm run generate -- generate \
  -i specs/api.json \
  -o pkg/models/types.go \
  -l go \
  -n models
```

**Package-private:**
```bash
npm run generate -- generate \
  -i specs/internal.json \
  -o internal/models/types.go \
  -l go \
  -a package \
  -n models
```

## Best Practices

1. **Library Code:** Always use `public`/`export` for published libraries
2. **Test Code:** Use `private`/`internal` for test fixtures
3. **Internal APIs:** Use `internal` (Swift/Kotlin) or `package` (Go)
4. **Consistent Visibility:** Use same access level for related types
5. **Documentation:** Document why certain types are private/internal

## Limitations

- **Python:** No access control enforcement
- **Dart:** `_` prefix only provides library-level privacy
- **Cross-Language:** Access levels don't map 1:1 across languages

## See Also

- [TypeScript Modules](https://www.typescriptlang.org/docs/handbook/modules.html)
- [Go Package Visibility](https://go.dev/tour/basics/3)
- [Swift Access Control](https://docs.swift.org/swift-book/LanguageGuide/AccessControl.html)
- [Kotlin Visibility Modifiers](https://kotlinlang.org/docs/visibility-modifiers.html)
- [Rust Visibility](https://doc.rust-lang.org/reference/visibility-and-privacy.html)
