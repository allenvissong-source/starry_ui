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

  group('StarryStateLayer.resolve', () {
    test('rest resolves to null (no overlay)', () {
      expect(StarryStateLayer.resolve(tokens), isNull);
    });

    test('hover / focus / pressed / dragged map to the matching opacity step',
        () {
      final base = tokens.semantic.textPrimary;
      expect(
        StarryStateLayer.resolve(tokens, hovered: true)!.a,
        closeTo(tokens.opacity.stateHover, 1e-6),
      );
      expect(
        StarryStateLayer.resolve(tokens, focused: true)!.a,
        closeTo(tokens.opacity.stateFocus, 1e-6),
      );
      expect(
        StarryStateLayer.resolve(tokens, pressed: true)!.a,
        closeTo(tokens.opacity.statePressed, 1e-6),
      );
      expect(
        StarryStateLayer.resolve(tokens, dragged: true)!.a,
        closeTo(tokens.opacity.stateDragged, 1e-6),
      );
      // All neutral overlays use the textPrimary base RGB.
      final hover = StarryStateLayer.resolve(tokens, hovered: true)!;
      expect(hover.r, closeTo(base.r, 1e-6));
      expect(hover.g, closeTo(base.g, 1e-6));
      expect(hover.b, closeTo(base.b, 1e-6));
    });

    test('priority is pressed > dragged > focused > hovered', () {
      final all = StarryStateLayer.resolve(
        tokens,
        hovered: true,
        focused: true,
        dragged: true,
        pressed: true,
      )!;
      expect(all.a, closeTo(tokens.opacity.statePressed, 1e-6));

      final noPress = StarryStateLayer.resolve(
        tokens,
        hovered: true,
        focused: true,
        dragged: true,
      )!;
      expect(noPress.a, closeTo(tokens.opacity.stateDragged, 1e-6));
    });

    test('disabled never stacks an overlay, even with active states', () {
      expect(
        StarryStateLayer.resolve(
          tokens,
          hovered: true,
          pressed: true,
          focused: true,
          disabled: true,
        ),
        isNull,
      );
    });

    test('selected uses the brand base color', () {
      final selected =
          StarryStateLayer.resolve(tokens, hovered: true, selected: true)!;
      expect(selected.r, closeTo(tokens.semantic.brand.r, 1e-6));
      expect(selected.g, closeTo(tokens.semantic.brand.g, 1e-6));
      expect(selected.b, closeTo(tokens.semantic.brand.b, 1e-6));
    });
  });

  group('StarryStateLayer.overlayColor (WidgetStateProperty factory)', () {
    test('hover reads ~8% (single overlay, not double 16%)', () {
      final prop = StarryStateLayer.overlayColor(tokens);
      final hover = prop.resolve(<WidgetState>{WidgetState.hovered})!;
      expect(hover.a, closeTo(tokens.opacity.stateHover, 1e-6));
      // Guard against the double-overlay pitfall: hover must not be ~16%.
      expect(hover.a, lessThan(tokens.opacity.stateDragged));
    });

    test('pressed > focused > hovered priority via WidgetState set', () {
      final prop = StarryStateLayer.overlayColor(tokens);
      final pressed = prop.resolve(<WidgetState>{
        WidgetState.hovered,
        WidgetState.focused,
        WidgetState.pressed,
      })!;
      expect(pressed.a, closeTo(tokens.opacity.statePressed, 1e-6));
    });

    test('disabled resolves to transparent', () {
      final prop = StarryStateLayer.overlayColor(tokens);
      expect(
        prop.resolve(<WidgetState>{WidgetState.disabled}),
        Colors.transparent,
      );
    });

    test('rest resolves to transparent', () {
      final prop = StarryStateLayer.overlayColor(tokens);
      expect(prop.resolve(<WidgetState>{}), Colors.transparent);
    });
  });

  group('StarryRoundActionButton', () {
    testWidgets('invokes onTap and exposes the stable key', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(
          StarryRoundActionButton(
            onTap: () => taps++,
            child: const Icon(Icons.auto_awesome),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('starry-round-action-button')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('starry-round-action-button')));
      expect(taps, 1);
    });

    testWidgets('renders the injected child glyph', (tester) async {
      await tester.pumpWidget(
        _host(
          StarryRoundActionButton(
            onTap: () {},
            child: const Icon(Icons.auto_awesome),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });
  });

  group('StarryDockBar', () {
    List<StarryNavItem> items() => const <StarryNavItem>[
          StarryNavItem(label: 'Home', icon: Icons.home),
          StarryNavItem(label: 'Search', icon: Icons.search),
          StarryNavItem(label: 'Me', icon: Icons.person),
        ];

    testWidgets('renders all tabs and reports the tapped index',
        (tester) async {
      var tapped = -1;
      await tester.pumpWidget(
        _host(
          StarryDockBar(
            items: items(),
            currentIndex: 0,
            onTap: (i) => tapped = i,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Me'), findsOneWidget);

      await tester.tap(find.text('Search'));
      expect(tapped, 1);
    });

    testWidgets('selected tab tints brand; rest tints textSecondary',
        (tester) async {
      await tester.pumpWidget(
        _host(
          StarryDockBar(
            items: items(),
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final selectedIcon = tester.widget<Icon>(find.byIcon(Icons.home));
      expect(selectedIcon.color, tokens.semantic.brand);

      final restIcon = tester.widget<Icon>(find.byIcon(Icons.search));
      expect(restIcon.color, tokens.semantic.textSecondary);
    });

    testWidgets('renders the leading affordance before the pill',
        (tester) async {
      await tester.pumpWidget(
        _host(
          StarryDockBar(
            items: items(),
            currentIndex: 0,
            onTap: (_) {},
            leading: StarryRoundActionButton(
              onTap: () {},
              child: const Icon(Icons.auto_awesome),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('starry-round-action-button')),
        findsOneWidget,
      );
    });
  });
}
