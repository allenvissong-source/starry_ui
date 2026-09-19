import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../theme/starry_tokens.dart';
import 'starry_chip.dart';

@UseCase(name: 'All Variants', type: StarryChip)
Widget allVariantsStarryChip(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;

  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const StarryChip(label: 'Outlined'),
        SizedBox(height: t.spacing.s3),
        const StarryChip(label: 'Filled', variant: StarryChipVariant.filled),
        SizedBox(height: t.spacing.s3),
        const StarryChip(label: 'Tonal', variant: StarryChipVariant.tonal),
        SizedBox(height: t.spacing.s3),
        const StarryChip(label: 'Selected', selected: true),
        SizedBox(height: t.spacing.s3),
        const StarryChip(
          label: 'Leading',
          leading: Icon(Icons.location_on),
          variant: StarryChipVariant.tonal,
        ),
        SizedBox(height: t.spacing.s3),
        StarryChip(label: 'Deletable', onDelete: () {}, deleteTooltip: '删除'),
        SizedBox(height: t.spacing.s3),
        const StarryChip(label: 'Disabled', enabled: false),
      ],
    ),
  );
}

@UseCase(name: 'Playground', type: StarryChip)
Widget playgroundStarryChip(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  final deletable = context.knobs.boolean(label: 'Deletable');
  final withTrailing = context.knobs.boolean(label: 'With Trailing');
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        StarryChip(
          label: context.knobs.string(label: 'Label', initialValue: 'Chip'),
          selected: context.knobs.boolean(label: 'Selected'),
          enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
          pill: context.knobs.boolean(label: 'Pill', initialValue: true),
          variant: context.knobs.object.dropdown<StarryChipVariant>(
            label: 'Variant',
            options: StarryChipVariant.values,
            labelBuilder: (v) => v.name,
          ),
          trailing: withTrailing ? const Icon(Icons.keyboard_arrow_down) : null,
          onTap: () {},
          onDelete: deletable ? () {} : null,
          deleteTooltip: deletable ? '删除' : null,
        ),
      ],
    ),
  );
}
