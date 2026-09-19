import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import 'package:widgetbook/widgetbook.dart';

import '../tags/starry_tag.dart';
import '../theme/starry_tokens.dart';
import 'starry_identity_row.dart';

@UseCase(name: 'All Densities', type: StarryIdentityRow)
Widget allDensitiesStarryIdentityRow(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const StarryIdentityRow(
          name: 'Feed byline',
          subtitle: '2h ago',
          avatarFallbackText: 'FB',
          density: StarryIdentityDensity.feed,
        ),
        SizedBox(height: t.spacing.s4),
        const StarryIdentityRow(
          name: 'Compact user',
          avatarFallbackText: 'CU',
          density: StarryIdentityDensity.compact,
        ),
        SizedBox(height: t.spacing.s4),
        const StarryIdentityRow(
          name: 'Regular header',
          subtitle: '@regular',
          avatarFallbackText: 'RH',
          badges: <Widget>[
            StarryTag(label: 'AI', status: StarryTagStatus.accent),
          ],
          trailing: Icon(Icons.chevron_right),
        ),
      ],
    ),
  );
}

@UseCase(name: 'Playground', type: StarryIdentityRow)
Widget playgroundStarryIdentityRow(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  final hasSubtitle = context.knobs.boolean(
    label: 'Subtitle',
    initialValue: true,
  );
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: StarryIdentityRow(
      name: context.knobs.string(label: 'Name', initialValue: 'Ada Lovelace'),
      subtitle: hasSubtitle ? '@ada' : null,
      avatarFallbackText: 'AL',
      density: context.knobs.object.dropdown<StarryIdentityDensity>(
        label: 'Density',
        options: StarryIdentityDensity.values,
        labelBuilder: (v) => v.name,
      ),
    ),
  );
}
