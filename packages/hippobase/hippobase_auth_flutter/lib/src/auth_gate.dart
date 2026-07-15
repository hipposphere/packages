import 'dart:async';

import 'package:flutter/widgets.dart';

import 'auth_controller.dart';
import 'session.dart';
import 'state.dart';

/// Resolves app dependencies as the user moves between auth states.
final class HippobaseAuthGate<TAuthenticated, TUnauthenticated> extends StatefulWidget {
  const HippobaseAuthGate({
    super.key,
    required this.controller,
    required this.createAuthenticated,
    required this.createUnauthenticated,
    required this.authenticatedBuilder,
    required this.unauthenticatedBuilder,
    required this.loadingBuilder,
    required this.errorBuilder,
  });

  final HippobaseAuthController controller;
  final FutureOr<TAuthenticated> Function(HippobaseAuthSession session) createAuthenticated;
  final FutureOr<TUnauthenticated> Function() createUnauthenticated;
  final Widget Function(BuildContext, TAuthenticated, HippobaseAuthSession) authenticatedBuilder;
  final Widget Function(BuildContext, TUnauthenticated) unauthenticatedBuilder;
  final WidgetBuilder loadingBuilder;
  final Widget Function(BuildContext, HippobaseAuthFailure) errorBuilder;

  @override
  State<HippobaseAuthGate<TAuthenticated, TUnauthenticated>> createState() =>
      _HippobaseAuthGateState<TAuthenticated, TUnauthenticated>();
}

final class _HippobaseAuthGateState<TAuthenticated, TUnauthenticated>
    extends State<HippobaseAuthGate<TAuthenticated, TUnauthenticated>> {
  StreamSubscription<HippobaseAuthState>? _subscription;
  int _revision = 0;
  _GatePhase _phase = _GatePhase.loading;
  Object? _data;
  HippobaseAuthSession? _session;
  HippobaseAuthFailure? _failure;

  @override
  void initState() {
    super.initState();
    _subscribe();
    _handle(widget.controller.state.value);
  }

  @override
  void didUpdateWidget(covariant HippobaseAuthGate<TAuthenticated, TUnauthenticated> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _subscription?.cancel();
      _subscribe();
      _handle(widget.controller.state.value);
    }
  }

  void _subscribe() {
    _subscription = widget.controller.state.stream.skip(1).listen(_handle);
  }

  void _handle(HippobaseAuthState state) {
    final revision = ++_revision;
    switch (state) {
      case HippobaseAuthLoading():
        _set(_GatePhase.loading);
      case HippobaseAuthFailure():
        _set(_GatePhase.error, failure: state);
      case HippobaseAuthenticated(:final session):
        _resolveAuthenticated(revision, session);
      case HippobaseUnauthenticated():
        _resolveUnauthenticated(revision);
    }
  }

  Future<void> _resolveAuthenticated(int revision, HippobaseAuthSession session) async {
    _set(_GatePhase.loading);
    try {
      final data = await Future<TAuthenticated>.sync(() => widget.createAuthenticated(session));
      if (mounted && revision == _revision) {
        _set(_GatePhase.authenticated, data: data, session: session);
      }
    } catch (error) {
      if (mounted && revision == _revision) {
        _set(_GatePhase.error, failure: HippobaseAuthFailure(error));
      }
    }
  }

  Future<void> _resolveUnauthenticated(int revision) async {
    _set(_GatePhase.loading);
    try {
      final data = await Future<TUnauthenticated>.sync(widget.createUnauthenticated);
      if (mounted && revision == _revision) {
        _set(_GatePhase.unauthenticated, data: data);
      }
    } catch (error) {
      if (mounted && revision == _revision) {
        _set(_GatePhase.error, failure: HippobaseAuthFailure(error));
      }
    }
  }

  void _set(
    _GatePhase phase, {
    Object? data,
    HippobaseAuthSession? session,
    HippobaseAuthFailure? failure,
  }) {
    void update() {
      _phase = phase;
      _data = data;
      _session = session;
      _failure = failure;
    }

    if (mounted) {
      setState(update);
    } else {
      update();
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (_phase) {
      _GatePhase.loading => widget.loadingBuilder(context),
      _GatePhase.error => widget.errorBuilder(context, _failure!),
      _GatePhase.authenticated => widget.authenticatedBuilder(
        context,
        _data as TAuthenticated,
        _session!,
      ),
      _GatePhase.unauthenticated => widget.unauthenticatedBuilder(
        context,
        _data as TUnauthenticated,
      ),
    };
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

enum _GatePhase { loading, authenticated, unauthenticated, error }
