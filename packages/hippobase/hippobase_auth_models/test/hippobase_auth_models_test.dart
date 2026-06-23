import 'package:hippobase_auth_models/hippobase_auth_models.dart';
import 'package:test/test.dart';

void main() {
  test('exports generated Better Auth table schemas', () {
    expect(
      HippobaseAuthDatabase.schemas.map((schema) => schema.id),
      containsAll(<String>[
        HippobaseAuthUserRow.schemaId,
        HippobaseAuthSessionRow.schemaId,
        HippobaseAuthAccountRow.schemaId,
        HippobaseAuthVerificationRow.schemaId,
        HippobaseAuthPasskeyRow.schemaId,
      ]),
    );
  });
}
