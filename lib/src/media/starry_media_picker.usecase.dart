import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../theme/starry_tokens.dart';
import 'starry_media_picker.dart';

Widget _picker(
  BuildContext context, {
  required int count,
  bool enabled = true,
}) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return SizedBox(
    width: t.controlMetrics.controlHeight * 8,
    height: t.controlMetrics.controlHeight * 8,
    child: StarryMediaPicker(
      itemCount: count,
      enabled: enabled,
      addLabel: '添加图片',
      cameraLabel: '相机',
      galleryLabel: '相册',
      gridLabel: '宫格',
      description: 'JPG、PNG、GIF，最多 9 张',
      removeLabel: '删除图片',
      editLabel: '裁剪图片',
      onAddFromCamera: () {},
      onAddFromGallery: () {},
      onRemove: (_) {},
      onEdit: (_) {},
      mediaBuilder: (_, index) => ColoredBox(
        color: t.semantic.surfaceVariant,
        child: Center(child: Text('媒体 ${index + 1}')),
      ),
    ),
  );
}

@UseCase(name: 'All Variants', type: StarryMediaPicker)
Widget allStarryMediaPicker(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return SingleChildScrollView(
    padding: EdgeInsets.all(t.spacing.s6),
    child: Column(
      children: [
        _picker(context, count: 0),
        SizedBox(height: t.spacing.s6),
        _picker(context, count: 3),
        SizedBox(height: t.spacing.s6),
        _picker(context, count: 9, enabled: false),
      ],
    ),
  );
}

@UseCase(name: 'Playground', type: StarryMediaPicker)
Widget playgroundStarryMediaPicker(BuildContext context) => Center(
  child: _picker(
    context,
    count: context.knobs.int.slider(
      label: '已选数量',
      initialValue: 2,
      min: 0,
      max: 9,
    ),
    enabled: context.knobs.boolean(label: '可操作', initialValue: true),
  ),
);
