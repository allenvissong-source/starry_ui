import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../theme/starry_tokens.dart';
import 'starry_slidable_drawer.dart';
import 'starry_swipeable.dart';

@UseCase(name: 'Default', type: StarrySlidableDrawer)
Widget defaultStarrySlidableDrawer(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  final s = t.semantic;
  return Center(
    child: Padding(
      padding: EdgeInsets.all(t.spacing.s4),
      child: SizedBox(
        width: 360,
        child: StarrySlidableDrawer(
          onTap: () {},
          actions: <StarrySwipeAction>[
            StarrySwipeAction(
              label: '归档',
              icon: Icons.archive_outlined,
              backgroundColor: s.info,
              foregroundColor: s.onError,
              onTap: () {},
            ),
            StarrySwipeAction(
              label: '删除',
              icon: Icons.delete_outline,
              backgroundColor: s.error,
              foregroundColor: s.onError,
              onTap: () {},
            ),
          ],
          child: Container(
            height: t.spacing.s16,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: t.spacing.s4),
            color: s.surface,
            child: Text(
              '向左滑动以展开操作',
              style: t.typography.bodyMedium.textStyle.copyWith(
                color: s.textPrimary,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

@UseCase(name: 'Single action', type: StarrySlidableDrawer)
Widget singleActionStarrySlidableDrawer(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  final s = t.semantic;
  return Center(
    child: Padding(
      padding: EdgeInsets.all(t.spacing.s4),
      child: SizedBox(
        width: 360,
        child: StarrySlidableDrawer(
          onTap: () {},
          actions: <StarrySwipeAction>[
            StarrySwipeAction(
              label: '删除',
              icon: Icons.delete_outline,
              backgroundColor: s.error,
              foregroundColor: s.onError,
              onTap: () {},
            ),
          ],
          child: Container(
            height: t.spacing.s16,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: t.spacing.s4),
            color: s.surface,
            child: Text(
              '单个操作',
              style: t.typography.bodyMedium.textStyle.copyWith(
                color: s.textPrimary,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
