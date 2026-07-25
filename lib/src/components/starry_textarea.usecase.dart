import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import 'package:widgetbook/widgetbook.dart';

import 'starry_textarea.dart';

@UseCase(name: 'Default', type: StarryTextArea)
Widget defaultStarryTextArea(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(24),
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
