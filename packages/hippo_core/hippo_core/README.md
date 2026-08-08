# hippo_core

Core reactive primitives for Hipposphere Dart packages.

Includes small key-value storage contracts and bulk `BinaryObjectStore` primitives for local
object/document caches, with JSON and encrypted-store wrappers.

`LruResourceCache` provides bounded ownership for reusable controllers, blocs, and other
resources. It supports recency promotion, pinned entries, dynamic eviction eligibility, and
deterministic disposal. If every eviction candidate is pinned or busy, it temporarily exceeds
its capacity until `trim()` can safely release older resources.
