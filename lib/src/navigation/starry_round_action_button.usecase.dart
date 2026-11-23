import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../theme/starry_tokens.dart';
import 'starry_round_action_button.dart';

@UseCase(name: 'Default', type: StarryRoundActionButton)
Widget defaultStarryRoundActionButton(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Padding(
    padding: EdgeInsets.all(t.spacing.s10),
    child: Wrap(
      spacing: t.spacing.s10,
      runSpacing: t.spacing.s10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        StarryRoundActionButton(
          onTap: () {},
          semanticsLabel: 'Sparkle',
          child: const Icon(Icons.auto_awesome, size: 20),
        ),
        StarryRoundActionButton(
          onTap: () {},
          semanticsLabel: 'Add',
          child: const Icon(Icons.add, size: 20),
        ),
        const StarryRoundActionButton(
          semanticsLabel: 'Disabled',
          child: Icon(Icons.auto_awesome, size: 20),
        ),
      ],
    ),
  );
}

@UseCase(name: 'Playground', type: StarryRoundActionButton)
Widget playgroundStarryRoundActionButton(BuildContext context) {
  final enabled = context.knobs.boolean(label: 'Enabled', initialValue: true);
  final size = context.knobs.double.slider(
    label: 'Size',
    initialValue: 48,
    min: 32,
    max: 96,
  );
  return Center(
    child: StarryRoundActionButton(
      size: size,
      onTap: enabled ? () {} : null,
      semanticsLabel: 'Action',
      child: const Icon(Icons.auto_awesome, size: 20),
    ),
  );
}
