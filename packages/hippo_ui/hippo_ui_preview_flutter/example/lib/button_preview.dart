/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:hippo_ui_flutter/hippo_ui_flutter.dart';

@HippoWidgetPreview(
  name: 'Demo button',
  path: 'Components/Button',
  description: 'A configurable button preview rendered from the generated catalog.',
)
final class PreviewButton extends StatelessWidget {
  const PreviewButton({
    @HippoWidgetPreviewField(.text(label: 'Label', defaultValue: 'Continue')) required this.label,
    @HippoWidgetPreviewField(.integerRange(label: 'Count', defaultValue: 2, min: 0, max: 8))
    required this.count,
    @HippoWidgetPreviewField(.boolean(label: 'Prominent', defaultValue: true))
    required this.prominent,
    super.key,
  });

  final String label;

  final int count;

  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: prominent ? theme.colorScheme.primary : theme.colorScheme.secondary,
          foregroundColor: prominent ? theme.colorScheme.onPrimary : theme.colorScheme.onSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        ),
        onPressed: () {},
        icon: Badge.count(count: count),
        label: Text(label),
      ),
    );
  }
}

@HippoWidgetPreview(
  name: 'Status card',
  path: 'Components/Card',
  description: 'A compact status card preview with configurable tone and value.',
)
final class PreviewStatusCard extends StatelessWidget {
  const PreviewStatusCard({
    @HippoWidgetPreviewField(.text(label: 'Title', defaultValue: 'Pipeline health'))
    required this.title,
    @HippoWidgetPreviewField(.text(label: 'Value', defaultValue: '98%')) required this.value,
    @HippoWidgetPreviewField(.boolean(label: 'Warning', defaultValue: false)) required this.warning,
    @HippoWidgetPreviewField(HippoUiAlignmentOption(label: 'Alignment', defaultValue: .center))
    required this.alignment,
    @HippoWidgetPreviewField(
      HippoUiEnumOption<MainAxisAlignment>(
        label: 'Layout',
        defaultValue: .start,
        values: [
          .new(value: .start, label: 'Start'),
          .new(value: .center, label: 'Center'),
          .new(value: .end, label: 'End'),
          .new(value: .spaceBetween, label: 'Space between'),
        ],
      ),
    )
    required this.mainAxisAlignment,
    super.key,
  });

  final String title;

  final String value;

  final bool warning;

  final Alignment alignment;

  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = warning ? theme.colorScheme.error : theme.colorScheme.tertiary;
    final onColor = warning ? theme.colorScheme.onError : theme.colorScheme.onTertiary;

    return Align(
      alignment: alignment,
      child: SizedBox(
        width: 280,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: mainAxisAlignment,
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: color,
                  foregroundColor: onColor,
                  child: Icon(warning ? Icons.priority_high : Icons.check),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(title, style: theme.textTheme.labelLarge),
                      const SizedBox(height: 4),
                      Text(value, style: theme.textTheme.headlineSmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
