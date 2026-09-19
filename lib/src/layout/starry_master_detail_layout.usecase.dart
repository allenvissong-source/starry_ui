import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../navigation/starry_navigation_pane.dart';
import 'starry_master_detail_layout.dart';

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
        id: 'favorites',
        label: '收藏',
        icon: Icons.star_border_rounded,
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
    ],
  ),
];

@UseCase(name: 'All Variants', type: StarryMasterDetailLayout)
Widget allVariantsStarryMasterDetailLayout(BuildContext context) {
  return const Column(
    children: [
      Expanded(child: _Demo(width: 1000, label: 'sideBySide · 1000pt')),
      Divider(height: 1),
      // sideBySide with the host-hide pane: detail reclaims the full width.
      Expanded(
        child: _Demo(
          width: 1000,
          label: 'sideBySide · 1000pt · pane hidden',
          paneVisible: false,
        ),
      ),
      Divider(height: 1),
      Expanded(child: _Demo(width: 700, label: 'overlay · 700pt')),
    ],
  );
}

@UseCase(name: 'Playground', type: StarryMasterDetailLayout)
Widget playgroundStarryMasterDetailLayout(BuildContext context) {
  final width = context.knobs.double.slider(
    label: 'Available width',
    initialValue: 1000,
    min: 400,
    max: 1400,
  );
  return _Demo(width: width, label: 'width=${width.round()}pt');
}

class _Demo extends StatefulWidget {
  const _Demo({
    required this.width,
    required this.label,
    this.paneVisible = true,
  });

  final double width;
  final String label;
  final bool paneVisible;

  @override
  State<_Demo> createState() => _DemoState();
}

class _DemoState extends State<_Demo> {
  late bool _paneVisible = widget.paneVisible;
  String _selected = 'profile';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: widget.width,
        child: StarryMasterDetailLayout(
          paneVisible: _paneVisible,
          onPaneVisibleChanged: (v) => setState(() => _paneVisible = v),
          pane: StarryNavigationPane(
            sections: _sections,
            selectedId: _selected,
            onItemSelected: (id) => setState(() {
              _selected = id;
              _paneVisible = true;
            }),
          ),
          detail: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.label),
                Text('selected: $_selected'),
                TextButton(
                  onPressed: () => setState(() => _paneVisible = !_paneVisible),
                  child: Text(_paneVisible ? 'Hide pane' : 'Show pane'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
