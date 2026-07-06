final class QueryApplicationException implements Exception {
  const QueryApplicationException(this.message);

  final String message;

  @override
  String toString() => 'QueryApplicationException: $message';
}
