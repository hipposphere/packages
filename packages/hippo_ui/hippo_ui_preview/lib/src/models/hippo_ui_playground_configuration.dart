/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

import 'package:json_schema/json_schema.dart';
import 'package:hippo_ui/hippo_ui.dart';

/// Runtime option values for a generated preview playground.
final class HippoUiPlaygroundConfiguration implements JsonEncodable {
  const HippoUiPlaygroundConfiguration({this.values = const <String, Object?>{}});

  factory HippoUiPlaygroundConfiguration.fromJson(Object? json) {
    if (json is! Map) {
      return const HippoUiPlaygroundConfiguration();
    }

    return HippoUiPlaygroundConfiguration(
      values: Map<String, Object?>.fromEntries(
        json.entries
            .where((entry) => entry.key is String)
            .map((entry) => MapEntry(entry.key as String, entry.value)),
      ),
    );
  }

  factory HippoUiPlaygroundConfiguration.fromPreviewDefinition(
    HippoUiGeneratedPreview previewDefinition, {
    Map<String, Object?> initialValues = const <String, Object?>{},
  }) {
    return HippoUiPlaygroundConfiguration(
      values: <String, Object?>{
        for (final option in previewDefinition.options) option.key: option.defaultValue,
        ...initialValues,
      },
    );
  }

  final Map<String, Object?> values;

  Object? valueFor(String optionKey) {
    return values[optionKey];
  }

  HippoUiPlaygroundConfiguration copyWith({Map<String, Object?>? values}) {
    return HippoUiPlaygroundConfiguration(values: values ?? this.values);
  }

  HippoUiPlaygroundConfiguration withValue(String optionKey, Object? value) {
    return copyWith(values: <String, Object?>{...values, optionKey: value});
  }

  HippoUiPlaygroundConfiguration withoutValue(String optionKey) {
    return copyWith(values: <String, Object?>{...values}..remove(optionKey));
  }

  @override
  Map<String, Object?> toJson() {
    return values;
  }
}
