import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

void main() {
  testWidgets('host back works when the local Navigator has no history', (
    tester,
  ) async {
    var backs = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: StarryPageTopBarScope(
          onBack: () => backs++,
          child: const Scaffold(
            appBar: StarryPageTopBar(showDefaultBack: true, titleText: 'Page'),
          ),
        ),
      ),
    );
    expect(
      Navigator.of(tester.element(find.byType(StarryPageTopBar))).canPop(),
      isFalse,
    );
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    expect(backs, 1);
  });

  testWidgets('explicit leading still takes precedence over host back', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: StarryPageTopBarScope(
          onBack: () {},
          child: const Scaffold(
            appBar: StarryPageTopBar(
              showDefaultBack: true,
              leading: Text('Local back'),
            ),
          ),
        ),
      ),
    );
    expect(find.text('Local back'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new), findsNothing);
  });

  for (final sliver in [false, true]) {
    testWidgets('workspace and local actions share layout; sliver=$sliver', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      var menus = 0;
      const actions = [
        StarryTopBarActionItem(icon: Icon(Icons.more_horiz), tooltip: 'More'),
      ];
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: StarryPageTopBarScope(
            onBack: () {},
            rightActions: [
              StarryTopBarActionItem(
                icon: const Icon(Icons.menu_open_rounded),
                tooltip: 'Workspace',
                onPressed: () => menus++,
              ),
            ],
            child: sliver
                ? const Scaffold(
                    body: CustomScrollView(
                      slivers: [
                        StarrySliverPageTopBar(
                          showDefaultBack: true,
                          titleText: 'A long translated page title',
                          rightActions: actions,
                        ),
                      ],
                    ),
                  )
                : const Scaffold(
                    appBar: StarryPageTopBar(
                      showDefaultBack: true,
                      titleText: 'A long translated page title',
                      rightActions: actions,
                    ),
                  ),
          ),
        ),
      );
      final back = tester.getRect(find.byTooltip('Back'));
      final menu = tester.getRect(find.byTooltip('Workspace'));
      final more = tester.getRect(find.byTooltip('More'));
      expect(back.overlaps(menu), isFalse);
      expect(menu.overlaps(more), isFalse);
      expect(back.center.dy, menu.center.dy);
      await tester.tap(find.byTooltip('Workspace'));
      expect(menus, 1);
      expect(tester.takeException(), isNull);
    });
  }
}
