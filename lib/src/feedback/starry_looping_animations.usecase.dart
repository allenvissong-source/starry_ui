import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../theme/starry_tokens.dart';
import 'starry_looping_animations.dart';

@UseCase(name: 'Pulsing', type: StarryPulsingWidget)
Widget pulsingStarryLoopingAnimation(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Center(
    child: StarryPulsingWidget(
      enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
      child: Container(
        width: 120,
        height: 16,
        decoration: BoxDecoration(
          color: t.semantic.surfaceVariant,
          borderRadius: BorderRadius.circular(t.radius.sm),
        ),
      ),
    ),
  );
}

@UseCase(name: 'Rotating', type: StarryRotatingWidget)
Widget rotatingStarryLoopingAnimation(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Center(
    child: StarryRotatingWidget(
      enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
      clockwise: context.knobs.boolean(label: 'Clockwise', initialValue: true),
      child: Icon(Icons.refresh, color: t.semantic.brand),
    ),
  );
}

@UseCase(name: 'Scaling', type: StarryScalingWidget)
Widget scalingStarryLoopingAnimation(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Center(
    child: StarryScalingWidget(
      enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
      child: Icon(Icons.favorite, color: t.semantic.brand),
    ),
  );
}
