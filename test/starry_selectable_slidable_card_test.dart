import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';
import 'package:starry_ui/src/interactions/starry_swipeable.dart';

Widget _host({
  required Widget child,
  Brightness brightness = Brightness.light,
}) {
  return MaterialApp(
    theme: brightness == Brightness.light ? AppTheme.light() : AppTheme.dark(),
    home: Scaffold(
      body: Center(child: SizedBox(width: 360, child: child)),
    ),
  );
}

List<StarrySwipeAction> _actions(StarryTokens tokens) => <StarrySwipeAction>[
  StarrySwipeAction(
    label: '删除',
    icon: Icons.delete_outline,
    backgroundColor: tokens.semantic.error,
    foregroundColor: tokens.semantic.onError,
    onTap: () {},
  ),
];

void main() {
  group('StarrySelectableSlidableCard', () {
    for (final brightness in Brightness.values) {
      testWidgets('owns a single clipped surface in $brightness', (
        tester,
      ) async {
        final tokens = brightness == Brightness.light
            ? StarryTokens.light
            : StarryTokens.dark;
        await tester.pumpWidget(
          _host(
            brightness: brightness,
            child: StarrySelectableSlidableCard(
              selected: true,
              actions: _actions(tokens),
              onTap: () {},
              child: const SizedBox(height: 56, child: Text('Ailore')),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Ailore'), findsOneWidget);
        expect(find.byType(StarrySwipeable), findsOneWidget);
        expect(find.byType(ClipRRect), findsOneWidget);
        expect(tester.takeException(), isNull);

        final swipeable = tester.widget<StarrySwipeable>(
          find.byType(StarrySwipeable),
        );
        expect(swipeable.backgroundColor, isNotNull);
      });
    }

    testWidgets('closed content completely covers trailing actions', (
      tester,
    ) async {
      final tokens = StarryTokens.light;
      await tester.pumpWidget(
        _host(
          child: StarrySelectableSlidableCard(
            actions: _actions(tokens),
            onTap: () {},
            child: const SizedBox(height: 56, child: Text('Ailore')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final cardRect = tester.getRect(
        find.byType(StarrySelectableSlidableCard),
      );
      final swipeableRect = tester.getRect(find.byType(StarrySwipeable));
      expect(swipeableRect, cardRect);

      await tester.drag(find.text('Ailore'), const Offset(-120, 0));
      await tester.pumpAndSettle();
      expect(find.text('删除'), findsOneWidget);
    });
  });
}
