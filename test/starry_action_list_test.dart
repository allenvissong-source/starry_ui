import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

Widget _host(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: Center(child: child)),
  );
}

StarryActionItem _item(
  String id, {
  String? group,
  bool disabled = false,
  bool selected = false,
}) {
  return StarryActionItem(
    id: id,
    title: 'Item $id',
    group: group,
    disabled: disabled,
    selected: selected,
    onActivate: () {},
  );
}

void main() {
  group('StarryActionList keyboard navigation', () {
    testWidgets('Enter activates the current row; arrows move focus', (
      tester,
    ) async {
      final selected = <String>[];
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 320,
            child: StarryActionList(
              items: [_item('a'), _item('b'), _item('c')],
              onItemSelected: (item) => selected.add(item.id),
              onClose: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initial active row is the first one.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(selected, ['a']);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(selected, ['a', 'b']);

      // Up wraps from the first row to the last row.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(selected, ['a', 'b', 'c']);
    });

    testWidgets('arrows skip disabled rows', (tester) async {
      final selected = <String>[];
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 320,
            child: StarryActionList(
              items: [_item('a'), _item('b', disabled: true), _item('c')],
              onItemSelected: (item) => selected.add(item.id),
              onClose: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      // Skipped the disabled 'b', activated 'c'.
      expect(selected, ['c']);
    });

    testWidgets('Escape invokes onClose', (tester) async {
      var closed = 0;
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 320,
            child: StarryActionList(
              items: [_item('a')],
              onItemSelected: (_) {},
              onClose: () => closed++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      expect(closed, 1);
    });

    testWidgets('typing in the filter narrows the list', (tester) async {
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 320,
            child: StarryActionList(
              items: [
                _item('a'),
                StarryActionItem(
                  id: 'web',
                  title: 'Web Search',
                  keywords: const ['online'],
                ),
              ],
              onItemSelected: (_) {},
              onClose: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Item a'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'web');
      await tester.pumpAndSettle();
      expect(find.text('Item a'), findsNothing);
      expect(find.text('Web Search'), findsOneWidget);
    });

    testWidgets('group headers are rendered but not activable', (tester) async {
      final selected = <String>[];
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 320,
            child: StarryActionList(
              items: [_item('a', group: 'Runtime')],
              onItemSelected: (item) => selected.add(item.id),
              onClose: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('RUNTIME'), findsOneWidget);

      // Enter activates the row, never the header.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(selected, ['a']);
    });
  });

  group('StarryActionList row states', () {
    testWidgets('disabled row has no ink well tap and stays inert', (
      tester,
    ) async {
      var tapped = 0;
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 320,
            child: StarryActionList(
              items: [_item('a', disabled: true)],
              onItemSelected: (_) => tapped++,
              onClose: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final inkWell = tester.widget<InkWell>(
        find.descendant(
          of: find.byType(StarryActionList),
          matching: find.byType(InkWell),
        ),
      );
      expect(inkWell.onTap, isNull);

      await tester.tap(find.text('Item a'));
      await tester.pumpAndSettle();
      expect(tapped, 0);
    });

    testWidgets('selected row exposes a check affordance', (tester) async {
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 320,
            child: StarryActionList(
              items: [_item('a', selected: true)],
              onItemSelected: (_) {},
              onClose: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });

  group('StarryActionList IME and long text', () {
    testWidgets('arrow, Enter and Esc return ignored during IME composing', (
      tester,
    ) async {
      final selected = <String>[];
      var closed = 0;
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 320,
            child: StarryActionList(
              items: [_item('a'), _item('b')],
              onItemSelected: (item) => selected.add(item.id),
              onClose: () => closed++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Force the internal filter controller into a composing range.
      final field = tester.widget<TextField>(find.byType(TextField));
      field.controller!.value = const TextEditingValue(
        text: 'ni',
        composing: TextRange(start: 0, end: 2),
      );
      await tester.pump();

      // Arrow, Enter and Esc are returned as ignored so the IME/TextField
      // consumes them (candidate navigation, confirm composition, cancel
      // composition). The list must not navigate or close.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      expect(selected, isEmpty);
      expect(closed, 0);

      // Clear composing AND reset the filter so all rows are visible again.
      field.controller!.clear();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(selected, ['b']);
    });

    testWidgets('long title and subtitle ellipsize within narrow width', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 200,
            child: StarryActionList(
              items: const [
                StarryActionItem(
                  id: 'long',
                  title:
                      'ThisIsAVeryLongModelNameThatShouldEllipsizeWhenNarrow',
                  subtitle: 'AlsoAVeryLongSubtitleThatNeedsToEllipsize',
                  onActivate: null,
                ),
              ],
              onItemSelected: (_) {},
              onClose: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final titleText = tester.widget<Text>(
        find
            .descendant(
              of: find.byType(StarryActionList),
              matching: find.byType(Text),
            )
            .first,
      );
      expect(titleText.maxLines, 1);
      expect(titleText.overflow, TextOverflow.ellipsis);
    });

    testWidgets('keyboard selection scrolls the active row into view', (
      tester,
    ) async {
      final items = List.generate(20, (i) => _item('row-$i'));
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 320,
            height: 300,
            child: StarryActionList(
              items: items,
              onItemSelected: (_) {},
              onClose: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final listView = tester.widget<ListView>(
        find.descendant(
          of: find.byType(StarryActionList),
          matching: find.byType(ListView),
        ),
      );
      final controller = listView.controller!;
      final beforeScroll = controller.position.pixels;

      // Move down past the visible rows.
      for (var i = 0; i < 10; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
      }
      await tester.pumpAndSettle();

      expect(controller.position.pixels, greaterThan(beforeScroll));
    });
  });

  group('StarryActionListController external driver', () {
    testWidgets('attached controller moves, activates and closes the list', (
      tester,
    ) async {
      final selected = <String>[];
      var closed = 0;
      final controller = StarryActionListController();
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 320,
            child: StarryActionList(
              controller: controller,
              items: [_item('a'), _item('b'), _item('c')],
              onItemSelected: (item) => selected.add(item.id),
              onClose: () => closed++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(controller.isAttached, isTrue);

      // moveDown advances the highlight; Enter-equivalent activate picks 'b'.
      controller.moveDown();
      await tester.pump();
      controller.activate();
      await tester.pump();
      expect(selected, ['b']);

      controller.close();
      expect(closed, 1);
    });

    testWidgets('unattached controller methods are no-ops; detach on dispose', (
      tester,
    ) async {
      final controller = StarryActionListController();
      expect(controller.isAttached, isFalse);
      // No exception and no state while nothing is attached.
      controller.moveUp();
      controller.moveDown();
      controller.activate();
      controller.close();

      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 320,
            child: StarryActionList(
              controller: controller,
              items: [_item('a')],
              onItemSelected: (_) {},
              onClose: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(controller.isAttached, isTrue);

      // Dispose the list: callbacks drop so a stale driver cannot fire.
      await tester.pumpWidget(_host(const SizedBox.shrink()));
      await tester.pumpAndSettle();
      expect(controller.isAttached, isFalse);
      controller.activate();
      controller.close();
    });
  });

  group('localized label overrides', () {
    testWidgets(
      'custom filter placeholder and empty-state label replace the English '
      'fallbacks',
      (tester) async {
        await tester.pumpWidget(
          _host(
            SizedBox(
              width: 320,
              child: StarryActionList(
                items: [_item('a')],
                filterPlaceholder: 'フィルタ',
                emptyLabel: '一致する項目なし',
                onItemSelected: (_) {},
                onClose: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final field = tester.widget<TextField>(find.byType(TextField));
        expect(field.decoration?.hintText, 'フィルタ');

        // Type a query that matches nothing; the custom empty label renders.
        await tester.enterText(find.byType(TextField), 'zzz');
        await tester.pumpAndSettle();
        expect(find.text('一致する項目なし'), findsOneWidget);
      },
    );
  });
}
