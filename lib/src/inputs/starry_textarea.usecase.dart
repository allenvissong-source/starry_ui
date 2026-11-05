import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import 'package:widgetbook/widgetbook.dart';

import '../theme/starry_tokens.dart';
import 'starry_textarea.dart';

@UseCase(name: 'Default', type: StarryTextArea)
Widget defaultStarryTextArea(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: StarryTextArea(
      label: context.knobs.string(label: 'Label', initialValue: '备注'),
      hint: context.knobs.string(label: 'Hint', initialValue: '请输入详细描述…'),
      minLines: context.knobs.int.slider(
        label: 'Min lines',
        initialValue: 3,
        min: 1,
        max: 6,
      ),
      maxLines: context.knobs.int.slider(
        label: 'Max lines',
        initialValue: 6,
        min: 3,
        max: 12,
      ),
      enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
    ),
  );
}

@UseCase(name: 'Composer', type: StarryTextArea)
Widget composerStarryTextArea(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Center(
    child: SizedBox(
      width: t.controlMetrics.controlHeight * 10,
      height: t.controlMetrics.controlHeight * 8,
      child: StarryTextArea.composer(
        hint: '分享你的想法…',
        maxLength: 2000,
        enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
      ),
    ),
  );
}
