/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'frame_rate_ticker_provider.dart';

/// Supplies frame-rate-limited tickers to a [State].
///
/// This is the frame-limited counterpart to [TickerProviderStateMixin]. It
/// binds its tickers to the surrounding [TickerMode] and current display, and
/// disposes its underlying [FrameRateTickerProvider] automatically.
///
/// Override [tickerFramesPerSecond] when a rate other than 30 frames per second
/// is needed. Dispose every [AnimationController] created with this mixin before
/// calling `super.dispose()`.
///
/// Start animations after `super.didChangeDependencies()` so the provider is
/// bound before the first frame is requested.
mixin FrameRateTickerProviderStateMixin<T extends StatefulWidget> on State<T>
    implements TickerProvider {
  FrameRateTickerProvider? _frameRateTickerProvider;

  /// The maximum number of ticker callbacks requested per second.
  @protected
  double get tickerFramesPerSecond => 30;

  FrameRateTickerProvider get _tickerProvider =>
      _frameRateTickerProvider ??= FrameRateTickerProvider(framesPerSecond: tickerFramesPerSecond);

  @override
  Ticker createTicker(TickerCallback onTick) => _tickerProvider.createTicker(onTick);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _synchronizeTickerProvider();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    _frameRateTickerProvider?.framesPerSecond = tickerFramesPerSecond;
  }

  void _synchronizeTickerProvider() {
    _tickerProvider
      ..framesPerSecond = tickerFramesPerSecond
      ..bind(context);
  }

  @override
  void dispose() {
    _frameRateTickerProvider?.dispose();
    super.dispose();
  }
}
