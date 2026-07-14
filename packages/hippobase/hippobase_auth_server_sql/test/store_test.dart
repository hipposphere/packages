import 'package:dart_edge_sql/dart_edge_sql.dart';
import 'package:hippobase_auth_server_sql/hippobase_auth_server_sql.dart';
import 'package:test/test.dart';

void main() {
  test('creates credential users and sessions transactionally', () async {
    final database = SqliteDatabase.inMemory();
    addTearDown(database.close);
    await _createTables(database);
    final store = HippobaseAuthSqlStore(database);

    final created = await store.createCredentialUserWithSession(
      email: 'ada@example.com',
      name: 'Ada',
      passwordHash: 'salt:hash',
      role: 'user',
      emailVerified: true,
      sessionDuration: const Duration(days: 90),
    );

    expect((await store.userByEmail('ADA@example.com'))?.id, created.user.id);
    expect((await store.credentialAccount(created.user.id))?.password, 'salt:hash');
    expect((await store.sessionByToken(created.session.token))?.userId, created.user.id);
    expect(await store.countUsers(), 1);
  });
}

Future<void> _createTables(SqlPool database) async {
  for (final statement in <String>[
    '''CREATE TABLE "user" ("id" TEXT PRIMARY KEY, "name" TEXT NOT NULL, "email" TEXT NOT NULL UNIQUE, "emailVerified" BOOLEAN NOT NULL, "image" TEXT, "createdAt" TIMESTAMP NOT NULL, "updatedAt" TIMESTAMP NOT NULL, "role" TEXT, "banned" BOOLEAN, "banReason" TEXT, "banExpires" TIMESTAMP, "phoneNumber" TEXT, "phoneNumberVerified" BOOLEAN)''',
    '''CREATE TABLE "session" ("id" TEXT PRIMARY KEY, "expiresAt" TIMESTAMP NOT NULL, "token" TEXT NOT NULL UNIQUE, "createdAt" TIMESTAMP NOT NULL, "updatedAt" TIMESTAMP NOT NULL, "ipAddress" TEXT, "userAgent" TEXT, "userId" TEXT NOT NULL REFERENCES "user"("id") ON DELETE CASCADE, "impersonatedBy" TEXT)''',
    '''CREATE TABLE "account" ("id" TEXT PRIMARY KEY, "accountId" TEXT NOT NULL, "providerId" TEXT NOT NULL, "userId" TEXT NOT NULL REFERENCES "user"("id") ON DELETE CASCADE, "accessToken" TEXT, "refreshToken" TEXT, "idToken" TEXT, "accessTokenExpiresAt" TIMESTAMP, "refreshTokenExpiresAt" TIMESTAMP, "scope" TEXT, "password" TEXT, "createdAt" TIMESTAMP NOT NULL, "updatedAt" TIMESTAMP NOT NULL, UNIQUE("providerId", "accountId"))''',
  ]) {
    await database.execute(sql(statement));
  }
}
