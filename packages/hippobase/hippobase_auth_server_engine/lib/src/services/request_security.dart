part of '../service.dart';

extension HippobaseAuthRequestSecurityService on HippobaseAuthService {
  Future<void> ensureRateLimit(HippobaseAuthRequestMetadata metadata, String action) async {
    final key = '$action:${metadata.ipAddress ?? 'unknown'}';
    if (!await rateLimiter.allow(key, limit: options.rateLimit, window: options.rateLimitWindow)) {
      throw const HippobaseAuthException(429, 'RateLimited', 'Too many authentication attempts.');
    }
  }

  void ensureTrustedOrigin(
    HippobaseAuthRequestMetadata metadata, {
    HippobaseAuthIdentity? identity,
  }) {
    if (identity != null && !identity.fromCookie) return;
    final origin = metadata.origin;
    if (origin == null || origin.isEmpty) return;
    final allowed = <String>{
      options.normalizedBaseUrl.origin,
      ...options.trustedOrigins.map(_origin),
    };
    if (!allowed.contains(_origin(origin))) {
      throw const HippobaseAuthException(403, 'UntrustedOrigin', 'Request origin is not trusted.');
    }
  }
}
