import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_flutter_app_architecture/hippo_flutter_app_architecture.dart';

void main() {
  group('AppLocale.toLocale', () {
    test('resolves US English', () {
      expect(AppLocale.enUs.toLocale(const Locale('de')), const Locale('en', 'US'));
    });

    test('resolves UK English using the GB region code', () {
      expect(AppLocale.enUk.toLocale(const Locale('de')), const Locale('en', 'GB'));
    });

    test('resolves additional language locales', () {
      const expectedLocales = <AppLocale, Locale>{
        AppLocale.es: Locale('es'),
        AppLocale.pt: Locale('pt'),
        AppLocale.ja: Locale('ja'),
        AppLocale.fr: Locale('fr'),
        AppLocale.nl: Locale('nl'),
      };

      for (final MapEntry(key: appLocale, value: expectedLocale) in expectedLocales.entries) {
        expect(appLocale.toLocale(const Locale('de')), expectedLocale);
      }
    });
  });

  test('migrates the removed generic English setting to US English', () {
    final settings = AppSettings.fromData(<String, dynamic>{
      'theme_mode': AppThemeMode.system.name,
      'locale': 'en',
    });

    expect(settings.locale, AppLocale.enUs);
  });
}
