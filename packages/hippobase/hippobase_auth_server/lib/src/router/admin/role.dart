import '../../error.dart';

String? parseHippobaseAuthAdminRole(Object? value) {
  if (value == null) return null;
  if (value is String) {
    final role = value.trim();
    if (role.isEmpty) {
      throw const HippobaseAuthException(400, 'AdminInvalidRole', 'Role must not be empty.');
    }
    return role;
  }
  if (value is List) {
    if (value.length != 1) {
      throw const HippobaseAuthException(
        400,
        'AdminInvalidRole',
        'Exactly one role must be provided.',
      );
    }
    return parseHippobaseAuthAdminRole(value.single);
  }
  throw const HippobaseAuthException(400, 'AdminInvalidRole', 'Invalid role value.');
}
