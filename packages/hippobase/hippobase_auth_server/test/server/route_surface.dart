import 'package:dart_edge_http_server/dart_edge_http_server.dart' hide SqlPool;
import 'package:dart_edge_sql/dart_edge_sql.dart';
import 'package:hippobase_auth_server/hippobase_auth_server.dart';
import 'package:test/test.dart';

import '../support/auth_test_harness.dart';

void registerRouteSurfaceTests() {
  test('signed Better Auth cookie aliases and raw bearer tokens resolve', () {
    final codec = HippobaseAuthSessionTokenCodec(
      secret: testAuthSecret,
      baseUrl: Uri.parse('https://auth.example.test'),
      cookieName: defaultHippobaseAuthSessionCookieName,
    );
    final signed = codec.sign('session-legacy');

    expect(
      codec.resolve(<String, String>{'authorization': 'Bearer session-legacy'})?.token,
      'session-legacy',
    );
    expect(
      codec.resolve(<String, String>{
        'cookie': '__Secure-better-auth.session_token=${Uri.encodeComponent(signed)}',
      })?.token,
      'session-legacy',
    );
  });

  test('public and admin routers mount independently', () async {
    final database = SqliteDatabase.inMemory();
    final auth = createTestAuth(database);
    addTearDown(() async {
      await auth.close();
      await database.close();
    });
    final publicApp = DartEdge<void>(services: () {});
    auth.mountPublic(publicApp);
    final publicPaths = publicApp.buildOpenApiDocumentJson()['paths']! as Map<String, Object?>;
    expect(publicPaths, contains('/v1/user/sign-in-email'));
    expect(publicPaths.keys, isNot(contains('/v1/admin/users')));
    expect(publicPaths.keys.where((path) => path.contains('oauth-client')), isEmpty);
    expect(publicPaths.keys.where((path) => path.contains('better-auth')), isEmpty);

    final adminApp = DartEdge<void>(services: () {});
    auth.mountAdmin(adminApp);
    final adminPaths = adminApp.buildOpenApiDocumentJson()['paths']! as Map<String, Object?>;
    expect(adminPaths.keys, containsAll(<String>['/v1/admin/users', '/v1/admin/users/{userId}']));
    expect(adminPaths.keys, hasLength(2));
    expect(
      (adminPaths['/v1/admin/users']! as Map<String, Object?>).keys,
      containsAll(['get', 'post']),
    );
    expect(
      (adminPaths['/v1/admin/users/{userId}']! as Map<String, Object?>).keys,
      containsAll(['patch', 'delete']),
    );
  });
}
