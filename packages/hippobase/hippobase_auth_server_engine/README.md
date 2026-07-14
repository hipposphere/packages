# Hippobase Auth Server Engine

Pure-Dart, server-only authentication semantics for Hippobase Auth. This
package owns password hashing, session security, recovery, account-linking
rules, rate limiting, and the persistence interfaces consumed by adapters.

Applications normally depend on `hippobase_auth_server`, not this package.
Flutter clients must use `hippobase_auth_client` and never depend on a
`hippobase_auth_server_*` package.
