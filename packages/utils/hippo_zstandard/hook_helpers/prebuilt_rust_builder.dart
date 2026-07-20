import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:crypto/crypto.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_rust/native_toolchain_rust.dart';

/// Provides the package's native code asset from a verified prebuilt binary.
///
/// A Rust source build is deliberately opt-in so applications consuming this
/// package never need a Rust toolchain during their normal builds.
final class HippoZstandardPrebuiltRustBuilder {
  const HippoZstandardPrebuiltRustBuilder({
    required this.assetName,
    this.cratePath = 'native',
    this.releaseBaseUrl = 'https://storage.hippolabs.org/native/hippo_zstandard',
  });

  final String assetName;
  final String cratePath;
  final String releaseBaseUrl;

  Future<void> run({required BuildInput input, required BuildOutputBuilder output}) async {
    final buildFromSource = input.userDefines['build_from_source'];
    if (buildFromSource is! bool?) {
      throw const FormatException(
        'hooks.user_defines.hippo_zstandard.build_from_source must be a '
        'boolean or omitted.',
      );
    }
    if (buildFromSource == true) {
      await RustBuilder(
        assetName: assetName,
        cratePath: cratePath,
      ).run(input: input, output: output);
      return;
    }

    final codeConfig = input.config.code;
    final target = _PrebuiltTarget.fromCodeConfig(codeConfig);
    if (target == null) {
      throw UnsupportedError(
        'hippo_zstandard has no prebuilt binary for '
        '${codeConfig.targetOS.name}-${codeConfig.targetArchitecture.name}. '
        'Package developers can set '
        'hooks.user_defines.hippo_zstandard.build_from_source to true.',
      );
    }

    final linkMode = _linkMode(codeConfig);
    if (linkMode is! DynamicLoadingBundled) {
      throw UnsupportedError(
        'hippo_zstandard prebuilts require dynamic bundled native assets. '
        'The requested link mode is ${codeConfig.linkModePreference}.',
      );
    }

    final packageRoot = Directory.fromUri(input.packageRoot);
    final nativeVersion = await _readNativeVersion(packageRoot);
    final libraryName = codeConfig.targetOS
        .libraryFileName('hippo_zstandard_native', linkMode)
        .replaceAll('-', '_');
    final artifactName = '${input.packageName}-$nativeVersion-${target.name}-$libraryName';
    final cacheDirectory = Directory('${_cacheRoot(input)}/${input.packageName}/$nativeVersion');
    final cachedArtifact = File('${cacheDirectory.path}/$artifactName');
    final cachedChecksum = File('${cachedArtifact.path}.sha256');

    if (!await _isValid(cachedArtifact, cachedChecksum)) {
      await _deleteIfExists(cachedArtifact);
      await _deleteIfExists(cachedChecksum);
      await _download(
        input: input,
        nativeVersion: nativeVersion,
        artifactName: artifactName,
        artifact: cachedArtifact,
        checksum: cachedChecksum,
      );
    }

    final outputDirectory = Directory.fromUri(input.outputDirectory);
    await outputDirectory.create(recursive: true);
    final outputFile = File('${outputDirectory.path}/$libraryName');
    await cachedArtifact.copy(outputFile.path);

    output.dependencies.addAll([
      packageRoot.uri.resolve('$cratePath/Cargo.toml'),
      packageRoot.uri.resolve('$cratePath/rust-toolchain.toml'),
    ]);
    output.assets.code.add(
      CodeAsset(
        package: input.packageName,
        name: assetName,
        linkMode: linkMode,
        file: outputFile.uri,
      ),
    );
  }

  Future<void> _download({
    required BuildInput input,
    required String nativeVersion,
    required String artifactName,
    required File artifact,
    required File checksum,
  }) async {
    final baseUrl = _baseUrl(input, nativeVersion);
    final artifactUri = Uri.parse('$baseUrl/$artifactName');
    final checksumUri = Uri.parse('$baseUrl/$artifactName.sha256');
    final temporaryDirectory = Directory(
      '${artifact.parent.path}.tmp-$pid-${DateTime.now().microsecondsSinceEpoch}',
    );

    try {
      await temporaryDirectory.create(recursive: true);
      final temporaryArtifact = File('${temporaryDirectory.path}/$artifactName');
      final temporaryChecksum = File('${temporaryDirectory.path}/$artifactName.sha256');
      await _downloadFile(artifactUri, temporaryArtifact);
      await _downloadFile(checksumUri, temporaryChecksum);

      if (!await _isValid(temporaryArtifact, temporaryChecksum)) {
        throw StateError(
          'The downloaded hippo_zstandard checksum did not match '
          '$artifactUri.',
        );
      }

      await artifact.parent.create(recursive: true);
      await temporaryArtifact.copy(artifact.path);
      await temporaryChecksum.copy(checksum.path);
    } on Object catch (error) {
      throw StateError(
        'Could not obtain the prebuilt hippo_zstandard native asset from '
        '$artifactUri. Consumers do not need Rust; ensure the matching native '
        'artifact workflow completed before publishing the Dart package. '
        'Package developers can explicitly set '
        'hooks.user_defines.hippo_zstandard.build_from_source to true. '
        'Cause: $error',
      );
    } finally {
      await _deleteIfExists(temporaryDirectory, recursive: true);
    }
  }

