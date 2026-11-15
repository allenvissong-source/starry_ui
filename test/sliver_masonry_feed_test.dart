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
  testWidgets('multi-row leading feed never rewinds its following section', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1100, 500);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: CustomScrollView(
          controller: controller,
          slivers: [
            SliverMainAxisGroup(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 64)),
                SliverMasonryFeed(
                  minimumColumns: 1,
                  maximumColumns: 4,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 9,
                  itemBuilder: (_, i) => SizedBox(height: 200 + i % 3 * 160),
                ),
              ],
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 1500)),
          ],
        ),
      ),
    );
    for (final offset in [
      for (var i = 1; i <= 22; i++) i * 100.0,
      for (var i = 21; i >= 0; i--) i * 100.0,
    ]) {
      controller.jumpTo(offset);
      await tester.pumpAndSettle();
      expect(controller.offset, offset);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('uneven multi-row sections survive jumps across their boundary', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 500);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final width in [600.0, 900.0, 1200.0, 1600.0]) {
      tester.view.physicalSize = Size(width, 500);
      for (final count in [5, 9, 17, 60]) {
        final controller = ScrollController();
        final metrics = MasonryFeedMetrics.resolve(
          width,
          minimumColumns: 1,
          maximumColumns: 4,
        );
        double height(int i) => i == 0 ? 1000 : 190 + i % 3 * 90.0;
        final ends = List.filled(metrics.columns, 0.0);
        for (var i = 0; i < count; i++) {
          var column = 0;
          for (var j = 1; j < ends.length; j++) {
            if (ends[j] < ends[column]) column = j;
          }
          ends[column] += height(i) + masonryFeedRowGap;
        }
        final boundary =
            64 + ends.reduce((a, b) => a > b ? a : b) - masonryFeedRowGap;
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: CustomScrollView(
              controller: controller,
              slivers: [
                SliverMainAxisGroup(
                  slivers: [
                    const SliverToBoxAdapter(child: SizedBox(height: 64)),
                    SliverMasonryFeed(
                      minimumColumns: 1,
                      maximumColumns: 4,
                      itemCount: count,
                      itemBuilder: (_, i) => SizedBox(
                        key: ValueKey('uneven_$i'),
                        height: height(i),
                      ),
                    ),
                  ],
                ),
                SliverMasonryFeed(
                  minimumColumns: 1,
                  maximumColumns: 4,
                  itemCount: 60,
                  itemBuilder: (_, _) => const SizedBox(height: 260),
                ),
              ],
            ),
          ),
        );
        final firstPosition = tester.getTopLeft(
          find.byKey(const ValueKey('uneven_0')),
        );
        if (count == 60) {
          expect(find.byKey(const ValueKey('uneven_59')).evaluate(), isEmpty);
        }
        for (final offset in [
          boundary / 2,
          boundary - 100,
          boundary + 400,
          boundary + 1200,
          boundary + 800,
          boundary - 40,
          boundary / 2,
          0.0,
        ]) {
          controller.jumpTo(offset);
          await tester.pumpAndSettle();
          expect(
            controller.offset,
            offset,
            reason: '$count cards at width $width',
          );
          expect(tester.takeException(), isNull);
        }
        expect(
          tester.getTopLeft(find.byKey(const ValueKey('uneven_0'))),
          firstPosition,
        );
        await tester.pumpWidget(const SizedBox.shrink());
        controller.dispose();
      }
    }
  });

  testWidgets(
    'offscreen section rebuilds and item changes keep valid offsets',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1100, 500);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final controller = ScrollController();
      addTearDown(controller.dispose);
      Widget app(int count, {bool reversed = false}) => Directionality(
        textDirection: TextDirection.ltr,
        child: CustomScrollView(
          controller: controller,
          slivers: [
            SliverMasonryFeed(
              minimumColumns: 1,
              maximumColumns: 4,
              itemCount: count,
              itemBuilder: (_, i) => SizedBox(
                height: 200 + i % 3 * 160,
                child: Text('updated:${reversed ? count - i - 1 : i}'),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 3000)),
          ],
        ),
      );
      await tester.pumpWidget(app(9));
      controller.jumpTo(1800);
      await tester.pumpAndSettle();
      for (final count in [9, 18, 9]) {
        await tester.pumpWidget(app(count, reversed: true));
        await tester.pumpAndSettle();
        expect(controller.offset, 1800, reason: 'rebuild with $count cards');
        controller.jumpTo(300);
        await tester.pumpAndSettle();
        expect(controller.offset, 300);
        expect(tester.takeException(), isNull);
        controller.jumpTo(1800);
        await tester.pumpAndSettle();
        expect(controller.offset, 1800);
      }
      controller.jumpTo(0);
      await tester.pumpAndSettle();
      expect(find.text('updated:8'), findsOneWidget);
    },
  );

  testWidgets('restored offsets and column changes keep the feed scrollable', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 500);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = ScrollController(initialScrollOffset: 1800);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: CustomScrollView(
          controller: controller,
          slivers: [
            SliverMasonryFeed(
              itemCount: 100,
              itemBuilder: (_, i) => SizedBox(height: 200 + i % 3 * 160),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(controller.offset, 1800);
    for (final width in [1600.0, 600.0, 1200.0]) {
      tester.view.physicalSize = Size(width, 500);
      await tester.pumpAndSettle();
      expect(controller.offset, greaterThan(0));
      expect(tester.takeException(), isNull);
      controller.jumpTo(700);
      await tester.pumpAndSettle();
      expect(controller.offset, 700);
    }
  });

  for (var count = 1; count <= 4; count++) {
    testWidgets('short leading feed of $count cards never rewinds the page', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1600, 500);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: CustomScrollView(
            controller: controller,
            slivers: [
              SliverMainAxisGroup(
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 64)),
                  SliverMasonryFeed(
                    minimumColumns: 1,
                    maximumColumns: 4,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: count,
                    itemBuilder: (_, i) => SizedBox(
                      key: ValueKey('short_$i'),
                      height: 200 + i * 60,
                    ),
                  ),
                ],
              ),
              SliverMasonryFeed(
                minimumColumns: 1,
                maximumColumns: 4,
                itemCount: 80,
                itemBuilder: (_, i) => SizedBox(height: 200 + i % 3 * 50),
              ),
            ],
          ),
        ),
      );
      final metrics = MasonryFeedMetrics.resolve(
        1600,
        minimumColumns: 1,
        maximumColumns: 4,
      );
      expect(
        tester.getSize(find.byKey(const ValueKey('short_0'))).width,
        metrics.cardWidth - 32 / metrics.columns,
      );
      for (final offset in [450.0, 650.0, 850.0, 1050.0, 850.0, 450.0, 0.0]) {
        controller.jumpTo(offset);
        await tester.pumpAndSettle();
        expect(controller.offset, offset);
        expect(tester.takeException(), isNull);
      }
    });
  }

  testWidgets('scroll layouts keep cached card builders intact', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 500);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = ScrollController();
    addTearDown(controller.dispose);
    var builds = 0;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: CustomScrollView(
          controller: controller,
          slivers: [
            SliverMasonryFeed(
              itemCount: 100,
              itemBuilder: (_, _) {
                builds++;
                return const SizedBox(height: 300);
              },
            ),
          ],
        ),
      ),
    );
    final initialBuilds = builds;
    for (var i = 1; i <= 40; i++) {
      controller.jumpTo(i * 20);
      await tester.pump();
    }
    // Only newly exposed children build; the visible/cache region is not
    // rebuilt forty times merely because scrollOffset changed.
    expect(builds - initialBuilds, lessThanOrEqualTo(9));
    expect(builds, lessThan(25));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a completed leading feed stays cached during later scrolling', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1100, 500);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = ScrollController();
    addTearDown(controller.dispose);
    var builds = 0;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: CustomScrollView(
          controller: controller,
          slivers: [
            SliverMasonryFeed(
              itemCount: 9,
              itemBuilder: (_, i) {
                builds++;
                return SizedBox(height: 200 + i % 3 * 160);
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 3000)),
          ],
        ),
      ),
    );
    controller.jumpTo(1600);
    await tester.pumpAndSettle();
    final completedBuilds = builds;
    for (var i = 1; i <= 40; i++) {
      controller.jumpTo(1600 + i * 20.0);
      await tester.pump();
    }
    expect(builds, completedBuilds);
    expect(controller.offset, 2400);
    expect(tester.takeException(), isNull);
  });

  testWidgets('data and direction changes still update a short row', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 500);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    Widget app(int count, TextDirection direction) => Directionality(
      textDirection: direction,
      child: CustomScrollView(
        slivers: [
          SliverMasonryFeed(
            itemCount: count,
            itemBuilder: (_, i) => SizedBox(
              key: ValueKey('data_$i'),
              height: 100,
              child: Text('$count:$i'),
            ),
          ),
        ],
      ),
    );
    await tester.pumpWidget(app(1, TextDirection.ltr));
    final left = tester.getTopLeft(find.byKey(const ValueKey('data_0'))).dx;
    await tester.pumpWidget(app(2, TextDirection.rtl));
    expect(find.text('2:1'), findsOneWidget);
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('data_0'))).dx,
      greaterThan(left),
    );
    expect(tester.takeException(), isNull);
  });

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

  testWidgets('replacing a long feed with a short row updates its extent', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    Widget app(int count) => Directionality(
      textDirection: TextDirection.ltr,
      child: CustomScrollView(
        controller: controller,
        slivers: [
          SliverMasonryFeed(
            itemCount: count,
            itemBuilder: (_, i) =>
                SizedBox(height: 300, child: Text('$count:$i')),
          ),
        ],
      ),
    );
    await tester.pumpWidget(app(30));
    controller.jumpTo(700);
    await tester.pumpAndSettle();
    await tester.pumpWidget(app(2));
    await tester.pumpAndSettle();
    expect(controller.position.maxScrollExtent, 0);
    expect(controller.offset, 0);
    expect(find.text('2:0'), findsOneWidget);
    expect(tester.takeException(), isNull);
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
