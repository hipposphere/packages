/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

import 'package:flutter/widget_previews.dart';
import 'package:hippo_ui/hippo_ui.dart';

/// Flutter preview annotation carrying Hippo widget preview metadata.
///
/// This annotation extends Flutter's [Preview] so Flutter widget preview tooling
/// can discover the target. It also implements [HippoWidgetPreviewMetadata] so
/// Hippo tooling can read the same annotation for catalogs, playgrounds, and
/// review apps.
base class HippoWidgetPreviewFlutter extends Preview implements HippoWidgetPreviewMetadata {
  const HippoWidgetPreviewFlutter({
    this.id,
    required String name,
    required this.path,
    this.description,
    this.tags = const <String>[],
    String? group,
    super.size,
    super.textScaleFactor,
    super.wrapper,
    super.theme,
    super.brightness,
    super.localizations,
  }) : _name = name,
       super(group: group ?? path, name: name);

  @override
  final String? id;

  final String _name;

  @override
  String get name => _name;

  @override
  final String path;

  @override
  final String? description;

  @override
  final List<String> tags;
}
