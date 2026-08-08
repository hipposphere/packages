/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Creates tickers that request engine frames at a deliberate maximum rate.
///
/// A regular [Ticker] immediately requests another engine frame after every
/// tick. On a high-refresh-rate display that can make a low-frame-rate ambient
/// animation run Flutter's complete frame pipeline much more often than its
/// content requires. Tickers created by this provider park on a timer between
/// target frames, so no engine frame is scheduled during that interval.
///
/// Use this provider with a regular [AnimationController]. The controller still
/// receives timestamps from Flutter frames, preserving its normal wall-clock,
/// curve, status, and future semantics. If a timer fires late, intermediate
/// visual frames are dropped instead of slowing the animation.
///
/// Call [bind] before creating a controller and again from
/// [State.didChangeDependencies]. Binding observes the surrounding [TickerMode]
/// and the refresh rate of the current [FlutterView]. Dispose every controller
/// created with this provider before calling [dispose].
///
/// This limits how frequently the whole Flutter view produces frames. It does
/// not give a widget subtree an independent compositor or make a target rate
/// equal to the display refresh rate cheaper.
final class FrameRateTickerProvider implements TickerProvider {
  /// Creates a provider capped at [framesPerSecond].
  FrameRateTickerProvider({required double framesPerSecond})
    : _framesPerSecond = _validateFramesPerSecond(framesPerSecond);

  final Set<_FrameRateTicker> _tickers = <_FrameRateTicker>{};
  double _framesPerSecond;
  double _displayRefreshRate = 60;
  bool _enabled = true;
  bool _forceFrames = false;
  bool _disposed = false;

  /// The maximum number of ticks requested per second.
  double get framesPerSecond => _framesPerSecond;

  set framesPerSecond(double value) {
    _ensureNotDisposed();
    final validated = _validateFramesPerSecond(value);
    if (_framesPerSecond == validated) {
      return;
    }
    _framesPerSecond = validated;
    _timingDidChange();
  }

  /// Synchronizes this provider with the widget's ticker mode and display.
  ///
  /// This method establishes inherited-widget dependencies and should normally
  /// be called from [State.didChangeDependencies]. Create the associated
  /// [AnimationController] after the first call so a controller mounted below
  /// a disabled [TickerMode] never requests an initial frame.
  void bind(BuildContext context) {
    _ensureNotDisposed();
    final tickerMode = TickerMode.valuesOf(context);
    final refreshRate = View.maybeOf(context)?.display.refreshRate;
    final effectiveRefreshRate = refreshRate != null && refreshRate.isFinite && refreshRate > 0
        ? refreshRate
        : 60.0;
    final timingChanged = _displayRefreshRate != effectiveRefreshRate;

    _displayRefreshRate = effectiveRefreshRate;
    _enabled = tickerMode.enabled;
    _forceFrames = tickerMode.forceFrames;

    for (final ticker in _tickers) {
      ticker
        ..forceFrames = _forceFrames
        ..muted = !_enabled;
    }
    if (timingChanged) {
      _timingDidChange();
    }
  }

  @override
  Ticker createTicker(TickerCallback onTick) {
    _ensureNotDisposed();
    late final _FrameRateTicker ticker;
    ticker = _FrameRateTicker(onTick, provider: this, onDisposed: () => _tickers.remove(ticker))
      ..forceFrames = _forceFrames
      ..muted = !_enabled;
    _tickers.add(ticker);
    return ticker;
  }

  /// Releases this provider after all associated controllers are disposed.
  void dispose() {
    assert(
      _tickers.isEmpty,
      'Dispose every AnimationController created with this '
      'FrameRateTickerProvider before disposing the provider.',
    );
    _disposed = true;
  }

  Duration get _frameInterval => Duration(
    microseconds: (Duration.microsecondsPerSecond / _framesPerSecond).round().clamp(1, 1 << 62),
  );

  Duration get _displayInterval => Duration(
    microseconds: (Duration.microsecondsPerSecond / _displayRefreshRate).round().clamp(1, 1 << 62),
  );

  void _timingDidChange() {
    for (final ticker in _tickers) {
      ticker.timingDidChange();
    }
  }

  void _ensureNotDisposed() {
    if (_disposed) {
      throw StateError('FrameRateTickerProvider has already been disposed.');
    }
  }

  static double _validateFramesPerSecond(double value) {
    if (!value.isFinite || value <= 0) {
      throw ArgumentError.value(value, 'framesPerSecond', 'Must be finite and greater than zero.');
    }
    return value;
  }
}

final class _FrameRateTicker extends Ticker {
  _FrameRateTicker(super.onTick, {required this._provider, required this._onDisposed});

  final FrameRateTickerProvider _provider;
  final VoidCallback _onDisposed;
  Duration? _nextTarget;
  Timer? _delayTimer;
  bool _disposed = false;

  @override
  bool get shouldScheduleTick => super.shouldScheduleTick && _delayTimer == null;

  @override
  void scheduleTick({bool rescheduling = false}) {
    final frameInterval = _provider._frameInterval;
    final displayInterval = _provider._displayInterval;
    if (!rescheduling || frameInterval <= displayInterval) {
      _nextTarget = null;
      super.scheduleTick(rescheduling: rescheduling);
      return;
    }

    final now = SchedulerBinding.instance.currentFrameTimeStamp;
    var target = (_nextTarget ?? now) + frameInterval;
    if (target <= now || target > now + frameInterval) {
      target = now + frameInterval;
    }
    _nextTarget = target;

    final periodMicroseconds = displayInterval.inMicroseconds;
    final periodsBeforeTarget = ((target - now).inMicroseconds - 1) ~/ periodMicroseconds;
    final delay = Duration(microseconds: periodsBeforeTarget * periodMicroseconds);
    if (delay <= Duration.zero) {
      super.scheduleTick(rescheduling: rescheduling);
      return;
    }

    _delayTimer = Timer(delay, () {
      _delayTimer = null;
      if (shouldScheduleTick) {
        super.scheduleTick();
      }
    });
  }

  @override
  void unscheduleTick() {
    _delayTimer?.cancel();
    _delayTimer = null;
    _nextTarget = null;
    super.unscheduleTick();
  }

  void timingDidChange() {
    _nextTarget = null;
    if (_delayTimer == null) {
      return;
    }
    _delayTimer?.cancel();
    _delayTimer = null;
    if (shouldScheduleTick) {
      // Configuration changes may happen outside a frame, where no current
      // frame timestamp exists. Request one immediate vsync, then resume
      // throttling from the timestamp delivered by that frame.
      super.scheduleTick();
    }
  }

  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    super.dispose();
    _onDisposed();
  }
}
