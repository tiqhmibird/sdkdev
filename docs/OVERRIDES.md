# Code Generation Overrides

## Overview

The `--overrides` option provides a granular customization system for code generation, allowing you to:
- **Exclude types** entirely from generation
- **Exclude specific properties** from types
- **Exclude specific enum values** from enums
- **Rename enum values** for better naming conventions

## Override File Structure

Create a JSON file with the following structure:

```json
{
  "enums": {
    "names": {
      "EnumName": {
        "originalValue": "customName"
      }
    },
    "exclude": {
      "EnumName": ["valueToExclude1", "valueToExclude2"]
    }
  },
  "types": {
    "exclude": ["TypeToExclude1", "TypeToExclude2"]
  },
  "properties": {
    "exclude": {
      "TypeName": ["propertyToExclude1", "propertyToExclude2"]
    }
  }
}
```

## Use Cases

### 1. Rename Enum Values

Useful for:
- Special characters in enum values (e.g., `*`, `-`, spaces)
- Reserved keywords in target languages
- Custom naming conventions
- Language-specific identifier requirements

**Example:**
```json
{
  "enums": {
    "names": {
      "PostgresChangeEvent": {
        "*": "all"
      },
      "Region": {
        "us-east-1": "usEast1",
        "eu-west-1": "euWest1"
      }
    }
  }
}
```

**Result:**
- Swift: `PostgresChangeEvent.all`
- Python: `PostgresChangeEvent.ALL`
- Go: `PostgresChangeEventAll`
- Rust: `PostgresChangeEvent::All`

### 2. Exclude Enum Values

Remove deprecated or unwanted enum values from generated code:

```json
{
  "enums": {
    "exclude": {
      "RealtimeEventType": ["deprecated_event", "legacy_event"],
      "Status": ["internal_status"]
    }
  }
}
```

### 3. Exclude Types

Prevent entire types from being generated (e.g., internal types, deprecated types):

```json
{
  "types": {
    "exclude": ["InternalConfig", "DeprecatedUser", "LegacyResponse"]
  }
}
```

**Use cases:**
- Internal-only types not needed in client SDKs
- Deprecated types being phased out
- Types with unresolved schema issues
- Reducing generated code size

### 4. Exclude Properties

Remove specific properties from types:

```json
{
  "properties": {
    "exclude": {
      "User": ["internal_id", "password_hash", "salt"],
      "Config": ["deprecated_option", "internal_flag"],
      "Response": ["debug_info"]
    }
  }
}
```

**Use cases:**
- Internal-only fields not for public APIs
- Sensitive data (passwords, tokens, internal IDs)
- Deprecated fields being phased out
- Platform-specific fields
- Debug/development-only properties

## Complete Example

File: `specs/myapi/overrides.json`

```json
{
  "enums": {
    "names": {
      "PostgresChangeEvent": {
        "*": "all"
      },
      "HttpMethod": {
        "DELETE": "remove"
      }
    },
    "exclude": {
      "Status": ["internal", "debug"],
      "Feature": ["experimental_v1"]
    }
  },
  "types": {
    "exclude": [
      "InternalMetrics",
      "DebugInfo",
      "LegacyResponse"
    ]
  },
  "properties": {
    "exclude": {
      "User": ["password_hash", "internal_id"],
      "Config": ["debug_mode", "internal_flags"],
      "Session": ["server_state"]
    }
  }
}
```

## CLI Usage

```bash
# Generate with overrides
npm run generate -- generate \
  -i specs/myapi/schema.json \
  -o output/types.ts \
  -l typescript \
  --overrides specs/myapi/overrides.json

# Or for multiple languages
for lang in typescript python go swift; do
  npm run generate -- generate \
    -i specs/myapi/schema.json \
    -o output/types.$lang \
    -l $lang \
    --overrides specs/myapi/overrides.json
done
```

## Language-Specific Behavior

### Enum Naming

Each language applies its own conventions to renamed values:

| Language   | Input: `"*": "all"` | Output                        |
|------------|---------------------|-------------------------------|
| TypeScript | `"all"`             | (literal, not needed)         |
| Python     | `"all"`             | `ALL = "*"`                   |
| Go         | `"all"`             | `PostgresChangeEventAll`      |
| Swift      | `"all"`             | `static let all`              |
| Kotlin     | `"all"`             | `ALL("*")`                    |
| Rust       | `"all"`             | `All`                         |
| Dart       | `"all"`             | `all`                         |

### Property Exclusion

Excluded properties are removed from:
- Type/struct/class definitions
- Constructor parameters (Dart, Kotlin)
- Serialization methods (`fromJson`, `toJson`, etc.)
- CodingKeys enums (Swift)

## Best Practices

1. **Use descriptive names** for enum overrides that make sense across all target languages
2. **Document exclusions** - add comments in your override file explaining why items are excluded
3. **Version your overrides** alongside your schemas
4. **Test across languages** to ensure overrides work as expected
5. **Keep exclusions minimal** - prefer fixing the schema when possible
6. **Use property exclusion sparingly** - consider if the property belongs in a different type
7. **Validate** that excluded items don't break references elsewhere in your schema

## Troubleshooting

### Enum Value Not Renamed
- Check that the enum name matches exactly (case-sensitive)
- Verify the original value is spelled correctly
- Ensure the override file is being loaded (check CLI output)

### Type Still Generated
- Verify the type name is in the `types.exclude` array
- Check for typos (names are case-sensitive)
- Make sure other types don't reference it (references are not automatically excluded)

### Property Still Present
- Ensure the property is listed under the correct type name
- Check that the property name matches exactly
- Verify the override file path is correct in the CLI command

### Generated Code Won't Compile
- Some exclusions may break required relationships
- Check if excluded properties are marked as required in the schema
- Verify no other types reference excluded types

## Migration from Legacy Format

If you have old override files using the `enumNames` format, update them to the new structure:

**Old format (deprecated):**
```json
{
  "enumNames": {
    "PostgresChangeEvent": {
      "*": "all"
    }
  }
}
```

**New format:**
```json
{
  "enums": {
    "names": {
      "PostgresChangeEvent": {
        "*": "all"
      }
    }
  }
}
```

The old format is no longer supported as of v0.2.0.
