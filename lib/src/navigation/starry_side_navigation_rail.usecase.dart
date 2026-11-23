import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../theme/starry_tokens.dart';
import 'starry_side_navigation_rail.dart';

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
    selectedIcon: Icon(Icons.home),
  ),
  StarrySideNavigationItem(
    id: 'square',
    label: 'Square',
    icon: Icon(Icons.sports_esports_outlined),
  ),
  StarrySideNavigationItem(
    id: 'disabled',
    label: 'Disabled',
    icon: Icon(Icons.block_outlined),
    enabled: false,
  ),
];

class _RailDemo extends StatefulWidget {
  const _RailDemo({required this.collapsed, this.initialSelected = 'home'});

  final bool collapsed;
  final String? initialSelected;

  @override
  State<_RailDemo> createState() => _RailDemoState();
}

class _RailDemoState extends State<_RailDemo> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelected;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        height: t.spacing.s16 * 7,
        child: StarrySideNavigationRail(
          items: _items,
          selectedId: _selected,
          collapsed: widget.collapsed,
          onItemSelected: (id) => setState(() => _selected = id),
          footer: IconButton(
            tooltip: 'Settings',
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined),
          ),
        ),
      ),
    );
  }
}

@UseCase(name: 'All Variants', type: StarrySideNavigationRail)
Widget allVariantsStarrySideNavigationRail(BuildContext context) {
  return const _RailDemo(collapsed: false);
}

@UseCase(name: 'Playground', type: StarrySideNavigationRail)
Widget playgroundStarrySideNavigationRail(BuildContext context) {
  final collapsed = context.knobs.boolean(label: 'Collapsed');
  final selected = context.knobs.object.dropdown<String?>(
    label: 'Selected',
    options: const [null, 'chat', 'home', 'square'],
    initialOption: 'home',
    labelBuilder: (value) => value ?? 'None',
  );
  return _RailDemo(collapsed: collapsed, initialSelected: selected);
}
