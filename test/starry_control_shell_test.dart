import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

Widget _host(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: Center(child: child)),
  );
}

BoxDecoration _shellDecoration(WidgetTester tester, Finder root) {
  final container = tester
      .widgetList<Container>(
        find.descendant(of: root, matching: find.byType(Container)),
      )
      .firstWhere(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration! as BoxDecoration).border != null,
      );
  return container.decoration! as BoxDecoration;
}

BoxDecoration _animatedShellDecoration(WidgetTester tester, Finder root) {
  final container = tester
      .widgetList<AnimatedContainer>(
        find.descendant(of: root, matching: find.byType(AnimatedContainer)),
      )
      .firstWhere(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration! as BoxDecoration).border != null,
      );
  return container.decoration! as BoxDecoration;
}

void main() {
  final tokens = StarryTokens.light;

  group('StarryControlShell primitive', () {
    testWidgets('paints radius.lg + surface fill + level2 by default',
        (tester) async {
      await tester.pumpWidget(
        _host(const StarryControlShell(child: SizedBox(width: 80, height: 48))),
      );
      await tester.pumpAndSettle();

      final deco = _shellDecoration(tester, find.byType(StarryControlShell));
      expect(deco.color, tokens.semantic.surface);
      expect(deco.borderRadius, BorderRadius.circular(tokens.radius.lg));
      expect(deco.boxShadow, tokens.elevation.level2);
    });

    testWidgets('rest border is transparent at focusBorderWidth', (tester) async {
      await tester.pumpWidget(
        _host(const StarryControlShell(child: SizedBox(width: 80, height: 48))),
      );
      await tester.pumpAndSettle();

      final deco = _shellDecoration(tester, find.byType(StarryControlShell));
      final border = deco.border! as Border;
      expect(border.top.color, Colors.transparent);
      expect(border.top.width, tokens.controlMetrics.focusBorderWidth);
    });

    testWidgets('active border is brand at focusBorderWidth (equal width)',
        (tester) async {
      await tester.pumpWidget(
        _host(
          const StarryControlShell(
            isActive: true,
            child: SizedBox(width: 80, height: 48),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final deco = _shellDecoration(tester, find.byType(StarryControlShell));
      final border = deco.border! as Border;
      expect(border.top.color, tokens.semantic.brand);
      // Size stability: active and rest widths are identical.
      expect(border.top.width, tokens.controlMetrics.focusBorderWidth);
    });
  });

  group('StarryAnimatedControlShell', () {
    testWidgets('active border toggles to brand at focusBorderWidth',
        (tester) async {
      await tester.pumpWidget(
        _host(
          const StarryAnimatedControlShell(
            isActive: true,
            child: SizedBox(width: 80, height: 48),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final deco =
          _animatedShellDecoration(tester, find.byType(StarryAnimatedControlShell));
      final border = deco.border! as Border;
      expect(border.top.color, tokens.semantic.brand);
      expect(border.top.width, tokens.controlMetrics.focusBorderWidth);
    });
  });

  group('StarryRoundIconShell', () {
    testWidgets('exposes button semantics and a circular InkWell',
        (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(
          StarryRoundIconShell(
            onTap: () => taps++,
            semanticsLabel: 'Add',
            child: const Icon(Icons.add),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final semantics = tester.widget<Semantics>(
        find
            .descendant(
              of: find.byType(StarryRoundIconShell),
              matching: find.byType(Semantics),
            )
            .first,
      );
      expect(semantics.properties.button, isTrue);

      final inkWell = tester.widget<InkWell>(
        find.descendant(
          of: find.byType(StarryRoundIconShell),
          matching: find.byType(InkWell),
        ),
      );
      expect(inkWell.customBorder, isA<CircleBorder>());

      final deco =
          _animatedShellDecoration(tester, find.byType(StarryRoundIconShell));
      expect(deco.shape, BoxShape.circle);

      await tester.tap(find.byType(InkWell));
      expect(taps, 1);
    });
  });
}
