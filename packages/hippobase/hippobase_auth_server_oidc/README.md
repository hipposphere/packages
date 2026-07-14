# Hippobase Auth Server OIDC

OpenID Connect discovery, authorization-code with PKCE, token validation,
nonce validation, and verified-claim extraction for Hippobase Auth servers.
Account matching and collision policy remain in the server engine.

```dart
final auth = HippobaseAuthServer(
  options,
  store: store,
  oauthAdapterFactory: const HippobaseAuthOidcAdapterFactory(),
);
```

Only servers with configured SSO providers need this package.
