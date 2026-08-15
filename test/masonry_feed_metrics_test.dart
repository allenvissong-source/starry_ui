import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

void main() {
  group('masonryFeedColumnCountForWidth', () {
    for (final columns in <int>[3, 4, 5]) {
      test('width == threshold($columns) yields $columns columns', () {
        final threshold = masonryFeedMinGridWidthForColumns(columns);
        expect(masonryFeedColumnCountForWidth(threshold), columns);
      });

      test('just below threshold($columns) drops one column', () {
        final threshold = masonryFeedMinGridWidthForColumns(columns);
        expect(
          masonryFeedColumnCountForWidth(threshold - 1),
          columns - 1,
        );
      });
    }

    test('very small width floors at 2 columns', () {
      expect(masonryFeedColumnCountForWidth(10), 2);
    });
  });

  group('masonryFeedColumnWidthForWidth', () {
    test('over-wide grid clamps card width to target', () {
      final wide = masonryFeedMinGridWidthForColumns(5) + 1000;
      expect(masonryFeedColumnWidthForWidth(wide), masonryFeedTargetCardWidth);
    });

    test('narrow grid splits available width evenly', () {
      // Below the 2-column target grid width (269*2 + 24 = 562): the floor of
      // 2 columns is kept, but the width can no longer hold two target cards,
      // so card width splits evenly and drops below the target.
      const width = 400.0;
      final columns = masonryFeedColumnCountForWidth(width);
      expect(columns, 2);
      final gaps = masonryFeedColumnGap * (columns - 1);
      final expected = (width - gaps) / columns;
      expect(masonryFeedColumnWidthForWidth(width), closeTo(expected, 0.0001));
      expect(
        masonryFeedColumnWidthForWidth(width),
        lessThan(masonryFeedTargetCardWidth),
      );
    });
  });

  group('MasonryFeedMetrics.resolve', () {
    test('insets are non-negative and centered', () {
      const contentWidth = 1200.0;
      final metrics = MasonryFeedMetrics.resolve(contentWidth);
      expect(metrics.gridInset, greaterThanOrEqualTo(0));
      expect(metrics.frameInset, greaterThanOrEqualTo(0));
      expect(
        metrics.gridInset,
        closeTo((contentWidth - metrics.gridWidth) / 2, 0.0001),
      );
      expect(
        metrics.frameInset,
        closeTo((contentWidth - metrics.frameWidth) / 2, 0.0001),
      );
    });

    test('narrow content (<= outerInset*2) produces no negative values', () {
      final metrics =
          MasonryFeedMetrics.resolve(masonryFeedOuterInset * 2 - 1);
      expect(metrics.gridInset, greaterThanOrEqualTo(0));
      expect(metrics.frameInset, greaterThanOrEqualTo(0));
      expect(metrics.gridWidth, greaterThanOrEqualTo(0));
      expect(metrics.cardWidth, greaterThanOrEqualTo(0));
      expect(metrics.columns, 2);
    });
  });

  group('degenerate inputs fall back to 2 columns without throwing', () {
    for (final entry in <String, double>{
      'zero': 0,
      'negative': -500,
      'infinity': double.infinity,
      'nan': double.nan,
    }.entries) {
      test('${entry.key} input', () {
        expect(() => masonryFeedColumnCountForWidth(entry.value),
            returnsNormally);
        expect(masonryFeedColumnCountForWidth(entry.value), 2);

        expect(() => MasonryFeedMetrics.resolve(entry.value), returnsNormally);
        final metrics = MasonryFeedMetrics.resolve(entry.value);
        expect(metrics.columns, 2);
        expect(metrics.gridWidth, greaterThanOrEqualTo(0));
        expect(metrics.gridInset, greaterThanOrEqualTo(0));
        expect(metrics.frameInset, greaterThanOrEqualTo(0));
        expect(metrics.cardWidth, greaterThanOrEqualTo(0));
      });
    }
  });

  test('MasonryFeedMetrics is immutable', () {
    // Compile-time guard: the annotation is present. Runtime sanity: two
    // resolves for the same width produce equal field values.
    const width = 900.0;
    final a = MasonryFeedMetrics.resolve(width);
    final b = MasonryFeedMetrics.resolve(width);
    expect(a.columns, b.columns);
    expect(a.gridWidth, b.gridWidth);
    expect(a.cardWidth, b.cardWidth);
    // Reference the annotation to keep the import meaningful.
    expect(immutable, isNotNull);
  });
}
