import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import 'package:widgetbook/widgetbook.dart';

import 'starry_input.dart';

@UseCase(name: 'Default', type: StarryInput)
Widget defaultStarryInput(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(24),
    child: StarryInput(
      label: context.knobs.string(label: 'Label', initialValue: '用户名'),
      hint: context.knobs.string(label: 'Hint', initialValue: '请输入用户名'),
      helperText: context.knobs.stringOrNull(label: 'Helper'),
      enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
    ),
  );
}

@UseCase(name: 'Error', type: StarryInput)
Widget errorStarryInput(BuildContext context) {
  return const Padding(
    padding: EdgeInsets.all(24),
    child: StarryInput(
      label: '邮箱',
      hint: 'name@example.com',
      errorText: '邮箱格式不正确',
    ),
  );
}
