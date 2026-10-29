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
