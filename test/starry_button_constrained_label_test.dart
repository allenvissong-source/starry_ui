import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

void main() {
  for (final icon in [null, Icons.key]) {
    testWidgets('constrained long label with $icon remains accessible', (
      tester,
    ) async {
      const label = 'Copy connection configuration for this application';
      var taps = 0;
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 180,
                child: StarryButton(
                  label: label,
                  icon: icon,
                  onPressed: () => taps++,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.bySemanticsLabel(label), findsOneWidget);
      expect(
        tester.getSize(find.byType(StarryButton)).height,
        StarryTokens.light.controlMetrics.controlHeight,
      );
      await tester.tap(find.byType(StarryButton));
      expect(taps, 1);
      semantics.dispose();
    });
  }
}
