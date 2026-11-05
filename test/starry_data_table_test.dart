import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

Widget _app(Widget child, Brightness brightness) => MaterialApp(
  theme: brightness == Brightness.light ? AppTheme.light() : AppTheme.dark(),
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

StarryDataTable<String> _table(List<String> rows) => StarryDataTable<String>(
  rows: rows,
  rowKey: (row) => row,
  pageSize: 2,
  empty: const Text('No rows'),
  columns: [
    StarryDataColumn(
      label: 'Name',
      compare: (a, b) => a.compareTo(b),
      cellBuilder: (_, row) => Text(row),
    ),
    StarryDataColumn(
      label: 'Actions',
      cellBuilder: (_, row) =>
          StarryButton(label: 'Edit $row', onPressed: () {}),
    ),
  ],
);

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      '$brightness aligns columns, centers cells and equalizes row heights',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(1200, 700);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          _app(
            StarryDataTable<int>(
              rows: const [0, 1, 2],
              rowKey: (row) => 'row-$row',
              empty: const Text('Empty'),
              columns: [
                StarryDataColumn(
                  label: 'Key ID',
                  flex: 2,
                  compare: (a, b) => a.compareTo(b),
                  cellBuilder: (_, row) =>
                      SelectableText('key-$row', maxLines: 1),
                ),
                StarryDataColumn(
                  label: 'Application',
                  cellBuilder: (_, row) => Text('app-$row'),
                ),
                StarryDataColumn(
                  label: 'Status',
                  cellBuilder: (_, row) => StarryTag(
                    label: row == 2 ? 'Active' : 'Revoked',
                    key: ValueKey('status-$row'),
                  ),
                ),
                StarryDataColumn(
                  label: 'Actions',
                  flex: 2,
                  cellBuilder: (_, row) => row == 2
                      ? StarryDataTableAction(label: 'Rotate', onPressed: () {})
                      : const SizedBox.shrink(),
                ),
              ],
            ),
            brightness,
          ),
        );
        final heights = [
          for (var row = 0; row < 3; row++)
            tester.getSize(find.byKey(ValueKey<Object>('row-$row'))).height,
        ];
        expect(heights.toSet(), hasLength(1));
        for (var row = 0; row < 3; row++) {
          final rowRect = tester.getRect(
            find.byKey(ValueKey<Object>('row-$row')),
          );
          expect(
            tester.getCenter(find.text('key-$row')).dy,
            closeTo(rowRect.center.dy, 0.01),
          );
          expect(
            tester.getCenter(find.byKey(ValueKey('status-$row'))).dy,
            closeTo(rowRect.center.dy, 0.01),
          );
          expect(
            tester.getTopLeft(find.text('Key ID')).dx,
            closeTo(tester.getTopLeft(find.text('key-$row')).dx, 0.01),
          );
          expect(
            tester.getTopLeft(find.text('Application')).dx,
            closeTo(tester.getTopLeft(find.text('app-$row')).dx, 0.01),
          );
        }
        expect(
          tester.getCenter(find.text('Rotate')).dy,
          closeTo(
            tester
                .getRect(find.byKey(const ValueKey<Object>('row-2')))
                .center
                .dy,
            0.01,
          ),
        );
        expect(
          tester.getTopLeft(find.text('Actions')).dx,
          closeTo(tester.getTopLeft(find.text('Rotate')).dx, 0.01),
        );
        expect(
          tester.getSize(find.byType(TextButton).last).height,
          greaterThanOrEqualTo(48),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final brightness in Brightness.values) {
    for (final width in [360.0, 1200.0]) {
      testWidgets('$brightness $width sorts, pages and resets on filtering', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 1000);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(_app(_table(['C', 'A', 'B']), brightness));
        expect(find.text('C'), findsOneWidget);
        expect(find.text('B'), findsNothing);
        await tester.tap(find.widgetWithText(TextButton, 'Name'));
        await tester.pumpAndSettle();
        expect(find.text('C'), findsNothing);
        expect(find.text('A'), findsOneWidget);
        await tester.tap(find.widgetWithText(StarryButton, 'Next page'));
        await tester.pumpAndSettle();
        expect(find.text('C'), findsOneWidget);
        expect(find.text('Edit C'), findsOneWidget);
        await tester.pumpWidget(_app(_table(['A']), brightness));
        await tester.pumpAndSettle();
        expect(find.text('A'), findsOneWidget);
        expect(find.text('C'), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('sort supports keyboard activation and empty/error states', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_table(['B', 'A']), Brightness.light));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    final a = tester.getTopLeft(find.text('A')).dy;
    final b = tester.getTopLeft(find.text('B')).dy;
    expect(a, lessThan(b));
    await tester.pumpWidget(_app(_table([]), Brightness.light));
    expect(find.text('No rows'), findsOneWidget);
    await tester.pumpWidget(
      _app(
        StarryDataTable<String>(
          rows: const [],
          columns: [
            StarryDataColumn(label: 'Name', cellBuilder: (_, row) => Text(row)),
          ],
          rowKey: (row) => row,
          empty: const Text('No rows'),
          error: const Text('Load failed'),
        ),
        Brightness.dark,
      ),
    );
    expect(find.text('Load failed'), findsOneWidget);
    expect(find.text('No rows'), findsNothing);
  });
}
