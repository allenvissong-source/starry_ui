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

  group('StarryActionOptionCard', () {
    testWidgets('renders icon, title, description and trailing chevron', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const SizedBox(
            width: 360,
            child: StarryActionOptionCard(
              icon: Icons.auto_awesome,
              title: 'Create with AI',
              description: 'Generate a draft.',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Create with AI'), findsOneWidget);
      expect(find.text('Generate a draft.'), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
    });

    testWidgets('paints the badge with the brand color and onBrand glyph', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const SizedBox(
            width: 360,
            child: StarryActionOptionCard(
              icon: Icons.auto_awesome,
              title: 'Title',
              description: 'Desc',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final badge = tester.widget<Container>(
        find
            .ancestor(
              of: find.byIcon(Icons.auto_awesome),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = badge.decoration! as BoxDecoration;
      expect(decoration.color, tokens.semantic.brand);
      expect(decoration.shape, BoxShape.circle);

      final icon = tester.widget<Icon>(find.byIcon(Icons.auto_awesome));
      expect(icon.color, tokens.semantic.onBrand);
    });

    testWidgets('invokes onTap when enabled', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 360,
            child: StarryActionOptionCard(
              icon: Icons.auto_awesome,
              title: 'Tap me',
              description: 'Desc',
              onTap: () => tapped++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(StarryActionOptionCard));
      await tester.pumpAndSettle();
      expect(tapped, 1);
    });

    testWidgets('disabled: dims content, drops elevation and ignores taps', (
      tester,
    ) async {
      var tapped = 0;
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 360,
            child: StarryActionOptionCard(
              icon: Icons.lock_outline,
              title: 'Locked',
              description: 'Desc',
              enabled: false,
              onTap: () => tapped++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final opacity = tester.widget<Opacity>(
        find.descendant(
          of: find.byType(StarryActionOptionCard),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacity.opacity, tokens.opacity.disabledContent);

      await tester.tap(find.byType(StarryActionOptionCard));
      await tester.pumpAndSettle();
      expect(tapped, 0);
    });
  });
}
