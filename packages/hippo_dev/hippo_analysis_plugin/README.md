# Hippo Analysis Plugin

Native Dart analyzer rules and IDE quick fixes for Hipposphere workspaces. Since
`hippo_analysis` 0.2.2, its default Dart and Flutter presets leave this plugin off.
Opt in at the workspace root with `package:hippo_analysis/plugins.yaml` alongside
your Dart or Flutter preset, or configure the plugin directly as shown below.
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

Public typedefs of private classes from another library keep their explicit
constructor calls. Shorthand lookup uses the underlying class, so the alias
cannot make that private class accessible. Aliases to public classes and private
classes within the same library remain eligible.

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
    version: ^0.1.1
    diagnostics:
      prefer_dot_shorthands: true
```

Consumers may disable the rule with `prefer_dot_shorthands: false` in the same
diagnostics section or suppress one instance using
`// ignore: hippo_analysis_plugin/prefer_dot_shorthands`.

Disabling the rule leaves the plugin runtime loaded. That runtime uses a separate
analyzer with an in-memory cache and can substantially increase analysis time and
memory use in large workspaces. To remove that overhead, remove the explicit
plugin declaration/include. For older presets that enable it automatically,
`plugins: null` clears all plugins inherited by an options file. Apply it to every
options file that includes those older presets, including package-local files;
a root-only override does not clear their independent includes. Restart the Dart
Analysis Server after changing plugin configuration.

For local development, replace the hosted/version source with a `path` pointing
to this package, then restart the Dart Analysis Server. Publish this package
before releasing a preset version that enables it.
