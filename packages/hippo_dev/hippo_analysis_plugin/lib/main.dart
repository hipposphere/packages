/*
// ---------------------------------------------------------------------------
// Copyright (c) 2026 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

import 'src/prefer_dot_shorthands.dart';
import 'src/use_dot_shorthand.dart';

final plugin = HippoAnalysisPlugin();

class HippoAnalysisPlugin extends Plugin {
  @override
  String get name => 'hippo_analysis_plugin';

  @override
  void register(PluginRegistry registry) {
    registry.registerLintRule(PreferDotShorthands());
    registry.registerFixForRule(PreferDotShorthands.code, UseDotShorthand.new);
  }
}
