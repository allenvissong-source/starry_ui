import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../theme/starry_tokens.dart';
import 'starry_page_wrapper.dart';

@UseCase(name: 'Default', type: StarryPageWrapper)
Widget defaultStarryPageWrapper(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return StarryPageWrapper(
    child: Container(
      alignment: Alignment.center,
      color: t.semantic.backgroundSecondary,
      child: Text('页面内容', style: t.typography.titleMedium.textStyle),
    ),
  );
}

@UseCase(name: 'Playground', type: StarryPageWrapper)
Widget playgroundStarryPageWrapper(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return StarryPageWrapper(
    safeArea: context.knobs.boolean(label: 'SafeArea', initialValue: true),
    child: Container(
      alignment: Alignment.center,
      color: t.semantic.backgroundSecondary,
      child: Text('页面内容', style: t.typography.titleMedium.textStyle),
    ),
  );
}
