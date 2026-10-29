# Hippo Analysis Plugin

Native Dart analyzer rules and IDE quick fixes for Hipposphere workspaces. The
`hippo_analysis` Dart and Flutter presets enable this plugin automatically.
Formatter users do not acquire analyzer dependencies through `hippo_analysis`.

## prefer_dot_shorthands

Prefer `.active`, `.origin()`, and `.new()` when the surrounding type identifies
the same class or enum as the explicit qualifier. The rule uses resolved types
for arguments, explicitly typed variables, assignments, defaults, return values,
callbacks, equality right operands, conditional branches, and explicitly typed
collections. It also supports nullable contexts and async return values.

```dart
enum Status { active }

Status initialStatus() => .active;
bool isActive(Status status) => status == .active;
```

The rule leaves inferred variables, inferred return types, generic parameter
inference, subtype construction, generic constructors, and explicit generic
arguments alone. It does not add type annotations just to enable shorthand.
Existing shorthands are accepted. Files using language versions before Dart 3.10
are skipped.

The **Use dot shorthand** quick fix changes only the qualifier, preserving
`const`, argument evaluation order, and comments. Imported qualifiers are
supported. Qualifiers with embedded comments are left unchanged rather than
discarding those comments. The fix supports an individual diagnostic and IDE
fix-all within one file. The native plugin framework does not currently expose
these fixes through `dart fix` bulk cleanup.

To configure this plugin directly:

```yaml
plugins:
  hippo_analysis_plugin:
    hosted: https://pub.hippolabs.org
    version: ^0.1.0
    diagnostics:
      prefer_dot_shorthands: true
```

Consumers may disable the rule with `prefer_dot_shorthands: false` in the same
diagnostics section or suppress one instance using
`// ignore: hippo_analysis_plugin/prefer_dot_shorthands`.

For local development, replace the hosted/version source with a `path` pointing
to this package, then restart the Dart Analysis Server. Publish this package
before releasing a preset version that enables it.
