/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

import 'hippo_ui_option_value.dart';
import 'hippo_ui_option_converter.dart';

/// Describes one editable preview option.
abstract class HippoUiOption {
  const HippoUiOption();

  const factory HippoUiOption.boolean({
    String? key,
    String? label,
    String? description,
    bool defaultValue,
    HippoUiOptionConverter<dynamic>? converter,
  }) = HippoUiBooleanOption;

  const factory HippoUiOption.integer({
    String? key,
    String? label,
    String? description,
    int defaultValue,
    List<HippoUiOptionValue<int>> values,
    HippoUiOptionConverter<dynamic>? converter,
  }) = HippoUiIntegerOption;

  const factory HippoUiOption.integerRange({
    String? key,
    required int defaultValue,
    required int min,
    required int max,
    int step,
    String? label,
    String? description,
    HippoUiOptionConverter<dynamic>? converter,
  }) = HippoUiIntegerOption.range;

  const factory HippoUiOption.double({
    String? key,
    String? label,
    String? description,
    double defaultValue,
    List<HippoUiOptionValue<double>> values,
    HippoUiOptionConverter<dynamic>? converter,
  }) = HippoUiDoubleOption;

  const factory HippoUiOption.doubleRange({
    String? key,
    required double defaultValue,
    required double min,
    required double max,
    double step,
    String? label,
    String? description,
    HippoUiOptionConverter<dynamic>? converter,
  }) = HippoUiDoubleOption.range;

  const factory HippoUiOption.text({
    String? key,
    String? label,
    String? description,
    String defaultValue,
    List<HippoUiOptionValue<String>> values,
    HippoUiOptionConverter<dynamic>? converter,
  }) = HippoUiTextOption;

  const factory HippoUiOption.choice({
    String? key,
    String? label,
    String? description,
    String defaultValue,
    required List<HippoUiOptionValue<String>> values,
    HippoUiOptionConverter<dynamic>? converter,
  }) = HippoUiTextOption;

  const factory HippoUiOption.object({
    String? key,
    String? label,
    String? description,
    Map<String, Object?> defaultValue,
    List<HippoUiOptionValue<Map<String, Object?>>> values,
    HippoUiOptionConverter<dynamic>? converter,
  }) = HippoUiObjectOption;

  /// Stable option/property name.
  String? get key;

  /// Optional UI label. Defaults to [name] in tooling.
  String? get label;

  String? get description;

  /// Const primitive default value used when opening a playground.
  Object? get defaultValue;

  /// Maps the JSON-safe option value to the constructor parameter value.
  HippoUiOptionConverter<dynamic>? get converter;
}

final class HippoUiBooleanOption extends HippoUiOption {
  const HippoUiBooleanOption({
    this.key,
    this.label,
    this.description,
    this.defaultValue = false,
    this.converter,
  });

  @override
  final String? key;

  @override
  final String? label;

  @override
  final String? description;

  @override
  final bool defaultValue;

  @override
  final HippoUiOptionConverter<dynamic>? converter;
}

final class HippoUiIntegerOption extends HippoUiOption {
  const HippoUiIntegerOption({
    this.key,
    this.label,
    this.description,
    this.defaultValue = 0,
    this.min,
    this.max,
    this.step,
    this.values = const <HippoUiOptionValue<int>>[],
    this.converter,
  });

  const HippoUiIntegerOption.range({
    this.key,
    required this.defaultValue,
    required int this.min,
    required int this.max,
    int this.step = 1,
    this.label,
    this.description,
    this.converter,
  }) : values = const <HippoUiOptionValue<int>>[];

  @override
  final String? key;

  @override
  final String? label;

  @override
  final String? description;

  @override
  final int defaultValue;

  /// Numeric option lower bound. When both [min] and [max] are set, tooling can
  /// render bounded controls such as sliders.
  final int? min;

  /// Numeric option upper bound.
  final int? max;

  /// Numeric option step size.
  final int? step;

  /// Optional discrete allowed values for segmented controls, steppers, or menus.
  final List<HippoUiOptionValue<int>> values;

  @override
  final HippoUiOptionConverter<dynamic>? converter;
}

final class HippoUiDoubleOption extends HippoUiOption {
  const HippoUiDoubleOption({
    this.key,
    this.label,
    this.description,
    this.defaultValue = 0,
    this.min,
    this.max,
    this.step,
    this.values = const <HippoUiOptionValue<double>>[],
    this.converter,
  });

  const HippoUiDoubleOption.range({
    this.key,
    required this.defaultValue,
    required double this.min,
    required double this.max,
    double this.step = 0.1,
    this.label,
    this.description,
    this.converter,
  }) : values = const <HippoUiOptionValue<double>>[];

  @override
  final String? key;

  @override
  final String? label;

  @override
  final String? description;

  @override
  final double defaultValue;

  /// Numeric option lower bound. When both [min] and [max] are set, tooling can
  /// render bounded controls such as sliders.
  final double? min;

  /// Numeric option upper bound.
  final double? max;

  /// Numeric option step size.
  final double? step;

  /// Optional discrete allowed values for segmented controls, steppers, or menus.
  final List<HippoUiOptionValue<double>> values;

  @override
  final HippoUiOptionConverter<dynamic>? converter;
}

final class HippoUiTextOption extends HippoUiOption {
  const HippoUiTextOption({
    this.key,
    this.label,
    this.description,
    this.defaultValue = '',
    this.values = const <HippoUiOptionValue<String>>[],
    this.converter,
  });

  @override
  final String? key;

  @override
  final String? label;

  @override
  final String? description;

  @override
  final String defaultValue;

  /// Optional discrete allowed values for segmented controls, autocomplete, or menus.
  final List<HippoUiOptionValue<String>> values;

  @override
  final HippoUiOptionConverter<dynamic>? converter;
}

final class HippoUiEnumOption<T extends Enum> extends HippoUiOption {
  const HippoUiEnumOption({
    this.key,
    this.label,
    this.description,
    required this.defaultValue,
    required this.values,
    this.converter,
  });

  @override
  final String? key;

  @override
  final String? label;

  @override
  final String? description;

  @override
  final T defaultValue;

  final List<HippoUiOptionValue<T>> values;

  @override
  final HippoUiOptionConverter<dynamic>? converter;
}

final class HippoUiObjectOption extends HippoUiOption {
  const HippoUiObjectOption({
    this.key,
    this.label,
    this.description,
    this.defaultValue = const <String, Object?>{},
    this.values = const <HippoUiOptionValue<Map<String, Object?>>>[],
    this.converter,
  });

  @override
  final String? key;

  @override
  final String? label;

  @override
  final String? description;

  @override
  final Map<String, Object?> defaultValue;

  final List<HippoUiOptionValue<Map<String, Object?>>> values;

  @override
  final HippoUiOptionConverter<dynamic>? converter;
}
