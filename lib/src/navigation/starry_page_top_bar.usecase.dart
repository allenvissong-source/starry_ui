import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import 'starry_page_top_bar.dart';

@UseCase(name: 'Title Only', type: StarryPageTopBar)
Widget titleOnlyStarryPageTopBar(BuildContext context) {
  return const Scaffold(
    appBar: StarryPageTopBar(titleText: 'STARRY'),
    body: SizedBox.shrink(),
  );
}

@UseCase(name: 'With Actions', type: StarryPageTopBar)
Widget withActionsStarryPageTopBar(BuildContext context) {
  return Scaffold(
    appBar: StarryPageTopBar(
      titleText: '设置',
      showDivider: true,
      leftActions: <StarryTopBarActionItem>[
        StarryTopBarActionItem(
          icon: const Icon(Icons.arrow_back_ios_new),
          tooltip: '返回',
          motion: StarryTopBarIconMotion.backHoverShift,
          onPressed: () {},
        ),
      ],
      rightActions: <StarryTopBarActionItem>[
        StarryTopBarActionItem(
          icon: const Icon(Icons.add),
          tooltip: '新增',
          motion: StarryTopBarIconMotion.plusHoverRotate,
          onPressed: () {},
        ),
        StarryTopBarActionItem(
          icon: const Icon(Icons.more_horiz),
          tooltip: '更多',
          style: StarryTopBarActionStyle.flat,
          onPressed: () {},
        ),
      ],
    ),
    body: const SizedBox.shrink(),
  );
}

@UseCase(name: 'Playground', type: StarryPageTopBar)
Widget playgroundStarryPageTopBar(BuildContext context) {
  final title = context.knobs.string(label: 'Title', initialValue: '页面标题');
  final showDivider = context.knobs.boolean(
    label: 'Show Divider',
    initialValue: false,
  );
  final showBack = context.knobs.boolean(
    label: 'Show Back',
    initialValue: true,
  );
  final showAdd = context.knobs.boolean(
    label: 'Show Add Action',
    initialValue: true,
  );
  return Scaffold(
    appBar: StarryPageTopBar(
      titleText: title,
      showDivider: showDivider,
      leftActions: <StarryTopBarActionItem>[
        if (showBack)
          StarryTopBarActionItem(
            icon: const Icon(Icons.arrow_back_ios_new),
            tooltip: '返回',
            motion: StarryTopBarIconMotion.backHoverShift,
            onPressed: () {},
          ),
      ],
      rightActions: <StarryTopBarActionItem>[
        if (showAdd)
          StarryTopBarActionItem(
            icon: const Icon(Icons.add),
            tooltip: '新增',
            motion: StarryTopBarIconMotion.plusHoverRotate,
            onPressed: () {},
          ),
      ],
    ),
    body: const SizedBox.shrink(),
  );
}
