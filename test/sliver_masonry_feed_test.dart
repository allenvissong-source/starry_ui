import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

Widget _harness({required int itemCount}) {
  // Fill the whole (resized) test viewport so the feed's cross-axis extent
  // equals the window width. Cards' global x-positions then equal their column
  // offsets, letting the test count columns by distinct left edges.
  return Directionality(
    textDirection: TextDirection.ltr,
    child: MediaQuery(
      data: const MediaQueryData(),
      child: CustomScrollView(
        slivers: [
          SliverMasonryFeed(
            itemCount: itemCount,
            itemBuilder: (context, index) => SizedBox(
              key: ValueKey('card_$index'),
              height: 100 + (index % 3) * 40,
              child: const ColoredBox(color: Color(0xFF112233)),
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> _pumpAtWidth(
  WidgetTester tester, {
  required double width,
  required int itemCount,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(width, 800);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(_harness(itemCount: itemCount));
  await tester.pump();
}

void main() {
  testWidgets('column count matches metrics across widths', (tester) async {
    for (final width in <double>[600, 900, 1200, 1600]) {
      final metrics = MasonryFeedMetrics.resolve(width);
      await _pumpAtWidth(tester, width: width, itemCount: 12);

      // Collect the horizontal centers of rendered cards near the top of the
      // grid; the number of distinct x-columns must equal metrics.columns.
      final xs = <double>{};
      for (var i = 0; i < 12; i++) {
        final finder = find.byKey(ValueKey('card_$i'));
        if (finder.evaluate().isEmpty) continue;
        final box = tester.getTopLeft(finder);
        xs.add(double.parse(box.dx.toStringAsFixed(1)));
      }
      // Distinct left-edge positions correspond to columns.
      expect(
        xs.length,
        metrics.columns,
        reason: 'width=$width expected ${metrics.columns} columns, got $xs',
      );
    }
  });

  testWidgets('collapsed cross-axis extent renders empty without asserting', (
    tester,
  ) async {
    await _pumpAtWidth(tester, width: 0, itemCount: 12);
    // No "negative minimum width" assertion should be thrown; no cards render.
    expect(find.byKey(const ValueKey('card_0')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
