import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/main.directories.g.dart' as widgetbook_directories;
import 'package:starry_ui/starry_ui.dart';
import 'package:widgetbook/widgetbook.dart';

// Positive-evidence coverage for the Sheet5 layout/media sedimentation:
//   • StarryGlassPanel          — frosted surface: token border/shadow/fill
//   • StarryGradientFallback    — three-stop brand gradient
//   • StarryImmersiveBackground — hero image / fallback + atmosphere + glows
// All assertions are pump-only + widget/style inspection.

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  home: Scaffold(body: child),
);

StarryTokens _tokens(WidgetTester tester, Finder anchor) {
  final ctx = tester.element(anchor);
  return Theme.of(ctx).extension<StarryTokens>()!;
}

bool _widgetbookTreeContainsName(WidgetbookNode node, String name) {
  if (node.name == name) return true;
  if (node is WidgetbookFolder) {
    return (node.children ?? const <WidgetbookNode>[]).any(
      (child) => _widgetbookTreeContainsName(child, name),
    );
  }
  return false;
}

void main() {
  group('StarryGlassPanel', () {
    testWidgets('renders child and clips with the default token radius', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const Center(child: StarryGlassPanel(child: Text('GLASS')))),
      );
      expect(find.text('GLASS'), findsOneWidget);

      final t = _tokens(tester, find.text('GLASS'));
      final clip = tester.widget<ClipRRect>(find.byType(ClipRRect).first);
      // Default corner radius resolves to radius.xxl (28).
      expect(clip.borderRadius, BorderRadius.circular(t.radius.xxl));
    });

    testWidgets('border uses onMedia token and shadow uses glass tier', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const Center(child: StarryGlassPanel(child: Text('GLASS')))),
      );
      final t = _tokens(tester, find.text('GLASS'));

      final decorated = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(StarryGlassPanel),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      final decoration = decorated.decoration as BoxDecoration;

      // Fill = surface @ 0.82.
      expect(decoration.color, t.semantic.surface.withValues(alpha: 0.82));
      // Border color = onMedia @ 0.58.
      final border = decoration.border! as Border;
      expect(border.top.color, t.semantic.onMedia.withValues(alpha: 0.58));
      // Shadow = the dedicated glass tier.
      expect(decoration.boxShadow, t.elevation.glass);
    });

    testWidgets('honors custom borderRadius', (tester) async {
      await tester.pumpWidget(
        _host(
          const Center(
            child: StarryGlassPanel(borderRadius: 12, child: Text('GLASS')),
          ),
        ),
      );
      final clip = tester.widget<ClipRRect>(find.byType(ClipRRect).first);
      expect(clip.borderRadius, BorderRadius.circular(12));
    });

    testWidgets('Widgetbook directories expose StarryGlassPanel', (
      tester,
    ) async {
      expect(
        widgetbook_directories.directories.any(
          (n) => _widgetbookTreeContainsName(n, 'StarryGlassPanel'),
        ),
        isTrue,
      );
    });
  });

  group('StarryGradientFallback', () {
    testWidgets('paints a three-stop brand gradient', (tester) async {
      await tester.pumpWidget(_host(const StarryGradientFallback()));
      final t = _tokens(tester, find.byType(StarryGradientFallback));

      final decorated = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(StarryGradientFallback),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      final gradient =
          (decorated.decoration as BoxDecoration).gradient! as LinearGradient;
      expect(gradient.colors, <Color>[
        t.brand.primaryPale,
        t.brand.primaryTint50,
        t.brand.accentGradientEnd,
      ]);
    });

    testWidgets('Widgetbook directories expose StarryGradientFallback', (
      tester,
    ) async {
      expect(
        widgetbook_directories.directories.any(
          (n) => _widgetbookTreeContainsName(n, 'StarryGradientFallback'),
        ),
        isTrue,
      );
    });
  });

  group('StarryImmersiveBackground', () {
    testWidgets('with no image falls back to the gradient', (tester) async {
      await tester.pumpWidget(_host(const StarryImmersiveBackground()));
      expect(find.byType(StarryGradientFallback), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('renders the two ambient glow orbs by default', (tester) async {
      await tester.pumpWidget(_host(const StarryImmersiveBackground()));
      // Two orb layers use ImageFiltered blur.
      expect(find.byType(ImageFiltered), findsNWidgets(2));
    });

    testWidgets('showAmbientGlows:false drops the orbs', (tester) async {
      await tester.pumpWidget(
        _host(const StarryImmersiveBackground(showAmbientGlows: false)),
      );
      expect(find.byType(ImageFiltered), findsNothing);
    });

    testWidgets('Widgetbook directories expose StarryImmersiveBackground', (
      tester,
    ) async {
      expect(
        widgetbook_directories.directories.any(
          (n) => _widgetbookTreeContainsName(n, 'StarryImmersiveBackground'),
        ),
        isTrue,
      );
    });
  });
}