  Future<void> _downloadFile(Uri uri, File destination) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        await response.drain<void>();
        throw HttpException('HTTP ${response.statusCode} while downloading $uri', uri: uri);
      }
      await response.pipe(destination.openWrite());
    } finally {
      client.close(force: true);
    }
  }

  Future<bool> _isValid(File artifact, File checksum) async {
    if (!await artifact.exists() || !await checksum.exists()) {
      return false;
    }

    final expected = (await checksum.readAsString())
        .trim()
        .split(RegExp(r'\s+'))
        .first
        .toLowerCase();
    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(expected)) {
      return false;
    }
    final actual = (await sha256.bind(artifact.openRead()).first).toString();
    return expected == actual;
  }

  Future<String> _readNativeVersion(Directory packageRoot) async {
    final manifest = await File('${packageRoot.path}/$cratePath/Cargo.toml').readAsString();
    final match = RegExp(
      r'''^version\s*=\s*["']([^"']+)["']\s*$''',
      multiLine: true,
    ).firstMatch(manifest);
    if (match == null) {
      throw StateError('$cratePath/Cargo.toml has no package version.');
    }
    return match.group(1)!;
  }

  String _baseUrl(BuildInput input, String nativeVersion) {
    final override = input.userDefines['prebuilt_base_url'];
    if (override is! String?) {
      throw const FormatException(
        'hooks.user_defines.hippo_zstandard.prebuilt_base_url must be a '
        'string or omitted.',
      );
    }
    if (override != null && override.isNotEmpty) {
      return override.replaceFirst(RegExp(r'/$'), '');
    }
    return '$releaseBaseUrl/$nativeVersion';
  }

  String _cacheRoot(BuildInput input) {
    final override = input.userDefines.path('native_cache');
    if (override != null) {
      return Directory.fromUri(override).path;
    }

    final pubCache = Platform.environment['PUB_CACHE'];
    if (pubCache != null && pubCache.isNotEmpty) {
      return '$pubCache/hippo_zstandard/native_assets';
    }

    final home = Platform.environment['HOME'];
    if (home != null && home.isNotEmpty) {
      return '$home/.cache/hippo_zstandard/native_assets';
    }

    final localAppData = Platform.environment['LOCALAPPDATA'];
    if (localAppData != null && localAppData.isNotEmpty) {
      return '$localAppData/hippo_zstandard/native_assets';
    }

    return '${Directory.systemTemp.path}/hippo_zstandard/native_assets';
  }

  Future<void> _deleteIfExists(FileSystemEntity entity, {bool recursive = false}) async {
    try {
      if (await entity.exists()) {
        await entity.delete(recursive: recursive);
      }
    } on FileSystemException {
      // A concurrent build may already have cleaned the same temporary path.
    }
  }

  LinkMode _linkMode(CodeConfig codeConfig) {
    return switch (codeConfig.linkModePreference) {
      LinkModePreference.dynamic || LinkModePreference.preferDynamic => DynamicLoadingBundled(),
      LinkModePreference.static || LinkModePreference.preferStatic => StaticLinking(),
      _ => throw UnsupportedError('Unsupported link mode ${codeConfig.linkModePreference}.'),
    };
  }
}

final class _PrebuiltTarget {
  const _PrebuiltTarget(this.name);

  final String name;

  static _PrebuiltTarget? fromCodeConfig(CodeConfig config) {
    final architecture = config.targetArchitecture;
    return switch ((config.targetOS, architecture)) {
      (OS.android, Architecture.arm) => const _PrebuiltTarget('android-arm'),
      (OS.android, Architecture.arm64) => const _PrebuiltTarget('android-arm64'),
      (OS.android, Architecture.x64) => const _PrebuiltTarget('android-x64'),
      (OS.iOS, Architecture.arm64) when config.iOS.targetSdk == IOSSdk.iPhoneOS =>
        const _PrebuiltTarget('ios-device-arm64'),
      (OS.iOS, Architecture.arm64) when config.iOS.targetSdk == IOSSdk.iPhoneSimulator =>
        const _PrebuiltTarget('ios-simulator-arm64'),
      (OS.iOS, Architecture.x64) when config.iOS.targetSdk == IOSSdk.iPhoneSimulator =>
        const _PrebuiltTarget('ios-simulator-x64'),
      (OS.linux, Architecture.arm64) => const _PrebuiltTarget('linux-arm64'),
      (OS.linux, Architecture.x64) => const _PrebuiltTarget('linux-x64'),
      (OS.macOS, Architecture.arm64) => const _PrebuiltTarget('macos-arm64'),
      (OS.macOS, Architecture.x64) => const _PrebuiltTarget('macos-x64'),
      (OS.windows, Architecture.arm64) => const _PrebuiltTarget('windows-arm64'),
      (OS.windows, Architecture.x64) => const _PrebuiltTarget('windows-x64'),
      _ => null,
    };
  }
}
