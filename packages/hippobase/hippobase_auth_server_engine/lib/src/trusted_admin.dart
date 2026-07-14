import 'package:hippobase_auth_models/hippobase_auth_models.dart';

import 'error.dart';
import 'options.dart';
import 'password.dart';
import 'store.dart';

final class HippobaseAuthTrustedAdmin {
  const HippobaseAuthTrustedAdmin({
    required this.repository,
    required this.passwords,
    required this.options,
  });

  final HippobaseAuthStore repository;
  final HippobaseAuthPasswordService passwords;
  final HippobaseAuthAdminOptions options;

  Future<AuthUserRow> createUser({
    required String email,
    required String password,
    required String name,
    String? role,
    bool emailVerified = false,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      throw const HippobaseAuthException(
        400,
        'AdminCreateUserInvalidEmail',
        'Invalid email address.',
      );
    }
    if (await repository.userByEmail(normalizedEmail) != null) {
      throw const HippobaseAuthException(
        409,
        'UserAlreadyExists',
        'A user with this email already exists.',
      );
    }
    final hash = await passwords.hash(password);
    return repository.createCredentialUser(
      email: normalizedEmail,
      name: name,
      passwordHash: hash,
      role: role?.trim().isNotEmpty == true ? role!.trim() : options.defaultUserRole,
      emailVerified: emailVerified,
    );
  }

  Future<List<AuthUserRow>> listUsers({int? limit, int offset = 0}) {
    final effectiveLimit = (limit ?? options.defaultPageLimit).clamp(1, options.maxPageLimit);
    return repository.listUsers(limit: effectiveLimit, offset: offset < 0 ? 0 : offset);
  }

  Future<AuthUserRow> updateUserRole({required AuthUserId userId, required String role}) async {
    final normalizedRole = role.trim();
    if (normalizedRole.isEmpty) {
      throw const HippobaseAuthException(
        400,
        'AdminUpdateUserInvalidRole',
        'Role must not be empty.',
      );
    }
    final user = await repository.updateRole(userId, normalizedRole);
    if (user == null) throw const HippobaseAuthException(404, 'UserNotFound', 'User not found.');
    return user;
  }

  Future<bool> deleteUser(AuthUserId userId) => repository.deleteUser(userId);
}
