import 'dart:convert';

import 'package:auto_updater_linux/auto_updater_linux.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
}
