import 'dart:convert';

import 'package:dart_edge_sql/dart_edge_sql.dart';
import 'package:hippobase_auth_server_engine/hippobase_auth_server_engine.dart';
import 'package:uuid/uuid.dart';

import 'schema.dart';

part 'repositories/administration.dart';
part 'repositories/oauth_accounts.dart';
part 'repositories/sessions.dart';
part 'repositories/users.dart';
part 'repositories/verifications.dart';
part 'repository.dart';

final class HippobaseAuthSqlStore implements HippobaseAuthStore {
  HippobaseAuthSqlStore(SqlPool database, {String? schema})
    : _repository = _HippobaseAuthSqlRepository(
        database,
        schema: normalizedHippobaseAuthSqlSchema(schema),
      );

  final _HippobaseAuthSqlRepository _repository;

  SqlPool get database => _repository.database;

  @override
  Future<AuthUserRow?> userById(AuthUserId id) => _repository.userById(id);

  @override
  Future<AuthUserRow?> userByEmail(String email) => _repository.userByEmail(email);

  @override
  Future<AuthAccountRow?> credentialAccount(AuthUserId userId) {
    return _repository.credentialAccount(userId);
  }

  @override
  Future<AuthAccountRow?> providerAccount(String providerId, String accountId) {
    return _repository.providerAccount(providerId, accountId);
  }

  @override
  Future<AuthUserRow> createCredentialUser({
    required String email,
    required String name,
    required String passwordHash,
    required String role,
    bool emailVerified = false,
  }) {
    return _repository.createCredentialUser(
      email: email,
      name: name,
      passwordHash: passwordHash,
      role: role,
      emailVerified: emailVerified,
    );
  }

  @override
  Future<({AuthUserRow user, AuthSessionRow session})> createCredentialUserWithSession({
    required String email,
    required String name,
    required String passwordHash,
    required String role,
    required bool emailVerified,
    required Duration sessionDuration,
    String? ipAddress,
    String? userAgent,
  }) {
    return _repository.createCredentialUserWithSession(
      email: email,
      name: name,
      passwordHash: passwordHash,
      role: role,
      emailVerified: emailVerified,
      sessionDuration: sessionDuration,
      ipAddress: ipAddress,
      userAgent: userAgent,
    );
  }

  @override
  Future<({AuthUserRow user, AuthSessionRow session})> createOAuthUserWithSession({
    required String providerId,
    required String accountId,
    required String email,
    required String name,
    required bool emailVerified,
    required String role,
    required Duration sessionDuration,
    String? image,
    String? accessToken,
    String? refreshToken,
    String? idToken,
    String? scope,
    DateTime? accessTokenExpiresAt,
    String? ipAddress,
    String? userAgent,
  }) {
    return _repository.createOAuthUserWithSession(
      providerId: providerId,
      accountId: accountId,
      email: email,
      name: name,
      emailVerified: emailVerified,
      role: role,
      sessionDuration: sessionDuration,
      image: image,
      accessToken: accessToken,
      refreshToken: refreshToken,
      idToken: idToken,
      scope: scope,
      accessTokenExpiresAt: accessTokenExpiresAt,
      ipAddress: ipAddress,
      userAgent: userAgent,
    );
  }

  @override
  Future<AuthSessionRow> createSession({
    required AuthUserId userId,
    required Duration duration,
    String? ipAddress,
    String? userAgent,
  }) {
    return _repository.createSession(
      userId: userId,
      duration: duration,
      ipAddress: ipAddress,
      userAgent: userAgent,
    );
  }

  @override
  Future<AuthSessionRow?> sessionByToken(String token) => _repository.sessionByToken(token);

  @override
  Future<void> updateSessionExpiry(AuthSessionId id, DateTime expiresAt) {
    return _repository.updateSessionExpiry(id, expiresAt);
  }

  @override
  Future<bool> deleteSessionByToken(String token) => _repository.deleteSessionByToken(token);

  @override
  Future<String> createOneTimeToken({
    required String purpose,
    required AuthUserId userId,
    required Duration duration,
  }) {
    return _repository.createOneTimeToken(purpose: purpose, userId: userId, duration: duration);
  }

  @override
  Future<void> storeOAuthState({required String state, required Map<String, Object?> data}) {
    return _repository.storeOAuthState(state: state, data: data);
  }

  @override
  Future<Map<String, Object?>?> consumeOAuthState(String state) {
    return _repository.consumeOAuthState(state);
  }

  @override
  Future<bool> resetPassword({required String token, required String passwordHash}) {
    return _repository.resetPassword(token: token, passwordHash: passwordHash);
  }

  @override
  Future<bool> verifyEmail(String token) => _repository.verifyEmail(token);

  @override
  Future<List<AuthUserRow>> listUsers({required int limit, required int offset}) {
    return _repository.listUsers(limit: limit, offset: offset);
  }

  @override
  Future<int> countUsers() => _repository.countUsers();

  @override
  Future<AuthUserRow?> updateRole(AuthUserId userId, String role) {
    return _repository.updateRole(userId, role);
  }

  @override
  Future<bool> deleteUser(AuthUserId userId) => _repository.deleteUser(userId);
}
