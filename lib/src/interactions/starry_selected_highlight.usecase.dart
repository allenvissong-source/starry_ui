import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../theme/starry_tokens.dart';
import 'starry_selected_highlight.dart';

Widget _chip(BuildContext context, String label) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Padding(
    padding: EdgeInsets.all(t.spacing.s4),
    child: Text(
      label,
      style: t.typography.titleSmall.textStyle.copyWith(
        color: t.semantic.textPrimary,
      ),
    ),
  );
}

@UseCase(name: 'Selected vs Rest', type: StarrySelectedHighlight)
Widget statesStarrySelectedHighlight(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Center(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        StarrySelectedHighlight(
          isSelected: true,
          child: _chip(context, 'Selected'),
        ),
        SizedBox(width: t.spacing.s4),
        StarrySelectedHighlight(
          isSelected: false,
          child: _chip(context, 'Rest'),
        ),
      ],
    ),
  );
}

@UseCase(name: 'Playground', type: StarrySelectedHighlight)
Widget playgroundStarrySelectedHighlight(BuildContext context) {
  final selected = context.knobs.boolean(label: 'Selected', initialValue: true);
  return Center(
    child: StarrySelectedHighlight(
      isSelected: selected,
      child: _chip(context, 'Toggle me'),
    ),
  );
}
