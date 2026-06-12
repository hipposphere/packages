# hippo_ui

Framework-neutral widget preview metadata for Hipposphere UI tooling.

This package owns the source annotations, option models, generated catalog
models, and shared preview enums used by code generators and preview runtimes.
It is pure Dart so analyzer and build tooling can read metadata without loading
Flutter or another UI framework.

## Usage

```dart
import 'package:hippo_ui/hippo_ui.dart';

@HippoWidgetPreview(
  name: 'Button',
  path: 'Actions/Button',
  description: 'Primary command surface.',
)
class ButtonPreview {
  const ButtonPreview({
    @HippoWidgetPreviewField(.text(label: 'Label', defaultValue: 'Continue'))
    required this.label,
  });

  final String label;
}
```

Preview display names use `name`. Configurable constructor parameters use
generated option `key`s inferred from parameter names.

Generated previews include stable ids for deep links and persisted state. Pass
`id` to `@HippoWidgetPreview` when a public id must survive file moves; otherwise
`hippo_ui_codegen` derives one from the target import URI and declaration name.

Wrap generated preview lists in `HippoUiCatalog` to search, resolve by id, list
previews by path or tag, and build a folder tree for catalog navigation.

## Validation

```sh
dart analyze packages/hippo_ui
```
