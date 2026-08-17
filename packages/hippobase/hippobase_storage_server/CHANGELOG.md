## 0.1.8

* Add an optional provider-neutral native streaming upload capability.
* Forward native S3 upload bodies directly to `dart_edge_s3_client` without
  materializing their chunks in Dart memory.
* Require `dart_edge_s3_client` 0.3.18.

## 0.1.7

* Add optional provider-neutral native byte-range downloads.
* Forward S3 ranges directly into native S3 GET streams and expose the total
  object length without moving response bytes through the Dart heap.

## 0.1.6

* Add optional native streaming and native file provider capabilities without
  changing the base `StorageProvider` contract.
* Implement native streaming for `S3StorageProvider` and require
  `dart_edge_s3_client` 0.3.16.

## 0.1.5

* Propagate explicit close callbacks for storage download streams so resources
  can be released even when a body is never listened to.
* Require `dart_edge_s3_client` 0.3.15.

## 0.1.4

* Add demand-driven streaming downloads to the storage provider contract,
  including native S3, file-system, and in-memory implementations.
* Require `dart_edge_s3_client` 0.3.14.

## 0.1.2

* Add a close method to storage providers and the storage client facade.

## 0.1.0

* Add reusable storage client and provider abstractions.
* Add in-memory, file-system, and S3 storage providers.
