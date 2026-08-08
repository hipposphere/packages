/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

/// A temporary claim on a reusable resource.
///
/// A lease keeps its resource protected according to the policy of the owner
/// that issued it. Call [release] as soon as the resource is no longer in use.
/// Releasing a lease more than once is safe.
abstract interface class ResourceLease<T> {
  /// The leased resource.
  ///
  /// Throws a [StateError] after this lease has been released or invalidated
  /// by its owner.
  T get value;

  /// Whether this lease can no longer provide or protect its resource.
  bool get isReleased;

  /// Releases this claim on the resource.
  void release();
}
