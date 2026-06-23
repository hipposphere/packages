import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:hippobase_auth_models/hippobase_auth_models.dart';
import 'package:test/test.dart';

void main() {
  test('exports generated Better Auth table schemas', () {
    expect(
      AuthDatabase.schemas.map((schema) => schema.id),
      containsAll(<String>[
        AuthUserRow.schemaId,
        AuthSessionRow.schemaId,
        AuthAccountRow.schemaId,
        AuthVerificationRow.schemaId,
        AuthPasskeyRow.schemaId,
      ]),
    );
  });

  test('exports generated Better Auth id extension types', () {
    const userId = AuthUserId('user_1');
    const sessionId = AuthSessionId('session_1');
    const accountId = AuthAccountId('account_1');
    const verificationId = AuthVerificationId('verification_1');
    const passkeyId = AuthPasskeyId('passkey_1');

    expect(
      <String>[
        userId.value,
        sessionId.value,
        accountId.value,
        verificationId.value,
        passkeyId.value,
      ],
      <String>['user_1', 'session_1', 'account_1', 'verification_1', 'passkey_1'],
    );

    const sessionUpdate = AuthSessionUpdate(
      id: SqlValue<AuthSessionId>(sessionId),
      userId: SqlValue<AuthUserId>(userId),
    );
    expect(sessionUpdate.toJson(), <String, Object?>{'id': 'session_1', 'userId': 'user_1'});
  });
}
