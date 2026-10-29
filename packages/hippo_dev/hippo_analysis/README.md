# Hippo Analysis

Shared lint and formatting policy for Hipposphere Dart workspaces and code
generators. The package requires Dart 3.13 or newer.

Use the Dart preset at the workspace root:

```yaml
include: package:hippo_analysis/dart.yaml
```

Flutter packages select the Flutter preset with a package-local
`analysis_options.yaml`:

```yaml
include: package:hippo_analysis/flutter.yaml
```

Generators that format emitted Dart in memory should use the same policy:

```dart
import 'package:hippo_analysis/hippo_analysis.dart';

final formatter = createHippoDartFormatter();
```

Both presets use a page width of 100 and automatic trailing commas.

## Enforced structure

Both presets add these rules to the standard recommended lint sets:

| Rule | Convention |
| --- | --- |
| `sort_constructors_first` | Place constructors and factories before fields and methods. |
| `sort_unnamed_constructors_first` | Place the unnamed constructor before named constructors. |
| `always_put_required_named_parameters_first` | Declare required named parameters before optional named parameters. |
| `directives_ordering` | Group and order import and export directives consistently. |
| `sort_pub_dependencies` | Alphabetize dependency names within each pubspec dependency section. |

The Flutter preset also inherits `sort_child_properties_last`: place widget
configuration before `child` and `children` arguments. These rules cover
declarations and selected call-site conventions; they do not impose a general
argument sorter.

## Shared coding conventions

These conventions guide implementation and review; the presets do not enforce
every point below.

- Read a class in this order: constructors and factories; fields grouped by
  responsibility; getters and public operations with related private helpers
  nearby; lifecycle cleanup. Keep related behavior together rather than sorting
  methods alphabetically. Among named constructors, keep public entry points
  before private assembly constructors when practical.
- Prefer named constructor parameters, including private constructors, and super
  parameters. Preserve positional parameters where a framework, override, or
  established API requires them or a small conventional API benefits from them.
- Within required and optional parameter groups, prefer dependencies, primary
  data, configuration, then callbacks. Keep closely related parameters together.
  Follow the declaration's order at call sites where it aids readability, while
  keeping widget children last. Do not mechanically reorder argument expressions
  or field initializers: evaluation order can change behavior.
- Spell out generic constructor type arguments, for example
  `Resource<List<Item>>(...)`, `Command<ItemId, void>(...)`, and
  `DataSubject<int>.seeded(0)`. This does not require explicit types on every local
  variable. Prefer Dart dot shorthands where the contextual type is clear and
  explicit generic constructor arguments are not needed.
- For `ScopedBloc`, initialize fields eagerly using ordinary `final` fields. Use
  constructor initializers for simple dependencies and a public factory plus a
  private constructor for interconnected controllers. Assemble owned resources
  inside `ResourceScope.build<BlocType>` and pass `required super.scope` to the
  private constructor. Reserve `late final` for intentional lazy initialization.
- Prefer `scope.resource<T>`, `scope.command<I, O>`, and `scope.subject<T>` with
  explicit type arguments. Use `scope.own<T>` for other `Disposable` resources and
  Flutter adapters such as `scope.textController()` for Flutter controllers.
  Let the scope dispose resources it owns; manually dispose only resources owned
  directly by the Bloc.
- Use sealed command states for idle/running/succeeded/failed UI state. Handle
  invocation success/failure/skipped results at the action boundary; do not replay
  navigation or notifications from widget builds.

### Dot shorthands

Prefer dot shorthands for enum values, static members, and constructors when the
surrounding type makes the target clear:

```dart
enum AuthenticationMode { signIn, signUp }

AuthenticationMode initialMode() => .signIn;
bool isSignIn(AuthenticationMode mode) => mode == .signIn;
```

Keep the type name where context is absent, such as
`final mode = AuthenticationMode.signIn`, and keep explicit generic constructor
arguments such as `DataSubject<int>.seeded(0)`. Do not introduce redundant type
annotations just to enable shorthand.

Both presets enable the native
`hippo_analysis_plugin/prefer_dot_shorthands` diagnostic and its **Use dot
shorthand** IDE quick fix. The companion plugin is loaded separately from the
formatter library and does not add analyzer dependencies to formatter consumers.
It preserves generic constructors, explicit generic arguments, inferred
variables, and expressions whose context would select a different class or enum.
See the [plugin documentation](../hippo_analysis_plugin/README.md) for supported
contexts and local development configuration. This is a plugin diagnostic under
`plugins.hippo_analysis_plugin.diagnostics`, not a standard `linter.rules` entry.

## Adoption

Version 0.2.0 enables additional style diagnostics. Measure changes in a dedicated
cleanup before enabling the new version across a large repository. Use
`dart fix --dry-run` to preview supported fixes, review changes, then format and
analyze. Keep cleanup separate from feature work. Fix generated-code conventions
in their owning generators and regenerate; do not hand-edit generated output.
Use `dart analyze --fatal-infos` (or `flutter analyze --fatal-infos`) in CI when
style diagnostics should fail the check; `dart analyze` does not fail on infos by
default.

For a local checkout, keep the preset's diagnostics and override the plugin
dependency source:

```yaml
plugins:
  dependency_overrides:
    hippo_analysis_plugin:
      path: /path/to/hippo_analysis_plugin
```

Publish the companion plugin before releasing this preset version. Restart the
Dart Analysis Server after changing plugin sources.
