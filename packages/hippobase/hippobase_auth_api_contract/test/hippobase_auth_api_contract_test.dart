import 'package:hippobase_auth_api_contract/hippobase_auth_api_contract.dart';
import 'package:test/test.dart';

void main() {
  test('publishes only functional auth routes', () {
    expect(HippobaseAuthRoutes.publicRoutes, hasLength(12));
    expect(HippobaseAuthRoutes.adminRoutes, hasLength(4));
    expect(
      [
        ...HippobaseAuthRoutes.publicRoutes,
        ...HippobaseAuthRoutes.adminRoutes,
      ].map((route) => route.path),
      everyElement(isNot(contains('oauth-client'))),
    );
  });

  test('publishes a resource-oriented admin user contract', () {
    expect(
      HippobaseAuthRoutes.adminRoutes.map((route) => (route.method, route.path)),
      containsAll(<(HippobaseAuthMethod, String)>[
        (HippobaseAuthMethod.post, '/v1/admin/users'),
        (HippobaseAuthMethod.get, '/v1/admin/users'),
        (HippobaseAuthMethod.patch, '/v1/admin/users/<userId>'),
        (HippobaseAuthMethod.delete, '/v1/admin/users/<userId>'),
      ]),
    );
  });

  test('round-trips admin user pages with shared pagination metadata', () {
    final page = HippobaseAuthAdminListUsersResponse.fromJson(<String, Object?>{
      'items': const <Object?>[],
      'meta': paginationMetaFromConfig(
        config: paginationConfig(offset: 20, limit: 10),
        totalItems: 42,
      ).toJson(),
    });

    expect(page.items, isEmpty);
    expect(page.meta.offset, 20);
    expect(page.meta.limit, 10);
    expect(page.meta.totalItems, 42);
    expect(page.meta.nextOffset, 30);
  });

  test('round-trips session payloads with the legacy JSON keys', () {
    final payload = HippobaseAuthSessionPayload.fromJson(<String, Object?>{
      'session_id': 'session-1',
      'token': 'token-1',
      'expires_at': '2026-07-13T12:00:00.000Z',
      'user': <String, Object?>{
        'id': 'user-1',
        'name': 'Test User',
        'email': 'test@example.com',
        'emailVerified': true,
        'image': null,
        'createdAt': '2026-07-13T10:00:00.000Z',
        'updatedAt': '2026-07-13T10:00:00.000Z',
        'role': 'user',
        'banned': false,
        'banReason': null,
        'banExpires': null,
        'phoneNumber': null,
        'phoneNumberVerified': null,
      },
    });

    expect(payload.sessionId, 'session-1');
    expect(payload.toJson()['expires_at'], '2026-07-13T12:00:00.000Z');
  });
}
