import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';

import 'hippo_zstandard.dart';
import 'native_bindings.g.dart' as bindings;

const _expectedAbiVersion = 1;

Future<Uint8List> compress(
  Uint8List input, {
  required int level,
  required String? webAssetBaseUrl,
}) => Isolate.run(() => _compressSync(input, level));

Future<Uint8List> decompress(
  Uint8List input, {
  required int maxOutputBytes,
  required String? webAssetBaseUrl,
}) => Isolate.run(() => _decompressSync(input, maxOutputBytes));

Uint8List _compressSync(Uint8List input, int level) {
  _checkAbi();
  return _withNativeInput(
    input,
    (pointer, length) => bindings.hippo_zstd_compress(pointer, length, level),
  );
}

Uint8List _decompressSync(Uint8List input, int maxOutputBytes) {
  _checkAbi();
  return _withNativeInput(
    input,
    (pointer, length) => bindings.hippo_zstd_decompress(pointer, length, maxOutputBytes),
  );
}

void _checkAbi() {
  final actual = bindings.hippo_zstd_abi_version();
  if (actual != _expectedAbiVersion) {
    throw StateError(
      'Unsupported hippo_zstandard native ABI $actual; expected $_expectedAbiVersion.',
    );
  }
}

Uint8List _withNativeInput(
  Uint8List input,
  Pointer<bindings.HippoZstdResult> Function(Pointer<Uint8>, int) operation,
) {
  final inputPointer = bindings.hippo_zstd_alloc(input.length);
  if (input.isNotEmpty && inputPointer == nullptr) {
    throw const HippoZstandardException(HippoZstandardError.internal);
  }

  try {
    if (input.isNotEmpty) {
      inputPointer.asTypedList(input.length).setAll(0, input);
    }
    final result = operation(inputPointer, input.length);
    if (result == nullptr) {
      throw const HippoZstandardException(HippoZstandardError.internal);
    }

    try {
      final error = bindings.hippo_zstd_result_error(result);
      if (error != 0) {
        throw HippoZstandardException(_errorFromCode(error));
      }

      final length = bindings.hippo_zstd_result_length(result);
      final data = bindings.hippo_zstd_result_data(result);
      if (length == 0) {
        return Uint8List(0);
      }
      if (data == nullptr) {
        throw const HippoZstandardException(HippoZstandardError.internal);
      }
      return Uint8List.fromList(data.asTypedList(length));
    } finally {
      bindings.hippo_zstd_result_free(result);
    }
  } finally {
    bindings.hippo_zstd_input_free(inputPointer, input.length);
  }
}

HippoZstandardError _errorFromCode(int code) => switch (code) {
  1 => HippoZstandardError.invalidData,
  2 => HippoZstandardError.outputLimitExceeded,
  4 => HippoZstandardError.invalidArgument,
  _ => HippoZstandardError.internal,
};
