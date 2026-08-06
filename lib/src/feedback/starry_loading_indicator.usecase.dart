import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import 'starry_loading_indicator.dart';

@UseCase(name: 'Default', type: StarryLoadingIndicator)
Widget defaultStarryLoadingIndicator(BuildContext context) {
  return const StarryLoadingIndicator();
}

@UseCase(name: 'Playground', type: StarryLoadingIndicator)
Widget playgroundStarryLoadingIndicator(BuildContext context) {
  return StarryLoadingIndicator(
    size: context.knobs.double.slider(
      label: 'Size',
      initialValue: 24,
      min: 12,
      max: 96,
    ),
    strokeWidth: context.knobs.double.slider(
      label: 'Stroke width',
      initialValue: 3,
      min: 1,
      max: 8,
    ),
  );
}

@UseCase(name: 'Full Screen', type: StarryFullScreenLoadingIndicator)
Widget fullScreenStarryLoadingIndicator(BuildContext context) {
  return StarryFullScreenLoadingIndicator(
    message: context.knobs.stringOrNull(
      label: 'Message',
      initialValue: '加载中…',
    ),
  );
}
