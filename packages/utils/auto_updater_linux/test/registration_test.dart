import 'package:auto_updater_linux/auto_updater_linux.dart';
import 'package:auto_updater_platform_interface/auto_updater_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

// Deliberately does not initialize a binding: Flutter registers Dart plugins
// before the app calls WidgetsFlutterBinding.ensureInitialized.
void main() {
  test('registers before the services binding is initialized', () {
    AutoUpdaterLinux.registerWith();

    expect(AutoUpdaterPlatform.instance, isA<AutoUpdaterLinux>());
  });
}
