import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import 'package:widgetbook/widgetbook.dart';

import '../theme/starry_tokens.dart';
import 'starry_tag.dart';

@UseCase(name: 'All Variants', type: StarryTag)
Widget allStatesStarryTag(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: Wrap(
      spacing: t.spacing.s4,
      runSpacing: t.spacing.s4,
      children: const <Widget>[
        StarryTag(label: '默认', status: StarryTagStatus.neutral),
        StarryTag(label: '成功', status: StarryTagStatus.success),
        StarryTag(label: '警告', status: StarryTagStatus.warning),
        StarryTag(label: '错误', status: StarryTagStatus.error),
        StarryTag(label: 'AI', status: StarryTagStatus.accent),
        StarryTag(
          label: '已启用',
          status: StarryTagStatus.success,
          leading: Icon(Icons.check),
        ),
        StarryTag(
          label: '媒体标签',
          onMedia: true,
          leading: Icon(Icons.image_outlined),
        ),
      ],
    ),
  );
}

@UseCase(name: 'Playground', type: StarryTag)
Widget playgroundStarryTag(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  final onMedia = context.knobs.boolean(label: 'On Media', initialValue: false);
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: Container(
      color: onMedia
          ? const Color(0xFF334155)
          : null, // hardcode-allow: 画廊演示用的深色媒体背板,仅为展示 onMedia 效果,非被消费的组件配色
      padding: onMedia ? EdgeInsets.all(t.spacing.s4) : EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          StarryTag(
            leading:
                context.knobs.boolean(label: 'Leading', initialValue: false)
                ? const Icon(Icons.info_outline)
                : null,
            label: context.knobs.string(label: 'Label', initialValue: '标签'),
            status: context.knobs.object.dropdown<StarryTagStatus>(
              label: 'Status',
              options: StarryTagStatus.values,
              labelBuilder: (v) => v.name,
            ),
            onMedia: onMedia,
          ),
        ],
      ),
    ),
  );
}
