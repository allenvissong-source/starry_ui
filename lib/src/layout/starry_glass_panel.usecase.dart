import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../theme/starry_tokens.dart';
import 'starry_glass_panel.dart';

@UseCase(name: 'Default', type: StarryGlassPanel)
Widget defaultStarryGlassPanel(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [t.brand.primaryPale, t.brand.accentGradientEnd],
      ),
    ),
    child: Center(
      child: StarryGlassPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('玻璃面板', style: t.typography.titleLarge.textStyle),
            SizedBox(height: t.spacing.s2),
            Text('半透明磨砂表面，浮于媒体背景之上。', style: t.typography.bodyMedium.textStyle),
          ],
        ),
      ),
    ),
  );
}

@UseCase(name: 'Playground', type: StarryGlassPanel)
Widget playgroundStarryGlassPanel(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [t.brand.primaryPale, t.brand.accentGradientEnd],
      ),
    ),
    child: Center(
      child: StarryGlassPanel(
        borderRadius: context.knobs.double.slider(
          label: 'borderRadius',
          initialValue: 34,
          min: 0,
          max: 48,
        ),
        blurSigma: context.knobs.double.slider(
          label: 'blurSigma',
          initialValue: 22,
          min: 0,
          max: 40,
        ),
        child: Text('玻璃面板', style: t.typography.titleLarge.textStyle),
      ),
    ),
  );
}
