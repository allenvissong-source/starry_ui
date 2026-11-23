import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../theme/starry_tokens.dart';
import 'starry_dock_bar.dart';
import 'starry_round_action_button.dart';

const List<StarryNavItem> _demoItems = <StarryNavItem>[
  StarryNavItem(
    label: 'Home',
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
  ),
  StarryNavItem(
    label: 'Search',
    icon: Icons.search_outlined,
    activeIcon: Icons.search,
  ),
  StarryNavItem(
    label: 'Me',
    icon: Icons.person_outline,
    activeIcon: Icons.person,
  ),
];

class _DockBarHarness extends StatefulWidget {
  const _DockBarHarness({required this.leading});

  final bool leading;

  @override
  State<_DockBarHarness> createState() => _DockBarHarnessState();
}

class _DockBarHarnessState extends State<_DockBarHarness> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    return Padding(
      padding: EdgeInsets.all(t.spacing.s10),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: StarryDockBar(
          items: _demoItems,
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          leading: widget.leading
              ? StarryRoundActionButton(
                  onTap: () {},
                  semanticsLabel: 'AI',
                  child: const Icon(Icons.auto_awesome, size: 20),
                )
              : null,
        ),
      ),
    );
  }
}

@UseCase(name: 'Default', type: StarryDockBar)
Widget defaultStarryDockBar(BuildContext context) {
  return const _DockBarHarness(leading: false);
}

@UseCase(name: 'With Leading Action', type: StarryDockBar)
Widget leadingStarryDockBar(BuildContext context) {
  return const _DockBarHarness(leading: true);
}

@UseCase(name: 'Playground', type: StarryDockBar)
Widget playgroundStarryDockBar(BuildContext context) {
  final leading = context.knobs.boolean(
    label: 'Leading action',
    initialValue: true,
  );
  return _DockBarHarness(leading: leading);
}
