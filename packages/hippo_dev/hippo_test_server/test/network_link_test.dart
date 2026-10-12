import 'dart:convert';
import 'dart:io';

import 'package:hippo_test_server/hippo_test_server.dart';
import 'package:test/test.dart';

void main() {
  test('disconnecting A preserves B and reconnect restores real requests', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    server.listen((r) {
      r.response.write('actual server');
      r.response.close();
    });
    final uri = Uri(scheme: 'http', host: '127.0.0.1', port: server.port);
    final a = await ClientNetworkLink.open(uri), b = await ClientNetworkLink.open(uri);
    addTearDown(a.close);
    addTearDown(b.close);
    final http = HttpClient()..connectionTimeout = const Duration(seconds: 1);
    addTearDown(() => http.close(force: true));
    Future<String> get(ClientNetworkLink link) async =>
        utf8.decoder.bind(await (await http.getUrl(link.baseUri)).close()).join();
    expect(await get(a), 'actual server');
    await a.setOffline(true);
    await expectLater(get(a), throwsA(isA<IOException>()));
    expect(await get(b), 'actual server');
    await a.setOffline(false);
    expect(await get(a), 'actual server');
    expect(a.offlineTransitions, greaterThan(0));
  });
  test('network fixtures reject non-loopback targets', () async {
    await expectLater(
      ClientNetworkLink.open(Uri.parse('https://example.com')),
      throwsArgumentError,
    );
  });
}
