import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../theme/starry_tokens.dart';
import 'starry_sliver_skeleton_or_content.dart';

Widget _skeletonSliver(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return SliverList.builder(
    itemCount: 4,
    itemBuilder: (context, index) => Container(
      margin: EdgeInsets.symmetric(
        horizontal: t.spacing.s4,
        vertical: t.spacing.s2,
      ),
      height: t.spacing.s6,
      decoration: BoxDecoration(
        color: t.semantic.surfaceVariant,
        borderRadius: BorderRadius.circular(t.radius.md),
      ),
    ),
  );
}

Widget _contentSliver(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return SliverList.builder(
    itemCount: 4,
    itemBuilder: (context, index) => Padding(
      padding: EdgeInsets.symmetric(
        horizontal: t.spacing.s4,
        vertical: t.spacing.s2,
      ),
      child: Text(
        '列表项 #${index + 1}',
        style: t.typography.bodyMedium.textStyle.copyWith(
          color: t.semantic.textPrimary,
        ),
      ),
    ),
  );
}

@UseCase(name: 'Content', type: StarrySliverSkeletonOrContent)
Widget contentStarrySliverSkeletonOrContent(BuildContext context) {
  return CustomScrollView(
    slivers: <Widget>[
      StarrySliverSkeletonOrContent(
        isLoading: false,
        isEmpty: false,
        skeletonSliverBuilder: _skeletonSliver,
        contentSliverBuilder: _contentSliver,
      ),
    ],
  );
}

@UseCase(name: 'Skeleton', type: StarrySliverSkeletonOrContent)
Widget skeletonStarrySliverSkeletonOrContent(BuildContext context) {
  return CustomScrollView(
    slivers: <Widget>[
      StarrySliverSkeletonOrContent(
        isLoading: true,
        isEmpty: false,
        appearDelay: Duration.zero,
        skeletonSliverBuilder: _skeletonSliver,
        contentSliverBuilder: _contentSliver,
      ),
    ],
  );
}
