import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../../starry_ui.dart';

const _sample = '{\n  "name": "星空档案",\n  "entries": ["角色", "世界书"]\n}';

StarryCodeBlock _block({
  String code = _sample,
  String title = '响应示例',
  String language = 'JSON',
  bool copying = true,
  bool fail = false,
  double? maxHeight,
  bool embedded = false,
}) => StarryCodeBlock(
  code: code,
  title: title,
  language: language,
  maxHeight: maxHeight,
  embedded: embedded,
  copyLabel: copying ? '复制代码' : null,
  copyingLabel: '正在复制…',
  copiedLabel: '已复制',
  copyErrorLabel: '复制失败，请重试',
  onCopy: fail ? (_) async => throw StateError('Clipboard unavailable') : null,
);

@UseCase(name: 'All Variants', type: StarryCodeBlock)
Widget allVariantsStarryCodeBlock(BuildContext context) {
  final t = context.starryTokens;
  return SingleChildScrollView(
    padding: EdgeInsets.all(t.spacing.s6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _block(),
        SizedBox(height: t.spacing.s4),
        _block(title: '只读代码', copying: false),
        SizedBox(height: t.spacing.s4),
        StarryContentSection(
          title: '嵌入源码',
          child: _block(title: '原始文本', copying: false, embedded: true),
        ),
        SizedBox(height: t.spacing.s4),
        _block(title: '复制失败反馈（点击复制）', fail: true),
        SizedBox(height: t.spacing.s4),
        _block(
          title: '长代码视窗',
          code: List.filled(50, _sample).join('\n'),
          maxHeight: t.controlMetrics.controlHeight * 4,
        ),
      ],
    ),
  );
}

@UseCase(name: 'Playground', type: StarryCodeBlock)
Widget playgroundStarryCodeBlock(BuildContext context) {
  final t = context.starryTokens;
  return SingleChildScrollView(
    padding: EdgeInsets.all(t.spacing.s6),
    child: _block(
      embedded: context.knobs.boolean(label: 'Embedded', initialValue: false),
      code: context.knobs.string(label: 'Code', initialValue: _sample),
      title: context.knobs.string(label: 'Title', initialValue: '响应示例'),
      language: context.knobs.string(label: 'Language', initialValue: 'JSON'),
      copying: context.knobs.boolean(label: 'Enable copy', initialValue: true),
      fail: context.knobs.boolean(label: 'Fail clipboard', initialValue: false),
      maxHeight:
          context.knobs.boolean(label: 'Limit viewport', initialValue: false)
          ? t.controlMetrics.controlHeight * 4
          : null,
    ),
  );
}
