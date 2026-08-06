import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../theme/starry_tokens.dart';
import 'starry_empty_state.dart';
import 'starry_skeleton_or_content.dart';

Widget _skeletonBlock(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: List<Widget>.generate(
      3,
      (_) => Container(
        margin: EdgeInsets.only(bottom: t.spacing.s3),
        height: t.spacing.s6,
        width: 200,
        decoration: BoxDecoration(
          color: t.semantic.surfaceVariant,
          borderRadius: BorderRadius.circular(t.radius.md),
        ),
      ),
    ),
  );
}

Widget _contentBlock(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Text(
    '真实内容已加载完成。',
    style: t.typography.bodyMedium.textStyle.copyWith(
      color: t.semantic.textPrimary,
    ),
  );
}

@UseCase(name: 'Content', type: StarrySkeletonOrContent)
Widget contentStarrySkeletonOrContent(BuildContext context) {
  return StarrySkeletonOrContent(
    isLoading: false,
    isEmpty: false,
    skeletonBuilder: _skeletonBlock,
    contentBuilder: _contentBlock,
  );
}

@UseCase(name: 'Skeleton', type: StarrySkeletonOrContent)
Widget skeletonStarrySkeletonOrContent(BuildContext context) {
  return StarrySkeletonOrContent(
    isLoading: true,
    isEmpty: false,
    // Show the skeleton immediately in the gallery.
    appearDelay: Duration.zero,
    skeletonBuilder: _skeletonBlock,
    contentBuilder: _contentBlock,
  );
}

@UseCase(name: 'Empty', type: StarrySkeletonOrContent)
Widget emptyStarrySkeletonOrContent(BuildContext context) {
  return StarrySkeletonOrContent(
    isLoading: false,
    isEmpty: true,
    skeletonBuilder: _skeletonBlock,
    contentBuilder: _contentBlock,
    emptyBuilder: (context) => const StarryEmptyState(title: '暂无数据'),
  );
}
