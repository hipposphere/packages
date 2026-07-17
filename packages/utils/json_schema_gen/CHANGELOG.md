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
