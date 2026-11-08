import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import 'package:widgetbook/widgetbook.dart';

import '../theme/starry_tokens.dart';
import 'starry_textarea.dart';
import 'starry_text_field.dart';

@UseCase(name: 'Playground', type: StarryTextArea)
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
        max: 3,
      ),
      maxLines: context.knobs.int.slider(
        label: 'Max lines',
        initialValue: 6,
        min: 3,
        max: 12,
      ),
      enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
      readOnly: context.knobs.boolean(label: 'Read only', initialValue: false),
      maxLength: 200,
      showCounter: true,
    ),
  );
}

@UseCase(name: 'All Variants', type: StarryTextArea)
Widget allVariantsStarryTextArea(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return SingleChildScrollView(
    padding: EdgeInsets.all(t.spacing.s6),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const StarryTextArea(label: '描述', maxLength: 200, showCounter: true),
        SizedBox(height: t.spacing.s4),
        const StarryTextArea(label: '只读', hint: '只读内容', readOnly: true),
        SizedBox(height: t.spacing.s4),
        const StarryTextArea(label: '禁用', enabled: false),
        SizedBox(height: t.spacing.s4),
        const StarryTextArea(
          label: '错误',
          validationState: StarryTextFieldState.error,
          errorText: '请填写描述',
        ),
      ],
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
