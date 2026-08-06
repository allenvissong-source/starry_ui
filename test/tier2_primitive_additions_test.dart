import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

// Positive-evidence coverage for the tier-2 primitive parameter additions:
//   • StarryButton   — pressScale + StarryButtonLayout
//   • StarryIconButton — selected
//   • StarryChip      — pill + trailing
//   • StarryTag       — onMedia
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
  group('StarryButton — pressScale + layout', () {
    testWidgets('layout enum has inline + stacked, inline is the default',
        (tester) async {
      expect(StarryButtonLayout.values, <StarryButtonLayout>[
        StarryButtonLayout.inline,
        StarryButtonLayout.stacked,
      ]);
      await tester.pumpWidget(
        _host(StarryButton(label: 'A', icon: Icons.add, onPressed: () {})),
      );
      final b = tester.widget<StarryButton>(find.byType(StarryButton));
      expect(b.layout, StarryButtonLayout.inline);
      expect(b.pressScale, isFalse);
    });

    testWidgets('inline (default) lays icon + label in a Row, no Column',
        (tester) async {
      await tester.pumpWidget(
        _host(StarryButton(label: 'A', icon: Icons.add, onPressed: () {})),
      );
      expect(
        find.descendant(
          of: find.byType(StarryButton),
          matching: find.byType(Column),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(StarryButton),
          matching: find.byType(Icon),
        ),
        findsOneWidget,
      );
    });

    testWidgets('stacked lays icon above label in a Column', (tester) async {
      await tester.pumpWidget(
        _host(StarryButton(
          label: 'A',
          icon: Icons.add,
          layout: StarryButtonLayout.stacked,
          onPressed: () {},
        )),
      );
      final column = find.descendant(
        of: find.byType(StarryButton),
        matching: find.byType(Column),
      );
      expect(column, findsOneWidget);
      expect(
        find.descendant(of: column, matching: find.byType(Icon)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: column, matching: find.text('A')),
        findsOneWidget,
      );
    });

    testWidgets('pressScale wraps the button in the shared pressable AnimatedScale',
        (tester) async {
      await tester.pumpWidget(
        _host(StarryButton(label: 'Go', pressScale: true, onPressed: () {})),
      );
      final scale = find.descendant(
        of: find.byType(StarryButton),
        matching: find.byType(AnimatedScale),
      );
      expect(scale, findsOneWidget);
      // At rest the shared pressable scale is 1.0.
      expect(tester.widget<AnimatedScale>(scale).scale, 1.0);
    });

    testWidgets('pressScale=false renders no AnimatedScale wrapper',
        (tester) async {
      await tester.pumpWidget(
        _host(StarryButton(label: 'Go', onPressed: () {})),
      );
      expect(
        find.descendant(
          of: find.byType(StarryButton),
          matching: find.byType(AnimatedScale),
        ),
        findsNothing,
      );
    });

    testWidgets('pressScale is suppressed while disabled', (tester) async {
      await tester.pumpWidget(
        _host(const StarryButton(label: 'Go', pressScale: true)),
      );
      expect(
        find.descendant(
          of: find.byType(StarryButton),
          matching: find.byType(AnimatedScale),
        ),
        findsNothing,
      );
    });

    testWidgets('pill defaults to true — default button is a StadiumBorder',
        (tester) async {
      await tester.pumpWidget(_host(StarryButton(label: 'Go', onPressed: () {})));
      final b = tester.widget<StarryButton>(find.byType(StarryButton));
      expect(b.pill, isTrue);
      final btn = tester.widget<TextButton>(
        find.descendant(
          of: find.byType(StarryButton),
          matching: find.byType(TextButton),
        ),
      );
      final shape =
          btn.style!.shape!.resolve(<WidgetState>{}) as OutlinedBorder;
      expect(shape, isA<StadiumBorder>());
    });

    testWidgets('pill:false renders a radius.md rounded rectangle',
        (tester) async {
      await tester.pumpWidget(
        _host(StarryButton(label: 'Go', pill: false, onPressed: () {})),
      );
      final t = _tokens(tester, find.byType(StarryButton));
      final btn = tester.widget<TextButton>(
        find.descendant(
          of: find.byType(StarryButton),
          matching: find.byType(TextButton),
        ),
      );
      final shape =
          btn.style!.shape!.resolve(<WidgetState>{}) as RoundedRectangleBorder;
      expect(
        shape.borderRadius,
        BorderRadius.circular(t.radius.md),
      );
    });
  });

  group('StarryIconButton — selected', () {
    testWidgets('selected defaults to false', (tester) async {
      await tester.pumpWidget(
        _host(StarryIconButton(
          icon: Icons.star,
          tooltip: 'Star',
          onPressed: () {},
        )),
      );
      final b =
          tester.widget<StarryIconButton>(find.byType(StarryIconButton));
      expect(b.selected, isFalse);
    });

    testWidgets('selected uses the brand / onBrand active pair', (tester) async {
      await tester.pumpWidget(
        _host(StarryIconButton(
          icon: Icons.bookmark,
          tooltip: 'Bookmark',
          selected: true,
          onPressed: () {},
        )),
      );
      final t = _tokens(tester, find.byType(StarryIconButton));
      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(StarryIconButton),
          matching: find.byType(Material),
        ),
      );
      expect(material.color, t.semantic.brand);
      final icon = tester.widget<Icon>(
        find.descendant(
          of: find.byType(StarryIconButton),
          matching: find.byType(Icon),
        ),
      );
      expect(icon.color, t.semantic.onBrand);
    });

    testWidgets('selected wins over variant (filledTonal still reads active)',
        (tester) async {
      await tester.pumpWidget(
        _host(StarryIconButton(
          icon: Icons.bookmark,
          tooltip: 'Bookmark',
          variant: StarryIconButtonVariant.filledTonal,
          selected: true,
          onPressed: () {},
        )),
      );
      final t = _tokens(tester, find.byType(StarryIconButton));
      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(StarryIconButton),
          matching: find.byType(Material),
        ),
      );
      expect(material.color, t.semantic.brand);
    });

    testWidgets('selected is surfaced to assistive tech', (tester) async {
      await tester.pumpWidget(
        _host(StarryIconButton(
          icon: Icons.bookmark,
          tooltip: 'Bookmark',
          selected: true,
          onPressed: () {},
        )),
      );
      final semantics = tester
          .widgetList<Semantics>(
            find.descendant(
              of: find.byType(StarryIconButton),
              matching: find.byType(Semantics),
            ),
          )
          .firstWhere((s) => s.properties.selected != null);
      expect(semantics.properties.selected, isTrue);
    });
  });

  group('StarryChip — pill + trailing', () {
    testWidgets('pill defaults to true (capsule radius)', (tester) async {
      await tester.pumpWidget(_host(const StarryChip(label: 'Tag')));
      final t = _tokens(tester, find.byType(StarryChip));
      final container = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(StarryChip),
              matching: find.byType(Container),
            ),
          )
          .firstWhere((c) => c.decoration is BoxDecoration);
      final radius = (container.decoration! as BoxDecoration).borderRadius!
          .resolve(TextDirection.ltr);
      expect(
        radius.topLeft.x,
        t.controlMetrics.heightXs / 2,
      );
    });

    testWidgets('pill=false uses the radius.md rounded rectangle',
        (tester) async {
      await tester.pumpWidget(
        _host(const StarryChip(label: 'CN +86', pill: false)),
      );
      final t = _tokens(tester, find.byType(StarryChip));
      final container = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(StarryChip),
              matching: find.byType(Container),
            ),
          )
          .firstWhere((c) => c.decoration is BoxDecoration);
      final radius = (container.decoration! as BoxDecoration).borderRadius!
          .resolve(TextDirection.ltr);
      expect(radius.topLeft.x, t.radius.md);
    });

    testWidgets('trailing widget renders after the label', (tester) async {
      await tester.pumpWidget(
        _host(const StarryChip(
          label: 'CN +86',
          trailing: Icon(Icons.expand_more),
        )),
      );
      expect(
        find.descendant(
          of: find.byType(StarryChip),
          matching: find.byIcon(Icons.expand_more),
        ),
        findsOneWidget,
      );
    });
  });

  group('StarryTag — onMedia', () {
    testWidgets('onMedia defaults to false (tinted status surface)',
        (tester) async {
      await tester.pumpWidget(
        _host(const StarryTag(label: 'NEW', status: StarryTagStatus.success)),
      );
      final t = _tokens(tester, find.byType(StarryTag));
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(StarryTag),
          matching: find.byType(Container),
        ),
      );
      final deco = container.decoration! as BoxDecoration;
      expect(deco.color, t.semantic.successBg);
    });

    testWidgets('onMedia uses a translucent white scrim + light bold xs label',
        (tester) async {
      await tester.pumpWidget(
        _host(const StarryTag(label: 'VIDEO', onMedia: true)),
      );
      final t = _tokens(tester, find.byType(StarryTag));
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(StarryTag),
          matching: find.byType(Container),
        ),
      );
      final deco = container.decoration! as BoxDecoration;
      expect(deco.color, Colors.white.withValues(alpha: t.opacity.mediaScrim));

      final text = tester.widget<Text>(
        find.descendant(
          of: find.byType(StarryTag),
          matching: find.byType(Text),
        ),
      );
      expect(text.style!.color, Colors.white);
      expect(text.style!.fontWeight, FontWeight.w700);
      // xs == labelSmall (one step below the default bodySmall).
      expect(text.style!.fontSize, t.typography.labelSmall.size);
    });

    testWidgets('onMedia ignores status (always the neutral scrim)',
        (tester) async {
      await tester.pumpWidget(
        _host(const StarryTag(
          label: 'VIDEO',
          status: StarryTagStatus.error,
          onMedia: true,
        )),
      );
      final t = _tokens(tester, find.byType(StarryTag));
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(StarryTag),
          matching: find.byType(Container),
        ),
      );
      final deco = container.decoration! as BoxDecoration;
      expect(deco.color, Colors.white.withValues(alpha: t.opacity.mediaScrim));
    });
  });
}
