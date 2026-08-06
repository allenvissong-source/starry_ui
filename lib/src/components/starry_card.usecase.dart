import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../theme/starry_tokens.dart';
import 'starry_card.dart';

Widget _content(BuildContext context, String title, String body) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  final s = t.semantic;
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        title,
        style: t.typography.titleMedium.textStyle.copyWith(
          color: s.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      SizedBox(height: t.spacing.s2),
      Text(
        body,
        style: t.typography.bodyMedium.textStyle.copyWith(
          color: s.textSecondary,
        ),
      ),
    ],
  );
}

@UseCase(name: 'All States', type: StarryCard)
Widget allStatesStarryCard(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        StarryCard(
          child: _content(context, 'Elevated card', 'Uses level2 elevation.'),
        ),
        SizedBox(height: t.spacing.s4),
        StarryCard(
          elevated: false,
          child: _content(context, 'Flat card', 'Uses the semantic border.'),
        ),
        SizedBox(height: t.spacing.s4),
        StarryCard(
          onTap: () {},
          child: _content(context, 'Interactive card', 'Keyboard and tap ready.'),
        ),
      ],
    ),
  );
}

@UseCase(name: 'Playground', type: StarryCard)
Widget playgroundStarryCard(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  final interactive = context.knobs.boolean(label: 'Interactive');
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        StarryCard(
          elevated: context.knobs.boolean(label: 'Elevated', initialValue: true),
          onTap: interactive ? () {} : null,
          child: _content(
            context,
            context.knobs.string(label: 'Title', initialValue: 'Card title'),
            context.knobs
                .string(label: 'Body', initialValue: 'Card body content.'),
          ),
        ),
      ],
    ),
  );
}
