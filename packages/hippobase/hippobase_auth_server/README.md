# Hippobase Auth Server

A pure-Dart authentication server compatible with the existing Hippobase
Better Auth database, password hashes, bearer tokens, and signed cookies.

```dart
final store = HippobaseAuthSqlStore(database, schema: 'auth');
final auth = HippobaseAuthServer(
  HippobaseAuthServerOptions(
    secret: environment.authSecret,
    baseUrl: 'https://api.example.com/auth',
    trustedOrigins: const ['https://app.example.com'],
  ),
  store: store,
);

auth.mountPublic(router, basePath: '/auth');
auth.mountAdmin(router, basePath: '/auth');
```

Mounting the admin router is explicit. Its routes require an authenticated user
with an configured admin role unless an application guard is supplied. Use
`auth.trustedAdmin` for trusted bootstrap work that must not depend on an HTTP
session, and call `auth.close()` during server shutdown.

The admin router exposes `POST` and `GET` on `/v1/admin/users`, plus `PATCH`
and `DELETE` on `/v1/admin/users/<userId>`. List requests use the shared
Hippobase `PaginationConfig` query (`offset` and `limit`) and return `items`
with `PaginationMeta`.

Password hashing and authentication policy live in
`hippobase_auth_server_engine`. OAuth/OIDC protocol handling lives in
`hippobase_auth_server_oidc`. SQL repositories and transactions live in
`hippobase_auth_server_sql` and are injected through `HippobaseAuthStore`.
When SSO providers are configured, pass
`oauthAdapterFactory: const HippobaseAuthOidcAdapterFactory()` and depend on
`hippobase_auth_server_oidc` explicitly.

## Structure

HTTP registration lives under `lib/src/router`. Public, admin, OAuth2, and
hosted-view routers each have their own folder, and every endpoint has its own
route folder. This package owns only HTTP routing, guards, cookies, response
mapping, and composition.
