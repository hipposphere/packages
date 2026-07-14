import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hippobase_auth_client/hippobase_auth_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('admin client uses resource routes and typed pagination', () async {
    final requests = <http.Request>[];
    final client = HippobaseAuthAdminClient(
      baseUrl: Uri.parse('https://api.example.test/auth'),
      tokenProvider: () => 'admin-token',
      httpClient: MockClient((request) async {
        requests.add(request);
        return switch (request.method) {
          'GET' => http.Response(jsonEncode(_page()), 200),
          'DELETE' => http.Response(
            jsonEncode(<String, Object?>{'success': true, 'user_id': 'user-1'}),
            200,
          ),
          _ => http.Response(jsonEncode(<String, Object?>{'user': _user()}), 200),
        };
      }),
    );
    addTearDown(client.close);

    await client.createUser(
      email: 'ada@example.com',
      password: 'password123',
      name: 'Ada',
      emailVerified: true,
    );
    final page = await client.listUsers(pagination: paginationConfig(offset: 25, limit: 10));
    await client.updateUserRole(userId: 'user-1', role: 'admin');
    expect(await client.deleteUser('user-1'), isTrue);

    expect(requests.map((request) => request.method), ['POST', 'GET', 'PATCH', 'DELETE']);
    expect(requests.map((request) => request.url.path).toSet(), {
      '/auth/v1/admin/users',
      '/auth/v1/admin/users/user-1',
    });
    expect(requests[1].url.queryParameters, {'offset': '25', 'limit': '10'});
    expect(
      requests.every((request) => request.headers['authorization'] == 'Bearer admin-token'),
      isTrue,
    );
    expect(page.meta.offset, 25);
    expect(page.items.single.email, 'ada@example.com');
  });
}

Map<String, Object?> _page() => <String, Object?>{
  'items': <Object?>[_user()],
  'meta': <String, Object?>{
    'offset': 25,
    'limit': 10,
    'total_items': 30,
    'has_more': false,
    'next_offset': null,
    'previous_offset': 15,
    'first_item_index': 26,
    'last_item_index': 30,
  },
};

Map<String, Object?> _user() => <String, Object?>{
  'id': 'user-1',
  'name': 'Ada',
  'email': 'ada@example.com',
  'emailVerified': true,
  'image': null,
  'createdAt': '2026-07-14T10:00:00.000Z',
  'updatedAt': '2026-07-14T10:00:00.000Z',
  'role': 'admin',
  'banned': false,
  'banReason': null,
  'banExpires': null,
  'phoneNumber': null,
  'phoneNumberVerified': null,
};
