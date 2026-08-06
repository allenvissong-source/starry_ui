import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';
import 'package:starry_ui/src/inputs/input_shell.dart';

Widget _host(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: Center(child: child)),
  );
}

ShapeDecoration _shellDecoration(WidgetTester tester, Finder root) {
  final container = tester
      .widgetList<Container>(
        find.descendant(of: root, matching: find.byType(Container)),
      )
      .firstWhere((c) => c.decoration is ShapeDecoration);
  return container.decoration! as ShapeDecoration;
}

ShapeDecoration _animatedShellDecoration(WidgetTester tester, Finder root) {
  final container = tester
      .widgetList<AnimatedContainer>(
        find.descendant(of: root, matching: find.byType(AnimatedContainer)),
      )
      .firstWhere((c) => c.decoration is ShapeDecoration);
  return container.decoration! as ShapeDecoration;
}

BorderSide _sideOf(ShapeBorder shape) {
  if (shape is RoundedRectangleBorder) return shape.side;
  if (shape is StadiumBorder) return shape.side;
  if (shape is CircleBorder) return shape.side;
  fail('Unexpected shape: $shape');
}

void main() {
  final tokens = StarryTokens.light;

  group('StarryControlShell primitive', () {
    testWidgets('paints radius.xxl + surface fill + level2 by default',
        (tester) async {
      await tester.pumpWidget(
        _host(const StarryControlShell(child: SizedBox(width: 80, height: 48))),
      );
      await tester.pumpAndSettle();

      final deco = _shellDecoration(tester, find.byType(StarryControlShell));
      expect(deco.color, tokens.semantic.surface);
      final shape = deco.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(tokens.radius.xxl));
      expect(deco.shadows, tokens.elevation.level2);
    });

    testWidgets('rest border is transparent at focusBorderWidth', (tester) async {
      await tester.pumpWidget(
        _host(const StarryControlShell(child: SizedBox(width: 80, height: 48))),
      );
      await tester.pumpAndSettle();

      final deco = _shellDecoration(tester, find.byType(StarryControlShell));
      final side = _sideOf(deco.shape);
      expect(side.color, Colors.transparent);
      expect(side.width, tokens.controlMetrics.focusBorderWidth);
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
      final side = _sideOf(deco.shape);
      expect(side.color, tokens.semantic.brand);
      // Size stability: active and rest widths are identical.
      expect(side.width, tokens.controlMetrics.focusBorderWidth);
    });

    testWidgets('pill renders a StadiumBorder', (tester) async {
      await tester.pumpWidget(
        _host(
          const StarryControlShell(
            pill: true,
            child: SizedBox(width: 80, height: 48),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final deco = _shellDecoration(tester, find.byType(StarryControlShell));
      expect(deco.shape, isA<StadiumBorder>());
    });

    testWidgets('activeBorderSide honors an explicit color at focusBorderWidth',
        (tester) async {
      const validation = Color(0xFFAABBCC);
      late BorderSide restColored;
      late BorderSide activeColored;
      late BorderSide restDefault;
      await tester.pumpWidget(
        _host(
          Builder(
            builder: (context) {
              restColored = StarryControlShell.activeBorderSide(
                context,
                isActive: false,
                color: validation,
              );
              activeColored = StarryControlShell.activeBorderSide(
                context,
                isActive: true,
                color: validation,
              );
              restDefault =
                  StarryControlShell.activeBorderSide(context, isActive: false);
              return const SizedBox();
            },
          ),
        ),
      );

      // Explicit color wins in BOTH rest and active states.
      expect(restColored.color, validation);
      expect(activeColored.color, validation);
      // Width is always focusBorderWidth (size stability).
      expect(restColored.width, tokens.controlMetrics.focusBorderWidth);
      expect(activeColored.width, tokens.controlMetrics.focusBorderWidth);
      // Without a color, rest falls back to transparent.
      expect(restDefault.color, Colors.transparent);
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
      final side = _sideOf(deco.shape);
      expect(side.color, tokens.semantic.brand);
      expect(side.width, tokens.controlMetrics.focusBorderWidth);
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
      expect(deco.shape, isA<CircleBorder>());

      await tester.tap(find.byType(InkWell));
      expect(taps, 1);
    });
  });

  group('StarryInputShell parity', () {
    testWidgets('focus paints brand border at focusBorderWidth + level2',
        (tester) async {
      await tester.pumpWidget(
        _host(
          const StarryInputShell(
            focused: true,
            child: SizedBox(width: 120, height: 48),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final deco =
          _animatedShellDecoration(tester, find.byType(StarryInputShell));
      final side = _sideOf(deco.shape);
      expect(side.color, tokens.semantic.brand);
      expect(side.width, tokens.controlMetrics.focusBorderWidth);
      expect(deco.shadows, tokens.elevation.level2);
    });

    testWidgets('rest is transparent border + level1 elevation',
        (tester) async {
      await tester.pumpWidget(
        _host(
          const StarryInputShell(
            focused: false,
            child: SizedBox(width: 120, height: 48),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final deco =
          _animatedShellDecoration(tester, find.byType(StarryInputShell));
      final side = _sideOf(deco.shape);
      expect(side.color, Colors.transparent);
      expect(side.width, tokens.controlMetrics.focusBorderWidth);
      expect(deco.shadows, tokens.elevation.level1);
    });

    testWidgets('borderColor is painted even at rest', (tester) async {
      const validation = Color(0xFFEE0000);
      await tester.pumpWidget(
        _host(
          const StarryInputShell(
            focused: false,
            borderColor: validation,
            child: SizedBox(width: 120, height: 48),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final deco =
          _animatedShellDecoration(tester, find.byType(StarryInputShell));
      final side = _sideOf(deco.shape);
      expect(side.color, validation);
      expect(side.width, tokens.controlMetrics.focusBorderWidth);
    });
  });
}
