void validateStorageKey(String key) {
  if (key.isEmpty) {
    throw ArgumentError.value(key, 'key', 'key must not be empty.');
  }
  if (key.startsWith('/')) {
    throw ArgumentError.value(key, 'key', 'key must be relative.');
  }
  if (key.split('/').contains('..')) {
    throw ArgumentError.value(key, 'key', 'key must not contain ".." path segments.');
  }
}
