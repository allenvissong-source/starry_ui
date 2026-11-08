import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../../starry_ui.dart';

const _paths = [
  'SKILL.md',
  'references/role-core.md',
  'references/behavior.md',
  'references/examples.md',
];

@UseCase(name: 'All Variants', type: StarryFileTree)
Widget allVariantsStarryFileTree(BuildContext context) {
  final t = context.starryTokens;
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: const _FileTreeDemo(),
  );
}

@UseCase(name: 'Playground', type: StarryFileTree)
Widget playgroundStarryFileTree(BuildContext context) => _FileTreeDemo(
  label: context.knobs.string(label: 'Label', initialValue: '内容与文件'),
);

class _FileTreeDemo extends StatefulWidget {
  const _FileTreeDemo({this.label = '内容与文件'});
  final String label;
  @override
  State<_FileTreeDemo> createState() => _FileTreeDemoState();
}

class _FileTreeDemoState extends State<_FileTreeDemo> {
  String _path = 'SKILL.md';
  @override
  Widget build(BuildContext context) => StarryFileTree(
    paths: _paths,
    selectedPath: _path,
    onSelected: (path) => setState(() => _path = path),
    label: widget.label,
  );
}
