import 'dart:convert';

final class HippobaseAuthSession {
  const HippobaseAuthSession({required this.id, required this.token, required this.expiresAt});

  factory HippobaseAuthSession.fromJson(Map<String, Object?> json) {
    return HippobaseAuthSession(
      id: json['id']! as String,
      token: json['token']! as String,
      expiresAt: DateTime.parse(json['expires_at']! as String),
    );
  }

  factory HippobaseAuthSession.decode(String value) {
    return HippobaseAuthSession.fromJson(Map<String, Object?>.from(jsonDecode(value) as Map));
  }

  final String id;
  final String token;
  final DateTime expiresAt;

  bool get isExpired => !expiresAt.toUtc().isAfter(DateTime.now().toUtc());

  bool get canBeRefreshed =>
      !isExpired &&
      !expiresAt.toUtc().isAfter(DateTime.now().toUtc().add(const Duration(days: 89)));

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'token': token,
    'expires_at': expiresAt.toUtc().toIso8601String(),
  };

  String encode() => jsonEncode(toJson());

  HippobaseAuthSession copyWith({DateTime? expiresAt}) {
    return HippobaseAuthSession(id: id, token: token, expiresAt: expiresAt ?? this.expiresAt);
  }
}
