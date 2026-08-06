import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';
import 'package:starry_ui/src/foundations/foundations.dart';

void main() {
  group('StarryBreakpoints', () {
    final bp = StarryTokens.light.breakpoints;

    test('threshold values match Material 3 window size classes', () {
      expect(bp.compact, 600);
      expect(bp.medium, 840);
      expect(bp.expanded, 1200);
      expect(bp.large, 1600);
    });

    test('steps expose four ordered thresholds', () {
      expect(bp.steps.length, 4);
      expect(bp.steps.map((e) => e.$2).toList(), [600, 840, 1200, 1600]);
    });

    test('resolve() honours lower-bound-inclusive / upper-bound-exclusive', () {
      expect(bp.resolve(0), StarryWindowSizeClass.compact);
      expect(bp.resolve(599), StarryWindowSizeClass.compact);
      expect(bp.resolve(600), StarryWindowSizeClass.medium);
      expect(bp.resolve(839.9), StarryWindowSizeClass.medium);
      expect(bp.resolve(840), StarryWindowSizeClass.expanded);
      expect(bp.resolve(1199), StarryWindowSizeClass.expanded);
      expect(bp.resolve(1200), StarryWindowSizeClass.large);
      expect(bp.resolve(1599), StarryWindowSizeClass.large);
      expect(bp.resolve(1600), StarryWindowSizeClass.extraLarge);
      expect(bp.resolve(4000), StarryWindowSizeClass.extraLarge);
    });

    test('breakpoints survive copyWith identity and are theme-exposed', () {
      expect(StarryTokens.dark.breakpoints.expanded, 1200);
      final copy = StarryTokens.light.copyWith();
      expect(copy.breakpoints.large, 1600);
    });
  });

  testWidgets('BreakpointsFoundation renders its section without errors', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [StarryTokens.light]),
        home: const Scaffold(body: BreakpointsFoundation()),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.textContaining('断点 Breakpoints'), findsOneWidget);
    expect(find.text('breakpoint/compact'), findsOneWidget);
    expect(find.text('breakpoint/large'), findsOneWidget);
  });
}
