import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../../starry_ui.dart';

Widget _media(BuildContext context, double ratio) => AspectRatio(
  aspectRatio: ratio,
  child: ColoredBox(
    color: context.starryTokens.semantic.surfaceVariant,
    child: Center(
      child: Icon(
        Icons.image_outlined,
        size: context.starryTokens.controlMetrics.iconXl,
        color: context.starryTokens.semantic.textSecondary,
      ),
    ),
  ),
);

@UseCase(name: 'All Variants', type: StarryMediaStage)
Widget allVariantsStarryMediaStage(BuildContext context) {
  final t = context.starryTokens;
  return SingleChildScrollView(
    padding: EdgeInsets.all(t.spacing.s6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final ratio in [0.5, 1.0, 2.0]) ...[
          SizedBox(
            width: t.controlMetrics.controlHeight * 5,
            child: StarryMediaStage(
              overlay: Text('原始比例 $ratio'),
              child: _media(context, ratio),
            ),
          ),
          SizedBox(height: t.spacing.s4),
        ],
        SizedBox(
          width: t.controlMetrics.controlHeight * 5,
          child: StarryMediaStage(
            aspectRatio: 4 / 3,
            overlay: const Text('指定比例 4:3'),
            child: _media(context, 0.5),
          ),
        ),
      ],
    ),
  );
}

@UseCase(name: 'Playground', type: StarryMediaStage)
Widget playgroundStarryMediaStage(BuildContext context) {
  final t = context.starryTokens;
  final ratio = context.knobs.double.slider(
    label: 'Media ratio',
    initialValue: 0.5,
    min: 0.25,
    max: 3,
  );
  return SingleChildScrollView(
    padding: EdgeInsets.all(t.spacing.s6),
    child: SizedBox(
      width: t.controlMetrics.controlHeight * 5,
      child: StarryMediaStage(
        aspectRatio:
            context.knobs.boolean(label: 'Fixed 4:3 stage', initialValue: false)
            ? 4 / 3
            : null,
        overlay: context.knobs.boolean(label: 'Overlay', initialValue: true)
            ? const Text('封面信息')
            : null,
        child: _media(context, ratio),
      ),
    ),
  );
}
