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

      expect(
        tester.widget<AnimatedRotation>(find.byType(AnimatedRotation)).turns,
        0.25,
      );
      expect(find.text('思考已完成'), findsOneWidget);
      expect(find.text('阅读 App.tsx'), findsOneWidget);
      expect(find.text('编辑 App.tsx'), findsOneWidget);

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();
      expect(find.text('阅读 App.tsx'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('live steps collapse once on completion and can reopen', (
      tester,
    ) async {
      Widget workflow(bool running) => _host(
        SizedBox(
          width: 360,
          child: StarryWorkflowSummary(
            name: 'Starry',
            elapsedText: '工作 49 秒',
            isRunning: running,
            steps: const [StarryWorkflowStep(label: '读取文件')],
          ),
        ),
      );
      await tester.pumpWidget(workflow(true));
      await tester.pumpAndSettle();
      expect(find.text('读取文件'), findsOneWidget);

      // A manual collapse during execution survives an event refresh.
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();
      await tester.pumpWidget(workflow(true));
      expect(find.text('读取文件'), findsNothing);
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      await tester.pumpWidget(workflow(false));
      await tester.pumpAndSettle();
      expect(find.text('读取文件'), findsNothing);
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();
      await tester.pumpWidget(workflow(false));
      expect(find.text('读取文件'), findsOneWidget);
    });

    testWidgets(
      'chevron follows elapsed and expansion has intermediate sizes',
      (tester) async {
        await tester.pumpWidget(
          _host(
            const SizedBox(
              width: 640,
              child: StarryWorkflowSummary(
                name: 'Starry',
                elapsedText: '工作 49 秒',
                steps: [
                  StarryWorkflowStep(label: '读取文件'),
                  StarryWorkflowStep(label: '确认结果'),
                ],
              ),
            ),
          ),
        );
        final arrow = tester.getRect(
          find.byIcon(Icons.keyboard_arrow_right_rounded),
        );
        final elapsed = tester.getRect(find.text('工作 49 秒'));
        expect(arrow.left - elapsed.right, inInclusiveRange(0, 8));
        final collapsed = tester
            .getSize(find.byType(StarryWorkflowSummary))
            .height;
        await tester.tap(find.byType(InkWell));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 75));
        final intermediate = tester
            .getSize(find.byType(StarryWorkflowSummary))
            .height;
        await tester.pumpAndSettle();
        final expanded = tester
            .getSize(find.byType(StarryWorkflowSummary))
            .height;
        expect(intermediate, greaterThan(collapsed));
        expect(intermediate, lessThan(expanded));
        await tester.tap(find.byType(InkWell));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 75));
        expect(
          tester.getSize(find.byType(StarryWorkflowSummary)).height,
          inExclusiveRange(collapsed, expanded),
        );
        await tester.pumpAndSettle();
        expect(find.text('读取文件'), findsNothing);
      },
    );

    testWidgets(
      'narrow header keeps chevron visible and reduced motion settles',
      (tester) async {
        await tester.pumpWidget(
          _host(
            MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: const SizedBox(
                width: 160,
                child: StarryWorkflowSummary(
                  name: '一个很长的助手名称',
                  elapsedText: '工作 49 秒',
                  steps: [StarryWorkflowStep(label: '读取文件')],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byType(InkWell));
        await tester.pumpAndSettle();
        expect(find.text('读取文件'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
