part of '../app_settings.dart';

enum AppLocale {
  system,
  enUs,
  enUk,
  de,
  es,
  pt,
  ja,
  fr,
  nl,
  zh;

  Locale toLocale(Locale systemLocale) {
    return switch (this) {
      system => systemLocale,
      enUs => Locale('en', 'US'),
      enUk => Locale('en', 'GB'),
      de => Locale('de'),
      es => Locale('es'),
      pt => Locale('pt'),
      ja => Locale('ja'),
      fr => Locale('fr'),
      nl => Locale('nl'),
      zh => Locale('zh'),
    };
  }
}
