import 'package:dart_edge_http_server/dart_edge_http_server.dart';
import 'package:test/test.dart';

import '../support/auth_test_harness.dart';

void registerAdminRouteTests() {
  test('admin roles are enforced and an application guard can override', () async {
    final harness = await AuthTestHarness.start();
    addTearDown(harness.close);
    final signup = await postJson(
      harness.client,
      harness.baseUri.resolve('/v1/user/sign-up-email'),
      <String, Object?>{
        'name': 'Regular User',
        'email': 'regular@example.com',
        'password': 'password123',
      },
    );
    final userToken = signup.json['token']! as String;
    final forbidden = await getJson(
      harness.client,
      harness.baseUri.resolve('/v1/admin/users'),
      headers: <String, String>{'authorization': 'Bearer $userToken'},
    );
    expect(forbidden.status, 403);

    final admin = await harness.auth.trustedAdmin.createUser(
      email: 'admin@example.com',
      password: 'password123',
      name: 'Admin User',
      role: 'admin',
    );
    final adminSession = await harness.auth.repository.createSession(
      userId: admin.id,
      duration: const Duration(days: 1),
    );
    final allowed = await getJson(
      harness.client,
      harness.baseUri.resolve('/v1/admin/users'),
      headers: <String, String>{'authorization': 'Bearer ${adminSession.token}'},
    );
    expect(allowed.status, 200, reason: allowed.body);

    final customApp = DartEdge<void>(services: () {});
    harness.auth.mountAdmin(customApp, guard: const AllowGuard());
    final customServer = await customApp.listen(port: 0, workers: 1);
    try {
      final overridden = await getJson(
        harness.client,
        Uri.http('127.0.0.1:${customServer.port}', '/v1/admin/users'),
        headers: <String, String>{'authorization': 'Bearer $userToken'},
      );
      expect(overridden.status, 200, reason: overridden.body);
    } finally {
      await customServer.close();
    }
  });

  test('admin user CRUD uses shared pagination metadata', () async {
    final harness = await AuthTestHarness.start();
    addTearDown(harness.close);
    final admin = await harness.auth.trustedAdmin.createUser(
      email: 'crud-admin@example.com',
      password: 'password123',
      name: 'CRUD Admin',
      role: 'admin',
    );
    final session = await harness.auth.repository.createSession(
      userId: admin.id,
      duration: const Duration(days: 1),
    );
    final headers = <String, String>{'authorization': 'Bearer ${session.token}'};

    final created = await postJson(
      harness.client,
      harness.baseUri.resolve('/v1/admin/users'),
      <String, Object?>{
        'email': 'managed@example.com',
        'password': 'password123',
        'name': 'Managed User',
        'role': 'user',
        'email_verified': true,
      },
      headers: headers,
    );
    expect(created.status, 201, reason: created.body);
    final user = created.json['user']! as Map<String, Object?>;
    final userId = user['id']! as String;
    expect(user['emailVerified'], isTrue);

    final page = await getJson(
      harness.client,
      harness.baseUri.resolve('/v1/admin/users?offset=1&limit=1'),
      headers: headers,
    );
    expect(page.status, 200, reason: page.body);
    expect(page.json['items'], hasLength(1));
    final meta = page.json['meta']! as Map<String, Object?>;
    expect(meta['offset'], 1);
    expect(meta['limit'], 1);
    expect(meta['total_items'], 2);
    expect(meta['previous_offset'], 0);

    final updated = await patchJson(
      harness.client,
      harness.baseUri.resolve('/v1/admin/users/$userId'),
      <String, Object?>{'role': 'manager'},
      headers: headers,
    );
    expect(updated.status, 200, reason: updated.body);
    expect((updated.json['user']! as Map<String, Object?>)['role'], 'manager');

    final deleted = await deleteJson(
      harness.client,
      harness.baseUri.resolve('/v1/admin/users/$userId'),
      headers: headers,
    );
    expect(deleted.status, 200, reason: deleted.body);
    expect(deleted.json, <String, Object?>{'success': true, 'user_id': userId});

    final invalidPage = await getJson(
      harness.client,
      harness.baseUri.resolve('/v1/admin/users?limit=501'),
      headers: headers,
    );
    expect(invalidPage.status, 400);
  });
}
