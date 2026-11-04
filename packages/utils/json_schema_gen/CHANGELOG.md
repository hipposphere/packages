## 0.2.0

- Generate sealed Dart unions for discriminated `oneOf`/`anyOf` schemas whose
  branches reference other `@FromSchema` models, with exhaustive `switch`
  support, tag inference, `FormatException` on unknown tags, and an opt-in
  `unknownVariant` fallback that preserves the raw JSON.
- Type properties and list items that reference or inline such unions with the
  generated sealed type.
- Treat `anyOf`/`oneOf` of one schema plus `JsonSchema.nullType()` as that
  schema made nullable, including nullable references.
- Fix re-emitted schema constants dropping `anyOf`/`oneOf`/`allOf` branches and
  emitting redundant `const` keywords.
- Escape `$` and backslashes in generated string literals.
- Require `json_schema` 0.2.

## 0.1.6

- Support Hippo Analysis 0.2 and current analyzer/source_gen APIs.
- Order required generated constructor parameters before optional parameters.
- Preserve explicit generated type names under the dot shorthand lint.

## 0.1.5

- Support analyzer 14.x while retaining analyzer 13.x compatibility.

## 0.1.2

- Preserve primitive JSON Schema defaults and apply them to generated optional
  model fields when the JSON key is absent.

## 0.1.1

- Use the shared `hippo_analysis` formatter policy by default while preserving
  builder-level formatter overrides.

## 0.1.0

- Add a standalone `build_runner` generator for portable `@FromSchema` Dart
  models, plus generator-facing schema type adapter contracts.
- Generate object and enum models that implement `JsonEncodable`.
