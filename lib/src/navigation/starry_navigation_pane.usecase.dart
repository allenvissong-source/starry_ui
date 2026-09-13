import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import 'starry_navigation_pane.dart';

const _sections = [
  StarryNavigationSection(
    title: '个人',
    items: [
      StarryNavigationItem(
        id: 'profile',
        label: '个人资料',
        icon: Icons.badge_outlined,
      ),
      StarryNavigationItem(
        id: 'memory',
        label: '记忆',
        icon: Icons.history_rounded,
        enabled: false,
      ),
      StarryNavigationItem(
        id: 'personas',
        label: '人设',
        icon: Icons.badge_rounded,
      ),
    ],
  ),
  StarryNavigationSection(
    title: '模型',
    items: [
      StarryNavigationItem(
        id: 'model',
        label: '模型服务',
        icon: Icons.cloud_outlined,
      ),
      StarryNavigationItem(
        id: 'default-model',
        label: '默认模型',
        icon: Icons.smart_toy_outlined,
      ),
    ],
  ),
];

@UseCase(name: 'All Variants', type: StarryNavigationPane)
Widget allVariantsStarryNavigationPane(BuildContext context) {
  return const Center(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Resting: an active row is marked, the disabled row stays inert.
        SizedBox(width: 256, child: _Demo(selected: 'profile')),
        SizedBox(width: 256, child: _Demo(selected: null)),
      ],
    ),
  );
}

@UseCase(name: 'Playground', type: StarryNavigationPane)
Widget playgroundStarryNavigationPane(BuildContext context) {
  final selected = context.knobs.object.dropdown<String>(
    label: 'selectedId',
    options: const ['profile', 'personas', 'model', 'default-model'],
  );
  final width = context.knobs.double.slider(
    label: 'Pane width',
    initialValue: 256,
    min: 200,
    max: 360,
  );
  return Center(
    child: SizedBox(width: width, child: _Demo(selected: selected)),
  );
}

class _Demo extends StatefulWidget {
  const _Demo({required this.selected});

  final String? selected;

  @override
  State<_Demo> createState() => _DemoState();
}

class _DemoState extends State<_Demo> {
  String? _selected;

  @override
  void didUpdateWidget(covariant _Demo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) _selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return StarryNavigationPane(
      sections: _sections,
      selectedId: _selected ?? widget.selected,
      onItemSelected: (id) => setState(() => _selected = id),
    );
  }
}
