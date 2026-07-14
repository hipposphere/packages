import 'package:hippobase_auth_api_contract/hippobase_auth_api_contract.dart';
import 'package:http/http.dart' as http;

import 'http_transport.dart';

final class HippobaseAuthClient {
  HippobaseAuthClient({required this.baseUrl, required this.tokenProvider, http.Client? httpClient})
    : _transport = HippobaseAuthHttpTransport(
        baseUrl: baseUrl,
        tokenProvider: tokenProvider,
        httpClient: httpClient,
      );

  final Uri baseUrl;
  final HippobaseAuthTokenProvider tokenProvider;
  final HippobaseAuthHttpTransport _transport;

  Future<HippobaseAuthInfoResponse> info() async {
    return HippobaseAuthInfoResponse.fromJson(await _transport.request('GET', 'v1/user/info'));
  }

  Future<HippobaseAuthSessionPayload> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final body = HippobaseAuthSignUpEmailRequest(name: name, email: email, password: password);
    return HippobaseAuthSessionPayload.fromJson(
      await _transport.request('POST', 'v1/user/sign-up-email', body: body.toJson()),
    );
  }

  Future<HippobaseAuthSessionPayload> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final body = HippobaseAuthSignInEmailRequest(email: email, password: password);
    return HippobaseAuthSessionPayload.fromJson(
      await _transport.request('POST', 'v1/user/sign-in-email', body: body.toJson()),
    );
  }

  Future<HippobaseAuthUserResponse> getUser() async {
    return HippobaseAuthUserResponse.fromJson(
      await _transport.request('GET', 'v1/user/get_user', authenticated: true),
    );
  }

  Future<HippobaseAuthLogoutResponse> logout() async {
    return HippobaseAuthLogoutResponse.fromJson(
      await _transport.request('GET', 'v1/user/logout', authenticated: true),
    );
  }

  Future<HippobaseAuthRefreshSessionResponse> refreshSession() async {
    return HippobaseAuthRefreshSessionResponse.fromJson(
      await _transport.request('POST', 'v1/user/refresh-session', authenticated: true),
    );
  }

  Future<bool> requestPasswordReset(String email) async {
    final response = HippobaseAuthSuccessResponse.fromJson(
      await _transport.request(
        'POST',
        'v1/user/request-password-reset',
        body: HippobaseAuthEmailRequest(email: email).toJson(),
      ),
    );
    return response.success;
  }

  Future<bool> resetPassword({required String token, required String newPassword}) async {
    final response = HippobaseAuthSuccessResponse.fromJson(
      await _transport.request(
        'POST',
        'v1/user/reset-password',
        body: HippobaseAuthResetPasswordRequest(token: token, newPassword: newPassword).toJson(),
      ),
    );
    return response.success;
  }

  Future<bool> confirmEmail(String token) async {
    final response = HippobaseAuthSuccessResponse.fromJson(
      await _transport.request(
        'POST',
        'v1/user/confirm-mail',
        body: HippobaseAuthTokenRequest(token: token).toJson(),
      ),
    );
    return response.success;
  }

  Uri oauth2SignInUrl({required String provider, required Uri callbackUrl}) {
    return _transport.uri(
      'v1/oauth2/sign-in/${Uri.encodeComponent(provider)}',
      queryParameters: <String, String>{'callbackURL': callbackUrl.toString()},
    );
  }

  void close() => _transport.close();
}
