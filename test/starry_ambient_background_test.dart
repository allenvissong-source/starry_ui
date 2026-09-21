import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'StarryAmbientBackground app variant follows $brightness tokens',
      (tester) async {
        final tokens = brightness == Brightness.light
            ? StarryTokens.light
            : StarryTokens.dark;
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              brightness: brightness,
              extensions: <ThemeExtension<dynamic>>[tokens],
            ),
            home: const StarryAmbientBackground(
              child: SizedBox(key: Key('content')),
            ),
          ),
        );

        expect(find.byKey(const Key('content')), findsOneWidget);
        final gradients = tester
            .widgetList<DecoratedBox>(find.byType(DecoratedBox))
            .map((box) => box.decoration)
            .whereType<BoxDecoration>()
            .map((decoration) => decoration.gradient)
            .whereType<Gradient>()
            .toList();
        expect(gradients, isNotEmpty);
        final primary = gradients.first as LinearGradient;
        expect(
          primary.colors.first.r,
          closeTo(tokens.brand.gradientStart.r, 0.01),
        );
        expect(
          primary.colors.first.g,
          closeTo(tokens.brand.gradientStart.g, 0.01),
        );
        expect(
          primary.colors.first.b,
          closeTo(tokens.brand.gradientStart.b, 0.01),
        );
        if (brightness == Brightness.dark) {
          expect(gradients.whereType<RadialGradient>(), isNotEmpty);
        } else {
          expect(gradients.whereType<RadialGradient>(), isEmpty);
        }
      },
    );
  }

  testWidgets('StarryAmbientBackground auth variant ends at theme background', (
    tester,
  ) async {
    const tokens = StarryTokens.light;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          extensions: const <ThemeExtension<dynamic>>[tokens],
        ),
        home: const StarryAmbientBackground.auth(),
      ),
    );

    final decoration =
        tester.widget<DecoratedBox>(find.byType(DecoratedBox).first).decoration
            as BoxDecoration;
    final gradient = decoration.gradient! as LinearGradient;
    expect(gradient.colors.first, tokens.brand.primaryPale);
    expect(gradient.colors.last, tokens.semantic.background);
  });
}
