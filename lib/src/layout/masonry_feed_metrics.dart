import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../theme/starry_tokens.dart';

/// Target card width used to reverse-derive the masonry column count.
const double masonryFeedTargetCardWidth = 269;

/// Resolved masonry layout geometry for a given available content width.
///
/// Gaps and radius share a continuous transition between compact and wide
/// geometry. The column count is derived separately from the available space.
@immutable
class MasonryFeedMetrics {
  const MasonryFeedMetrics._({
    required this.contentWidth,
    required this.densityProgress,
    required this.outerInset,
    required this.columnGap,
    required this.rowGap,
    required this.cardRadius,
    required this.frameWidth,
    required this.frameInset,
    required this.gridWidth,
    required this.gridInset,
    required this.columns,
    required this.cardWidth,
  });

  static const double _compactContentWidth = 480;
  static const _breakpoints = StarryBreakpoints();

  final double contentWidth;
  final double densityProgress;
  final double outerInset;
  final double columnGap;
  final double rowGap;
  final double cardRadius;
  final double frameWidth;
  final double frameInset;
  final double gridWidth;
  final double gridInset;
  final int columns;
  final double cardWidth;

  static MasonryFeedMetrics resolve(
    double contentWidth, {
    int minimumColumns = 2,
    int maximumColumns = 5,
  }) {
    assert(minimumColumns >= 1 && maximumColumns >= minimumColumns);
    final safeContentWidth = contentWidth.isFinite
        ? math.max(0.0, contentWidth)
        : 0.0;
    final fraction =
        ((safeContentWidth - _compactContentWidth) /
                (_breakpoints.expanded - _compactContentWidth))
            .clamp(0.0, 1.0);
    final progress = fraction * fraction * (3 - 2 * fraction);
    double interpolate(double compact, double wide) =>
        compact + (wide - compact) * progress;

    const compactSpacing = StarrySpacingTokens.s1;
    const radius = StarryRadius();
    final outerInset = interpolate(compactSpacing, StarrySpacingTokens.s6);
    final columnGap = interpolate(compactSpacing, StarrySpacingTokens.s6);
    final rowGap = interpolate(compactSpacing, StarrySpacingTokens.s3);
    final usableGridWidth = math.max(0.0, safeContentWidth - outerInset * 2);
    final columnsFitting =
        ((usableGridWidth + columnGap) /
                (masonryFeedTargetCardWidth + columnGap))
            .floor();
    final columns = columnsFitting.clamp(minimumColumns, maximumColumns);
    final gaps = columnGap * (columns - 1);
    final cardWidth = ((usableGridWidth - gaps) / columns)
        .clamp(0, masonryFeedTargetCardWidth)
        .toDouble();
    final gridWidth = cardWidth <= 0 ? 0.0 : cardWidth * columns + gaps;
    final frameWidth = math.min(safeContentWidth, gridWidth + outerInset * 2);

    return MasonryFeedMetrics._(
      contentWidth: safeContentWidth,
      densityProgress: progress,
      outerInset: outerInset,
      columnGap: columnGap,
      rowGap: rowGap,
      cardRadius: interpolate(radius.xs, radius.lg),
      frameWidth: frameWidth,
      frameInset: math.max(0.0, (safeContentWidth - frameWidth) / 2),
      gridWidth: gridWidth,
      gridInset: math.max(0.0, (safeContentWidth - gridWidth) / 2),
      columns: columns,
      cardWidth: cardWidth,
    );
  }
}
