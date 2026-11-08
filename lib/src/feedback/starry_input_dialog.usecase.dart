import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../../starry_ui.dart';

Future<String?> _open(
  BuildContext context, {
  bool multiline = false,
  bool validate = false,
}) => StarryInputDialog.show(
  context: context,
  title: multiline ? '编辑描述' : '编辑名称',
  fieldLabel: multiline ? '描述' : '名称',
  initialValue: multiline ? '世界书的背景说明' : '星空档案',
  confirmLabel: '保存',
  cancelLabel: '取消',
  maxLines: multiline ? 4 : 1,
  maxLength: multiline ? 200 : 30,
  helperText: validate ? '名称至少包含两个有效字符' : null,
  validator: validate
      ? (value) => value.trim().length < 2 ? '请输入至少两个有效字符' : null
      : null,
);

@UseCase(name: 'All Variants', type: StarryInputDialog)
Widget allVariantsStarryInputDialog(BuildContext context) {
  final t = context.starryTokens;
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StarryButton(label: '单行输入', onPressed: () => _open(context)),
        SizedBox(height: t.spacing.s4),
        StarryButton(
          label: '多行输入与计数',
          onPressed: () => _open(context, multiline: true),
        ),
        SizedBox(height: t.spacing.s4),
        StarryButton(
          label: '校验反馈',
          onPressed: () => _open(context, validate: true),
        ),
      ],
    ),
  );
}

@UseCase(name: 'Playground', type: StarryInputDialog)
Widget playgroundStarryInputDialog(BuildContext context) {
  final title = context.knobs.string(label: 'Title', initialValue: '编辑名称');
  final initialValue = context.knobs.string(
    label: 'Initial value',
    initialValue: '星空档案',
  );
  final multiline = context.knobs.boolean(
    label: 'Multiline',
    initialValue: false,
  );
  final validate = context.knobs.boolean(
    label: 'Require non-empty value',
    initialValue: true,
  );
  return Center(
    child: StarryButton(
      label: '打开输入弹窗',
      onPressed: () => StarryInputDialog.show(
        context: context,
        title: title,
        fieldLabel: '文本',
        initialValue: initialValue,
        confirmLabel: '保存',
        cancelLabel: '取消',
        maxLines: multiline ? 4 : 1,
        maxLength: 100,
        validator: validate
            ? (value) => value.trim().isEmpty ? '请输入文本' : null
            : null,
      ),
    ),
  );
}
