import 'package:flutter/material.dart';

import 'starry_skeleton_or_content.dart';
import 'starry_skeleton_timing.dart';

/// Sliver variant of [StarrySkeletonOrContent].
///
/// Same loading / empty / error / content switch and anti-flicker timing, but
/// every branch builds a sliver so it can live directly inside a
/// [CustomScrollView]. Falls back to an empty [SliverToBoxAdapter] when an
/// optional branch builder is not supplied.
///
/// Resolution order: [error] → skeleton (while loading) → empty → content.
class StarrySliverSkeletonOrContent extends StatefulWidget {
  const StarrySliverSkeletonOrContent({
    required this.isLoading,
    required this.isEmpty,
    required this.skeletonSliverBuilder,
    required this.contentSliverBuilder,
    super.key,
    this.error,
    this.emptySliverBuilder,
    this.errorSliverBuilder,
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

  /// Builds the skeleton sliver shown while loading.
  final WidgetBuilder skeletonSliverBuilder;

  /// Builds the real content sliver once data is available.
  final WidgetBuilder contentSliverBuilder;

  /// Builds the empty-state sliver. Falls back to an empty sliver when null.
  final WidgetBuilder? emptySliverBuilder;

  /// Builds the error sliver. Falls back to an empty sliver when null.
  final Widget Function(BuildContext context, Object error)? errorSliverBuilder;

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
  State<StarrySliverSkeletonOrContent> createState() =>
      _StarrySliverSkeletonOrContentState();
}

class _StarrySliverSkeletonOrContentState
    extends State<StarrySliverSkeletonOrContent>
    with StarrySkeletonTiming<StarrySliverSkeletonOrContent> {
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
      final builder = widget.errorSliverBuilder;
      return builder?.call(context, error) ?? const SliverToBoxAdapter();
    }

    if (showSkeleton && widget.isLoading) {
      return widget.skeletonSliverBuilder(context);
    }

    if (widget.isEmpty) {
      final builder = widget.emptySliverBuilder;
      return builder?.call(context) ?? const SliverToBoxAdapter();
    }

    return widget.contentSliverBuilder(context);
  }
}
