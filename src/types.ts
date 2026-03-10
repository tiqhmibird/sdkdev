export interface JSONSchema {
  $schema?: string
  definitions?: Record<string, SchemaDefinition>
  properties?: Record<string, SchemaProperty>
  type?: string
  required?: string[]
}

export interface SchemaDefinition {
  type: string
  description?: string
  properties?: Record<string, SchemaProperty>
  required?: string[]
  items?: SchemaProperty
  enum?: string[]
  oneOf?: SchemaDefinition[]
  allOf?: SchemaDefinition[]
  anyOf?: SchemaDefinition[]
  $ref?: string
  format?: string
  pattern?: string
  additionalProperties?: boolean | SchemaProperty
  patternProperties?: Record<string, SchemaProperty>
  deprecated?: boolean
}

export interface SchemaProperty {
  type?: string | string[]
  description?: string
  format?: string
  enum?: string[]
  items?: SchemaProperty
  $ref?: string
  oneOf?: SchemaDefinition[]
  properties?: Record<string, SchemaProperty>
  required?: string[]
  additionalProperties?: boolean | SchemaProperty
  pattern?: string
  example?: any
  default?: any
  deprecated?: boolean
}

export type AccessControl =
  | 'public'      // TypeScript, Swift, Kotlin, Rust
  | 'private'     // Swift, Kotlin, Rust
  | 'internal'    // Swift, Kotlin
  | 'protected'   // Kotlin
  | 'export'      // TypeScript (default)
  | 'package'     // Go (lowercase names)

export interface GeneratorOptions {
  namespace?: string
  includeComments?: boolean
  includeValidation?: boolean
  accessControl?: AccessControl
}

export interface CodeGenerator {
  generate(schema: JSONSchema, options?: GeneratorOptions): string
  generateType(name: string, definition: SchemaDefinition, options?: GeneratorOptions): string
}
