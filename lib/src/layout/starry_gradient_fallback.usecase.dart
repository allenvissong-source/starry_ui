import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import 'starry_gradient_fallback.dart';

@UseCase(name: 'Default', type: StarryGradientFallback)
Widget defaultStarryGradientFallback(BuildContext context) {
  return const SizedBox.expand(child: StarryGradientFallback());
}
