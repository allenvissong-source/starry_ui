import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

Widget _host(Widget child) => MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(body: Center(child: child)),
    );

StarryTokens _tokens(WidgetTester tester, Finder anchor) {
  final ctx = tester.element(anchor);
  return Theme.of(ctx).extension<StarryTokens>()!;
}

void main() {
  group('StarryMediaStage', () {
    testWidgets('uses the given aspectRatio', (tester) async {
      await tester.pumpWidget(
        _host(const StarryMediaStage(
          aspectRatio: 1.5,
          child: ColoredBox(color: Colors.blue),
        )),
      );
      final ar = tester.widget<AspectRatio>(
        find.descendant(
          of: find.byType(StarryMediaStage),
          matching: find.byType(AspectRatio),
        ),
      );
      expect(ar.aspectRatio, 1.5);
    });

    testWidgets('normalizes non-positive aspectRatio to 1', (tester) async {
      await tester.pumpWidget(
        _host(const StarryMediaStage(
          aspectRatio: 0,
          child: ColoredBox(color: Colors.blue),
        )),
      );
      final ar = tester.widget<AspectRatio>(
        find.descendant(
          of: find.byType(StarryMediaStage),
          matching: find.byType(AspectRatio),
        ),
      );
      expect(ar.aspectRatio, 1);
    });

    testWidgets('no overlay → no scrim gradient container', (tester) async {
      await tester.pumpWidget(
        _host(const StarryMediaStage(
          aspectRatio: 1,
          child: ColoredBox(color: Colors.blue),
        )),
      );
      final gradients = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(StarryMediaStage),
              matching: find.byType(Container),
            ),
          )
          .where((c) =>
              c.decoration is BoxDecoration &&
              (c.decoration! as BoxDecoration).gradient != null);
      expect(gradients, isEmpty);
    });

    testWidgets('overlay renders over a transparent → mediaOverlayEnd scrim',
        (tester) async {
      await tester.pumpWidget(
        _host(const StarryMediaStage(
          aspectRatio: 1,
          overlay: Text('LIVE'),
          child: ColoredBox(color: Colors.blue),
        )),
      );
      final t = _tokens(tester, find.byType(StarryMediaStage));
      expect(
        find.descendant(
          of: find.byType(StarryMediaStage),
          matching: find.text('LIVE'),
        ),
        findsOneWidget,
      );
      final container = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(StarryMediaStage),
              matching: find.byType(Container),
            ),
          )
          .firstWhere((c) =>
              c.decoration is BoxDecoration &&
              (c.decoration! as BoxDecoration).gradient != null);
      final gradient =
          (container.decoration! as BoxDecoration).gradient! as LinearGradient;
      expect(gradient.begin, Alignment.topCenter);
      expect(gradient.end, Alignment.bottomCenter);
      expect(gradient.colors.first, Colors.transparent);
      expect(gradient.colors.last, t.semantic.mediaOverlayEnd);
    });

    testWidgets('brightnessAnimation drives a ColorFiltered media layer',
        (tester) async {
      final controller = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(seconds: 1),
      )..value = 1;
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _host(StarryMediaStage(
          aspectRatio: 1,
          brightnessAnimation: controller,
          child: const ColoredBox(color: Colors.blue),
        )),
      );
      expect(
        find.descendant(
          of: find.byType(StarryMediaStage),
          matching: find.byType(ColorFiltered),
        ),
        findsOneWidget,
      );
    });

    testWidgets('no brightnessAnimation → no ColorFiltered layer',
        (tester) async {
      await tester.pumpWidget(
        _host(const StarryMediaStage(
          aspectRatio: 1,
          child: ColoredBox(color: Colors.blue),
        )),
      );
      expect(
        find.descendant(
          of: find.byType(StarryMediaStage),
          matching: find.byType(ColorFiltered),
        ),
        findsNothing,
      );
    });
  });

  group('StarryMasonryCard', () {
    // The card's own hover scale animates over `motion.durationMedium`; the
    // inner StarryPressScale's press scale uses `motion.durationShort`. Target
    // the hover one unambiguously by its duration.
    Finder hoverScaleFinder(WidgetTester tester) {
      final t = _tokens(tester, find.byType(StarryMasonryCard));
      return find.descendant(
        of: find.byType(StarryMasonryCard),
        matching: find.byWidgetPredicate(
          (w) => w is AnimatedScale && w.duration == t.motion.durationMedium,
        ),
      );
    }

    testWidgets('composes StarryPressScale + a single shadow layer',
        (tester) async {
      await tester.pumpWidget(
        _host(const StarryMasonryCard(child: SizedBox(width: 40, height: 40))),
      );
      expect(
        find.descendant(
          of: find.byType(StarryMasonryCard),
          matching: find.byType(StarryPressScale),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(StarryMasonryCard),
          matching: find.byType(AnimatedContainer),
        ),
        findsOneWidget,
      );
      expect(hoverScaleFinder(tester), findsOneWidget);
    });

    testWidgets('at rest: scale 1.0 and elevation.level2 shadow',
        (tester) async {
      await tester.pumpWidget(
        _host(const StarryMasonryCard(child: SizedBox(width: 40, height: 40))),
      );
      final t = _tokens(tester, find.byType(StarryMasonryCard));
      final scale = tester.widget<AnimatedScale>(hoverScaleFinder(tester));
      expect(scale.scale, 1.0);
      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(StarryMasonryCard),
          matching: find.byType(AnimatedContainer),
        ),
      );
      final deco = container.decoration! as BoxDecoration;
      expect(deco.boxShadow, t.elevation.level2);
    });

    testWidgets('hover: scales up to 1.01 and lifts to elevation.level3',
        (tester) async {
      await tester.pumpWidget(
        _host(const StarryMasonryCard(child: SizedBox(width: 40, height: 40))),
      );
      final t = _tokens(tester, find.byType(StarryMasonryCard));

      final gesture =
          await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await tester.pump();
      await gesture.moveTo(tester.getCenter(find.byType(StarryMasonryCard)));
      await tester.pumpAndSettle();

      final scale = tester.widget<AnimatedScale>(hoverScaleFinder(tester));
      expect(scale.scale, 1.01);
      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(StarryMasonryCard),
          matching: find.byType(AnimatedContainer),
        ),
      );
      final deco = container.decoration! as BoxDecoration;
      expect(deco.boxShadow, t.elevation.level3);
    });

    testWidgets('onTap fires', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(StarryMasonryCard(
          onTap: () => taps++,
          child: const SizedBox(width: 40, height: 40),
        )),
      );
      await tester.tap(find.byType(StarryMasonryCard));
      await tester.pump();
      expect(taps, 1);
    });
  });

  group('StarryMetricButton — activeColor', () {
    testWidgets('activeColor overrides the active ink (icon + count)',
        (tester) async {
      const heart = Color(0xFFEF4444);
      await tester.pumpWidget(
        _host(const StarryMetricButton(
          icon: Icons.favorite,
          count: 3,
          semanticLabel: 'like',
          active: true,
          activeColor: heart,
        )),
      );
      final icon = tester.widget<Icon>(
        find.descendant(
          of: find.byType(StarryMetricButton),
          matching: find.byType(Icon),
        ),
      );
      expect(icon.color, heart);
      final text = tester.widget<Text>(
        find.descendant(
          of: find.byType(StarryMetricButton),
          matching: find.byType(Text),
        ),
      );
      expect(text.style!.color, heart);
    });

    testWidgets('activeColor is ignored when inactive (follows tone)',
        (tester) async {
      const heart = Color(0xFFEF4444);
      await tester.pumpWidget(
        _host(const StarryMetricButton(
          icon: Icons.favorite_border,
          count: 3,
          semanticLabel: 'like',
          activeColor: heart,
        )),
      );
      final t = _tokens(tester, find.byType(StarryMetricButton));
      final icon = tester.widget<Icon>(
        find.descendant(
          of: find.byType(StarryMetricButton),
          matching: find.byType(Icon),
        ),
      );
      expect(icon.color, t.semantic.textSecondary);
    });

    testWidgets('null activeColor + active on surface tone → brand ink',
        (tester) async {
      await tester.pumpWidget(
        _host(const StarryMetricButton(
          icon: Icons.thumb_up,
          count: 3,
          semanticLabel: 'like',
          active: true,
        )),
      );
      final t = _tokens(tester, find.byType(StarryMetricButton));
      final icon = tester.widget<Icon>(
        find.descendant(
          of: find.byType(StarryMetricButton),
          matching: find.byType(Icon),
        ),
      );
      expect(icon.color, t.semantic.brand);
    });
  });
}
