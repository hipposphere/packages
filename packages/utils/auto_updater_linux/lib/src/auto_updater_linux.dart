import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math' show Random;

import 'package:auto_updater_linux/src/appcast_parser.dart';
import 'package:auto_updater_linux/src/signature_verifier.dart';
import 'package:auto_updater_linux/src/update_selector.dart';
import 'package:auto_updater_platform_interface/auto_updater_platform_interface.dart';
import 'package:cryptography/cryptography.dart' show SimplePublicKey;
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

const _uiChannelName = 'dev.hippolabs.auto_updater_linux/ui';

final class AutoUpdaterLinux extends AutoUpdaterPlatform {
  factory AutoUpdaterLinux({
    LinuxAppcastParser parser = const LinuxAppcastParser(),
    MethodChannel uiChannel = const MethodChannel(_uiChannelName),
  }) {
    return AutoUpdaterLinux.withDependencies(parser, uiChannel);
  }

  AutoUpdaterLinux.withDependencies(this._parser, this._uiChannel) {
    _uiChannel.setMethodCallHandler(_handleNativeMethod);
  }

  static void registerWith() {
    AutoUpdaterPlatform.instance = AutoUpdaterLinux();
  }

  final LinuxAppcastParser _parser;
  final MethodChannel _uiChannel;
  final _events = StreamController<Map<Object?, Object?>>.broadcast();
  final _signatureVerifier = LinuxUpdateSignatureVerifier();
  final _selector = const LinuxUpdateSelector();

  Uri? _feedUri;
  SimplePublicKey? _publicKey;
  Timer? _scheduledCheck;
  bool _checking = false;
  bool _downloadCancelled = false;

  @override
  Stream<Map<Object?, Object?>> get sparkleEvents => _events.stream;

