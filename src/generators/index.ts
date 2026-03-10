import { JSONSchema, GeneratorOptions } from '../types.js'
import { TypeScriptGenerator } from './typescript.js'
import { PythonGenerator } from './python.js'
import { GoGenerator } from './go.js'
import { DartGenerator } from './dart.js'
import { SwiftGenerator } from './swift.js'
import { KotlinGenerator } from './kotlin.js'
import { RustGenerator } from './rust.js'

const generators = {
  typescript: new TypeScriptGenerator(),
  python: new PythonGenerator(),
  go: new GoGenerator(),
  dart: new DartGenerator(),
  swift: new SwiftGenerator(),
  kotlin: new KotlinGenerator(),
  rust: new RustGenerator(),
}

export function generateCode(
  schema: JSONSchema,
  language: string,
  options?: GeneratorOptions
): string {
  const generator = generators[language as keyof typeof generators]

  if (!generator) {
    throw new Error(
      `Unsupported language: ${language}. Supported languages: ${Object.keys(generators).join(', ')}`
    )
  }

  return generator.generate(schema, options)
}
