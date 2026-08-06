import 'package:flutter/material.dart';

import 'starry_skeleton_timing.dart';

/// Declarative loading / empty / error / content switch with skeleton
/// anti-flicker timing.
///
/// Shows [skeletonBuilder] only after the content has been loading longer than
/// [appearDelay] (so brief loads never flash a skeleton), and — once shown —
/// keeps the skeleton visible for at least [minShowTime] (so it never flickers
/// away instantly). When [keepContentWhileLoading] is true a refresh over
/// already-rendered non-empty content keeps the content on screen instead of
/// dropping back to the skeleton.
///
/// Resolution order: [error] → skeleton (while loading) → empty → content.
class StarrySkeletonOrContent extends StatefulWidget {
  const StarrySkeletonOrContent({
    required this.isLoading,
    required this.isEmpty,
    required this.skeletonBuilder,
    required this.contentBuilder,
    super.key,
    this.error,
    this.onRetry,
    this.emptyBuilder,
    this.errorBuilder,
    this.keepContentWhileLoading = true,
    this.appearDelay,
    this.minShowTime,
  });

  /// Whether the underlying data is currently loading.
  final bool isLoading;

  /// Whether the loaded data set is empty.
  final bool isEmpty;

  /// When non-null, the error branch renders instead of any other state.
  final Object? error;

  /// Optional retry callback forwarded to [errorBuilder] consumers.
  final VoidCallback? onRetry;

  /// Builds the skeleton placeholder shown while loading.
  final WidgetBuilder skeletonBuilder;

  /// Builds the real content once data is available.
  final WidgetBuilder contentBuilder;

  /// Builds the empty-state view. Falls back to [SizedBox.shrink] when null.
  final WidgetBuilder? emptyBuilder;

  /// Builds the error view. Falls back to [SizedBox.shrink] when null.
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  /// Keep already-rendered non-empty content on screen during a refresh.
  final bool keepContentWhileLoading;

  /// Delay before the skeleton is allowed to appear.
  ///
  /// Defaults to `motion.durationShort` (150ms) when null.
  final Duration? appearDelay;

  /// Minimum time the skeleton stays visible once shown.
  ///
  /// Defaults to `motion.durationLong` (500ms) when null.
  final Duration? minShowTime;

  @override
  State<StarrySkeletonOrContent> createState() =>
      _StarrySkeletonOrContentState();
}

class _StarrySkeletonOrContentState extends State<StarrySkeletonOrContent>
    with StarrySkeletonTiming<StarrySkeletonOrContent> {
  @override
  bool get skeletonIsLoading => widget.isLoading;
  @override
  bool get skeletonIsEmpty => widget.isEmpty;
  @override
  Object? get skeletonError => widget.error;
  @override
  bool get skeletonKeepContentWhileLoading => widget.keepContentWhileLoading;
  @override
  Duration? get skeletonAppearDelay => widget.appearDelay;
  @override
  Duration? get skeletonMinShowTime => widget.minShowTime;

  @override
  Widget build(BuildContext context) {
    final error = widget.error;
    if (error != null) {
      final builder = widget.errorBuilder;
      if (builder != null) return builder(context, error);
      return const SizedBox.shrink();
    }

    if (showSkeleton && widget.isLoading) {
      return widget.skeletonBuilder(context);
    }

    if (widget.isEmpty) {
      final builder = widget.emptyBuilder;
      return builder?.call(context) ?? const SizedBox.shrink();
    }

    return widget.contentBuilder(context);
  }
}
