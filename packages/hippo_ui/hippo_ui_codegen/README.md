# hippo_ui_codegen

Code generators for Hipposphere UI preview annotations.

`hippo_ui_codegen` scans package libraries for annotations that implement
`HippoWidgetPreviewMetadata` and emits a package-level generated catalog.

## Usage

Add the package as a development dependency together with `build_runner`, then
run:

```sh
dart run build_runner build
```

The `hippo_ui_catalog` builder writes:

```text
lib/hippo_ui_catalog.g.dart
```

The generated file exports `hippoUiGeneratedPreviews`, a list of
`HippoUiGeneratedPreview` objects with preview metadata, option metadata, and a
builder closure for constructor-based previews.

For Flutter widget classes annotated with `HippoWidgetPreviewFlutter`, the
generated file also emits top-level `@Preview` bridge functions. Flutter's
widget preview scanner discovers those functions, while Hippo code can keep the
class-based preview pattern.

Each generated preview has a stable `id`. If the source annotation omits `id`,
the builder derives one from the target import URI and declaration name.

The builder also emits:

```text
lib/hippo_ui_catalog.manifest.json
```

The manifest contains schema version, preview ids, target names, display
metadata, tags, and option metadata. It intentionally omits Dart builder
closures and converter instances so non-Dart tooling can index the catalog.

## Preview Fields

```dart
@HippoWidgetPreview(
  name: 'Button',
  path: 'Actions/Button',
)
class ButtonPreview {
  const ButtonPreview({
    @HippoWidgetPreviewField(.text(label: 'Label', defaultValue: 'Continue'))
    required this.label,
    @HippoWidgetPreviewField(.integerRange(label: 'Count', defaultValue: 2, min: 1, max: 5))
    required this.count,
  });

  final String label;
  final int count;
}
```

The generated option key is inferred from the constructor parameter name.

## Validation

```sh
dart analyze packages/hippo_ui_codegen
```
