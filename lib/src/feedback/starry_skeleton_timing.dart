import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// Shared skeleton anti-flicker timing state machine.
///
/// Backs both [StarrySkeletonOrContent] and [StarrySliverSkeletonOrContent]:
/// the skeleton is shown only after loading has run longer than the resolved
/// appear delay (so brief loads never flash a skeleton), and — once shown —
/// stays visible for at least the resolved minimum show time (so it never
/// flickers away instantly).
///
/// Host [State] classes mix this in, forward their widget inputs through the
/// abstract getters below, and read [showSkeleton] when building.
mixin StarrySkeletonTiming<T extends StatefulWidget> on State<T> {
  /// Whether the underlying data is currently loading.
  bool get skeletonIsLoading;

  /// Whether the loaded data set is empty.
  bool get skeletonIsEmpty;

  /// When non-null, timers are cancelled and the skeleton is suppressed.
  Object? get skeletonError;

  /// Keep already-rendered non-empty content on screen during a refresh.
  bool get skeletonKeepContentWhileLoading;

  /// Delay before the skeleton may appear; null uses `motion.durationShort`.
  Duration? get skeletonAppearDelay;

  /// Minimum time the skeleton stays visible; null uses `motion.durationLong`.
  Duration? get skeletonMinShowTime;

  Timer? _appearTimer;
  Timer? _minShowTimer;
  DateTime? _skeletonShownAt;
  bool _showSkeleton = false;
  bool _hasShownContentOnce = false;

  late Duration _appearDelay;
  late Duration _minShowTime;

  /// Whether the skeleton should currently be shown. Read this in `build`.
  bool get showSkeleton => _showSkeleton;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resyncFromTokens();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    _resyncFromTokens();
  }

  @override
  void dispose() {
    _appearTimer?.cancel();
    _minShowTimer?.cancel();
    super.dispose();
  }

  void _resyncFromTokens() {
    final motion = Theme.of(context).extension<StarryTokens>()!.motion;
    _appearDelay = skeletonAppearDelay ?? motion.durationShort;
    _minShowTime = skeletonMinShowTime ?? motion.durationLong;
    _syncTimers();
  }

  void _syncTimers() {
    final hasError = skeletonError != null;
    if (hasError) {
      _appearTimer?.cancel();
      _minShowTimer?.cancel();
      _showSkeleton = false;
      _skeletonShownAt = null;
      return;
    }

    final preferContentWhileLoading =
        skeletonKeepContentWhileLoading &&
        _hasShownContentOnce &&
        !skeletonIsEmpty;
    if (preferContentWhileLoading) {
      _appearTimer?.cancel();
      _minShowTimer?.cancel();
      _showSkeleton = false;
      _skeletonShownAt = null;
      return;
    }

    if (skeletonIsLoading) {
      _minShowTimer?.cancel();
      if (_showSkeleton) return;
      if (_appearTimer?.isActive ?? false) return;

      _appearTimer = Timer(_appearDelay, () {
        if (!mounted) return;
        if (!skeletonIsLoading || skeletonError != null) return;
        setState(() {
          _showSkeleton = true;
          _skeletonShownAt = DateTime.now();
        });
      });
      return;
    }

    _appearTimer?.cancel();
    if (!_showSkeleton) {
      _hasShownContentOnce = !skeletonIsEmpty;
      return;
    }

    final shownAt = _skeletonShownAt;
    if (shownAt == null) {
      _showSkeleton = false;
      _hasShownContentOnce = !skeletonIsEmpty;
      return;
    }

    final elapsed = DateTime.now().difference(shownAt);
    final remaining = _minShowTime - elapsed;
    if (remaining <= Duration.zero) {
      _showSkeleton = false;
      _skeletonShownAt = null;
      _hasShownContentOnce = !skeletonIsEmpty;
      return;
    }

    if (_minShowTimer?.isActive ?? false) return;
    _minShowTimer = Timer(remaining, () {
      if (!mounted) return;
      if (skeletonError != null) return;
      setState(() {
        _showSkeleton = false;
        _skeletonShownAt = null;
        _hasShownContentOnce = !skeletonIsEmpty;
      });
    });
  }
}
