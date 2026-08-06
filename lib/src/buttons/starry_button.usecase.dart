import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import 'package:widgetbook/widgetbook.dart';

import '../theme/starry_tokens.dart';
import 'starry_button.dart';

@UseCase(name: 'All Variants', type: StarryButton)
Widget allVariantsStarryButton(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        StarryButton(label: '主按钮', onPressed: () {}),
        SizedBox(height: t.spacing.s4),
        StarryButton(
          label: '次按钮',
          variant: StarryButtonVariant.tonal,
          onPressed: () {},
        ),
        SizedBox(height: t.spacing.s4),
        StarryButton(
          label: '次品牌按钮',
          variant: StarryButtonVariant.secondary,
          onPressed: () {},
        ),
        SizedBox(height: t.spacing.s4),
        StarryButton(label: '发布', icon: Icons.add, onPressed: () {}),
        SizedBox(height: t.spacing.s4),
        StarryButton(label: '提交中', loading: true, onPressed: () {}),
        SizedBox(height: t.spacing.s4),
        const StarryButton(label: '禁用', onPressed: null),
      ],
    ),
  );
}

@UseCase(name: 'Playground', type: StarryButton)
Widget playgroundStarryButton(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  final variant = context.knobs.object.dropdown<StarryButtonVariant>(
    label: 'Variant',
    options: StarryButtonVariant.values,
    labelBuilder: (v) => v.name,
  );
  final withIcon = context.knobs.boolean(
    label: 'With Icon',
    initialValue: false,
  );
  final loading = context.knobs.boolean(label: 'Loading', initialValue: false);
  final enabled = context.knobs.boolean(label: 'Enabled', initialValue: true);
  final layout = context.knobs.object.dropdown<StarryButtonLayout>(
    label: 'Layout',
    options: StarryButtonLayout.values,
    labelBuilder: (v) => v.name,
  );
  final pressScale = context.knobs.boolean(
    label: 'Press Scale',
    initialValue: false,
  );
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        StarryButton(
          label: context.knobs.string(label: 'Label', initialValue: '按钮'),
          variant: variant,
          icon: withIcon ? Icons.add : null,
          loading: loading,
          layout: layout,
          pressScale: pressScale,
          onPressed: enabled ? () {} : null,
        ),
      ],
    ),
  );
}
