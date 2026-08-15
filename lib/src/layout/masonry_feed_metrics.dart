import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// Target card width used to reverse-derive the masonry column count.
@visibleForTesting
const double masonryFeedTargetCardWidth = 269;

/// Horizontal gap between masonry columns.
const double masonryFeedColumnGap = 24;

/// Outer inset applied on both sides of the masonry frame.
@visibleForTesting
const double masonryFeedOuterInset = masonryFeedColumnGap;

/// Vertical gap between stacked cards within a column.
const double masonryFeedRowGap = 12;

@visibleForTesting
double masonryFeedMinGridWidthForColumns(int columns) {
  if (columns <= 0) return 0;
  return masonryFeedTargetCardWidth * columns +
      masonryFeedColumnGap * (columns - 1);
}

@visibleForTesting
int masonryFeedColumnCountForWidth(double width) {
  final safeWidth = width.isFinite ? math.max(0.0, width) : 0.0;
  if (safeWidth >= masonryFeedMinGridWidthForColumns(5)) return 5;
  if (safeWidth >= masonryFeedMinGridWidthForColumns(4)) return 4;
  if (safeWidth >= masonryFeedMinGridWidthForColumns(3)) return 3;
  return 2;
}

@visibleForTesting
double masonryFeedColumnWidthForWidth(double width) {
  final safeWidth = width.isFinite ? math.max(0.0, width) : 0.0;
  final columns = masonryFeedColumnCountForWidth(safeWidth);
  final gaps = masonryFeedColumnGap * (columns - 1);
  final targetGridWidth = masonryFeedTargetCardWidth * columns + gaps;
  if (targetGridWidth <= safeWidth) return masonryFeedTargetCardWidth;
  return ((safeWidth - gaps) / columns)
      .clamp(0, masonryFeedTargetCardWidth)
      .toDouble();
}

@visibleForTesting
double masonryFeedGridWidthForWidth(double width) {
  final safeWidth = width.isFinite ? math.max(0.0, width) : 0.0;
  final columns = masonryFeedColumnCountForWidth(safeWidth);
  return masonryFeedColumnWidthForWidth(safeWidth) * columns +
      masonryFeedColumnGap * (columns - 1);
}

/// Resolved masonry layout geometry for a given available content width.
///
/// Pure value object with zero domain dependencies: it only knows how wide the
/// content area is and how a masonry grid should be centered inside it. Column
/// count is reverse-derived from [masonryFeedTargetCardWidth] rather than from
/// any breakpoint enum, so callers do not need a [BuildContext].
@immutable
class MasonryFeedMetrics {
  const MasonryFeedMetrics({
    required this.contentWidth,
    required this.frameWidth,
    required this.frameInset,
    required this.gridWidth,
    required this.gridInset,
    required this.columns,
    required this.cardWidth,
  });

  final double contentWidth;
  final double frameWidth;
  final double frameInset;
  final double gridWidth;
  final double gridInset;
  final int columns;
  final double cardWidth;

  static MasonryFeedMetrics resolve(double contentWidth) {
    final safeContentWidth = contentWidth.isFinite
        ? math.max(0.0, contentWidth)
        : 0.0;
    final usableGridWidth = math.max(
      0.0,
      safeContentWidth - masonryFeedOuterInset * 2,
    );
    final columns = masonryFeedColumnCountForWidth(usableGridWidth);
    final cardWidth = masonryFeedColumnWidthForWidth(usableGridWidth);
    final gridWidth = masonryFeedGridWidthForWidth(usableGridWidth);
    final frameWidth = math.min(
      safeContentWidth,
      gridWidth + masonryFeedOuterInset * 2,
    );

    return MasonryFeedMetrics(
      contentWidth: safeContentWidth,
      frameWidth: frameWidth,
      frameInset: math.max(0.0, (safeContentWidth - frameWidth) / 2),
      gridWidth: gridWidth,
      gridInset: math.max(0.0, (safeContentWidth - gridWidth) / 2),
      columns: columns,
      cardWidth: cardWidth,
    );
  }
}
