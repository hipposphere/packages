import 'package:hippobase_auth_api_contract/hippobase_auth_api_contract.dart';
import 'package:http/http.dart' as http;

import 'http_transport.dart';

final class HippobaseAuthAdminClient {
  HippobaseAuthAdminClient({
    required this.baseUrl,
    required this.tokenProvider,
    http.Client? httpClient,
  }) : _transport = HippobaseAuthHttpTransport(
         baseUrl: baseUrl,
         tokenProvider: tokenProvider,
         httpClient: httpClient,
       );

  final Uri baseUrl;
  final HippobaseAuthTokenProvider tokenProvider;
  final HippobaseAuthHttpTransport _transport;

  Future<HippobaseAuthUserResponse> createUser({
    required String email,
    required String password,
    required String name,
    String? role,
    bool emailVerified = false,
  }) async {
    return HippobaseAuthUserResponse.fromJson(
      await _request(
        'POST',
        'v1/admin/users',
        body: HippobaseAuthAdminCreateUserRequest(
          email: email,
          password: password,
          name: name,
          role: role,
          emailVerified: emailVerified,
        ).toJson(),
      ),
    );
  }

  Future<HippobaseAuthAdminListUsersResponse> listUsers({PaginationConfig? pagination}) async {
    final resolvedPagination = pagination;
    return HippobaseAuthAdminListUsersResponse.fromJson(
      await _request(
        'GET',
        'v1/admin/users',
        query: <String, String>{
          if (resolvedPagination?.offset case final offset?) 'offset': '$offset',
          if (resolvedPagination?.limit case final limit?) 'limit': '$limit',
        },
      ),
    );
  }

  Future<HippobaseAuthUserResponse> updateUserRole({
    required String userId,
    required String role,
  }) async {
    return HippobaseAuthUserResponse.fromJson(
      await _request(
        'PATCH',
        'v1/admin/users/${Uri.encodeComponent(userId)}',
        body: HippobaseAuthAdminUpdateUserRequest(role: role).toJson(),
      ),
    );
  }

  Future<bool> deleteUser(String userId) async {
    final response = HippobaseAuthAdminDeleteUserResponse.fromJson(
      await _request('DELETE', 'v1/admin/users/${Uri.encodeComponent(userId)}'),
    );
    return response.success;
  }

  Future<Map<String, Object?>> _request(
    String method,
    String path, {
    Map<String, Object?>? body,
    Map<String, String>? query,
  }) {
    return _transport.request(
      method,
      path,
      body: body,
      query: query,
      authenticated: true,
      fallbackCode: 'AdminAuthRequestFailed',
      fallbackMessage: 'Admin authentication request failed.',
    );
  }

  void close() => _transport.close();
}
