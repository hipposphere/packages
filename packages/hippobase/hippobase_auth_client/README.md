# Hippobase Auth Client

Plain Dart HTTP bindings for Hippobase Auth. The package has no Flutter,
session persistence, or UI dependencies.

```dart
String? token;
final auth = HippobaseAuthClient(
  baseUrl: Uri.parse('https://api.example.com/auth'),
  tokenProvider: () => token,
);

final session = await auth.signInWithEmail(
  email: 'user@example.com',
  password: password,
);
token = session.token;
```

The public client exposes typed user authentication routes. A token provider is
optional for public-only calls and is consulted for authenticated calls.

Admin bindings are opt-in and constructed separately only by admin surfaces:

```dart
import 'package:hippobase_auth_client/hippobase_auth_admin_client.dart';

final admin = HippobaseAuthAdminClient(
  baseUrl: Uri.parse('https://api.example.com/auth'),
  tokenProvider: () => token,
);

final users = await admin.listUsers(
  pagination: paginationConfig(offset: 0, limit: 50),
);
print(users.meta.totalItems);

admin.close();
```

Use `hippobase_auth_flutter` for persistent sessions, auth state, OAuth web
authentication, Flutter forms, gates, and provider widgets.

## Structure

Typed public and admin bindings live in `lib/src/api`; shared wire types come
from `hippobase_auth_api_contract` and `hippobase_auth_models`. The default
entrypoint exports only public bindings; the admin entrypoint adds the admin
client.
