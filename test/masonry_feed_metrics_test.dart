import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

void main() {
  test('compact, intermediate and wide geometry use the agreed endpoints', () {
    for (final (width, outer, column, row, radius) in [
      (390.0, 4.0, 4.0, 4.0, 4.0),
      (480.0, 4.0, 4.0, 4.0, 4.0),
      (840.0, 14.0, 14.0, 8.0, 10.0),
      (1200.0, 24.0, 24.0, 12.0, 16.0),
      (1800.0, 24.0, 24.0, 12.0, 16.0),
    ]) {
      final metrics = MasonryFeedMetrics.resolve(width);
      expect(
        (
          metrics.outerInset,
          metrics.columnGap,
          metrics.rowGap,
          metrics.cardRadius,
        ),
        (outer, column, row, radius),
        reason: 'width $width',
      );
    }
    final phone = MasonryFeedMetrics.resolve(390);
    expect(phone.columns, 2);
    expect(phone.gridInset, 4);
    expect(phone.cardWidth, 189);
  });

  test('resize grows the gaps and radius smoothly near both endpoints', () {
    final afterCompact = MasonryFeedMetrics.resolve(481);
    final beforeWide = MasonryFeedMetrics.resolve(1199);
    expect(afterCompact.outerInset, inExclusiveRange(4, 4.01));
    expect(beforeWide.outerInset, inExclusiveRange(23.99, 24));
    for (final (width, progress) in [(660.0, 0.15625), (1020.0, 0.84375)]) {
      expect(MasonryFeedMetrics.resolve(width).densityProgress, progress);
    }
  });

  test('expansion uses the resolved column gap and preserves desktop caps', () {
    // At 880 three target-width cards fit with the responsive gap and inset;
    // they would not fit with the old 24-pixel gap and inset.
    expect(MasonryFeedMetrics.resolve(880).columns, 3);
    expect(MasonryFeedMetrics.resolve(1195).columns, 3);
    expect(MasonryFeedMetrics.resolve(1196).columns, 4);
    expect(MasonryFeedMetrics.resolve(1488.999).columns, 4);
    expect(MasonryFeedMetrics.resolve(1489).columns, 5);
    final wide = MasonryFeedMetrics.resolve(1800);
    expect(wide.cardWidth, masonryFeedTargetCardWidth);
    expect(wide.gridInset, greaterThan(wide.outerInset));
    expect(wide.gridWidth + 2 * wide.gridInset, 1800);
  });

  test('management cards fit one to four columns and remain centered', () {
    for (final (width, columns) in [
      (320.0, 1),
      (760.0, 2),
      (1080.0, 3),
      (1600.0, 4),
    ]) {
      final metrics = MasonryFeedMetrics.resolve(
        width,
        minimumColumns: 1,
        maximumColumns: 4,
      );
      expect(metrics.columns, columns);
      expect(metrics.cardWidth, greaterThan(0));
      expect(metrics.gridWidth + 2 * metrics.gridInset, closeTo(width, 0.001));
      expect(
        metrics.frameWidth + 2 * metrics.frameInset,
        closeTo(width, 0.001),
      );
    }
  });

  test('collapsed or invalid width has no usable grid', () {
    for (final width in [0.0, 1.0, 10.0, -500.0, double.infinity, double.nan]) {
      final metrics = MasonryFeedMetrics.resolve(width);
      expect(metrics.columns, 2);
      expect(metrics.cardWidth, 0);
      expect(metrics.gridWidth, 0);
      expect(metrics.gridInset, greaterThanOrEqualTo(0));
      expect(metrics.frameInset, greaterThanOrEqualTo(0));
    }
  });
}
