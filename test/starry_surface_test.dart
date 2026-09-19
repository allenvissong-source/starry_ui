import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

Widget _host(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: Center(child: child)),
  );
}

BoxDecoration _surfaceDecoration(WidgetTester tester, Finder root) {
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

void main() {
  final tokens = StarryTokens.light;

  group('StarrySurface primitive', () {
    testWidgets('paints radius.lg + solid border + level2 by default', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const StarrySurface(child: SizedBox(width: 40, height: 40))),
      );
      await tester.pumpAndSettle();

      final deco = _surfaceDecoration(tester, find.byType(StarrySurface));
      expect(deco.color, tokens.semantic.surface);
      expect(deco.borderRadius, BorderRadius.circular(tokens.radius.lg));
      expect((deco.border! as Border).top.color, tokens.semantic.border);
      expect(deco.boxShadow, tokens.elevation.level2);
    });

    testWidgets('omits the drop shadow when elevated is false', (tester) async {
      await tester.pumpWidget(
        _host(
          const StarrySurface(
            elevated: false,
            child: SizedBox(width: 40, height: 40),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final deco = _surfaceDecoration(tester, find.byType(StarrySurface));
      expect(deco.boxShadow, isNull);
    });

    testWidgets('wraps in a button-semantic InkWell when onTap is set', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(
          StarrySurface(
            onTap: () => taps++,
            child: const SizedBox(width: 40, height: 40),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(StarrySurface),
          matching: find.byType(InkWell),
        ),
        findsOneWidget,
      );
      final semantics = tester.widget<Semantics>(
        find
            .descendant(
              of: find.byType(StarrySurface),
              matching: find.byType(Semantics),
            )
            .first,
      );
      expect(semantics.properties.button, isTrue);

      await tester.tap(find.byType(InkWell));
      expect(taps, 1);
    });
  });
}
