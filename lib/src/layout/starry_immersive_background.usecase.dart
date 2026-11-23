import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../theme/starry_tokens.dart';
import 'starry_immersive_background.dart';

@UseCase(name: 'Fallback (no image)', type: StarryImmersiveBackground)
Widget fallbackStarryImmersiveBackground(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  // No imageAsset → degrades to the gradient fallback + atmosphere + glows.
  return Stack(
    fit: StackFit.expand,
    children: [
      const StarryImmersiveBackground(),
      Center(
        child: Text(
          '沉浸式背景（回退）',
          style: t.typography.headlineSmall.textStyle.copyWith(
            color: t.semantic.onMedia,
          ),
        ),
      ),
    ],
  );
}

@UseCase(name: 'Playground', type: StarryImmersiveBackground)
Widget playgroundStarryImmersiveBackground(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  final customAtmosphere = context.knobs.boolean(
    label: 'customAtmosphere',
    initialValue: false,
  );
  return StarryImmersiveBackground(
    showAmbientGlows: context.knobs.boolean(
      label: 'showAmbientGlows',
      initialValue: true,
    ),
    atmosphereGradient: customAtmosphere
        ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              t.brand.accentGlow.withValues(alpha: 0.7),
              t.brand.brandGlow.withValues(alpha: 0.3),
            ],
          )
        : null,
  );
}
