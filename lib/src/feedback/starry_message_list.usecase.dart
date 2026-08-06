import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../theme/starry_tokens.dart';
import 'starry_message_list.dart';

List<StarryMessageListItemData> _demoItems(StarryTokens t) => <StarryMessageListItemData>[
      StarryMessageListItemData(
        id: 1,
        title: 'Nova Assistant',
        subtitle: '你的每周总结已生成，点击查看。',
        timeLabel: '09:24',
        avatarText: 'N',
        unread: true,
        actions: <StarryMessageListAction>[
          StarryMessageListAction(
            label: '归档',
            icon: Icons.archive_outlined,
            backgroundColor: t.semantic.info,
            foregroundColor: t.semantic.onError,
            onTap: () {},
          ),
          StarryMessageListAction(
            label: '删除',
            icon: Icons.delete_outline,
            backgroundColor: t.semantic.error,
            foregroundColor: t.semantic.onError,
            onTap: () {},
          ),
        ],
      ),
      StarryMessageListItemData(
        id: 2,
        title: 'Team Starry',
        subtitle: '设计规范 v1.07 已发布。',
        timeLabel: '昨天',
        avatarText: 'T',
        actions: <StarryMessageListAction>[
          StarryMessageListAction(
            label: '删除',
            icon: Icons.delete_outline,
            backgroundColor: t.semantic.error,
            foregroundColor: t.semantic.onError,
            onTap: () {},
          ),
        ],
      ),
      const StarryMessageListItemData(
        id: 3,
        title: 'System',
        subtitle: '你的账号已成功登录新设备。',
        timeLabel: '周一',
        avatarText: 'S',
      ),
    ];

@UseCase(name: 'With Items', type: StarryMessageList)
Widget withItemsStarryMessageList(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Padding(
    padding: const EdgeInsets.all(16),
    child: StarryMessageList(
      title: '消息',
      badgeLabel: '3 条未读',
      emptyLabel: '暂无消息',
      items: _demoItems(t),
    ),
  );
}

@UseCase(name: 'Empty', type: StarryMessageList)
Widget emptyStarryMessageList(BuildContext context) {
  return const Padding(
    padding: EdgeInsets.all(16),
    child: StarryMessageList(
      title: '消息',
      emptyLabel: '暂无消息',
      items: <StarryMessageListItemData>[],
    ),
  );
}

@UseCase(name: 'Playground', type: StarryMessageList)
Widget playgroundStarryMessageList(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  final showItems = context.knobs.boolean(label: 'Show items', initialValue: true);
  return Padding(
    padding: const EdgeInsets.all(16),
    child: StarryMessageList(
      title: context.knobs.string(label: 'Title', initialValue: '消息'),
      badgeLabel: context.knobs.stringOrNull(label: 'Badge', initialValue: '3 条未读'),
      emptyLabel: '暂无消息',
      items: showItems ? _demoItems(t) : const <StarryMessageListItemData>[],
    ),
  );
}
