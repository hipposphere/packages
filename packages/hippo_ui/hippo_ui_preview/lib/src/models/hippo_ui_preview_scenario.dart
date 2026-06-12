/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

import 'package:dart_edge_core/dart_edge_core.dart';

import 'hippo_ui_preview_addon.dart';
import 'hippo_ui_preview_session.dart';

/// Named preview state for docs, reviews, and visual regression tests.
final class HippoUiPreviewScenario implements JsonEncodable {
  const HippoUiPreviewScenario({
    required this.id,
    required this.name,
    required this.session,
    this.description,
    this.tags = const <String>[],
  });

  factory HippoUiPreviewScenario.fromJson(
    Object? json, {
    Iterable<HippoUiPreviewAddon<HippoUiPreviewAddonState>> addons =
        const <HippoUiPreviewAddon<HippoUiPreviewAddonState>>[],
  }) {
    if (json is! Map) {
      return const HippoUiPreviewScenario(
        id: '',
        name: '',
        session: HippoUiPreviewSession(previewId: ''),
      );
    }

    return HippoUiPreviewScenario(
      id: json['id'] is String ? json['id'] as String : '',
      name: json['name'] is String ? json['name'] as String : '',
      description: json['description'] is String ? json['description'] as String : null,
      tags: _stringList(json['tags']),
      session: HippoUiPreviewSession.fromJson(json['session'], addons: addons),
    );
  }

  final String id;

  final String name;

  final String? description;

  final List<String> tags;

  final HippoUiPreviewSession session;

  HippoUiPreviewScenario copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? tags,
    HippoUiPreviewSession? session,
  }) {
    return HippoUiPreviewScenario(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      session: session ?? this.session,
    );
  }

  @override
  Map<String, Object?> toJson() {
    final json = <String, Object?>{'id': id, 'name': name, 'session': session.toJson()};
    if (description case final description?) {
      json['description'] = description;
    }
    if (tags.isNotEmpty) {
      json['tags'] = tags;
    }
    return json;
  }
}

/// Group of named preview scenarios, usually owned by one design-system package.
final class HippoUiPreviewScenarioSet implements JsonEncodable {
  const HippoUiPreviewScenarioSet({
    required this.id,
    required this.name,
    this.description,
    this.tags = const <String>[],
    this.scenarios = const <HippoUiPreviewScenario>[],
  });

  factory HippoUiPreviewScenarioSet.fromJson(
    Object? json, {
    Iterable<HippoUiPreviewAddon<HippoUiPreviewAddonState>> addons =
        const <HippoUiPreviewAddon<HippoUiPreviewAddonState>>[],
  }) {
    if (json is! Map) {
      return const HippoUiPreviewScenarioSet(id: '', name: '');
    }

    return HippoUiPreviewScenarioSet(
      id: json['id'] is String ? json['id'] as String : '',
      name: json['name'] is String ? json['name'] as String : '',
      description: json['description'] is String ? json['description'] as String : null,
      tags: _stringList(json['tags']),
      scenarios: json['scenarios'] is List
          ? (json['scenarios'] as List)
                .map((scenario) => HippoUiPreviewScenario.fromJson(scenario, addons: addons))
                .toList(growable: false)
          : const <HippoUiPreviewScenario>[],
    );
  }

  final String id;

  final String name;

  final String? description;

  final List<String> tags;

  final List<HippoUiPreviewScenario> scenarios;

  HippoUiPreviewScenario? scenarioById(String id) {
    for (final scenario in scenarios) {
      if (scenario.id == id) {
        return scenario;
      }
    }
    return null;
  }

  List<HippoUiPreviewScenario> scenariosWithTag(String tag) {
    return scenarios.where((scenario) => scenario.tags.contains(tag)).toList(growable: false);
  }

  HippoUiPreviewScenarioSet copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? tags,
    List<HippoUiPreviewScenario>? scenarios,
  }) {
    return HippoUiPreviewScenarioSet(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      scenarios: scenarios ?? this.scenarios,
    );
  }

  @override
  Map<String, Object?> toJson() {
    final json = <String, Object?>{
      'id': id,
      'name': name,
      'scenarios': scenarios.map((scenario) => scenario.toJson()).toList(growable: false),
    };
    if (description case final description?) {
      json['description'] = description;
    }
    if (tags.isNotEmpty) {
      json['tags'] = tags;
    }
    return json;
  }
}

List<String> _stringList(Object? json) {
  return json is List ? json.whereType<String>().toList(growable: false) : const <String>[];
}
