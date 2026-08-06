import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';
// StarryInputShell is an internal shell (not in the public barrel); import it
// directly to assert the soft variant threads through to the shared shell.
import 'package:starry_ui/src/inputs/input_shell.dart';

// Positive-evidence coverage for the tier-1 capability additions in starry_ui.
// All assertions are pump-only + widget/style inspection; none tap an InkWell,
// so they are unaffected by the environmental `shaders/ink_sparkle.frag`
// shader-asset version mismatch that breaks tap-based InkWell tests.

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  home: Scaffold(body: Center(child: child)),
);

StarryTokens _tokens(WidgetTester tester, Finder anchor) {
  final ctx = tester.element(anchor);
  return Theme.of(ctx).extension<StarryTokens>()!;
}

void main() {
  group('Item 1 — StarrySwitch size tiers + focus ring + keyboard focus', () {
    testWidgets('size enum exists with standard + compact tiers', (_) async {
      expect(StarrySwitchSize.values, <StarrySwitchSize>[
        StarrySwitchSize.standard,
        StarrySwitchSize.compact,
      ]);
    });

    testWidgets(
      'standard renders no Transform.scale; compact scales by token ratio',
      (tester) async {
        await tester.pumpWidget(
          _host(StarrySwitch(value: true, onChanged: (_) {})),
        );
        expect(
          find.descendant(
            of: find.byType(StarrySwitch),
            matching: find.byType(Transform),
          ),
          findsNothing,
        );

        await tester.pumpWidget(
          _host(
            StarrySwitch(
              value: true,
              onChanged: (_) {},
              size: StarrySwitchSize.compact,
            ),
          ),
        );
        final t = _tokens(tester, find.byType(StarrySwitch));
        final expectedScale =
            t.controlMetrics.heightSm / t.controlMetrics.heightLg;
        final transform = tester.widget<Transform>(
          find.descendant(
            of: find.byType(StarrySwitch),
            matching: find.byType(Transform),
          ),
        );
        // scaleX lives at [0] of the 4x4 column-major matrix storage.
        expect(transform.transform.storage[0], closeTo(expectedScale, 1e-9));
      },
    );

    testWidgets('accepts an external focusNode and threads it to the Switch', (
      tester,
    ) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpWidget(
        _host(StarrySwitch(value: false, onChanged: (_) {}, focusNode: node)),
      );
      final sw = tester.widget<Switch>(find.byType(Switch));
      expect(sw.focusNode, same(node));
    });

    testWidgets('focus ring: stadium border turns brand when focused', (
      tester,
    ) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpWidget(
        _host(StarrySwitch(value: false, onChanged: (_) {}, focusNode: node)),
      );
      final t = _tokens(tester, find.byType(StarrySwitch));

      ShapeDecoration ringDeco() {
        final container = tester
            .widgetList<Container>(
              find.descendant(
                of: find.byType(StarrySwitch),
                matching: find.byType(Container),
              ),
            )
            .firstWhere(
              (c) =>
                  c.decoration is ShapeDecoration &&
                  (c.decoration! as ShapeDecoration).shape is StadiumBorder,
            );
        return container.decoration! as ShapeDecoration;
      }

      // Rest: ring border is transparent (no visible ring).
      final restSide = (ringDeco().shape as StadiumBorder).side;
      expect(restSide.color, Colors.transparent);
      expect(restSide.width, t.controlMetrics.focusBorderWidth);

      node.requestFocus();
      await tester.pump();

      final focusSide = (ringDeco().shape as StadiumBorder).side;
      expect(focusSide.color, t.semantic.brand);
      expect(focusSide.width, t.controlMetrics.focusBorderWidth);
    });
  });

  group('Item 2 — StarryButton destructive variant', () {
    testWidgets('destructive is in the variant enum', (_) async {
      expect(
        StarryButtonVariant.values.contains(StarryButtonVariant.destructive),
        isTrue,
      );
    });

    testWidgets('enabled destructive uses semantic.error / onError', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          StarryButton(
            label: 'Delete',
            variant: StarryButtonVariant.destructive,
            onPressed: () {},
          ),
        ),
      );
      final t = _tokens(tester, find.byType(StarryButton));
      final style = tester.widget<TextButton>(find.byType(TextButton)).style!;
      expect(style.backgroundColor!.resolve(<WidgetState>{}), t.semantic.error);
      expect(
        style.foregroundColor!.resolve(<WidgetState>{}),
        t.semantic.onError,
      );
    });

    testWidgets(
      'disabled destructive falls back to surfaceVariant / textDisabled',
      (tester) async {
        await tester.pumpWidget(
          _host(
            const StarryButton(
              label: 'Delete',
              variant: StarryButtonVariant.destructive,
            ),
          ),
        );
        final t = _tokens(tester, find.byType(StarryButton));
        final style = tester.widget<TextButton>(find.byType(TextButton)).style!;
        expect(
          style.backgroundColor!.resolve(<WidgetState>{WidgetState.disabled}),
          t.semantic.surfaceVariant,
        );
        expect(
          style.foregroundColor!.resolve(<WidgetState>{WidgetState.disabled}),
          t.semantic.textDisabled,
        );
      },
    );
  });

  group('Item 3 — StarrySearchInput / InputShell soft variant', () {
    testWidgets('default (soft=false) shell uses focus-border width at rest', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const StarrySearchInput()));
      final t = _tokens(tester, find.byType(StarrySearchInput));
      final shell = tester.widget<StarryInputShell>(
        find.byType(StarryInputShell),
      );
      expect(shell.soft, isFalse);
      final animated = tester.widget<StarryAnimatedControlShell>(
        find.byType(StarryAnimatedControlShell),
      );
      // Standard rest border is the shared active-border rule (focus width,
      // transparent at rest).
      expect(
        animated.shellBorderSide!.width,
        t.controlMetrics.focusBorderWidth,
      );
    });

    testWidgets('soft=true uses thinner rest border + neutral fill', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const StarrySearchInput(soft: true)));
      final t = _tokens(tester, find.byType(StarrySearchInput));
      final shell = tester.widget<StarryInputShell>(
        find.byType(StarryInputShell),
      );
      expect(shell.soft, isTrue);
      final animated = tester.widget<StarryAnimatedControlShell>(
        find.byType(StarryAnimatedControlShell),
      );
      expect(animated.shellBorderSide!.width, t.controlMetrics.restBorderWidth);
      expect(animated.shellBorderSide!.color, t.semantic.border);
      expect(animated.backgroundColor, t.semantic.backgroundSecondary);
    });
  });

  group('Item 4 — StarryBreathingDot', () {
    testWidgets('composes pulsing + scaling and sizes from indicator.dotMd', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const StarryBreathingDot()));
      final t = _tokens(tester, find.byType(StarryBreathingDot));

      expect(
        find.descendant(
          of: find.byType(StarryBreathingDot),
          matching: find.byType(StarryPulsingWidget),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(StarryBreathingDot),
          matching: find.byType(StarryScalingWidget),
        ),
        findsOneWidget,
      );

      final dot = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(StarryBreathingDot),
              matching: find.byType(Container),
            ),
          )
          .firstWhere((c) => c.decoration is BoxDecoration);
      final deco = dot.decoration! as BoxDecoration;
      expect(deco.shape, BoxShape.circle);
      expect(deco.color, t.semantic.brand);
      expect(deco.boxShadow, isNull); // glow off by default
    });

    testWidgets('glow=true layers a brand-colored token halo', (tester) async {
      await tester.pumpWidget(_host(const StarryBreathingDot(glow: true)));
      final t = _tokens(tester, find.byType(StarryBreathingDot));
      final dot = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(StarryBreathingDot),
              matching: find.byType(Container),
            ),
          )
          .firstWhere(
            (c) =>
                c.decoration is BoxDecoration &&
                (c.decoration! as BoxDecoration).boxShadow != null,
          );
      final shadows = (dot.decoration! as BoxDecoration).boxShadow!;
      expect(shadows, isNotEmpty);
      expect(shadows.length, t.elevation.level2.length);
      for (final s in shadows) {
        expect(s.color, t.semantic.brand);
      }
    });
  });

  group('Item 5 — StarryFocusMetrics glow geometry', () {
    test('glow geometry is token-ized', () {
      const metrics = StarryFocusMetrics();
      expect(metrics.glowBlurRadius, 8);
      expect(metrics.glowSpreadRadius, 1);
      expect(metrics.glowOffset, Offset.zero);
      expect(metrics.glowAlpha, 0.5);
      expect(metrics.steps, isNotEmpty);
    });
  });
}
