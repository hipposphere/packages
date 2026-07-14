String? normalizedHippobaseAuthSqlSchema(String? value) {
  final schema = value?.trim();
  if (schema == null || schema.isEmpty) return null;
  if (!RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(schema)) {
    throw ArgumentError.value(value, 'schema', 'Must be an unquoted PostgreSQL identifier.');
  }
  return schema;
}
