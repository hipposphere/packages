import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

import '../bin/sign_update.dart';

void main() {
  late Directory temporaryDirectory;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp('linux_sign_update.');
  });

  tearDown(() => temporaryDirectory.delete(recursive: true));

  test('creates a Sparkle-compatible Ed25519 signature', () async {
    final artifact = File('${temporaryDirectory.path}/app.AppImage');
    await artifact.writeAsString('AppImage update');
    final keyPair = await Ed25519().newKeyPair();
    final privateKey = await keyPair.extractPrivateKeyBytes();

    final result = await signUpdateWithEd25519(
      artifact: artifact,
      encodedPrivateKey: base64Encode(privateKey),
    );

    expect(result.length, await artifact.length());
    expect(base64Decode(result.signature), hasLength(64));
    expect(
      await Ed25519().verify(
        await artifact.readAsBytes(),
        signature: Signature(
          base64Decode(result.signature),
          publicKey: await keyPair.extractPublicKey(),
        ),
      ),
      isTrue,
    );
  });

  test('rejects legacy or malformed Sparkle private keys', () async {
    final artifact = File('${temporaryDirectory.path}/app.AppImage');
    await artifact.writeAsString('AppImage update');

    await expectLater(
      signUpdateWithEd25519(
        artifact: artifact,
        encodedPrivateKey: base64Encode(List.filled(96, 0)),
      ),
      throwsFormatException,
    );
  });
}
