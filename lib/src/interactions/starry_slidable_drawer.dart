import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';
import 'starry_swipeable.dart';

/// A swipe-to-reveal drawer of trailing actions, rendered as inset rounded
/// chips.
///
/// Thin layer over [StarrySwipeable]: it supplies the drawer-style visuals
/// (per-action padding + rounded chips) while reusing the shared drag/settle
/// primitive. Actions are described with [StarrySwipeAction], the same model
/// used by `StarryMessageList` rows.
class StarrySlidableDrawer extends StatelessWidget {
  const StarrySlidableDrawer({
    required this.child,
    required this.actions,
    super.key,
    this.onTap,
    this.actionWidth = _defaultActionWidth,
    this.borderRadius,
    this.actionBorderRadius,
  });

  /// Default per-action chip width. Matches the legacy drawer's `actionWidth`.
  static const double _defaultActionWidth = 64;

  final Widget child;
  final List<StarrySwipeAction> actions;
  final VoidCallback? onTap;
  final double actionWidth;

  /// Outer clip radius. Defaults to `radius.lg`.
  final BorderRadius? borderRadius;

  /// Per-chip corner radius. Defaults to `radius.lg`.
  final BorderRadius? actionBorderRadius;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final chipRadius = actionBorderRadius ?? BorderRadius.circular(t.radius.lg);
    return StarrySwipeable(
      actions: actions,
      onTap: onTap,
      actionWidth: actionWidth,
      borderRadius: borderRadius ?? BorderRadius.circular(t.radius.lg),
      // Drawer style: inset chips with their own rounding.
      actionPadding: EdgeInsets.symmetric(
        horizontal: t.spacing.s1,
        vertical: t.spacing.s1,
      ),
      actionBorderRadius: chipRadius,
      child: child,
    );
  }
}
