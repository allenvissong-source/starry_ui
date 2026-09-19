import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import 'package:widgetbook/widgetbook.dart';

import '../theme/starry_tokens.dart';
import 'starry_ai_button.dart';

@UseCase(name: 'All States', type: StarryAiButton)
Widget allStatesStarryAiButton(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Padding(
    padding: EdgeInsets.all(t.spacing.s10),
    child: Wrap(
      spacing: t.spacing.s10,
      runSpacing: t.spacing.s10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        StarryAiButton(onTap: () {}),
        const StarryAiButton(busy: true),
        StarryAiButton(icon: Icons.smart_toy, onTap: () {}),
      ],
    ),
  );
}

@UseCase(name: 'Sizes', type: StarryAiButton)
Widget sizesStarryAiButton(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Padding(
    padding: EdgeInsets.all(t.spacing.s10),
    child: Wrap(
      spacing: t.spacing.s10,
      runSpacing: t.spacing.s10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        StarryAiButton(size: 48, onTap: () {}),
        StarryAiButton(size: 64, onTap: () {}),
      ],
    ),
  );
}

@UseCase(name: 'Playground', type: StarryAiButton)
Widget playgroundStarryAiButton(BuildContext context) {
  return Center(
    child: StarryAiButton(
      busy: context.knobs.boolean(label: 'Busy', initialValue: false),
      size: context.knobs.double.slider(
        label: 'Size',
        initialValue: 48,
        min: 32,
        max: 96,
      ),
      onTap: () {},
    ),
  );
}
