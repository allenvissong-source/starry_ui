import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../../starry_ui.dart';

void _showChoices(BuildContext context, {bool loading = false}) {
  StarryDialog.show<String>(
    context: context,
    barrierDismissible: !loading,
    builder: (dialogContext) => StarryDialog(
      title: '尚有未保存的修改',
      message: '可保存当前修改、暂存草稿或继续编辑。',
      actions: [
        StarryDialogAction(
          label: '继续编辑',
          onPressed: () => Navigator.of(dialogContext).pop('edit'),
        ),
        StarryDialogAction(
          label: '放弃修改',
          destructive: true,
          onPressed: loading
              ? null
              : () => Navigator.of(dialogContext).pop('discard'),
        ),
        StarryDialogAction(
          label: '存为草稿',
          onPressed: loading
              ? null
              : () => Navigator.of(dialogContext).pop('draft'),
        ),
        StarryDialogAction(
          label: '保存',
          primary: true,
          loading: loading,
          loadingLabel: '正在保存…',
          onPressed: () => Navigator.of(dialogContext).pop('save'),
        ),
      ],
    ),
  );
}

@UseCase(name: 'All Variants', type: StarryDialog)
Widget allVariantsStarryDialog(BuildContext context) {
  final t = context.starryTokens;
  return SingleChildScrollView(
    padding: EdgeInsets.all(t.spacing.s6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final tone in StarryDialogTone.values) ...[
          StarryButton(
            label: '打开 ${tone.name} 弹窗',
            onPressed: () => StarryDialog.confirm(
              context: context,
              title: tone == StarryDialogTone.destructive ? '删除条目？' : '确认操作',
              message: tone == StarryDialogTone.destructive
                  ? '删除后无法恢复，请确认已经备份。'
                  : '操作结果由页面接收并处理。',
              tone: tone,
              confirmLabel: '确认',
              cancelLabel: '取消',
            ),
          ),
          SizedBox(height: t.spacing.s4),
        ],
        StarryButton(label: '打开四操作确认框', onPressed: () => _showChoices(context)),
        SizedBox(height: t.spacing.s4),
        StarryButton(
          label: '打开加载与禁用状态',
          onPressed: () => _showChoices(context, loading: true),
        ),
      ],
    ),
  );
}

@UseCase(name: 'Playground', type: StarryDialog)
Widget playgroundStarryDialog(BuildContext context) {
  final title = context.knobs.string(label: 'Title', initialValue: '确认操作');
  final message = context.knobs.string(
    label: 'Message',
    initialValue: '请检查修改后继续。',
  );
  final tone = context.knobs.object.dropdown(
    label: 'Tone',
    options: StarryDialogTone.values,
    labelBuilder: (tone) => tone.name,
  );
  final dismissible = context.knobs.boolean(
    label: 'Dismissible',
    initialValue: true,
  );
  return Center(
    child: StarryButton(
      label: '打开弹窗',
      onPressed: () => StarryDialog.confirm(
        context: context,
        title: title,
        message: message,
        tone: tone,
        confirmLabel: '确认',
        cancelLabel: '取消',
        barrierDismissible: dismissible,
      ),
    ),
  );
}
