import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../tags/starry_tag.dart';
import '../theme/starry_tokens.dart';
import 'starry_data_table.dart';

@UseCase(name: 'All Variants', type: StarryDataTable)
Widget allStarryDataTable(BuildContext context) => _demo(context, 24, false);

@UseCase(name: 'Playground', type: StarryDataTable)
Widget playgroundStarryDataTable(BuildContext context) => _demo(
  context,
  context.knobs.int.slider(label: 'Rows', initialValue: 12, min: 0, max: 50),
  context.knobs.boolean(label: 'Loading'),
);

@UseCase(name: 'All Variants', type: StarryDataTableAction)
Widget allStarryDataTableAction(BuildContext context) => Wrap(
  spacing: Theme.of(context).extension<StarryTokens>()!.spacing.s4,
  children: [
    StarryDataTableAction(label: 'Edit', onPressed: () {}),
    StarryDataTableAction(label: 'Revoke', destructive: true, onPressed: () {}),
    const StarryDataTableAction(label: 'Disabled', onPressed: null),
  ],
);

@UseCase(name: 'Playground', type: StarryDataTableAction)
Widget playgroundStarryDataTableAction(BuildContext context) =>
    StarryDataTableAction(
      label: context.knobs.string(label: 'Label', initialValue: 'Edit'),
      destructive: context.knobs.boolean(label: 'Destructive'),
      onPressed: context.knobs.boolean(label: 'Enabled', initialValue: true)
          ? () {}
          : null,
    );

Widget _demo(BuildContext context, int count, bool loading) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return SingleChildScrollView(
    padding: EdgeInsets.all(t.spacing.s6),
    child: StarryDataTable<int>(
      rows: List.generate(count, (i) => i),
      rowKey: (row) => row,
      loading: loading,
      empty: const Text('No applications'),
      columns: [
        StarryDataColumn(
          label: 'Application',
          compare: (a, b) => a.compareTo(b),
          cellBuilder: (_, row) => Text('Application ${row + 1}'),
          flex: 2,
        ),
        StarryDataColumn(
          label: 'Status',
          cellBuilder: (_, row) => StarryTag(
            label: row.isEven ? 'Active' : 'Disabled',
            status: row.isEven
                ? StarryTagStatus.success
                : StarryTagStatus.neutral,
          ),
        ),
        StarryDataColumn(
          label: 'ID',
          cellBuilder: (_, row) =>
              SelectableText('application-id-$row', maxLines: 1),
        ),
        StarryDataColumn(
          label: 'Actions',
          cellBuilder: (_, row) =>
              StarryDataTableAction(label: 'Edit', onPressed: () {}),
        ),
      ],
    ),
  );
}
