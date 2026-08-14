/// An error returned by systemd over D-Bus.
final class SystemdClientException implements Exception {
  const SystemdClientException({required this.method, required this.errorName, this.message});

  final String method;
  final String errorName;
  final String? message;

  @override
  String toString() {
    final detail = message;
    return detail == null || detail.isEmpty
        ? 'SystemdClientException($method, $errorName)'
        : 'SystemdClientException($method, $errorName): $detail';
  }
}
