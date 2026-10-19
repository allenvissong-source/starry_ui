import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import 'starry_action_item.dart';
import 'starry_action_list.dart';

@UseCase(name: 'Grouped With States', type: StarryActionList)
Widget groupedStarryActionList(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(24),
    child: SizedBox(
      width: 320,
      child: StarryActionList(
        items: [
          StarryActionItem(id: 'new', title: 'New chat', onActivate: () {}),
          StarryActionItem(
            id: 'status',
            title: 'Status',
            group: 'Runtime',
            onActivate: () {},
          ),
          StarryActionItem(
            id: 'model',
            title: 'Model',
            subtitle: 'Pick connection',
            group: 'Runtime',
            selected: true,
            onActivate: () {},
          ),
          StarryActionItem(
            id: 'effort',
            title: 'Reasoning effort',
            subtitle: 'Current topic only',
            group: 'Runtime',
            disabled: true,
            onActivate: () {},
          ),
          StarryActionItem(
            id: 'web',
            title: 'Web search',
            keywords: const ['online'],
            group: 'Tools',
            onActivate: () {},
          ),
        ],
        onItemSelected: (_) {},
        onClose: () {},
      ),
    ),
  );
}
