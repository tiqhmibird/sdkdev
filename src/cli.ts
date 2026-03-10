#!/usr/bin/env node
import { program } from 'commander'
import { readFileSync } from 'fs'
import { resolve } from 'path'
import { generateCode } from './generators/index.js'

program
  .name('sdkdev')
  .description('SDK development tools for generating types from JSON schemas')
  .version('0.1.0')

program
  .command('generate')
  .description('Generate code from JSON schema')
  .requiredOption('-i, --input <path>', 'Input JSON schema file')
  .requiredOption('-o, --output <path>', 'Output file path')
  .requiredOption('-l, --language <lang>', 'Target language (typescript, python, go, dart, swift, kotlin, rust)')
  .option('-n, --namespace <name>', 'Namespace/module name for generated code')
  .option('-a, --access <control>', 'Access control (public, private, internal, protected, export, package)')
  .action(async (options) => {
    try {
      const schemaPath = resolve(process.cwd(), options.input)
      const outputPath = resolve(process.cwd(), options.output)

      console.log(`Reading schema from: ${schemaPath}`)
      const schemaContent = readFileSync(schemaPath, 'utf-8')
      const schema = JSON.parse(schemaContent)

      console.log(`Generating ${options.language} code...`)
      const code = generateCode(schema, options.language, {
        namespace: options.namespace,
        accessControl: options.access,
      })

      const fs = await import('fs')
      fs.writeFileSync(outputPath, code)

      console.log(`✓ Generated code written to: ${outputPath}`)
    } catch (error) {
      console.error('Error generating code:', error)
      process.exit(1)
    }
  })

program.parse()
