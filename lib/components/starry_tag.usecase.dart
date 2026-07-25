import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import 'package:widgetbook/widgetbook.dart';

import 'starry_tag.dart';

@UseCase(name: 'All States', type: StarryTag)
Widget allStatesStarryTag(BuildContext context) {
  return const Center(
    child: Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        StarryTag(label: '默认', status: StarryTagStatus.neutral),
        StarryTag(label: '成功', status: StarryTagStatus.success),
        StarryTag(label: '警告', status: StarryTagStatus.warning),
        StarryTag(label: '错误', status: StarryTagStatus.error),
      ],
    ),
  );
}

@UseCase(name: 'Playground', type: StarryTag)
Widget playgroundStarryTag(BuildContext context) {
  return Center(
    child: StarryTag(
      label: context.knobs.string(label: 'Label', initialValue: '标签'),
      status: context.knobs.object.dropdown<StarryTagStatus>(
        label: 'Status',
        options: StarryTagStatus.values,
        labelBuilder: (v) => v.name,
      ),
    ),
  );
}
