import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import 'package:widgetbook/widgetbook.dart';

import 'starry_card.dart';

@UseCase(name: 'Default', type: StarryCard)
Widget defaultStarryCard(BuildContext context) {
  return const Center(
    child: StarryCard(
      title: '卡片标题',
      body: '表面色、文字、描边与圆角绑定变量，阴影使用 shadow/md 规范。',
      actionLabel: '查看详情 →',
    ),
  );
}

@UseCase(name: 'Flat', type: StarryCard)
Widget flatStarryCard(BuildContext context) {
  return const Center(
    child: StarryCard(
      title: '卡片标题',
      body: '仅描边、无阴影的扁平卡片。',
      elevated: false,
    ),
  );
}

@UseCase(name: 'Playground', type: StarryCard)
Widget playgroundStarryCard(BuildContext context) {
  return Center(
    child: StarryCard(
      title: context.knobs.string(label: 'Title', initialValue: '卡片标题'),
      body: context.knobs.stringOrNull(
        label: 'Body',
        initialValue: '表面色、文字、描边与圆角绑定变量，阴影使用 shadow/md 规范。',
      ),
      actionLabel: context.knobs.stringOrNull(
        label: 'Action',
        initialValue: '查看详情 →',
      ),
      elevated: context.knobs.boolean(label: 'Elevated', initialValue: true),
    ),
  );
}
