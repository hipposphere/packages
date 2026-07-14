import 'dart:io';

import 'package:dart_edge_http_server/dart_edge_http_server.dart' hide SqlPool;
import 'package:dart_edge_sql_pglite/dart_edge_sql_pglite.dart';
import 'package:test/test.dart';

import '../support/auth_test_harness.dart';

void registerPgliteTests() {
  test('runs against schema-qualified PGlite', () async {
    final database = PgliteDatabase.temporary().asPostgresPool();
    await createPostgresSchema(database);
    final auth = createTestAuth(database, schema: 'auth');
    final probe = await auth.trustedAdmin.createUser(
      email: 'probe@example.com',
      password: 'password123',
      name: 'Probe User',
    );
    expect(await auth.trustedAdmin.deleteUser(probe.id), isTrue);
    final app = DartEdge<void>(services: () {});
    auth.mountPublic(app);
    final server = await app.listen(port: 0, workers: 1);
    final client = HttpClient();
    addTearDown(() async {
      client.close(force: true);
      await server.close();
      await auth.close();
      await database.close();
    });
    final response = await postJson(
      client,
      Uri.http('127.0.0.1:${server.port}', '/v1/user/sign-up-email'),
      <String, Object?>{
        'name': 'PGlite User',
        'email': 'pglite@example.com',
        'password': 'password123',
      },
    );
    expect(response.status, 200, reason: response.body);
  });
}
