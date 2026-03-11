# Code Generation Overrides

## Overview

The `--overrides` option allows you to customize code generation by providing naming overrides for enum values that might not be valid identifiers in target languages.

## Use Cases

- Special characters in enum values (e.g., `*`, `-`, spaces)
- Reserved keywords in target languages
- Custom naming conventions
- Language-specific identifier requirements

## Usage

### Creating an Overrides File

Create a JSON file with the following structure:

```json
{
  "enumNames": {
    "TypeName": {
      "originalValue": "targetName"
    }
  }
}
```

### Example: Realtime Schema

File: `specs/realtime/overrides.json`

```json
{
  "enumNames": {
    "PostgresChangeEvent": {
      "*": "all"
    }
  }
}
```

This maps the `*` wildcard in `PostgresChangeEvent` enum to:
- `all` in Swift
- `ALL` in Python
- `all` in TypeScript
- etc.

### CLI Usage

```bash
npm run generate -- generate \
  -i specs/realtime/schemas.json \
  -o output/realtime.ts \
  -l typescript \
  --overrides specs/realtime/overrides.json
```

## Generated Code Examples

### Without Overrides

**Swift:**
```swift
// Would fail to compile!
public static let * = PostgresChangeEvent(rawValue: "*")
// Error: expected pattern
```

**Python:**
```python
# Would fail to compile!
* = "*"
# SyntaxError: invalid syntax
```

### With Overrides

**Swift:**
```swift
public struct PostgresChangeEvent: RawRepresentable, Codable, Hashable {
    public let rawValue: String

    public static let insert = PostgresChangeEvent(rawValue: "INSERT")
    public static let update = PostgresChangeEvent(rawValue: "UPDATE")
    public static let delete = PostgresChangeEvent(rawValue: "DELETE")
    public static let all = PostgresChangeEvent(rawValue: "*")  // ✅ Valid identifier
}
```

**Python:**
```python
class PostgresChangeEvent:
    """Postgres database change event types"""
    INSERT = "INSERT"
    UPDATE = "UPDATE"
    DELETE = "DELETE"
    ALL = "*"  # ✅ Valid identifier
```

**TypeScript:**
```typescript
export type PostgresChangeEvent = 'INSERT' | 'UPDATE' | 'DELETE' | '*'
// Type unions don't need identifier overrides, but the feature is available if needed
```

## Override File Structure

### Full Structure

```json
{
  "enumNames": {
    "EnumTypeName1": {
      "enum-value-1": "customName1",
      "enum-value-2": "customName2"
    },
    "EnumTypeName2": {
      "*": "all",
      "special-char": "specialChar"
    }
  }
}
```

### Multiple Overrides Example

```json
{
  "enumNames": {
    "PostgresChangeEvent": {
      "*": "all"
    },
    "StatusCode": {
      "200": "ok",
      "404": "notFound",
      "500": "serverError"
    },
    "HTTPMethod": {
      "GET": "get",
      "POST": "post",
      "PUT": "put",
      "DELETE": "del"  // 'delete' might be a keyword
    }
  }
}
```

## Language-Specific Behavior

### Swift
- Overrides applied to static property names in RawRepresentable structs
- Falls back to camelCase conversion if no override exists
- Sanitizes special characters automatically

### Python
- Overrides converted to UPPER_CASE for class constants
- Falls back to UPPER_SNAKE_CASE conversion
- Sanitizes invalid characters

### TypeScript
- Primarily uses string literal types
- Overrides available but rarely needed for TS
- Most useful for const enums if implemented

### Go, Dart, Kotlin, Rust
- Similar sanitization and fallback logic
- Language-specific naming conventions applied

## Best Practices

1. **Keep Overrides Minimal**: Only override when necessary (invalid identifiers)
2. **Use Semantic Names**: Choose names that match the value's meaning
3. **Be Consistent**: Use similar naming patterns across types
4. **Document Rationale**: Comment why overrides are needed
5. **Version Control**: Commit override files with schemas

## Fallback Behavior

If no override is provided:
- Special characters are removed or sanitized
- Case conversion applied (camelCase, UPPER_CASE, etc.)
- May result in invalid identifiers if value is unsupported

## Future Enhancements

Potential additions:
- Property name overrides
- Type name overrides
- Language-specific override sections
- Regex-based pattern matching
- Override templates

## Troubleshooting

### Override Not Applied

Check:
1. File path is correct in `--overrides` argument
2. JSON is valid (no syntax errors)
3. Type name matches exactly (case-sensitive)
4. Enum value matches exactly

### Still Getting Compilation Errors

1. Verify the override file is being loaded (check console output)
2. Check target language's identifier rules
3. Ensure override doesn't use reserved keywords
4. Try a different override value

## Related

- [JSON Schema Documentation](../README.md)
- [CLI Usage Guide](../README.md#usage)
- [Generator Implementation](../src/generators/)
