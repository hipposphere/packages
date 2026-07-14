# Hippobase Auth Client

Flutter client and persistent session controller for Hippobase Auth.

```dart
final auth = HippobaseAuthController.create(
  baseUrl: Uri.parse('https://api.example.com/auth'),
  storage: HippobaseAuthKeyValueSessionStorage(store: keyValueStore),
);

await auth.ready;
await auth.signInWithEmail(
  email: 'user@example.com',
  password: password,
);

final users = await auth.adminClient.listUsers(
  pagination: paginationConfig(offset: 0, limit: 50),
);
print(users.meta.totalItems);
```

The package includes typed public and admin clients, injectable session
storage, a Dart Edge authorization interceptor, auth states and gates, sign-in
and sign-up blocs, and reusable Flutter login widgets.

## Structure

Typed transports live in `lib/src/api`, controller and login state in
`lib/src/controllers`, session and error types in `lib/src/models`, persistence
in `lib/src/storage`, and Flutter gates/forms/dialogs in `lib/src/widgets`.
Small compatibility barrels retain the package's original public imports.
