import 'dart:convert';
import 'dart:io';

import 'package:auto_updater_linux/src/signature_verifier.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory temporaryDirectory;
  late File artifact;
  late SimpleKeyPair keyPair;
  late String publicKey;
  late String signature;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp('auto_updater_linux_signature.');
    artifact = File('${temporaryDirectory.path}/app.AppImage');
    await artifact.writeAsString('signed AppImage bytes');
    keyPair = await Ed25519().newKeyPair();
    final publicKeyData = await keyPair.extractPublicKey();
    publicKey = base64Encode(publicKeyData.bytes);
    signature = base64Encode(
      (await Ed25519().sign(await artifact.readAsBytes(), keyPair: keyPair)).bytes,
    );
  });

  tearDown(() => temporaryDirectory.delete(recursive: true));

  test('accepts a valid Sparkle-compatible Ed25519 signature', () async {
    final verifier = LinuxUpdateSignatureVerifier();

    await verifier.verify(
      file: artifact,
      encodedSignature: signature,
      publicKey: verifier.decodePublicKey(publicKey),
    );
  });

  test('rejects tampered artifacts and wrong keys', () async {
    final verifier = LinuxUpdateSignatureVerifier();
    await artifact.writeAsString('tampered');

    await expectLater(
      verifier.verify(
        file: artifact,
        encodedSignature: signature,
        publicKey: verifier.decodePublicKey(publicKey),
      ),
      throwsStateError,
    );

    final wrongPublicKey = await (await Ed25519().newKeyPair()).extractPublicKey();
    await expectLater(
      verifier.verify(file: artifact, encodedSignature: signature, publicKey: wrongPublicKey),
      throwsStateError,
    );
  });

  test('rejects malformed keys and signatures', () async {
    final verifier = LinuxUpdateSignatureVerifier();

    expect(() => verifier.decodePublicKey('bad'), throwsArgumentError);
    await expectLater(
      verifier.verify(
        file: artifact,
        encodedSignature: base64Encode([1, 2, 3]),
        publicKey: verifier.decodePublicKey(publicKey),
      ),
      throwsFormatException,
    );
  });
}
