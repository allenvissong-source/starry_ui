import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

Widget _host(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  final tokens = StarryTokens.light;

  group('StarryPressScale', () {
    testWidgets('rests at scale 1.0 and settles to pressedScale on press down',
        (tester) async {
      await tester.pumpWidget(
        _host(
          const StarryPressScale(
            child: SizedBox(
              width: 80,
              height: 48,
              child: ColoredBox(color: Color(0xFF000000)),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      AnimatedScale scaleOf() => tester.widget<AnimatedScale>(
            find.descendant(
              of: find.byType(StarryPressScale),
              matching: find.byType(AnimatedScale),
            ),
          );
      expect(scaleOf().scale, 1.0);

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(StarryPressScale)),
      );
      await tester.pump();
      expect(scaleOf().scale, tokens.motion.pressedScale);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(scaleOf().scale, 1.0);
    });

    testWidgets('invokes onTap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(
          StarryPressScale(
            onTap: () => taps++,
            child: const SizedBox(
              width: 80,
              height: 48,
              child: ColoredBox(color: Color(0xFF000000)),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(StarryPressScale));
      expect(taps, 1);
    });
  });

  group('StarrySelectedHighlight', () {
    BoxDecoration decoOf(WidgetTester tester) {
      final c = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(StarrySelectedHighlight),
          matching: find.byType(AnimatedContainer),
        ),
      );
      return c.decoration! as BoxDecoration;
    }

    testWidgets('selected paints surface fill + brand border + level2',
        (tester) async {
      await tester.pumpWidget(
        _host(
          const StarrySelectedHighlight(
            isSelected: true,
            child: SizedBox(width: 80, height: 48),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final deco = decoOf(tester);
      expect(deco.color, tokens.semantic.surface);
      expect(deco.boxShadow, tokens.elevation.level2);
      expect(deco.border!.top.color, tokens.semantic.brand);
      expect(deco.border!.top.width, tokens.controlMetrics.focusBorderWidth);
      expect(deco.borderRadius, BorderRadius.circular(tokens.radius.lg));
    });

    testWidgets('rest is fully transparent at equal border width',
        (tester) async {
      await tester.pumpWidget(
        _host(
          const StarrySelectedHighlight(
            isSelected: false,
            child: SizedBox(width: 80, height: 48),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final deco = decoOf(tester);
      expect(deco.color, Colors.transparent);
      expect(deco.boxShadow, isNull);
      expect(deco.border!.top.color, Colors.transparent);
      expect(deco.border!.top.width, tokens.controlMetrics.focusBorderWidth);
    });

    testWidgets('overrides win in the selected state', (tester) async {
      const ring = Color(0xFF123456);
      final shadow = <BoxShadow>[const BoxShadow(color: ring)];
      await tester.pumpWidget(
        _host(
          StarrySelectedHighlight(
            isSelected: true,
            selectedColor: Colors.transparent,
            selectedBorderColor: ring,
            selectedShadow: shadow,
            borderRadius: BorderRadius.circular(24),
            child: const SizedBox(width: 80, height: 48),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final deco = decoOf(tester);
      expect(deco.color, Colors.transparent);
      expect(deco.boxShadow, shadow);
      expect(deco.border!.top.color, ring);
      expect(deco.borderRadius, BorderRadius.circular(24));
    });
  });
}
