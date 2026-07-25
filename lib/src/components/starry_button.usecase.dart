import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import 'package:widgetbook/widgetbook.dart';

import 'starry_button.dart';

@UseCase(name: 'Filled', type: StarryButton)
Widget filledStarryButton(BuildContext context) {
  return Center(
    child: StarryButton(
      label: context.knobs.string(label: 'Label', initialValue: '主按钮'),
      onPressed: () {},
    ),
  );
}

@UseCase(name: 'Tonal', type: StarryButton)
Widget tonalStarryButton(BuildContext context) {
  return Center(
    child: StarryButton(
      label: context.knobs.string(label: 'Label', initialValue: '次按钮'),
      variant: StarryButtonVariant.tonal,
      onPressed: () {},
    ),
  );
}

@UseCase(name: 'With Icon', type: StarryButton)
Widget iconStarryButton(BuildContext context) {
  return Center(
    child: StarryButton(
      label: context.knobs.string(label: 'Label', initialValue: '发布'),
      icon: Icons.add,
      onPressed: context.knobs.boolean(label: 'Enabled', initialValue: true)
          ? () {}
          : null,
    ),
  );
}

@UseCase(name: 'Secondary', type: StarryButton)
Widget secondaryStarryButton(BuildContext context) {
  return Center(
    child: StarryButton(
      label: context.knobs.string(label: 'Label', initialValue: '次品牌按钮'),
      variant: StarryButtonVariant.secondary,
      onPressed: () {},
    ),
  );
}

@UseCase(name: 'Disabled', type: StarryButton)
Widget disabledStarryButton(BuildContext context) {
  final variant = context.knobs.object.dropdown<StarryButtonVariant>(
    label: 'Variant',
    options: StarryButtonVariant.values,
    labelBuilder: (v) => v.name,
  );
  return Center(
    child: StarryButton(
      label: context.knobs.string(label: 'Label', initialValue: '禁用'),
      variant: variant,
      onPressed: null,
    ),
  );
}
