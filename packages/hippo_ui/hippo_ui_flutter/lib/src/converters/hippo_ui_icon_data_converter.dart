/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:hippo_ui/hippo_ui.dart';

final class HippoUiIconDataConverter extends HippoUiOptionConverter<IconData> {
  const HippoUiIconDataConverter();

  static Map<String, Object?> encode(IconData icon) {
    final encoded = <String, Object?>{'codePoint': icon.codePoint};
    final fontFamily = icon.fontFamily;
    final fontPackage = icon.fontPackage;
    final fontFamilyFallback = icon.fontFamilyFallback;

    if (fontFamily != null) {
      encoded['fontFamily'] = fontFamily;
    }
    if (fontPackage != null) {
      encoded['fontPackage'] = fontPackage;
    }
    if (icon.matchTextDirection) {
      encoded['matchTextDirection'] = icon.matchTextDirection;
    }
    if (fontFamilyFallback != null) {
      encoded['fontFamilyFallback'] = fontFamilyFallback;
    }

    return encoded;
  }

  static String encodeString(IconData icon) {
    return jsonEncode(encode(icon));
  }

  @override
  IconData convert(Object? value) {
    if (value is String) {
      try {
        return convert(jsonDecode(value));
      } on FormatException {
        return const IconData(0);
      }
    }

    if (value is Map) {
      final map = value;
      final codePoint = map['codePoint'];
      if (codePoint is int) {
        // IconData is reconstructed from JSON-safe generated preview metadata.
        return IconData(
          // ignore: non_const_argument_for_const_parameter
          codePoint,
          // ignore: non_const_argument_for_const_parameter
          fontFamily: map['fontFamily'] is String ? map['fontFamily'] as String : null,
          // ignore: non_const_argument_for_const_parameter
          fontPackage: map['fontPackage'] is String ? map['fontPackage'] as String : null,
          matchTextDirection: map['matchTextDirection'] as bool? ?? false,
          fontFamilyFallback: _stringList(map['fontFamilyFallback']),
        );
      }
    }
    return const IconData(0);
  }

  List<String>? _stringList(Object? value) {
    if (value is! List) {
      return null;
    }
    return value.whereType<String>().toList(growable: false);
  }
}
