# hippobase_storage_server

Reusable Hippobase server-side storage abstractions.

The package exposes a provider interface plus a small `StorageClient` facade:

- `StorageProvider`: implement this for custom storage backends.
- `StorageClient`: validates keys and delegates upload, download, metadata, delete, and close calls.
- `InMemoryStorageProvider`: useful for tests and ephemeral storage.
- `FileSystemStorageProvider`: stores objects under a local directory.
- `S3StorageProvider`: stores objects through `dart_edge_s3_client`.

Native-capable providers can stream an object directly into another native
component. A byte range remains provider-neutral at the facade and is forwarded
as an S3 ranged GET when the provider supports it:

```dart
final download = await storage.downloadNativeStream(
  'recordings/long.wav',
  range: const StorageByteRange.from(1024 * 1024),
);
```

Unsupported ranged-native providers return `null` without starting a download.
For a ranged result, `metadata.contentLength` is the selected byte count and
`metadata.objectLength` is the complete stored object size.
