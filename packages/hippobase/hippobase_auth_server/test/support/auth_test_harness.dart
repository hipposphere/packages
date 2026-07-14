import 'dart:convert';
import 'dart:io';

import 'package:dart_edge_http_server/dart_edge_http_server.dart' hide SqlPool;
import 'package:dart_edge_sql/dart_edge_sql.dart';
import 'package:dart_edge_sql_migrator/dart_edge_sql_migrator.dart';
import 'package:hippobase_auth_db_schema/hippobase_auth_db_schema.dart';
import 'package:hippobase_auth_server/hippobase_auth_server.dart';
import 'package:hippobase_auth_server_sql/hippobase_auth_server_sql.dart';

const testAuthSecret = 'test-secret-key-that-is-at-least-32-characters-long';

final class AuthTestHarness {
  AuthTestHarness._(this.database, this.client);

  static Future<AuthTestHarness> start() async {
    final database = SqliteDatabase.inMemory();
    await createSchemaLess(database);
    final harness = AuthTestHarness._(database, HttpClient());
    await harness.restart(mountAdmin: true);
    return harness;
  }

  final SqlPool database;
  final HttpClient client;
  late HippobaseAuthServer auth;
  late DartEdgeServer server;
  late Uri baseUri;

  Future<void> restart({HippobaseAuthNotifier? notifier, bool mountAdmin = false}) async {
    if (_started) {
      await server.close();
      await auth.close();
    }
    auth = createTestAuth(database, notifier: notifier);
    final app = DartEdge<void>(services: () {});
    auth.mountPublic(app);
    if (mountAdmin) auth.mountAdmin(app);
    server = await app.listen(port: 0, workers: 1);
    baseUri = Uri.http('127.0.0.1:${server.port}');
    _started = true;
  }

  bool _started = false;

  Future<void> close() async {
    client.close(force: true);
    if (_started) {
      await server.close();
      await auth.close();
    }
    await database.close();
  }
}

HippobaseAuthServer createTestAuth(
  SqlPool database, {
  String? schema,
  HippobaseAuthNotifier? notifier,
}) {
  return HippobaseAuthServer(
    HippobaseAuthServerOptions(
      secret: testAuthSecret,
      baseUrl: 'http://localhost:3000',
      notifier: notifier,
      passwordWorkerCount: 1,
    ),
    store: HippobaseAuthSqlStore(database, schema: schema),
  );
}

Future<void> createPostgresSchema(SqlPool database) async {
  await database.execute(sql('CREATE SCHEMA IF NOT EXISTS "auth"'));
  final plan = SqlSchemaDiff.between(
    current: const SqlDatabaseSchema(tables: <SqlTableSchema>[]),
    desired: hippobaseAuthDbSchema,
  ).toMigrationPlan();
  for (final statement in plan.byDialect[SqlDialect.postgres] ?? const <SqlStatement>[]) {
    await database.execute(statement);
  }
}

Future<void> createSchemaLess(SqlPool database) async {
  for (final statement in <String>[
    '''CREATE TABLE "user" ("id" TEXT PRIMARY KEY, "name" TEXT NOT NULL, "email" TEXT NOT NULL UNIQUE, "emailVerified" BOOLEAN NOT NULL, "image" TEXT, "createdAt" TIMESTAMP NOT NULL, "updatedAt" TIMESTAMP NOT NULL, "role" TEXT, "banned" BOOLEAN, "banReason" TEXT, "banExpires" TIMESTAMP, "phoneNumber" TEXT, "phoneNumberVerified" BOOLEAN)''',
    '''CREATE TABLE "session" ("id" TEXT PRIMARY KEY, "expiresAt" TIMESTAMP NOT NULL, "token" TEXT NOT NULL UNIQUE, "createdAt" TIMESTAMP NOT NULL, "updatedAt" TIMESTAMP NOT NULL, "ipAddress" TEXT, "userAgent" TEXT, "userId" TEXT NOT NULL REFERENCES "user"("id") ON DELETE CASCADE, "impersonatedBy" TEXT)''',
    '''CREATE TABLE "account" ("id" TEXT PRIMARY KEY, "accountId" TEXT NOT NULL, "providerId" TEXT NOT NULL, "userId" TEXT NOT NULL REFERENCES "user"("id") ON DELETE CASCADE, "accessToken" TEXT, "refreshToken" TEXT, "idToken" TEXT, "accessTokenExpiresAt" TIMESTAMP, "refreshTokenExpiresAt" TIMESTAMP, "scope" TEXT, "password" TEXT, "createdAt" TIMESTAMP NOT NULL, "updatedAt" TIMESTAMP NOT NULL, UNIQUE("providerId", "accountId"))''',
    '''CREATE TABLE "verification" ("id" TEXT PRIMARY KEY, "identifier" TEXT NOT NULL, "value" TEXT NOT NULL, "expiresAt" TIMESTAMP NOT NULL, "createdAt" TIMESTAMP NOT NULL, "updatedAt" TIMESTAMP NOT NULL)''',
    '''CREATE TABLE "passkey" ("id" TEXT PRIMARY KEY, "name" TEXT, "publicKey" TEXT NOT NULL, "userId" TEXT NOT NULL REFERENCES "user"("id") ON DELETE CASCADE, "credentialID" TEXT NOT NULL, "counter" INTEGER NOT NULL, "deviceType" TEXT NOT NULL, "backedUp" BOOLEAN NOT NULL, "transports" TEXT, "createdAt" TIMESTAMP, "aaguid" TEXT)''',
  ]) {
    await database.execute(sql(statement));
  }
}

Future<TestResponse> postJson(
  HttpClient client,
  Uri uri,
  Map<String, Object?> body, {
  Map<String, String> headers = const <String, String>{},
}) async {
  final request = await client.postUrl(uri);
  request.headers.contentType = ContentType.json;
  headers.forEach(request.headers.set);
  request.write(jsonEncode(body));
  return readResponse(await request.close());
}

Future<TestResponse> getJson(
  HttpClient client,
  Uri uri, {
  Map<String, String> headers = const <String, String>{},
}) async {
  final request = await client.getUrl(uri);
  request.followRedirects = false;
  headers.forEach(request.headers.set);
  return readResponse(await request.close());
}

Future<TestResponse> patchJson(
  HttpClient client,
  Uri uri,
  Map<String, Object?> body, {
  Map<String, String> headers = const <String, String>{},
}) async {
  final request = await client.patchUrl(uri);
  request.headers.contentType = ContentType.json;
  headers.forEach(request.headers.set);
  request.write(jsonEncode(body));
  return readResponse(await request.close());
}

Future<TestResponse> deleteJson(
  HttpClient client,
  Uri uri, {
  Map<String, String> headers = const <String, String>{},
}) async {
  final request = await client.deleteUrl(uri);
  headers.forEach(request.headers.set);
  return readResponse(await request.close());
}

Future<TestResponse> readResponse(HttpClientResponse response) async {
  final body = await utf8.decoder.bind(response).join();
  final decoded = body.isEmpty ? <String, Object?>{} : jsonDecode(body) as Map<String, Object?>;
  return TestResponse(response.statusCode, response.headers, body, decoded);
}

final class TestResponse {
  const TestResponse(this.status, this.headers, this.body, this.json);

  final int status;
  final HttpHeaders headers;
  final String body;
  final Map<String, Object?> json;
}

final class AllowGuard implements Guard<void> {
  const AllowGuard();

  @override
  Future<GuardResult> authorize(RequestContext<void> context) async {
    return const GuardResult.allow();
  }
}
