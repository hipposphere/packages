/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

import 'package:hippo_ui/hippo_ui.dart';

/// Jaspr preview annotation carrying Hippo widget preview metadata.
///
/// Jaspr does not currently expose a framework preview annotation equivalent to
/// Flutter's `Preview`, so this class is intentionally only a Hippo metadata
/// annotation. Hippo tooling can discover it through [HippoWidgetPreviewMetadata].
final class HippoWidgetPreviewJaspr implements HippoWidgetPreviewMetadata {
  const HippoWidgetPreviewJaspr({
    this.id,
    required this.name,
    required this.path,
    this.description,
    this.tags = const <String>[],
  });

  @override
  final String? id;

  @override
  final String name;

  @override
  final String path;

  @override
  final String? description;

  @override
  final List<String> tags;
}
