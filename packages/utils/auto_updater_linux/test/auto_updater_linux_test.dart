import 'dart:convert';

import 'package:auto_updater_linux/auto_updater_linux.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const uiChannel = MethodChannel('test.auto_updater_linux/ui');

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      uiChannel,
      null,
    );
  });

  test('requires an absolute HTTPS feed URL', () async {
    final updater = AutoUpdaterLinux();

    await expectLater(updater.setFeedURL('http://example.com/appcast.xml'), throwsArgumentError);
    await expectLater(updater.setFeedURL('/appcast.xml'), throwsArgumentError);
  });

  test('validates the Sparkle public key format', () async {
    final updater = AutoUpdaterLinux();

    await expectLater(
      updater.setFeedURL('https://example.com/appcast.xml', ed25519PublicKey: 'not-base64'),
      throwsArgumentError,
    );
    await updater.setFeedURL(
      'https://example.com/appcast.xml',
      ed25519PublicKey: base64Encode(List.filled(32, 1)),
    );
  });

  test('enforces the scheduled-check interval', () async {
    final updater = AutoUpdaterLinux();

    await expectLater(updater.setScheduledCheckInterval(3599), throwsArgumentError);
    await updater.setScheduledCheckInterval(0);
  });

  test('manual checks show progress and surface failures', () async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      uiChannel,
      (call) async {
        calls.add(call);
        return null;
      },
    );
    final updater = AutoUpdaterLinux(uiChannel: uiChannel);

    await updater.checkForUpdates();

    expect(calls.map((call) => call.method), [
      'showCheckingProgress',
      'closeCheckingProgress',
      'showError',
    ]);
    expect(calls.last.arguments, containsPair('message', contains('Call setFeedURL')));
  });

  test('background checks do not show UI', () async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      uiChannel,
      (call) async {
        calls.add(call);
        return null;
      },
    );
    final updater = AutoUpdaterLinux(uiChannel: uiChannel);

    await updater.checkForUpdates(inBackground: true);

    expect(calls, isEmpty);
  });
}
