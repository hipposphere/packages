/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'package:build/build.dart';
import 'package:glob/glob.dart';

import 'annotation_catalog_reader.dart';
import 'catalog_library_emitter.dart';
import 'catalog_manifest_emitter.dart';

class HippoUiCatalogBuilder implements Builder {
  HippoUiCatalogBuilder({
    AnnotationCatalogReader? reader,
    CatalogLibraryEmitter? emitter,
    CatalogManifestEmitter? manifestEmitter,
  }) : _reader = reader ?? const AnnotationCatalogReader(),
       _emitter = emitter ?? CatalogLibraryEmitter(),
       _manifestEmitter = manifestEmitter ?? const CatalogManifestEmitter();

  static final Glob _dartSources = Glob('lib/**.dart');

  final AnnotationCatalogReader _reader;
  final CatalogLibraryEmitter _emitter;
  final CatalogManifestEmitter _manifestEmitter;

  @override
  final Map<String, List<String>> buildExtensions = const <String, List<String>>{
    r'$lib$': <String>['hippo_ui_catalog.g.dart', 'hippo_ui_catalog.manifest.json'],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final catalog = await _reader.readPackageCatalog(
      buildStep,
      await _sourceLibraries(buildStep).toList(),
    );

    await buildStep.writeAsString(
      AssetId(buildStep.inputId.package, 'lib/hippo_ui_catalog.g.dart'),
      _emitter.emit(catalog),
    );
    await buildStep.writeAsString(
      AssetId(buildStep.inputId.package, 'lib/hippo_ui_catalog.manifest.json'),
      _manifestEmitter.emit(catalog),
    );
  }

  Stream<AssetId> _sourceLibraries(BuildStep buildStep) async* {
    await for (final asset in buildStep.findAssets(_dartSources)) {
      if (_isGeneratedCatalog(asset)) {
        continue;
      }
      if (await buildStep.resolver.isLibrary(asset)) {
        yield asset;
      }
    }
  }

  bool _isGeneratedCatalog(AssetId asset) {
    return asset.path.endsWith('.g.dart') || asset.path.endsWith('.hippo_ui.g.dart');
  }
}
