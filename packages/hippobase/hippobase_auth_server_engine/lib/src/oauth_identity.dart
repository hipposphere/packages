final class HippobaseAuthVerifiedOAuthIdentity {
  const HippobaseAuthVerifiedOAuthIdentity({
    required this.providerId,
    required this.accountId,
    required this.email,
    required this.name,
    this.image,
    this.accessToken,
    this.refreshToken,
    this.idToken,
    this.scope,
    this.accessTokenExpiresAt,
  });

  final String providerId;
  final String accountId;
  final String email;
  final String name;
  final String? image;
  final String? accessToken;
  final String? refreshToken;
  final String? idToken;
  final String? scope;
  final DateTime? accessTokenExpiresAt;
}
