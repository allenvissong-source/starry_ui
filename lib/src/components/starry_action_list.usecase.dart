import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../theme/starry_tokens.dart';
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

@UseCase(name: 'Playground', type: StarryActionList)
Widget playgroundStarryActionList(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  final showFilter = context.knobs.boolean(
    label: 'Show filter',
    initialValue: true,
  );
  final includeDisabled = context.knobs.boolean(
    label: 'Include disabled row',
    initialValue: true,
  );
  final placeholder = context.knobs.string(
    label: 'Filter placeholder',
    initialValue: 'Type to filter',
  );
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: SizedBox(
      width: 320,
      child: StarryActionList(
        showFilter: showFilter,
        filterPlaceholder: placeholder,
        items: [
          StarryActionItem(id: 'new', title: 'New chat', onActivate: () {}),
          StarryActionItem(
            id: 'model',
            title: 'Model',
            subtitle: 'Pick connection',
            group: 'Runtime',
            selected: true,
            onActivate: () {},
          ),
          if (includeDisabled)
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
