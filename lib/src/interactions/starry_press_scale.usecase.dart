import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../theme/starry_tokens.dart';
import 'starry_press_scale.dart';

@UseCase(name: 'Default', type: StarryPressScale)
Widget defaultStarryPressScale(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  final s = t.semantic;
  return Center(
    child: StarryPressScale(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: t.spacing.s6,
          vertical: t.spacing.s4,
        ),
        decoration: BoxDecoration(
          color: s.brand,
          borderRadius: BorderRadius.circular(t.radius.lg),
          boxShadow: t.elevation.level2,
        ),
        child: Text(
          'Press me',
          style: t.typography.titleSmall.textStyle.copyWith(color: s.onBrand),
        ),
      ),
    ),
  );
}
