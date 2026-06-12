/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

import 'package:flutter/widgets.dart';
import 'package:hippo_ui_flutter/hippo_ui_flutter.dart';
import 'package:hippo_ui_preview/hippo_ui_preview.dart';

/// Flutter preview addon configuration for locale selection.
final class LocaleAddon extends HippoUiPreviewAddon<HippoUiPreviewConfiguredAddonState> {
  LocaleAddon({required this.defaultLocale, required this.supportedLocales})
    : assert(supportedLocales.isNotEmpty, 'supportedLocales must not be empty.'),
      assert(
        _containsLocale(supportedLocales, defaultLocale),
        'supportedLocales must contain defaultLocale.',
      ),
      super(
        id: addonId,
        label: 'Locale',
        configurationOptions: <HippoUiOption>[
          HippoUiOption.choice(
            key: localeKey,
            label: 'Locale',
            defaultValue: defaultLocale.toLanguageTag(),
            values: <HippoUiOptionValue<String>>[
              for (final Locale locale in supportedLocales)
                HippoUiOptionValue<String>(
                  value: locale.toLanguageTag(),
                  label: localeLabel(locale),
                ),
            ],
          ),
        ],
      );

  static const addonId = 'locale';

  static const localeKey = 'locale';

  final Locale defaultLocale;

  final List<Locale> supportedLocales;

  @override
  HippoUiPreviewConfiguredAddonState get defaultState {
    return stateFor(defaultLocale);
  }

  @override
  HippoUiPreviewConfiguredAddonState decodeState(Object? json) {
    final state = HippoUiPreviewConfiguredAddonState.fromJson(addonId, json);
    return stateFor(localeFromState(state));
  }

  HippoUiPreviewConfiguredAddonState stateFor(Locale locale) {
    final selectedLocale = _containsLocale(supportedLocales, locale) ? locale : defaultLocale;
    return HippoUiPreviewConfiguredAddonState(
      addonId: addonId,
      configuration: <String, Object?>{localeKey: selectedLocale.toLanguageTag()},
    );
  }

  Locale localeFromState(HippoUiPreviewAddonState? state) {
    final configuration = state is HippoUiPreviewConfiguredAddonState
        ? state.configuration
        : const <String, Object?>{};
    final locale = _localeFromLanguageTag(
      configuration[localeKey] as String?,
      fallback: defaultLocale,
    );
    return _containsLocale(supportedLocales, locale) ? locale : defaultLocale;
  }

  static String localeLabel(Locale locale) {
    return locale.toLanguageTag();
  }
}

/// Applies the selected preview locale to [child].
final class HippoUiPreviewLocaleBuilder extends StatelessWidget {
  const HippoUiPreviewLocaleBuilder({
    required this.addon,
    required this.state,
    required this.child,
    super.key,
  });

  final LocaleAddon addon;

  final HippoUiPreviewAddonState? state;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Localizations.override(
      context: context,
      locale: addon.localeFromState(state),
      child: child,
    );
  }
}

bool _containsLocale(List<Locale> locales, Locale locale) {
  for (final supportedLocale in locales) {
    if (supportedLocale.toLanguageTag() == locale.toLanguageTag()) {
      return true;
    }
  }
  return false;
}

Locale _localeFromLanguageTag(String? value, {required Locale fallback}) {
  if (value == null || value.isEmpty) {
    return fallback;
  }

  final parts = value.replaceAll('_', '-').split('-');
  if (parts.isEmpty || parts.first.isEmpty) {
    return fallback;
  }

  return Locale.fromSubtags(
    languageCode: parts[0],
    scriptCode: parts.length == 3 ? parts[1] : null,
    countryCode: switch (parts.length) {
      2 => parts[1],
      3 => parts[2],
      _ => null,
    },
  );
}
