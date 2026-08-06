import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../theme/starry_tokens.dart';
import 'starry_text_button.dart';

@UseCase(name: 'All States', type: StarryTextButton)
Widget allStatesStarryTextButton(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        StarryTextButton(label: 'Default', onPressed: () {}),
        SizedBox(height: t.spacing.s3),
        StarryTextButton(
          label: 'With icon',
          icon: Icons.add,
          onPressed: () {},
        ),
        SizedBox(height: t.spacing.s3),
        StarryTextButton(
          label: 'Loading',
          loading: true,
          onPressed: () {},
        ),
        SizedBox(height: t.spacing.s3),
        const StarryTextButton(label: 'Disabled', onPressed: null),
      ],
    ),
  );
}

@UseCase(name: 'Playground', type: StarryTextButton)
Widget playgroundStarryTextButton(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  final enabled = context.knobs.boolean(label: 'Enabled', initialValue: true);
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        StarryTextButton(
          label:
              context.knobs.string(label: 'Label', initialValue: 'Text action'),
          icon: context.knobs.boolean(label: 'Show icon') ? Icons.add : null,
          loading: context.knobs.boolean(label: 'Loading'),
          fullWidth: context.knobs.boolean(label: 'Full width'),
          onPressed: enabled ? () {} : null,
        ),
      ],
    ),
  );
}