  @override
  Future<void> setFeedURL(String feedUrl, {String? ed25519PublicKey}) async {
    final uri = Uri.tryParse(feedUrl);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      throw ArgumentError.value(
        feedUrl,
        'feedUrl',
        'Linux appcast URLs must be absolute HTTPS URLs.',
      );
    }
    final publicKey = _decodePublicKey(ed25519PublicKey);
    _feedUri = uri;
    _publicKey = publicKey;
  }

  @override
  Future<void> checkForUpdates({bool? inBackground}) {
    final background = inBackground ?? false;
    return _check(
      showChecking: !background,
      showUpdatePrompt: !background,
      showNoUpdate: !background,
      showErrors: !background,
    );
  }

  @override
  Future<void> setScheduledCheckInterval(int interval) async {
    _scheduledCheck?.cancel();
    _scheduledCheck = null;
    if (interval == 0) {
      return;
    }
    if (interval < 3600) {
      throw ArgumentError.value(
        interval,
        'interval',
        'The minimum scheduled check interval is 3600 seconds.',
      );
    }
    _scheduledCheck = Timer.periodic(Duration(seconds: interval), (_) {
      unawaited(
        _check(showChecking: false, showUpdatePrompt: true, showNoUpdate: false, showErrors: false),
      );
    });
  }

  Future<void> _check({
    required bool showChecking,
    required bool showUpdatePrompt,
    required bool showNoUpdate,
    required bool showErrors,
  }) async {
    if (_checking) {
      return;
    }
    _checking = true;
    var checkingDialogVisible = false;

    Future<void> closeCheckingDialog() async {
      if (!checkingDialogVisible) {
        return;
      }
      checkingDialogVisible = false;
      await _uiChannel.invokeMethod<void>('closeCheckingProgress');
    }

    try {
      if (showChecking) {
        await _uiChannel.invokeMethod<void>('showCheckingProgress', {
          'title': 'Software Update',
          'message': 'Checking for updates…',
        });
        checkingDialogVisible = true;
      }

      final feedUri = _feedUri;
      if (feedUri == null) {
        throw StateError('Call setFeedURL before checking for updates.');
      }
      if (_publicKey == null) {
        throw StateError('An Ed25519 public key is required for Linux updates.');
      }

      final packageInfo = await _readPackageInfo();
      final installedBuild = packageInfo.buildNumber.trim();
      if (installedBuild.isEmpty) {
        throw StateError('The Linux application has no Flutter build number.');
      }

      final source = await _fetchText(feedUri);
      final appcast = _parser.parse(source, architecture: currentLinuxArchitecture);
      _emit('checking-for-update', {'appcast': appcast});

      final item = _selector.select(appcast, installedBuild: installedBuild);
      if (item == null) {
        _emit('update-not-available');
        if (showNoUpdate) {
          await closeCheckingDialog();
          await _showInformation(
            title: packageInfo.appName,
            message: 'You’re up to date.',
            details: 'Version ${packageInfo.version} is the newest version.',
          );
        }
        return;
      }

      _emit('update-available', {'appcastItem': item});
      if (!showUpdatePrompt) {
        return;
      }

      await closeCheckingDialog();
      final accepted = await _showUpdateDialog(
        appName: packageInfo.appName,
        currentVersion: packageInfo.version,
        item: item,
      );
      if (accepted) {
        await _downloadAndInstall(item, packageInfo: packageInfo);
      }
    } on _UpdateCancelled {
      return;
    } catch (error) {
      _emit('error', {'error': error.toString()});
      if (showErrors) {
        await closeCheckingDialog();
        await _showError(title: 'Update failed', message: error.toString());
      }
    } finally {
      await closeCheckingDialog();
      _checking = false;
    }
  }

  Future<String> _fetchText(Uri initialUri) async {
    final client = HttpClient();
    try {
      var uri = initialUri;
      for (var redirects = 0; redirects <= 5; redirects += 1) {
        final request = await client.getUrl(uri);
        request.followRedirects = false;
        final response = await request.close();
        if (_isRedirect(response.statusCode)) {
          final location = response.headers.value(HttpHeaders.locationHeader);
          await response.drain<void>();
          if (location == null || redirects == 5) {
            throw HttpException('Invalid appcast redirect.', uri: uri);
          }
          uri = uri.resolve(location);
          _requireHttps(uri, 'Appcast redirect');
          continue;
        }
        if (response.statusCode != HttpStatus.ok) {
          await response.drain<void>();
          throw HttpException('Appcast request failed with HTTP ${response.statusCode}.', uri: uri);
        }
        return await response.transform(utf8.decoder).join();
      }
      throw StateError('Too many appcast redirects.');
    } finally {
      client.close(force: true);
    }
  }

  Future<void> _downloadAndInstall(
    Map<String, Object?> item, {
    required _LinuxPackageInfo packageInfo,
  }) async {
    final current = await _currentAppImage();
    final staged = await _createStagingFile(current);
    _downloadCancelled = false;
    await _uiChannel.invokeMethod<void>('showDownloadProgress', {
      'title': 'Updating ${packageInfo.appName}',
      'message': 'Downloading ${item['displayVersionString'] ?? item['versionString']}…',
    });

    try {
      await _download(
        Uri.parse(item['fileURL']! as String),
        staged,
        expectedLength: item['contentLength']! as int,
      );
      if (_downloadCancelled) {
        throw const _UpdateCancelled();
      }
      await _signatureVerifier.verify(
        file: staged,
        encodedSignature: item['edSignature']! as String,
        publicKey: _publicKey!,
      );
      await _uiChannel.invokeMethod<void>('closeDownloadProgress');

      _emit('update-downloaded', {'appcastItem': item});
      _emit('before-quit-for-update', {'appcastItem': item});
      await _startHelper(current: current, staged: staged);
      await _uiChannel.invokeMethod<void>('quitApplication');
    } catch (_) {
      await _uiChannel.invokeMethod<void>('closeDownloadProgress');
      if (await staged.exists()) {
        await staged.delete();
      }
      rethrow;
    }
  }

  Future<File> _currentAppImage() async {
    final value = Platform.environment['APPIMAGE'];
    if (value == null || value.isEmpty || !p.isAbsolute(value)) {
      throw StateError('Updates require an AppImage launched from a writable location.');
    }
    final file = File(await File(value).resolveSymbolicLinks());
    final stat = await file.stat();
    if (stat.type != FileSystemEntityType.file || stat.mode & 0x49 == 0) {
      throw StateError('APPIMAGE is not an executable regular file.');
    }
    return file;
  }

  Future<File> _createStagingFile(File current) async {
    final random = Random.secure();
    for (var attempt = 0; attempt < 10; attempt += 1) {
      final suffix = random.nextInt(0x7fffffff).toRadixString(16);
      final file = File('${current.path}.update-$suffix');
      try {
        await file.create(exclusive: true);
        return file;
      } on FileSystemException {
        if (attempt == 9) {
          rethrow;
        }
      }
    }
    throw StateError('Unable to create an update staging file.');
  }

  Future<void> _download(Uri initialUri, File destination, {required int expectedLength}) async {
    final client = HttpClient();
    client.autoUncompress = false;
    IOSink? sink;
    try {
      var uri = initialUri;
      HttpClientResponse? response;
      for (var redirects = 0; redirects <= 5; redirects += 1) {
        _requireHttps(uri, 'AppImage URL');
        final request = await client.getUrl(uri);
        request.followRedirects = false;
        final candidate = await request.close();
        if (_isRedirect(candidate.statusCode)) {
          final location = candidate.headers.value(HttpHeaders.locationHeader);
          await candidate.drain<void>();
          if (location == null || redirects == 5) {
            throw HttpException('Invalid AppImage redirect.', uri: uri);
          }
          uri = uri.resolve(location);
          continue;
        }
        response = candidate;
        break;
      }
      if (response == null || response.statusCode != HttpStatus.ok) {
        final status = response?.statusCode;
        await response?.drain<void>();
        throw HttpException(
          'AppImage request failed${status == null ? '' : ' with HTTP $status'}.',
          uri: uri,
        );
      }

      final responseLength = response.contentLength;
      if (responseLength >= 0 && responseLength != expectedLength) {
        await response.drain<void>();
        throw StateError('The AppImage Content-Length does not match the appcast.');
      }

      sink = destination.openWrite();
      var received = 0;
      var lastProgressUpdate = DateTime.fromMillisecondsSinceEpoch(0);
      await for (final chunk in response) {
        if (_downloadCancelled) {
          throw const _UpdateCancelled();
        }
        received += chunk.length;
        if (received > expectedLength) {
          throw StateError('The AppImage is larger than declared.');
        }
        sink.add(chunk);
        final now = DateTime.now();
        if (now.difference(lastProgressUpdate).inMilliseconds >= 100) {
          lastProgressUpdate = now;
          unawaited(
            _uiChannel.invokeMethod<void>('updateDownloadProgress', {
              'progress': received / expectedLength,
            }),
          );
        }
      }
      await sink.flush();
      await sink.close();
      sink = null;
      final stagedFile = await destination.open(mode: FileMode.append);
      try {
        await stagedFile.flush();
      } finally {
        await stagedFile.close();
      }
      if (received != expectedLength) {
        throw StateError('The AppImage download is incomplete.');
      }
    } finally {
      await sink?.close();
      client.close(force: true);
    }
  }

  Future<void> _startHelper({required File current, required File staged}) async {
    final helperPath = await _uiChannel.invokeMethod<String>('getHelperPath');
    if (helperPath == null || helperPath.isEmpty) {
      throw StateError('The Linux updater helper is unavailable.');
    }
    final helper = File(helperPath);
    if (!await helper.exists()) {
      throw StateError('The Linux updater helper is missing.');
    }

    final originalArguments = await _readProcessArguments();
    final result = await Process.start(helper.path, [
      '--current',
      current.path,
      '--staged',
      staged.path,
      '--parent-pid',
      pid.toString(),
      '--',
      ...originalArguments,
    ], mode: ProcessStartMode.detached);
    if (result.pid <= 0) {
      throw StateError('Unable to start the Linux updater helper.');
    }
  }

  Future<List<String>> _readProcessArguments() async {
    final bytes = await File('/proc/self/cmdline').readAsBytes();
    final arguments = <String>[];
    var start = 0;
    for (var index = 0; index < bytes.length; index += 1) {
      if (bytes[index] != 0) {
        continue;
      }
      if (index > start) {
        arguments.add(utf8.decode(bytes.sublist(start, index)));
      }
      start = index + 1;
    }
    return arguments.length <= 1 ? const [] : arguments.sublist(1);
  }

  Future<_LinuxPackageInfo> _readPackageInfo() async {
    final executable = await File('/proc/self/exe').resolveSymbolicLinks();
    final versionFile = File(
      p.join(p.dirname(executable), 'data', 'flutter_assets', 'version.json'),
    );
    final decoded = jsonDecode(await versionFile.readAsString());
    if (decoded is! Map) {
      throw const FormatException('Flutter version.json does not contain an object.');
    }
    final values = Map<String, Object?>.from(decoded);
    return _LinuxPackageInfo(
      appName: values['app_name'] as String? ?? '',
      version: values['version'] as String? ?? '',
      buildNumber: values['build_number'] as String? ?? '',
    );
  }

  Future<bool> _showUpdateDialog({
    required String appName,
    required String currentVersion,
    required Map<String, Object?> item,
  }) async {
    return await _uiChannel.invokeMethod<bool>('showUpdateDialog', {
          'appName': appName,
          'currentVersion': currentVersion,
          'newVersion': item['displayVersionString'] ?? item['versionString'],
          'releaseNotesURL': item['releaseNotesURL'],
          'description': item['itemDescription'],
        }) ??
        false;
  }

  Future<void> _showInformation({
    required String title,
    required String message,
    required String details,
  }) {
    return _uiChannel.invokeMethod<void>('showInformation', {
      'title': title,
      'message': message,
      'details': details,
    });
  }

  Future<void> _showError({required String title, required String message}) {
    return _uiChannel.invokeMethod<void>('showError', {'title': title, 'message': message});
  }

  Future<void> _handleNativeMethod(MethodCall call) async {
    if (call.method == 'cancelDownload') {
      _downloadCancelled = true;
    }
  }

  void _emit(String type, [Map<String, Object?>? data]) {
    _events.add({'type': type, 'data': ?data});
  }

  SimplePublicKey? _decodePublicKey(String? encoded) {
    if (encoded == null || encoded.trim().isEmpty) {
      return null;
    }
    return _signatureVerifier.decodePublicKey(encoded);
  }

  static String get currentLinuxArchitecture {
    return switch (Abi.current()) {
      Abi.linuxX64 => 'x86_64',
      Abi.linuxArm64 => 'aarch64',
      final abi => throw UnsupportedError('Linux architecture $abi is not supported.'),
    };
  }

  static bool _isRedirect(int statusCode) {
    return statusCode == HttpStatus.movedPermanently ||
        statusCode == HttpStatus.found ||
        statusCode == HttpStatus.seeOther ||
        statusCode == HttpStatus.temporaryRedirect ||
        statusCode == HttpStatus.permanentRedirect;
  }

  static void _requireHttps(Uri uri, String label) {
    LinuxUpdateSelector.requireHttps(uri, label);
  }
}

final class _UpdateCancelled implements Exception {
  const _UpdateCancelled();
}

final class _LinuxPackageInfo {
  const _LinuxPackageInfo({
    required this.appName,
    required this.version,
    required this.buildNumber,
  });

  final String appName;
  final String version;
  final String buildNumber;
}
