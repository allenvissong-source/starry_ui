import 'package:flutter/widgets.dart';

/// Exposes the resolved feed radius to cards, including cached item widgets.
class MasonryFeedScope extends InheritedWidget {
  const MasonryFeedScope({
    required this.cardRadius,
    required super.child,
    super.key,
  });

  final double cardRadius;

  static double? cardRadiusOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<MasonryFeedScope>()
      ?.cardRadius;

  @override
  bool updateShouldNotify(MasonryFeedScope oldWidget) =>
      cardRadius != oldWidget.cardRadius;
}
