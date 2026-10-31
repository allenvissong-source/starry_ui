import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

const _items = <StarrySideNavigationItem>[
  StarrySideNavigationItem(
    id: 'chat',
    label: 'Chat',
    icon: Icon(Icons.forum_outlined),
    selectedIcon: Icon(Icons.forum),
  ),
  StarrySideNavigationItem(
    id: 'home',
    label: 'Home',
    icon: Icon(Icons.home_outlined),
  ),
  StarrySideNavigationItem(
    id: 'disabled',
    label: 'Disabled',
    icon: Icon(Icons.block_outlined),
    enabled: false,
  ),
];

Widget _host({
  required Widget child,
  Size size = const Size(320, 640),
  bool disableAnimations = false,
}) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: MediaQuery(
      data: MediaQueryData(size: size, disableAnimations: disableAnimations),
      child: Scaffold(
        body: Align(alignment: Alignment.centerLeft, child: child),
      ),
    ),
  );
}

StarrySideNavigationRail _rail({
  String? selectedId = 'home',
  ValueChanged<String>? onSelected,
  bool collapsed = false,
  Widget? footer,
}) {
  return StarrySideNavigationRail(
    items: _items,
    selectedId: selectedId,
    collapsed: collapsed,
    onItemSelected: onSelected ?? (_) {},
    footer: footer,
  );
}

const _productItems = <StarrySideNavigationItem>[
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

Widget _productHost({bool collapsed = false, Widget? footer}) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          height: 600,
          child: StarrySideNavigationRail(
            collapsed: collapsed,
            items: _productItems,
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
    await tester.pumpWidget(_productHost());

    expect(StarrySideNavigationRail.expandedWidth, 72);
    expect(tester.getSize(find.byType(StarrySideNavigationRail)).width, 72);
  });

  testWidgets('destination renders icon above its centered label', (
    tester,
  ) async {
    await tester.pumpWidget(_productHost());

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
      _productHost(
        footer: const SizedBox(key: footerKey, width: 24, height: 24),
      ),
    );

    final railRect = tester.getRect(find.byType(StarrySideNavigationRail));
    final footerRect = tester.getRect(find.byKey(footerKey));

    expect(railRect.height, 600);
    expect(railRect.bottom - footerRect.bottom, StarryTokens.light.spacing.s4);
  });

  testWidgets('collapsed rail takes no layout width', (tester) async {
    await tester.pumpWidget(_productHost(collapsed: true));

    expect(tester.getSize(find.byType(StarrySideNavigationRail)).width, 0);
  });

  final t = StarryTokens.light;

  testWidgets('renders token-sized rail and reports enabled activation', (
    tester,
  ) async {
    String? selected;
    await tester.pumpWidget(
      _host(child: _rail(onSelected: (id) => selected = id)),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byType(StarrySideNavigationRail)).width,
      StarrySideNavigationRail.widthFor(t),
    );
    await tester.tap(find.text('Chat'));
    expect(selected, 'chat');

    await tester.tap(find.text('Disabled'));
    expect(selected, 'chat');
  });

  testWidgets('selected item uses selected artwork and semantics', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(child: _rail()));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.forum_outlined), findsOneWidget);
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    final semantics = tester.widget<Semantics>(
      find
          .ancestor(of: find.text('Home'), matching: find.byType(Semantics))
          .first,
    );
    expect(semantics.properties.label, 'Home');
    expect(semantics.properties.button, isTrue);
    expect(semantics.properties.selected, isTrue);
    expect(semantics.properties.enabled, isTrue);
    handle.dispose();
  });

  testWidgets('pointer press scales only the icon and restores on cancel', (
    tester,
  ) async {
    await tester.pumpWidget(_host(child: _rail(selectedId: 'chat')));
    await tester.pumpAndSettle();

    final scaleFinder = find.byKey(const ValueKey<String>('chat-icon-scale'));
    AnimatedScale scale() => tester.widget<AnimatedScale>(scaleFinder);
    expect(scale().scale, 1);

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Chat')),
    );
    await tester.pump(t.motion.durationShort);
    expect(scale().scale, t.motion.pressedScale);

    await gesture.cancel();
    await tester.pump();
    expect(scale().scale, 1);
  });

  testWidgets('hover adds no Material state overlay', (tester) async {
    await tester.pumpWidget(_host(child: _rail()));
    await tester.pumpAndSettle();

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.text('Chat')));
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: find.text('Chat'), matching: find.byType(InkWell)),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('keyboard enter activates focused item', (tester) async {
    String? selected;
    await tester.pumpWidget(
      _host(child: _rail(onSelected: (id) => selected = id)),
    );
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(selected, 'chat');
  });

  testWidgets('collapsed rail has zero width and no destination semantics', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(disableAnimations: true, child: _rail(collapsed: true)),
    );
    await tester.pump();

    expect(
      tester.getSize(find.byType(StarrySideNavigationRail)).width,
      t.spacing.s0,
    );
    expect(find.bySemanticsLabel('Chat'), findsNothing);
    handle.dispose();
  });

  testWidgets('short viewport scrolls destinations and keeps footer mounted', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        size: const Size(320, 220),
        child: _rail(footer: const Text('Footer')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('Footer'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
