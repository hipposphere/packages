import 'dart:async';
import 'dart:io';

/// TCP forwarding preserves real HTTP/WebSocket traffic. Offline closes all
/// established connections and rejects new ones for this client alone.
class ClientNetworkLink {
  ClientNetworkLink._(ServerSocket listener, this.upstream)
    : _listener = listener,
      _port = listener.port;
  ServerSocket? _listener;
  final int _port;
  final Uri upstream;
  final _sockets = <Socket>{};
  bool _offline = false, _closed = false;
  int forwardedConnections = 0,
      rejectedConnections = 0,
      disconnectedConnections = 0,
      offlineTransitions = 0;
  Uri get baseUri => Uri(scheme: 'http', host: '127.0.0.1', port: _port);
  bool get offline => _offline;
  static Future<ClientNetworkLink> open(Uri upstream) async {
    if (upstream.scheme != 'http' || !['127.0.0.1', 'localhost', '::1'].contains(upstream.host)) {
      throw ArgumentError('Only isolated loopback servers are supported');
    }
    final link = ClientNetworkLink._(
      await ServerSocket.bind(InternetAddress.loopbackIPv4, 0),
      upstream,
    );
    link._listener!.listen(link._accept);
    return link;
  }

  Future<void> _accept(Socket incoming) async {
    if (_offline || _closed) {
      rejectedConnections++;
      incoming.destroy();
      return;
    }
    _sockets.add(incoming);
    Socket? outgoing;
    try {
      outgoing = await Socket.connect(
        upstream.host,
        upstream.port,
        timeout: const Duration(seconds: 5),
      );
      if (_offline || _closed) {
        rejectedConnections++;
        incoming.destroy();
        outgoing.destroy();
        return;
      }
      forwardedConnections++;
      _sockets.add(outgoing);
      var pairClosed = false;
      void closePair() {
        if (pairClosed) return;
        pairClosed = true;
        incoming.destroy();
        outgoing!.destroy();
        _sockets.remove(incoming);
        _sockets.remove(outgoing);
      }

      incoming.listen(
        (bytes) {
          if (!pairClosed) outgoing!.add(bytes);
        },
        onError: (_) => closePair(),
        onDone: closePair,
      );
      outgoing.listen(
        (bytes) {
          if (!pairClosed) incoming.add(bytes);
        },
        onError: (_) => closePair(),
        onDone: closePair,
      );
    } catch (_) {
      incoming.destroy();
      outgoing?.destroy();
      _sockets.remove(incoming);
    }
  }

  Future<void> setOffline(bool offline) async {
    if (_closed || _offline == offline) return;
    _offline = offline;
    if (offline) {
      offlineTransitions++;
      disconnectedConnections += _sockets.length ~/ 2;
      for (final socket in _sockets.toList()) {
        socket.destroy();
      }
      _sockets.clear();
      final listener = _listener;
      _listener = null;
      await listener?.close();
    } else {
      final listener = await ServerSocket.bind(InternetAddress.loopbackIPv4, _port);
      if (_closed) {
        await listener.close();
        return;
      }
      _listener = listener;
      listener.listen(_accept);
    }
  }

  Map<String, Object?> get evidence => {
    'offline': offline,
    'forwardedConnections': forwardedConnections,
    'rejectedConnections': rejectedConnections,
    'disconnectedConnections': disconnectedConnections,
    'offlineTransitions': offlineTransitions,
  };
  Future<void> close() async {
    if (_closed) return;
    await setOffline(true);
    _closed = true;
  }
}
