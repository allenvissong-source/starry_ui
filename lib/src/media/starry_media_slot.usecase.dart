import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import '../../starry_ui.dart';

StarryMediaSlot _slot({
  Widget? preview,
  bool loading = false,
  bool readOnly = false,
  String? error,
}) => StarryMediaSlot(
  label: '封面',
  emptyLabel: '尚未添加封面',
  preview: preview,
  onAdd: () {},
  addLabel: '添加',
  onReplace: () {},
  replaceLabel: '替换',
  onRemove: () {},
  removeLabel: '移除',
  loading: loading,
  loadingLabel: '正在载入…',
  readOnly: readOnly,
  errorText: error,
);

Widget _preview(BuildContext context) => StarryAvatar(
  fallbackText: 'Starry',
  size: StarryAvatarSize.xxl,
  shape: StarryAvatarShape.rounded,
);

@UseCase(name: 'All Variants', type: StarryMediaSlot)
Widget allVariantsStarryMediaSlot(BuildContext context) {
  final t = context.starryTokens;
  return SingleChildScrollView(
    padding: EdgeInsets.all(t.spacing.s6),
    child: Wrap(
      spacing: t.spacing.s4,
      runSpacing: t.spacing.s4,
      children: [
        for (final slot in [
          _slot(),
          _slot(preview: _preview(context)),
          _slot(preview: _preview(context), readOnly: true),
          _slot(loading: true),
          _slot(error: '封面载入失败，请重试'),
        ])
          SizedBox(width: t.controlMetrics.controlHeight * 5, child: slot),
      ],
    ),
  );
}

@UseCase(name: 'Playground', type: StarryMediaSlot)
Widget playgroundStarryMediaSlot(BuildContext context) {
  final t = context.starryTokens;
  return Center(
    child: SizedBox(
      width: t.controlMetrics.controlHeight * 5,
      child: _slot(
        preview: context.knobs.boolean(label: 'Has media', initialValue: false)
            ? _preview(context)
            : null,
        loading: context.knobs.boolean(label: 'Loading', initialValue: false),
        readOnly: context.knobs.boolean(
          label: 'Read only',
          initialValue: false,
        ),
        error: context.knobs.boolean(label: 'Error', initialValue: false)
            ? '封面载入失败，请重试'
            : null,
      ),
    ),
  );
}
