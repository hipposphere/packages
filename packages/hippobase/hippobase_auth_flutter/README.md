# Hippobase Auth Flutter

Flutter providers and reactive auth-state widgets for `hippobase_auth_client`.
The package re-exports the client API, so an app normally needs only one import.

```dart
import 'package:hippobase_auth_flutter/hippobase_auth_flutter.dart';

final auth = HippobaseAuthController.create(
  baseUrl: Uri.parse('https://api.example.com/auth'),
  storage: sessionStorage,
);

HippobaseAuthProvider(
  controller: auth,
  child: HippobaseAuthView(
    loadingBuilder: (_) => const LoadingScreen(),
    unauthenticatedBuilder: (_) => HippobaseAuthLoginForm(controller: auth),
    authenticatedBuilder: (_, session) => const HomeScreen(),
    failureBuilder: (_, error) => AuthErrorScreen(error: error),
  ),
);
```

Typed HTTP bindings and wire contracts remain owned by
`hippobase_auth_client`. This package adds session persistence, OAuth web auth,
reactive state, forms, and gates without duplicating the server contract. It
does not export or create an admin client. Admin applications can import
`package:hippobase_auth_client/hippobase_auth_admin_client.dart` separately.

The creator of `HippobaseAuthController` owns its lifecycle and must call
`dispose()` when the app-level auth scope is torn down.
