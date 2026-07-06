# hippo_ui_flutter

Flutter preview metadata, options, and converters for Hipposphere UI tooling.

This package reexports `package:hippo_ui/hippo_ui.dart` and adds Flutter-specific
preview helpers such as `HippoWidgetPreviewFlutter`, alignment options, and
common Flutter converters.

## Usage

```dart
import 'package:flutter/widgets.dart';
import 'package:hippo_ui_flutter/hippo_ui_flutter.dart';

@HippoWidgetPreviewFlutter(
  name: 'Aligned label',
  path: 'Typography/Label',
)
final class PreviewLabel extends StatelessWidget {
  const PreviewLabel({
    @HippoWidgetPreviewField(.text(label: 'Text', defaultValue: 'Continue'))
    required this.text,
    @HippoWidgetPreviewField(HippoUiAlignmentOption(label: 'Alignment', defaultValue: .center))
    required this.alignment,
    super.key,
  });

  final String text;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(alignment: alignment, child: Text(text));
  }
}
```

`@HippoWidgetPreviewFlutter` on a widget class is read by Hippo catalog codegen.
Flutter's widget preview scanner only discovers public top-level functions,
public static methods, and public widget constructors or factories with no
required arguments, so `hippo_ui_codegen` emits top-level Flutter preview bridge
functions into `lib/hippo_ui_catalog.g.dart`.

Run codegen before starting Flutter Preview:

```sh
dart run build_runner build
flutter widget-preview start
```

Use the framework-neutral `@HippoWidgetPreview` when a declaration should appear
in Hippo catalogs without generating Flutter preview bridges.

Flutter-specific option helpers are available for constructor parameters that
cannot be represented directly as JSON-safe preview values:

```dart
import 'package:flutter/material.dart';

@HippoWidgetPreviewField(
  HippoUiIconDataOption(
    label: 'Icon',
    defaultValue: Icons.check,
    values: [
      HippoUiOptionValue(value: Icons.check, label: 'Check'),
      HippoUiOptionValue(value: Icons.close, label: 'Close'),
    ],
  ),
)
required IconData icon,
```

Additional prebuilt Flutter options are available for common constructor
parameters:

- `HippoUiColorOption`
- `HippoUiEdgeInsetsOption`
- `HippoUiBorderRadiusOption`
- `HippoUiSizeOption`
- `HippoUiDurationOption`
- `HippoUiCurveOption`
- `HippoUiBoxConstraintsOption`

For theme-dependent or compositional parameters, use string-keyed options with a
project converter: `HippoUiTextStyleOption` for `TextStyle` and
`HippoUiWidgetOption` for `Widget`.

Project-specific annotations can extend `HippoWidgetPreviewFlutter` when they
need custom constructor defaults or additional const metadata.

## Validation

```sh
flutter analyze packages/hippo_ui_flutter
```
