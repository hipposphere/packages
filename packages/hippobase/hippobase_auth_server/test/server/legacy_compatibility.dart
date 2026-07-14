import 'package:dart_edge_sql/dart_edge_sql.dart';
import 'package:hippobase_auth_server/hippobase_auth_server.dart';
import 'package:test/test.dart';

import '../support/auth_test_harness.dart';

void registerLegacyCompatibilityTests() {
  test('legacy-created users and sessions remain valid', () async {
    final harness = await AuthTestHarness.start();
    addTearDown(harness.close);
    final now = DateTime.now().toUtc();
    await harness.database.typed
        .insertInto(AuthUsersTable.withSchema(null))
        .values(
          AuthUserInsert(
            id: const SqlValue(AuthUserId('legacy-user')),
            name: 'Legacy User',
            email: 'legacy@example.com',
            emailVerified: true,
            image: null,
            createdAt: now,
            updatedAt: now,
            role: 'user',
            banned: false,
            banReason: null,
            banExpires: null,
            phoneNumber: null,
            phoneNumberVerified: null,
          ),
        )
        .execute();
    await harness.database.typed
        .insertInto(AuthAccountsTable.withSchema(null))
        .values(
          AuthAccountInsert(
            id: const SqlValue(AuthAccountId('legacy-account')),
            accountId: 'legacy-user',
            providerId: 'credential',
            userId: const AuthUserId('legacy-user'),
            accessToken: null,
            refreshToken: null,
            idToken: null,
            accessTokenExpiresAt: null,
            refreshTokenExpiresAt: null,
            scope: null,
            password:
                '000102030405060708090a0b0c0d0e0f:'
                '728f0dcd55b2fd21c9c1821d76b88d64121aad5cc2a18c9cd0294171901e2e82'
                'c9c42d8bb6cc00b92680423a125523fdb0d7be18eb3b92b1410a2d9e3890e198',
            createdAt: now,
            updatedAt: now,
          ),
        )
        .execute();
    await harness.database.typed
        .insertInto(AuthSessionsTable.withSchema(null))
        .values(
          AuthSessionInsert(
            id: const SqlValue(AuthSessionId('legacy-session')),
            expiresAt: now.add(const Duration(days: 10)),
            token: 'session_legacy',
            createdAt: now,
            updatedAt: now,
            ipAddress: null,
            userAgent: null,
            userId: const AuthUserId('legacy-user'),
            impersonatedBy: null,
          ),
        )
        .execute();

    final signin = await postJson(
      harness.client,
      harness.baseUri.resolve('/v1/user/sign-in-email'),
      <String, Object?>{'email': 'legacy@example.com', 'password': 'correct horse battery staple'},
    );
    expect(signin.status, 200, reason: signin.body);

    final codec = HippobaseAuthSessionTokenCodec(
      secret: testAuthSecret,
      baseUrl: Uri.parse('http://localhost:3000'),
      cookieName: defaultHippobaseAuthSessionCookieName,
    );
    final session = await getJson(
      harness.client,
      harness.baseUri.resolve('/v1/user/get_user'),
      headers: <String, String>{
        'cookie':
            '__Secure-better-auth.session_token=${Uri.encodeComponent(codec.sign('session_legacy'))}',
      },
    );
    expect(session.status, 200, reason: session.body);
  });
}
