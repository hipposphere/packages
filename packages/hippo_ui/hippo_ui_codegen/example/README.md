# hippo_ui_codegen example

This example shows how `hippo_ui_codegen` reads `package:hippo_ui`
annotations and framework-specific annotations that implement
`HippoWidgetPreviewMetadata`, then emits a package-level
`lib/hippo_ui_catalog.g.dart`.

Run from the repository root:

```sh
dart run build_runner build
```

The builder reads annotations like:

```dart
@HippoWidgetPreview(
  name: 'Button',
  path: 'Actions/Button',
  description: 'Primary action surface.',
  options: [
    .text(
      name: 'label',
      defaultValue: 'Continue',
    ),
    .integerRange(
      name: 'count',
      defaultValue: 2,
      min: 1,
      max: 5,
    ),
  ],
)
class ButtonPreview {}
```
