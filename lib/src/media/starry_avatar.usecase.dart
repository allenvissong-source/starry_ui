import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import 'package:widgetbook/widgetbook.dart';

import '../theme/starry_tokens.dart';
import 'starry_avatar.dart';

@UseCase(name: 'All Sizes', type: StarryAvatar)
Widget allSizesStarryAvatar(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: Wrap(
      spacing: t.spacing.s4,
      runSpacing: t.spacing.s4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        for (final size in StarryAvatarSize.values)
          StarryAvatar(size: size, fallbackText: 'JD'),
        const StarryAvatar(fallbackText: 'Alice'),
        const StarryAvatar(),
        const StarryAvatar(
          fallbackText: 'RS',
          shape: StarryAvatarShape.rounded,
          bordered: true,
        ),
      ],
    ),
  );
}

@UseCase(name: 'Playground', type: StarryAvatar)
Widget playgroundStarryAvatar(BuildContext context) {
  return Center(
    child: StarryAvatar(
      fallbackText: context.knobs.string(label: 'Fallback', initialValue: 'John Doe'),
      bordered: context.knobs.boolean(label: 'Bordered', initialValue: false),
      shape: context.knobs.boolean(label: 'Rounded', initialValue: false)
          ? StarryAvatarShape.rounded
          : StarryAvatarShape.circle,
      size: context.knobs.object.dropdown<StarryAvatarSize>(
        label: 'Size',
        options: StarryAvatarSize.values,
        labelBuilder: (v) => v.name,
      ),
    ),
  );
}
