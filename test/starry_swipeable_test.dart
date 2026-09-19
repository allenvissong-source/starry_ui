import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

Widget _host(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: Center(child: child)),
  );
}

List<StarrySwipeAction> _actions(
  StarryTokens tokens, {
  VoidCallback? onDelete,
}) {
  final s = tokens.semantic;
  return <StarrySwipeAction>[
    StarrySwipeAction(
      label: '删除',
      icon: Icons.delete_outline,
      backgroundColor: s.error,
      foregroundColor: s.onError,
      onTap: onDelete ?? () {},
    ),
  ];
}

void main() {
  final tokens = StarryTokens.light;

  group('StarrySwipeable', () {
    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 320,
            child: StarrySwipeable(
              actions: _actions(tokens),
              child: const SizedBox(height: 60, child: Text('row body')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('row body'), findsOneWidget);
    });

    testWidgets(
      'swiping left reveals the action, tapping it fires and closes',
      (tester) async {
        var deleted = false;
        await tester.pumpWidget(
          _host(
            SizedBox(
              width: 320,
              child: StarrySwipeable(
                actions: _actions(tokens, onDelete: () => deleted = true),
                child: const SizedBox(height: 60, child: Text('row body')),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Drag the content left far enough to open the action row.
        await tester.drag(find.text('row body'), const Offset(-120, 0));
        await tester.pumpAndSettle();

        expect(find.text('删除'), findsOneWidget);
        await tester.tap(find.text('删除'));
        await tester.pumpAndSettle();
        expect(deleted, isTrue);
      },
    );

    testWidgets('no actions disables swipe (action never appears)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 320,
            child: StarrySwipeable(
              actions: const <StarrySwipeAction>[],
              child: const SizedBox(height: 60, child: Text('row body')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.text('row body'), const Offset(-120, 0));
      await tester.pumpAndSettle();
      expect(find.text('删除'), findsNothing);
    });
  });

  group('StarrySlidableDrawer', () {
    testWidgets('delegates to StarrySwipeable and reveals inset action chips', (
      tester,
    ) async {
      var deleted = false;
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 360,
            child: StarrySlidableDrawer(
              actions: _actions(tokens, onDelete: () => deleted = true),
              child: const SizedBox(height: 60, child: Text('drawer body')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StarrySwipeable), findsOneWidget);
      expect(find.text('drawer body'), findsOneWidget);

      await tester.drag(find.text('drawer body'), const Offset(-120, 0));
      await tester.pumpAndSettle();

      await tester.tap(find.text('删除'));
      await tester.pumpAndSettle();
      expect(deleted, isTrue);
    });
  });
}
