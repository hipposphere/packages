import 'dart:typed_data';

import 'package:hippobase_auth_server_engine/hippobase_auth_server_engine.dart';
import 'package:test/test.dart';

void main() {
  final salt = Uint8List.fromList(List<int>.generate(16, (index) => index));
  late HippobaseAuthScryptPasswordService passwords;

  setUp(() => passwords = HippobaseAuthScryptPasswordService(workerCount: 1));
  tearDown(() => passwords.close());

  test('matches the Better Auth ASCII scrypt vector', () async {
    final hash = await passwords.hashWithSalt('correct horse battery staple', salt);
    expect(
      hash,
      '000102030405060708090a0b0c0d0e0f:'
      '728f0dcd55b2fd21c9c1821d76b88d64121aad5cc2a18c9cd0294171901e2e82'
      'c9c42d8bb6cc00b92680423a125523fdb0d7be18eb3b92b1410a2d9e3890e198',
    );
    expect(await passwords.verify('correct horse battery staple', hash), isTrue);
    expect(await passwords.verify('wrong', hash), isFalse);
  });

  test('normalizes NFKC-equivalent Unicode passwords', () async {
    final compatibilityForm = await passwords.hashWithSalt('ＡÅ', salt);
    final normalizedForm = await passwords.hashWithSalt('AÅ', salt);

    expect(compatibilityForm, normalizedForm);
    expect(
      compatibilityForm,
      '000102030405060708090a0b0c0d0e0f:'
      '3df7e30c020493f3244506b4b1f21eab66b8c31db2d3602f38478d2afa11405b'
      'b86eac3f3f0d94c21029baa14dc775fe02a59017eded33a7308dcc124a5ab925',
    );
  });

  test('rejects malformed encoded hashes', () async {
    expect(await passwords.verify('password', 'not-a-hash'), isFalse);
    expect(await passwords.verify('password', '00:00'), isFalse);
  });
}
