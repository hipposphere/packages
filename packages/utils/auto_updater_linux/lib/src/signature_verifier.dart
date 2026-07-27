import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

final class LinuxUpdateSignatureVerifier {
  LinuxUpdateSignatureVerifier() : _algorithm = Ed25519();

  final Ed25519 _algorithm;

  SimplePublicKey decodePublicKey(String encoded) {
    late Uint8List bytes;
    try {
      bytes = base64Decode(encoded.trim());
    } on FormatException {
      throw ArgumentError.value(encoded, 'ed25519PublicKey', 'The key is not valid base64.');
    }
    if (bytes.length != 32) {
      throw ArgumentError.value(
        encoded,
        'ed25519PublicKey',
        'A Sparkle Ed25519 public key must contain 32 bytes.',
      );
    }
    return SimplePublicKey(bytes, type: KeyPairType.ed25519);
  }

  Future<void> verify({
    required File file,
    required String encodedSignature,
    required SimplePublicKey publicKey,
  }) async {
    late Uint8List signatureBytes;
    try {
      signatureBytes = base64Decode(encodedSignature.trim());
    } on FormatException {
      throw const FormatException('sparkle:edSignature is not valid base64.');
    }
    if (signatureBytes.length != 64) {
      throw const FormatException('sparkle:edSignature must contain 64 bytes.');
    }
    final verified = await _algorithm.verify(
      await file.readAsBytes(),
      signature: Signature(signatureBytes, publicKey: publicKey),
    );
    if (!verified) {
      throw StateError('The AppImage Ed25519 signature is invalid.');
    }
  }
}
