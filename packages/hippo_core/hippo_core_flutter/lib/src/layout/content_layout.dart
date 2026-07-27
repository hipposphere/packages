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

/// Defines the shared geometry of a centered content lane.
@immutable
class ContentLayout {
  final double maxWidth;
  final EdgeInsetsGeometry gutters;

  const ContentLayout({
    this.maxWidth = 800,
    this.gutters = const EdgeInsets.symmetric(horizontal: 16),
  }) : assert(maxWidth >= 0);

  ContentLayout copyWith({double? maxWidth, EdgeInsetsGeometry? gutters}) {
    return ContentLayout(maxWidth: maxWidth ?? this.maxWidth, gutters: gutters ?? this.gutters);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ContentLayout && other.maxWidth == maxWidth && other.gutters == gutters;
  }

  @override
  int get hashCode => Object.hash(maxWidth, gutters);
}
