import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import '../../starry_ui.dart';

@UseCase(name: 'All Variants', type: StarryExpandableCard)
Widget allVariantsStarryExpandableCard(BuildContext context) {
  final t = context.starryTokens;
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const StarryExpandableCard(header: Text('折叠'), children: [Text('内容')]),
        SizedBox(height: t.spacing.s4),
        StarryExpandableCard(
          header: const Text('展开，带独立操作'),
          initiallyExpanded: true,
          headerActions: StarryIconButton(
            icon: Icons.more_horiz,
            tooltip: '更多操作',
            onPressed: () {},
          ),
          children: const [Text('内容')],
        ),
        SizedBox(height: t.spacing.s4),
        const StarryExpandableCard(
          header: Text('保留编辑状态'),
          maintainState: true,
          children: [StarryTextField(label: '草稿')],
        ),
      ],
    ),
  );
}

@UseCase(name: 'Playground', type: StarryExpandableCard)
Widget playgroundStarryExpandableCard(BuildContext context) {
  final t = context.starryTokens;
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: StarryExpandableCard(
      header: Text(context.knobs.string(label: 'Header', initialValue: '高级选项')),
      expanded: context.knobs.boolean(label: 'Expanded', initialValue: false),
      maintainState: context.knobs.boolean(
        label: 'Maintain state',
        initialValue: true,
      ),
      headerActions: StarryIconButton(
        icon: Icons.more_horiz,
        tooltip: '更多操作',
        onPressed: () {},
      ),
      children: const [StarryTextField(label: '备注')],
    ),
  );
}
