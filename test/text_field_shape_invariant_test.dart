import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';
import 'package:starry_ui/src/inputs/input_shell.dart';

/// Runtime evidence for StarryTextField's shape invariant:
///   * single line  → stable pill (full semicircle ends)
///   * multi line    → fixed `radius.xxl` (28) rounded rectangle
///
/// The field always hands the shell one fixed corner radius
/// (`math.max(radius.xxl, controlHeight / 2)` == 28 with the current tokens).
/// The *visible* shape therefore comes entirely from Skia's clamp
/// `corner = min(radius, height / 2)`, applied to the field's real rendered
/// height. This test pumps both cases, measures the actual shell [RenderBox],
/// and asserts the clamp outcome — evidence the CanvasKit web build cannot
/// render inline and the a11y tree cannot express.

Widget _host(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(
      body: Center(
        child: SizedBox(width: 320, child: child),
      ),
    ),
  );
}

({double radius, double height}) _shellGeometry(WidgetTester tester) {
  final containerFinder = find.descendant(
    of: find.byType(StarryInputShell),
    matching: find.byType(AnimatedContainer),
  );
  final container = tester
      .widgetList<AnimatedContainer>(containerFinder)
      .firstWhere((c) => c.decoration is ShapeDecoration);
  final deco = container.decoration! as ShapeDecoration;
  final shape = deco.shape as RoundedRectangleBorder;
  final radius = (shape.borderRadius.resolve(TextDirection.ltr)).topLeft.x;

  final element = containerFinder
      .evaluate()
      .firstWhere((e) => (e.widget as AnimatedContainer).decoration is ShapeDecoration);
  final box = element.renderObject! as RenderBox;
  return (radius: radius, height: box.size.height);
}

void main() {
  final tokens = StarryTokens.light;
  final fixedRadius = tokens.radius.xxl; // 28

  group('StarryTextField shape invariant', () {
    testWidgets('single line clamps to a full pill (radius >= height / 2)',
        (tester) async {
      await tester.pumpWidget(
        _host(
          const StarryTextField(
            hint: 'single line',
          ),
        ),
      );
      await tester.pumpAndSettle();

      final g = _shellGeometry(tester);
      // The shell hands over the fixed radius unchanged...
      expect(g.radius, fixedRadius);
      // ...and single-line height (== controlHeight, 48) makes half-height
      // (24) <= radius (28), so Skia clamps the corner to height/2 → a full
      // pill. Assert the clamp condition on the *real* rendered height.
      expect(
        g.radius >= g.height / 2,
        isTrue,
        reason:
            'single line should be a pill: radius ${g.radius} >= height/2 ${g.height / 2}',
      );
    });

    testWidgets('multi line stays a fixed radius.xxl rounded rectangle',
        (tester) async {
      await tester.pumpWidget(
        _host(
          const StarryTextField(
            hint: 'multi line',
            minLines: 5,
            maxLines: 5,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final g = _shellGeometry(tester);
      // Same fixed radius is handed over...
      expect(g.radius, fixedRadius);
      // ...but a tall multi-line box makes half-height > radius, so the corner
      // settles at the fixed radius.xxl rounded rectangle (NOT a pill).
      expect(
        g.radius < g.height / 2,
        isTrue,
        reason:
            'multi line should be a rounded rect: radius ${g.radius} < height/2 ${g.height / 2}',
      );
    });
  });
}
