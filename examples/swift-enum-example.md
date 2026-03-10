# Swift Enum Generation Example

The Swift generator creates enums as `RawRepresentable` structs with static let values instead of traditional Swift enums. This pattern provides better API flexibility and handles unknown values gracefully.

## Why Structs Instead of Enums?

### Traditional Swift Enum (❌ Not Used)
```swift
enum FunctionRegion: String, Codable {
    case any = "any"
    case usEast1 = "us-east-1"
}

// Problem: Cannot handle unknown values from API
// If API returns new region, decoding fails
```

### RawRepresentable Struct (✅ Used)
```swift
struct FunctionRegion: RawRepresentable, Codable, Equatable, Hashable, ExpressibleByStringLiteral {
    let rawValue: String

    static let any = FunctionRegion(rawValue: "any")
    static let usEast1 = FunctionRegion(rawValue: "us-east-1")

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    init(stringLiteral value: String) {
        self.rawValue = value
    }
}

// Benefits:
// ✓ Can handle unknown values gracefully
// ✓ Still provides convenient static constants
// ✓ Type-safe for known values
// ✓ String literal initialization: let region: FunctionRegion = "us-east-1"
// ✓ Forward-compatible with API changes
```

## Usage Example

```swift
// Using static constants (recommended for known values)
let region1: FunctionRegion = .usEast1

// Using string literals (thanks to ExpressibleByStringLiteral)
let region2: FunctionRegion = "us-east-1"

// Creating from string variable
let regionString = "us-west-3"
let region3 = FunctionRegion(rawValue: regionString)

// All three work seamlessly
let regions: [FunctionRegion] = [.usEast1, "us-west-2", FunctionRegion(rawValue: "any")]

// Comparing values
if region1 == .usEast1 {
    print("Using US East 1")
}

// String literal in function parameters
func deployTo(region: FunctionRegion) {
    print("Deploying to \(region.rawValue)")
}

deployTo(region: .usEast1)      // Static constant
deployTo(region: "us-west-2")   // String literal
deployTo(region: region3)       // Variable

// Decoding from JSON (handles unknown values)
let json = """
{
    "region": "ap-northeast-1"
}
"""

struct Config: Codable {
    let region: FunctionRegion
}

let decoder = JSONDecoder()
let config = try decoder.decode(Config.self, from: json.data(using: .utf8)!)
print(config.region.rawValue) // "ap-northeast-1"
```

## JSON Schema Input

```json
{
  "definitions": {
    "FunctionRegion": {
      "type": "string",
      "enum": [
        "any",
        "us-east-1",
        "us-west-1",
        "ap-northeast-1"
      ],
      "description": "AWS region for Edge Function deployment"
    }
  }
}
```

## Generated Swift Output

```swift
/// AWS region for Edge Function deployment
struct FunctionRegion: RawRepresentable, Codable, Equatable, Hashable, ExpressibleByStringLiteral {
    let rawValue: String

    static let any = FunctionRegion(rawValue: "any")
    static let usEast1 = FunctionRegion(rawValue: "us-east-1")
    static let usWest1 = FunctionRegion(rawValue: "us-west-1")
    static let apNortheast1 = FunctionRegion(rawValue: "ap-northeast-1")

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    init(stringLiteral value: String) {
        self.rawValue = value
    }
}
```

## Best Practices

### ✅ Do
```swift
// Use static constants for known values
let region: FunctionRegion = .usEast1

// Use string literals for convenience
let region2: FunctionRegion = "us-west-2"

// Create custom/unknown values when needed
let newRegion = FunctionRegion(rawValue: "eu-west-1")

// Compare using equality
if config.region == .usEast1 { }

// Pass string literals directly to functions
func configure(region: FunctionRegion) { }
configure(region: "us-east-1")  // Clean and concise
```

### ❌ Don't
```swift
// Don't use verbose initialization for known values
let region = FunctionRegion(rawValue: "us-east-1") // Use .usEast1 or "us-east-1" instead

// Don't switch on rawValue (use == instead)
switch region.rawValue {
case "us-east-1": break // Use if region == .usEast1 instead
}

// Don't force unwrap or use guard with string literals
guard let region = FunctionRegion(rawValue: "us-east-1") else { } // Unnecessary, use: let region: FunctionRegion = "us-east-1"
```

## Naming Conventions

The generator converts kebab-case and snake_case to camelCase for Swift property names:

| JSON Value       | Swift Static Constant |
|------------------|----------------------|
| `any`            | `.any`               |
| `us-east-1`      | `.usEast1`           |
| `ap-northeast-1` | `.apNortheast1`      |
| `eu_west_2`      | `.euWest2`           |

## ExpressibleByStringLiteral Benefits

The `ExpressibleByStringLiteral` conformance provides exceptional API ergonomics:

```swift
// Before (verbose)
func configure(region: FunctionRegion) {
    // ...
}
configure(region: FunctionRegion(rawValue: "us-east-1"))

// After (clean)
configure(region: "us-east-1")

// Dictionary literals
let configs: [String: FunctionRegion] = [
    "primary": "us-east-1",
    "backup": "us-west-2"
]

// Array literals
let regions: [FunctionRegion] = ["us-east-1", "us-west-2", .apNortheast1]

// Ternary expressions
let region: FunctionRegion = isProduction ? "us-east-1" : "us-west-2"
```

## Advantages for API Evolution

This pattern is ideal for APIs that evolve over time:

1. **New Values**: API can add new enum values without breaking existing clients
2. **Deprecation**: Old values can be marked as deprecated while remaining functional
3. **Custom Values**: Clients can create custom values for testing or special cases
4. **Decoding Safety**: JSON decoding never fails due to unknown enum values
5. **Ergonomic**: String literals work seamlessly thanks to `ExpressibleByStringLiteral`

## Command to Generate

```bash
npm run generate -- generate \
  -i specs/functions/schemas.json \
  -o Sources/Models/FunctionRegion.swift \
  -l swift
```
