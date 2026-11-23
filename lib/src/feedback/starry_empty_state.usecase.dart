import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import 'package:starry_ui/starry_ui.dart';

@UseCase(name: 'All Variants', type: StarryEmptyState)
Widget allVariantsStarryEmptyState(BuildContext context) {
  return SingleChildScrollView(
    child: Column(
      children: [
        const StarryEmptyState(
          illustration: StarryIllustration.noContent,
          title: '这里还没有内容',
        ),
        defaultStarryEmptyState(context),
        withActionStarryEmptyState(context),
      ],
    ),
  );
}

@UseCase(name: 'Default', type: StarryEmptyState)
Widget defaultStarryEmptyState(BuildContext context) {
  return const StarryEmptyState(title: '暂无数据', message: '这里还什么都没有，稍后再来看看。');
}

@UseCase(name: 'With Action', type: StarryEmptyState)
Widget withActionStarryEmptyState(BuildContext context) {
  return StarryEmptyState(
    icon: const Icon(Icons.search_off_outlined),
    title: '没有搜索结果',
    message: '试试换一个关键词。',
    action: StarryButton(label: '重新搜索', onPressed: () {}),
  );
}

@UseCase(name: 'Playground', type: StarryEmptyState)
Widget playgroundStarryEmptyState(BuildContext context) {
  final illustrated = context.knobs.boolean(
    label: 'No content illustration',
    initialValue: true,
  );
  return StarryEmptyState(
    illustration: illustrated ? StarryIllustration.noContent : null,
    title: context.knobs.string(label: 'Title', initialValue: '暂无数据'),
    message: context.knobs.stringOrNull(
      label: 'Message',
      initialValue: '这里还什么都没有。',
    ),
  );
}
