import { CodegenOverrides } from '../types.js'

/**
 * Normalize overrides (returns as-is, kept for consistency)
 */
export function normalizeOverrides(overrides?: CodegenOverrides): CodegenOverrides {
  return overrides || {}
}

/**
 * Check if a type should be excluded from generation
 */
export function isTypeExcluded(typeName: string, overrides?: CodegenOverrides): boolean {
  const normalized = normalizeOverrides(overrides)
  return normalized.types?.exclude?.includes(typeName) ?? false
}

/**
 * Check if a property should be excluded from a type
 */
export function isPropertyExcluded(
  typeName: string,
  propertyName: string,
  overrides?: CodegenOverrides
): boolean {
  const normalized = normalizeOverrides(overrides)
  return normalized.properties?.exclude?.[typeName]?.includes(propertyName) ?? false
}

/**
 * Check if an enum value should be excluded
 */
export function isEnumValueExcluded(
  enumName: string,
  value: string,
  overrides?: CodegenOverrides
): boolean {
  const normalized = normalizeOverrides(overrides)
  return normalized.enums?.exclude?.[enumName]?.includes(value) ?? false
}

/**
 * Get the renamed value for an enum, if any
 */
export function getEnumValueName(
  enumName: string,
  value: string,
  overrides?: CodegenOverrides
): string | undefined {
  const normalized = normalizeOverrides(overrides)
  return normalized.enums?.names?.[enumName]?.[value]
}

/**
 * Filter enum values based on exclusions
 */
export function filterEnumValues(
  enumName: string,
  values: string[],
  overrides?: CodegenOverrides
): string[] {
  const normalized = normalizeOverrides(overrides)
  const excluded = normalized.enums?.exclude?.[enumName] || []
  return values.filter((value) => !excluded.includes(value))
}
