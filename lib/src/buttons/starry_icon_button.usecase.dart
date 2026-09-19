import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../theme/starry_tokens.dart';
import 'starry_icon_button.dart';

@UseCase(name: 'All Variants', type: StarryIconButton)
Widget allVariantsStarryIconButton(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;

  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: Wrap(
      spacing: t.spacing.s3,
      runSpacing: t.spacing.s3,
      children: <Widget>[
        StarryIconButton(
          icon: Icons.settings_outlined,
          tooltip: 'Settings',
          onPressed: () {},
        ),
        StarryIconButton(
          icon: Icons.add,
          tooltip: 'Add',
          variant: StarryIconButtonVariant.filled,
          onPressed: () {},
        ),
        StarryIconButton(
          icon: Icons.favorite_outline,
          tooltip: 'Favorite',
          variant: StarryIconButtonVariant.filledTonal,
          onPressed: () {},
        ),
        StarryIconButton(
          icon: Icons.share_outlined,
          tooltip: 'Share',
          variant: StarryIconButtonVariant.outlined,
          onPressed: () {},
        ),
        const StarryIconButton(
          icon: Icons.block,
          tooltip: 'Unavailable',
          enabled: false,
        ),
      ],
    ),
  );
}

@UseCase(name: 'Playground', type: StarryIconButton)
Widget playgroundStarryIconButton(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  final enabled = context.knobs.boolean(label: 'Enabled', initialValue: true);
  final selected = context.knobs.boolean(
    label: 'Selected',
    initialValue: false,
  );

  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        StarryIconButton(
          icon: Icons.notifications_outlined,
          tooltip: context.knobs.string(
            label: 'Tooltip',
            initialValue: 'Notifications',
          ),
          variant: context.knobs.object.dropdown<StarryIconButtonVariant>(
            label: 'Variant',
            options: StarryIconButtonVariant.values,
            labelBuilder: (value) => value.name,
          ),
          enabled: enabled,
          selected: selected,
          onPressed: enabled ? () {} : null,
        ),
      ],
    ),
  );
}
