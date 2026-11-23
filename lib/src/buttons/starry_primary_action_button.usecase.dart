import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import 'package:widgetbook/widgetbook.dart';

import '../theme/starry_tokens.dart';
import 'starry_primary_action_button.dart';

@UseCase(name: 'Default', type: StarryPrimaryActionButton)
Widget defaultStarryPrimaryActionButton(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: StarryPrimaryActionButton(label: '开始', onPressed: () {}),
  );
}

@UseCase(name: 'With Icon', type: StarryPrimaryActionButton)
Widget withIconStarryPrimaryActionButton(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: StarryPrimaryActionButton(
      label: '继续',
      icon: Icons.arrow_forward,
      onPressed: () {},
    ),
  );
}

@UseCase(name: 'Disabled', type: StarryPrimaryActionButton)
Widget disabledStarryPrimaryActionButton(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: StarryPrimaryActionButton(
      label: '不可用',
      enabled: false,
      onPressed: () {},
    ),
  );
}

@UseCase(name: 'Playground', type: StarryPrimaryActionButton)
Widget playgroundStarryPrimaryActionButton(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  final withIcon = context.knobs.boolean(
    label: 'With Icon',
    initialValue: false,
  );
  final loading = context.knobs.boolean(label: 'Loading', initialValue: false);
  final enabled = context.knobs.boolean(label: 'Enabled', initialValue: true);
  final fullWidth = context.knobs.boolean(
    label: 'Full Width',
    initialValue: true,
  );
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: StarryPrimaryActionButton(
      label: context.knobs.string(label: 'Label', initialValue: '主操作'),
      icon: withIcon ? Icons.check : null,
      loading: loading,
      enabled: enabled,
      fullWidth: fullWidth,
      onPressed: () {},
    ),
  );
}
