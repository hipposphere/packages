# hippo_ui_jaspr

Jaspr widget preview annotations for Hipposphere UI tooling.

`hippo_ui_jaspr` provides a Jaspr-named annotation that implements the shared
`HippoWidgetPreviewMetadata` contract from `package:hippo_ui`. Jaspr support is
currently work in progress.

## Usage

```dart
import 'package:hippo_ui_jaspr/hippo_ui_jaspr.dart';

@HippoWidgetPreviewJaspr(
  name: 'Button',
  path: 'Actions/Button',
  description: 'Primary action surface.',
)
class ButtonPreview {}
```

## Validation

```sh
dart analyze packages/hippo_ui_jaspr
```
