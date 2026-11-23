import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../theme/starry_tokens.dart';
import 'starry_metric_button.dart';

@UseCase(name: 'All States', type: StarryMetricButton)
Widget allStatesStarryMetricButton(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: Wrap(
      spacing: t.spacing.s6,
      runSpacing: t.spacing.s4,
      children: <Widget>[
        StarryMetricButton(
          icon: Icons.favorite_border,
          count: 128,
          semanticLabel: 'Likes',
          onTap: () {},
        ),
        StarryMetricButton(
          icon: Icons.favorite_border,
          activeIcon: Icons.favorite,
          count: 12345,
          active: true,
          semanticLabel: 'Likes',
          onTap: () {},
        ),
        StarryMetricButton(
          icon: Icons.comment_outlined,
          count: 99999,
          disabled: true,
          semanticLabel: 'Comments',
          onTap: () {},
        ),
        StarryMetricButton(
          icon: Icons.share_outlined,
          count: 3,
          loading: true,
          semanticLabel: 'Share',
          onTap: () {},
        ),
      ],
    ),
  );
}

@UseCase(name: 'On Media', type: StarryMetricButton)
Widget onMediaStarryMetricButton(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Center(
    child: Container(
      color: const Color(
        0xFF334155,
      ), // hardcode-allow: 画廊演示用的深色媒体背板,仅展示 onMedia 效果,非被消费的组件配色
      padding: EdgeInsets.all(t.spacing.s6),
      child: StarryMetricButton(
        icon: Icons.favorite,
        count: 88000,
        tone: StarryMetricTone.onMedia,
        semanticLabel: 'Likes',
        onTap: () {},
      ),
    ),
  );
}
