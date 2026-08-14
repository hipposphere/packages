/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'package:uuid/v4.dart' as uuid_v4;

/// Generates UUIDs for caller-owned identifiers.
abstract interface class UuidGenerator {
  /// Generates a random version 4 UUID.
  String generateV4();
}

/// The default [UuidGenerator], backed by a cryptographically secure random UUID source.
final class RandomUuidGenerator implements UuidGenerator {
  const RandomUuidGenerator();

  @override
  String generateV4() => uuid_v4.UuidV4().generate();
}
