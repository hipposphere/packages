import 'dart:io';

/// Enables real network I/O in widget tests while containing it to loopback.
/// This replaces Flutter's HTTP-400 stub, not the product's HTTP transport.
class LoopbackHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.findProxy = (_) => 'DIRECT';
    client.connectionTimeout = const Duration(seconds: 5);
    client.connectionFactory = (uri, proxyHost, proxyPort) {
      if (uri.scheme != 'http' ||
          !['127.0.0.1', 'localhost', '::1'].contains(uri.host) ||
          proxyHost != null) {
        return Future.error(
          SocketException('Test network only permits loopback HTTP', address: null),
        );
      }
      return Socket.startConnect(uri.host, uri.port);
    };
    return client;
  }
}
