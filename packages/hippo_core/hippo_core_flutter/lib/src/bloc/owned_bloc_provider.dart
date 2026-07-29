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

import 'bloc_provider.dart';

/// Creates, exposes, and disposes one [BlocBase] for a mounted widget subtree.
///
/// The bloc is created once when this provider enters the tree, remains stable
/// across rebuilds, and is disposed when the provider leaves the tree. Use
/// [BlocProvider] instead when the bloc is owned by a longer-lived caller.
///
/// A route can use [OwnedBlocProvider.builder] to keep its page stateless while
/// scoping mutable form or flow state to the mounted route:
///
/// ```dart
/// OwnedBlocProvider<EditorBloc>.builder(
///   create: EditorBloc.new,
///   builder: (context, bloc) => EditorPage(bloc: bloc),
/// )
/// ```
class OwnedBlocProvider<T extends BlocBase> extends StatefulWidget {
  /// Creates an owned bloc and exposes it to [child].
  const OwnedBlocProvider({super.key, required this.create, required Widget this.child})
    : builder = null;

  /// Creates an owned bloc and passes it to [builder].
  ///
  /// The builder runs below the corresponding [BlocProvider], so both the
  /// provided [T] and [BlocProvider.of] resolve to the same instance.
  const OwnedBlocProvider.builder({
    super.key,
    required this.create,
    required Widget Function(BuildContext context, T bloc) this.builder,
  }) : child = null;

  /// Creates the bloc owned by this provider.
  final T Function() create;

  /// Static subtree exposed to the owned bloc.
  final Widget? child;

  /// Builds a subtree with the owned bloc.
  final Widget Function(BuildContext context, T bloc)? builder;

  @override
  State<OwnedBlocProvider<T>> createState() => _OwnedBlocProviderState<T>();
}

class _OwnedBlocProviderState<T extends BlocBase> extends State<OwnedBlocProvider<T>> {
  late final T _bloc = widget.create();

  @override
  Widget build(BuildContext context) {
    final Widget Function(BuildContext context, T bloc)? builder = widget.builder;

    return BlocProvider<T>(
      bloc: _bloc,
      child: builder == null
          ? widget.child!
          : Builder(builder: (BuildContext context) => builder(context, _bloc)),
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}
