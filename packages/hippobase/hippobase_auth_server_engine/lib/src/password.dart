import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/scrypt.dart';
import 'package:unorm_dart/unorm_dart.dart' as unorm;

part 'password/scrypt_isolate_pool.dart';

abstract interface class HippobaseAuthPasswordService {
  Future<String> hash(String password);

  Future<bool> verify(String password, String encodedHash);

  Future<void> close();
}

/// Better Auth compatible scrypt password service.
///
/// Work is dispatched to isolates and bounded to [workerCount] concurrent jobs,
/// preventing CPU-heavy password checks from blocking request isolates.
final class HippobaseAuthScryptPasswordService implements HippobaseAuthPasswordService {
  HippobaseAuthScryptPasswordService({int workerCount = 2, Random? random})
    : workerCount = workerCount < 1 ? 1 : workerCount,
      _random = random ?? Random.secure(),
      _pool = _ScryptIsolatePool(workerCount < 1 ? 1 : workerCount);

  static const int cost = 16384;
  static const int blockSize = 16;
  static const int parallelization = 1;
  static const int outputLength = 64;
  static const int saltLength = 16;

  final int workerCount;
  final Random _random;
  final _ScryptIsolatePool _pool;

  @override
  Future<String> hash(String password) async {
    final salt = Uint8List.fromList(List<int>.generate(saltLength, (_) => _random.nextInt(256)));
    return hashWithSalt(password, salt);
  }

  Future<String> hashWithSalt(String password, Uint8List salt) async {
    if (salt.length != saltLength) {
      throw ArgumentError.value(salt.length, 'salt', 'Must contain exactly 16 bytes.');
    }
    final result = await _run(<String, String>{'password': password, 'salt': _hex(salt)});
    return '${_hex(salt)}:$result';
  }

  @override
  Future<bool> verify(String password, String encodedHash) async {
    final parts = encodedHash.split(':');
    if (parts.length != 2) return false;
    final salt = _decodeHex(parts[0]);
    final expected = _decodeHex(parts[1]);
    if (salt == null ||
        salt.length != saltLength ||
        expected == null ||
        expected.length != outputLength) {
      return false;
    }
    final actualHex = await _run(<String, String>{
      'password': password,
      'salt': parts[0].toLowerCase(),
    });
    final actual = _decodeHex(actualHex)!;
    return _constantTimeEquals(actual, expected);
  }

  Future<String> _run(Map<String, String> input) async {
    return _pool.run(input);
  }

  @override
  Future<void> close() => _pool.close();
}
