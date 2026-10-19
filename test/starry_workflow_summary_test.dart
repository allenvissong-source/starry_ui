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
  group('StarryWorkflowSummary', () {
    testWidgets(
      'single row shows name and gray elapsed; no chevron without steps',
      (tester) async {
        await tester.pumpWidget(
          _host(
            const SizedBox(
              width: 360,
              child: StarryWorkflowSummary(
                name: 'Ailore',
                elapsedText: '工作了 49 秒',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Ailore'), findsOneWidget);
        expect(find.text('工作了 49 秒'), findsOneWidget);
        expect(find.byIcon(Icons.keyboard_arrow_right_rounded), findsNothing);
        expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('omitted elapsed renders no gray suffix', (tester) async {
      await tester.pumpWidget(
        _host(
          const SizedBox(
            width: 360,
            child: StarryWorkflowSummary(name: 'Ailore'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ailore'), findsOneWidget);
      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('tap chevron expands only the caller-provided real steps', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const SizedBox(
            width: 360,
            child: StarryWorkflowSummary(
              name: 'Ailore',
              elapsedText: '工作了 49 秒',
              steps: <StarryWorkflowStep>[
                StarryWorkflowStep(
                  icon: Icons.lightbulb_outline,
                  label: '思考已完成',
                ),
                StarryWorkflowStep(
                  icon: Icons.menu_book_outlined,
                  label: '阅读 App.tsx',
                ),
                StarryWorkflowStep(
                  icon: Icons.edit_outlined,
                  label: '编辑 App.tsx',
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Collapsed: chevron present, step labels removed from the tree.
      expect(find.byIcon(Icons.keyboard_arrow_right_rounded), findsOneWidget);
      expect(find.text('思考已完成'), findsNothing);
      expect(find.text('阅读 App.tsx'), findsNothing);

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
      expect(find.text('思考已完成'), findsOneWidget);
      expect(find.text('阅读 App.tsx'), findsOneWidget);
      expect(find.text('编辑 App.tsx'), findsOneWidget);

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();
      expect(find.text('阅读 App.tsx'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
