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
