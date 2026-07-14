import 'rate_limit.dart';

const defaultHippobaseAuthSessionCookieName = 'hippo_auth_session';

typedef HippobaseAuthNotificationCallback =
    Future<void> Function({required String email, required Uri url, required DateTime expiresAt});

final class HippobaseAuthNotifier {
  const HippobaseAuthNotifier({this.onPasswordReset, this.onEmailVerification});

  final HippobaseAuthNotificationCallback? onPasswordReset;
  final HippobaseAuthNotificationCallback? onEmailVerification;
}

final class HippobaseAuthServerOptions {
  const HippobaseAuthServerOptions({
    required this.secret,
    required this.baseUrl,
    this.trustedOrigins = const <String>[],
    this.appName = 'Hippobase Auth',
    this.passwordWorkerCount = 2,
    this.emailSignInEnabled = true,
    this.emailSignUpEnabled = true,
    this.enablePasswordManagement = true,
    this.enableEmailVerification = false,
    this.sessionCookieName = defaultHippobaseAuthSessionCookieName,
    this.sessionDuration = const Duration(days: 90),
    this.refreshThreshold = const Duration(days: 89),
    this.oneTimeTokenDuration = const Duration(minutes: 30),
    this.ssoProviders = const <HippobaseAuthSsoProvider>[],
    this.admin = const HippobaseAuthAdminOptions(),
    this.notifier,
    this.rateLimiter,
    this.rateLimit = 10,
    this.rateLimitWindow = const Duration(minutes: 1),
    this.allowLoopbackOAuthCallbackUrls = true,
    this.hostedViews = true,
  });

  final String secret;
  final String baseUrl;
  final List<String> trustedOrigins;
  final String appName;
  final int passwordWorkerCount;
  final bool emailSignInEnabled;
  final bool emailSignUpEnabled;
  final bool enablePasswordManagement;
  final bool enableEmailVerification;
  final String sessionCookieName;
  final Duration sessionDuration;
  final Duration refreshThreshold;
  final Duration oneTimeTokenDuration;
  final List<HippobaseAuthSsoProvider> ssoProviders;
  final HippobaseAuthAdminOptions admin;
  final HippobaseAuthNotifier? notifier;
  final HippobaseAuthRateLimiter? rateLimiter;
  final int rateLimit;
  final Duration rateLimitWindow;
  final bool allowLoopbackOAuthCallbackUrls;
  final bool hostedViews;

  Uri get normalizedBaseUrl {
    final uri = Uri.parse(baseUrl);
    if (!uri.hasScheme || uri.host.isEmpty) {
      throw ArgumentError.value(baseUrl, 'baseUrl', 'Must be an absolute URL.');
    }
    return uri;
  }
}

final class HippobaseAuthAdminOptions {
  const HippobaseAuthAdminOptions({
    this.adminRoles = const <String>['admin'],
    this.defaultUserRole = 'user',
    this.defaultPageLimit = 50,
    this.maxPageLimit = 500,
  });

  final List<String> adminRoles;
  final String defaultUserRole;
  final int defaultPageLimit;
  final int maxPageLimit;

  List<String> get normalizedAdminRoles {
    final roles = adminRoles.map((role) => role.trim()).where((role) => role.isNotEmpty).toList();
    return roles.isEmpty ? const <String>['admin'] : roles;
  }
}

final class HippobaseAuthSsoProvider {
  const HippobaseAuthSsoProvider({
    required this.providerId,
    required this.issuer,
    required this.clientId,
    required this.clientSecret,
    this.redirectUrl,
    this.scopes = const <String>['openid', 'email', 'profile'],
  });

  final String providerId;
  final Uri issuer;
  final String clientId;
  final String? clientSecret;
  final Uri? redirectUrl;
  final List<String> scopes;

  Map<String, Object?> toJson() => <String, Object?>{
    'provider_id': providerId,
    'provider_type': 'generic_oauth',
  };
}
