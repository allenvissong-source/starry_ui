import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../theme/starry_tokens.dart';
import 'starry_emoji_text.dart';

@UseCase(name: 'Default', type: StarryEmojiText)
Widget defaultStarryEmojiText(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        StarryEmojiText(
          'Hello 世界 👋 Starry ✨',
          style: t.typography.titleMedium.textStyle,
        ),
      ],
    ),
  );
}

@UseCase(name: 'Playground', type: StarryEmojiText)
Widget playgroundStarryEmojiText(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        StarryEmojiText(
          context.knobs.string(
            label: 'Text',
            initialValue: 'Mixed 中文 EN 🚀🎉 done ✅',
          ),
          style: t.typography.bodyLarge.textStyle,
        ),
      ],
    ),
  );
}
