import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

const _items = <StarrySideNavigationItem>[
  StarrySideNavigationItem(
    id: 'chat',
    label: '聊天',
    icon: Icon(Icons.chat_bubble_outline),
  ),
  StarrySideNavigationItem(
    id: 'cluster',
    label: '星团',
    icon: Icon(Icons.home_outlined),
  ),
];

Widget _host({bool collapsed = false, Widget? footer}) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          height: 600,
          child: StarrySideNavigationRail(
            collapsed: collapsed,
            items: _items,
            selectedId: 'cluster',
            footer: footer,
            onItemSelected: (_) {},
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('expanded rail keeps the 72px product width contract', (
    tester,
  ) async {
    await tester.pumpWidget(_host());

    expect(StarrySideNavigationRail.expandedWidth, 72);
    expect(tester.getSize(find.byType(StarrySideNavigationRail)).width, 72);
  });

  testWidgets('destination renders icon above its centered label', (
    tester,
  ) async {
    await tester.pumpWidget(_host());

    final iconCenter = tester.getCenter(find.byIcon(Icons.chat_bubble_outline));
    final labelCenter = tester.getCenter(find.text('聊天'));

    expect(iconCenter.dy, lessThan(labelCenter.dy));
    expect(iconCenter.dx, closeTo(labelCenter.dx, 0.5));
  });

  testWidgets('footer stays at the bottom of the full-height rail', (
    tester,
  ) async {
    const footerKey = Key('rail-footer-content');
    await tester.pumpWidget(
      _host(footer: const SizedBox(key: footerKey, width: 24, height: 24)),
    );

    final railRect = tester.getRect(find.byType(StarrySideNavigationRail));
    final footerRect = tester.getRect(find.byKey(footerKey));

    expect(railRect.height, 600);
    expect(railRect.bottom - footerRect.bottom, StarryTokens.light.spacing.s4);
  });

  testWidgets('collapsed rail takes no layout width', (tester) async {
    await tester.pumpWidget(_host(collapsed: true));

    expect(tester.getSize(find.byType(StarrySideNavigationRail)).width, 0);
  });
}
