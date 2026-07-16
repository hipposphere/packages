# Hippo Analysis

Shared lint and formatting policy for Hipposphere Dart workspaces and code
generators. The package requires Dart 3.12 or newer.

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
