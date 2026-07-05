# hippobase_storage_server

Reusable Hippobase server-side storage abstractions.

The package exposes a provider interface plus a small `StorageClient` facade:

- `StorageProvider`: implement this for custom storage backends.
- `StorageClient`: validates keys and delegates upload, download, metadata, and delete calls.
- `InMemoryStorageProvider`: useful for tests and ephemeral storage.
- `FileSystemStorageProvider`: stores objects under a local directory.
- `S3StorageProvider`: stores objects through `dart_edge_s3_client`.
