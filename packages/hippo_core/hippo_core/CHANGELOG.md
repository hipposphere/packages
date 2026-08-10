## 0.1.10

* Add `ValueChange` for explicit nullable value updates.

## 0.1.9

* Add read-only `DataValue` and typed lazy derived-value APIs.
* Correct `StoreController` initialization, write ordering, stale-load, error,
  and disposal behavior.
* Improve `DataSubject` nullable-value, error stack-trace, and close semantics.

## 0.1.8

* Add `ResourceLease` and reference-counted leases to `LruResourceCache`.

## 0.1.7

* Add `LruResourceCache` for bounded, lifecycle-aware resource ownership.

## 0.1.5

* Add `BinaryObjectStore` primitives with JSON, memory, and encrypted wrappers.

## 0.1.0

* Move pure Bloc and DataSubject primitives from `hippo_utils`.
* Move the `KeyValueStore` contract from `hippo_utils`.
