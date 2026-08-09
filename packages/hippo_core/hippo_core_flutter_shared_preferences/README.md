# hippo_core_flutter_shared_preferences

A `shared_preferences`-backed `KeyValueStore` adapter for `hippo_core`.

Add this package only to applications that need persistent, non-sensitive preferences:

```dart
import 'package:hippo_core_flutter_shared_preferences/hippo_core_flutter_shared_preferences.dart';

final store = SharedPreferencesKeyValueStore(storePrefix: 'my_app');
```
