/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

import 'dart:convert';

import 'package:hippo_analysis/hippo_analysis.dart';
import 'package:hippo_ui_codegen/src/builder/catalog_library_emitter.dart';
import 'package:hippo_ui_codegen/src/builder/catalog_manifest_emitter.dart';
import 'package:hippo_ui_codegen/src/builder/catalog_metadata.dart';
import 'package:test/test.dart';

void main() {
  const checkToken = '{"codePoint":57686,"fontFamily":"MaterialIcons"}';
  const closeToken = '{"codePoint":57706,"fontFamily":"MaterialIcons"}';
  const check = GeneratedIconDataMetadata(
    token: checkToken,
    codePoint: 57686,
    fontFamily: 'MaterialIcons',
  );
  const close = GeneratedIconDataMetadata(
    token: closeToken,
    codePoint: 57706,
    fontFamily: 'MaterialIcons',
  );
  const catalog = CatalogMetadata(
    previews: <GeneratedPreviewMetadata>[
      GeneratedPreviewMetadata(
        id: 'preview',
        targetName: 'Preview',
        targetImportUri: 'package:example/preview.dart',
        targetKind: GeneratedPreviewTargetKind.classDeclaration,
        name: 'Preview',
        path: 'Preview',
        options: <GeneratedOptionMetadata>[
          GeneratedIconDataOptionMetadata(
            key: 'icon',
            defaultValue: checkToken,
            defaultIcon: check,
            values: <GeneratedOptionValueMetadata<GeneratedIconDataMetadata>>[
              GeneratedOptionValueMetadata<GeneratedIconDataMetadata>(check, label: 'Check'),
              GeneratedOptionValueMetadata<GeneratedIconDataMetadata>(close, label: 'Close'),
            ],
          ),
        ],
      ),
    ],
  );

  test('emits a finite token-to-const IconData switch', () {
    final source = CatalogLibraryEmitter().emit(catalog);

    expect(source, contains("import 'package:flutter/widgets.dart';"));
    expect(source, contains('icon: switch'));
    expect(
      source,
      matches(RegExp(r"const IconData\(\s*57686,\s*fontFamily: 'MaterialIcons',?\s*\)")),
    );
    expect(
      source,
      matches(RegExp(r"const IconData\(\s*57706,\s*fontFamily: 'MaterialIcons',?\s*\)")),
    );
    expect(source, isNot(contains('HippoUiIconDataConverter')));
    expect(createHippoDartFormatter().format(source), source);
  });

  test('keeps icon tokens JSON-safe in the manifest', () {
    final manifest = jsonDecode(const CatalogManifestEmitter().emit(catalog));
    final previews = (manifest as Map<String, Object?>)['previews']! as List<Object?>;
    final preview = previews.single! as Map<String, Object?>;
    final options = preview['options']! as List<Object?>;
    final option = options.single! as Map<String, Object?>;
    final values = option['values']! as List<Object?>;

    expect(option['type'], 'text');
    expect(option['defaultValue'], checkToken);
    expect((values.last! as Map<String, Object?>)['value'], closeToken);
  });
}
