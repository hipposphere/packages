/*
// ---------------------------------------------------------------------------
// Copyright (c) 2026 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

import 'shorthand_edit.dart';

class UseDotShorthand extends ResolvedCorrectionProducer {
  UseDotShorthand({required super.context});

  static const kind = FixKind(
    'hippo.fix.useDotShorthand',
    DartFixKindPriority.standard,
    'Use dot shorthand',
  );

  @override
  CorrectionApplicability get applicability => .acrossSingleFile;

  @override
  FixKind get fixKind => kind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final expression = node;
    if (expression is! Expression) return;
    final edit = shorthandEdit(expression);
    if (edit == null) return;
    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(.new(edit.target.offset, edit.target.length), edit.replacement);
    });
  }
}
