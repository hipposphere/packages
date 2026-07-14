import 'package:hippobase_auth_server/hippobase_auth_server.dart';
import 'package:test/test.dart';

import '../support/auth_test_harness.dart';

void registerRecoveryTests() {
  test('recovery is enumeration-safe, single-use, and revokes sessions', () async {
    final harness = await AuthTestHarness.start();
    addTearDown(harness.close);
    Uri? resetUrl;
    await harness.restart(
      notifier: HippobaseAuthNotifier(
        onPasswordReset: ({required email, required url, required expiresAt}) async {
          resetUrl = url;
        },
      ),
    );

    final signup = await postJson(
      harness.client,
      harness.baseUri.resolve('/v1/user/sign-up-email'),
      <String, Object?>{
        'name': 'Reset User',
        'email': 'reset@example.com',
        'password': 'password123',
      },
    );
    final oldToken = signup.json['token']! as String;
    final unknown = await postJson(
      harness.client,
      harness.baseUri.resolve('/v1/user/request-password-reset'),
      <String, Object?>{'email': 'unknown@example.com'},
    );
    final known = await postJson(
      harness.client,
      harness.baseUri.resolve('/v1/user/request-password-reset'),
      <String, Object?>{'email': 'reset@example.com'},
    );
    expect(unknown.json, known.json);

    final resetToken = resetUrl!.queryParameters['token']!;
    final reset = await postJson(
      harness.client,
      harness.baseUri.resolve('/v1/user/reset-password'),
      <String, Object?>{'token': resetToken, 'new_password': 'new-password123'},
    );
    expect(reset.status, 200, reason: reset.body);
    final reused = await postJson(
      harness.client,
      harness.baseUri.resolve('/v1/user/reset-password'),
      <String, Object?>{'token': resetToken, 'new_password': 'new-password456'},
    );
    expect(reused.status, 400);
    final revoked = await getJson(
      harness.client,
      harness.baseUri.resolve('/v1/user/get_user'),
      headers: <String, String>{'authorization': 'Bearer $oldToken'},
    );
    expect(revoked.status, 401);
  });
}
