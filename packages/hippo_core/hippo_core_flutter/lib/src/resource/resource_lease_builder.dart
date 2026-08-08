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
import 'package:hippo_core/hippo_core.dart';

/// Acquires a resource lease for a mounted widget subtree.
///
/// The lease remains stable across ordinary rebuilds. When [identity] changes,
/// the replacement lease is acquired before the previous lease is released.
/// The active lease is released when this widget leaves the tree.
class ResourceLeaseBuilder<T> extends StatefulWidget {
  const ResourceLeaseBuilder({
    super.key,
    required this.identity,
    required this.acquire,
    required this.builder,
  });

  /// Stable identity of the requested resource.
  final Object identity;

  /// Acquires a lease for [identity].
  final ResourceLease<T> Function() acquire;

  /// Builds with the currently leased resource.
  final Widget Function(BuildContext context, T value) builder;

  @override
  State<ResourceLeaseBuilder<T>> createState() => _ResourceLeaseBuilderState<T>();
}

class _ResourceLeaseBuilderState<T> extends State<ResourceLeaseBuilder<T>> {
  late ResourceLease<T> _lease = widget.acquire();

  @override
  void didUpdateWidget(covariant ResourceLeaseBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.identity == widget.identity) return;
    final previousLease = _lease;
    _lease = widget.acquire();
    previousLease.release();
  }

  @override
  void dispose() {
    _lease.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _lease.value);
}
