# hippo_core

Core reactive primitives for Hipposphere Dart packages.

Includes small key-value storage contracts and bulk `BinaryObjectStore` primitives for local
object/document caches, with JSON and encrypted-store wrappers.

`LruResourceCache` provides bounded ownership for reusable controllers, blocs, and other
resources. It supports recency promotion, pinned entries, dynamic eviction eligibility, and
deterministic disposal. If every eviction candidate is pinned or busy, it temporarily exceeds
its capacity until `trim()` can safely release older resources.

Use `acquire()` or `getOrCreateLease()` for temporary consumers. A `ResourceLease` prevents
capacity eviction until its idempotent `release()` is called; releasing the final lease
automatically trims accumulated overflow. Explicit pins remain available for permanent policies.

`StoreController` exposes an optimistically updated value backed by a `KeyValueStore`. Await
`ready` when work depends on the initial persisted value. Initialization happens at most once,
and writes are persisted in invocation order. Pass `initializeOnCreation: false` to defer the
first read until `ready` or `initialize()` is used.

Use `DataValue<T>` when a consumer only needs read access to reactive state and `DataSubject<T>`
when an owner also needs to publish updates. `DataValues.select`, `combine2` through `combine4`,
typed `compute2` through `compute10`, and homogeneous `computeList` create lazy derived values
that listen only while consumed and require no disposal. The typed compute methods derive their
subscriptions from their arguments, so every value available to the callback triggers updates.
