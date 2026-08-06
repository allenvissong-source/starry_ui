import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../theme/starry_tokens.dart';
import 'starry_badge.dart';

@UseCase(name: 'All Variants', type: StarryBadge)
Widget allVariantsStarryBadge(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: Wrap(
      spacing: t.spacing.s4,
      runSpacing: t.spacing.s4,
      children: const <Widget>[
        StarryBadge(
          count: 3,
          child: Icon(Icons.notifications_outlined, size: 32),
        ),
        StarryBadge(
          count: 128,
          child: Icon(Icons.mail_outline, size: 32),
        ),
        StarryBadge(
          showDot: true,
          child: Icon(Icons.chat_bubble_outline, size: 32),
        ),
        StarryBadge(
          count: 5,
          position: StarryBadgePosition.bottomStart,
          child: Icon(Icons.person_outline, size: 32),
        ),
      ],
    ),
  );
}

@UseCase(name: 'Playground', type: StarryBadge)
Widget playgroundStarryBadge(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        StarryBadge(
          count: context.knobs.int.slider(
            label: 'Count',
            initialValue: 5,
            min: 0,
            max: 150,
          ),
          maxCount: context.knobs.int.slider(
            label: 'Max count',
            initialValue: 99,
            min: 9,
            max: 999,
          ),
          showDot: context.knobs.boolean(label: 'Show dot'),
          animate: context.knobs.boolean(label: 'Animate', initialValue: true),
          position: context.knobs.object.dropdown<StarryBadgePosition>(
            label: 'Position',
            options: StarryBadgePosition.values,
            labelBuilder: (v) => v.name,
          ),
          child: const Icon(Icons.notifications_outlined, size: 36),
        ),
      ],
    ),
  );
}
