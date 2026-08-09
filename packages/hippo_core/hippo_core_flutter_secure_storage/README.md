# hippo_core_flutter_secure_storage

A `flutter_secure_storage`-backed `KeyValueStore` adapter for `hippo_core`.

Add this package only to applications that need platform-secured key-value storage:

```dart
import 'package:hippo_core_flutter_secure_storage/hippo_core_flutter_secure_storage.dart';

final store = SecureKeyValueStore(storePrefix: 'my_app');
```
