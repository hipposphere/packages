## 0.2.1

- Require the corrected dot-shorthand plugin, which preserves public typedef
  constructor calls when their underlying private class belongs to another library.

## 0.2.0

- Enforce constructors before other members, unnamed constructors first, required
  named parameters first, ordered directives, and sorted pub dependencies in both
  analysis presets. Existing consumers may report additional lint diagnostics.
- Document shared class structure, parameter grouping, explicit generic
  constructor arguments, and scoped Bloc conventions.
- Keep the inherited Flutter rule that places widget children last.
- Enable the native `hippo_analysis_plugin/prefer_dot_shorthands` rule and its IDE
  quick fix in both presets, preserving explicit generic constructor arguments.

## 0.1.0

- Add shared Dart and Flutter analysis presets.
- Add a formatter factory for deterministic generated Dart output.
