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

/// Holds icon catalog state and search input for preview UIs.
final class HippoUiIconCatalogController extends ChangeNotifier {
  HippoUiIconCatalogController({
    required List<HippoUiFlutterIconDefinition> icons,
    TextEditingController? searchController,
  }) : _icons = List<HippoUiFlutterIconDefinition>.unmodifiable(icons),
       searchController = searchController ?? TextEditingController(),
       _ownsSearchController = searchController == null,
       super() {
    this.searchController.addListener(_handleSearchChanged);
  }

  final TextEditingController searchController;

  final bool _ownsSearchController;

  List<HippoUiFlutterIconDefinition> _icons;

  List<HippoUiFlutterIconDefinition> get icons => _icons;

  String get searchQuery => searchController.text.trim();

  List<HippoUiFlutterIconDefinition> get filteredIcons {
    final query = searchQuery.toLowerCase();
    if (query.isEmpty) {
      return icons;
    }

    return icons.where((icon) => _matchesQuery(icon, query)).toList(growable: false);
  }

  set icons(List<HippoUiFlutterIconDefinition> icons) {
    _icons = List<HippoUiFlutterIconDefinition>.unmodifiable(icons);
    notifyListeners();
  }

  void clearSearch() {
    searchController.clear();
  }

  bool _matchesQuery(HippoUiFlutterIconDefinition icon, String query) {
    final definition = icon.definition;
    final searchableValues = <String>[
      definition.id,
      definition.name,
      definition.path,
      ?definition.description,
      ...definition.tags,
      for (final variant in definition.variants) ...<String>[
        variant.id,
        variant.label,
        ?variant.style?.name,
        variant.colorMode.name,
        ...variant.tags,
      ],
    ];

    return searchableValues.any((value) => value.toLowerCase().contains(query));
  }

  void _handleSearchChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.removeListener(_handleSearchChanged);
    if (_ownsSearchController) {
      searchController.dispose();
    }
    super.dispose();
  }
}
