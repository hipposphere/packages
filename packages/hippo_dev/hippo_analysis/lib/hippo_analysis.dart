/*
// ---------------------------------------------------------------------------
// Copyright (c) 2026 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

import 'package:dart_style/dart_style.dart';

/// The page width used by Hipposphere analysis options and code generators.
const hippoFormatterPageWidth = 100;

/// The trailing-comma behavior used by Hipposphere formatters.
const hippoFormatterTrailingCommas = TrailingCommas.automate;

/// Creates a formatter using the shared Hipposphere formatting policy.
DartFormatter createHippoDartFormatter({int? pageWidth, TrailingCommas? trailingCommas}) {
  return DartFormatter(
    languageVersion: DartFormatter.latestLanguageVersion,
    pageWidth: pageWidth ?? hippoFormatterPageWidth,
    trailingCommas: trailingCommas ?? hippoFormatterTrailingCommas,
  );
}
