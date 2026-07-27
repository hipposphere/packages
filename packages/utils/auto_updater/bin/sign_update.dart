import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:auto_updater/src/sparkle_tools.dart';
import 'package:cryptography/cryptography.dart';
import 'package:path/path.dart' as p;

class SignUpdateResult {
  const SignUpdateResult({required this.signature, required this.length});

  final String signature;
  final int length;
}

Future<SignUpdateResult> signUpdate(List<String> args) async {
  final executable = sparkleToolExecutable(SparkleTool.signUpdate);
  final arguments = List<String>.from(args);
  if (Platform.isWindows) {
    if (arguments.length == 1) {
      arguments.add(p.join('dsa_priv.pem'));
    }
  }

  final processResult = await _runSignUpdate(executable, arguments);

  var signUpdateOutput = processResult.stdout;
  if (Platform.isWindows) {
    signUpdateOutput = signUpdateOutput.replaceFirst('\r\n', '').trim();
    signUpdateOutput = 'sparkle:dsaSignature="$signUpdateOutput" length="0"';
  }
  stdout.write(signUpdateOutput);

  final regex = RegExp(r'sparkle:(dsa|ed)Signature="([^"]+)" length="(\d+)"');
  final match = regex.firstMatch(signUpdateOutput);

  if (match == null) {
    throw Exception('Failed to sign update');
  }
  return SignUpdateResult(signature: match.group(2)!, length: int.tryParse(match.group(3)!)!);
}

Future<void> main(List<String> args) async {
  if (Platform.isLinux) {
    final result = await signUpdateOnLinux(args);
    stdout.write(
      'sparkle:edSignature="${result.signature}" '
      'length="${result.length}"',
    );
    return;
  }
  if (!(Platform.isMacOS || Platform.isWindows)) {
    throw UnsupportedError('auto_updater:sign_update');
  }
  await signUpdate(args);
}

Future<SignUpdateResult> signUpdateOnLinux(List<String> arguments) async {
  String? artifactPath;
  String? privateKeyPath;
  for (var index = 0; index < arguments.length; index += 1) {
    final argument = arguments[index];
    if (argument == '--ed-key-file') {
      if (index + 1 >= arguments.length) {
        throw const FormatException('--ed-key-file requires a value.');
      }
      privateKeyPath = arguments[++index];
    } else if (argument.startsWith('-')) {
      throw FormatException('Unsupported Linux signing option: $argument');
    } else if (artifactPath == null) {
      artifactPath = argument;
    } else {
      throw const FormatException('Only one update artifact may be signed.');
    }
  }
  if (artifactPath == null || privateKeyPath == null) {
    throw const FormatException('Usage: sign_update <artifact> --ed-key-file <path|->');
  }

  final encodedKey = privateKeyPath == '-'
      ? await stdin.transform(utf8.decoder).join()
      : await File(privateKeyPath).readAsString();
  final artifact = File(artifactPath);
  return signUpdateWithEd25519(artifact: artifact, encodedPrivateKey: encodedKey);
}

Future<SignUpdateResult> signUpdateWithEd25519({
  required File artifact,
  required String encodedPrivateKey,
}) async {
  late Uint8List privateKey;
  try {
    privateKey = base64Decode(encodedPrivateKey.trim());
  } on FormatException {
    throw const FormatException('The Sparkle Ed25519 private key is not valid base64.');
  }
  if (privateKey.length != 32) {
    throw const FormatException(
      'A current Sparkle Ed25519 private key must contain a 32-byte seed.',
    );
  }

  final bytes = await artifact.readAsBytes();
  final keyPair = await Ed25519().newKeyPairFromSeed(privateKey);
  final signature = await Ed25519().sign(bytes, keyPair: keyPair);
  return SignUpdateResult(signature: base64Encode(signature.bytes), length: bytes.length);
}

Future<({String stdout, String stderr})> _runSignUpdate(
  String executable,
  List<String> arguments,
) async {
  if (!_readsPrivateKeyFromStdin(arguments)) {
    final result = Process.runSync(executable, arguments);
    if (result.exitCode != 0) {
      stderr.write(result.stderr);
      throw Exception('Failed to sign update');
    }
    return (stdout: result.stdout.toString(), stderr: result.stderr.toString());
  }

  final process = await Process.start(executable, arguments);
  final stdoutBuffer = StringBuffer();
  final stderrBuffer = StringBuffer();
  final stdoutDone = process.stdout
      .transform(systemEncoding.decoder)
      .listen(stdoutBuffer.write)
      .asFuture<void>();
  final stderrDone = process.stderr
      .transform(systemEncoding.decoder)
      .listen(stderrBuffer.write)
      .asFuture<void>();

  await stdin.pipe(process.stdin);

  final exitCode = await process.exitCode;
  await Future.wait([stdoutDone, stderrDone]);

  final stderrText = stderrBuffer.toString();
  if (exitCode != 0) {
    stderr.write(stderrText);
    throw Exception('Failed to sign update');
  }

  return (stdout: stdoutBuffer.toString(), stderr: stderrText);
}

bool _readsPrivateKeyFromStdin(List<String> arguments) {
  for (var index = 0; index < arguments.length - 1; index += 1) {
    if (arguments[index] == '--ed-key-file' && arguments[index + 1] == '-') {
      return true;
    }
  }
  return false;
}
