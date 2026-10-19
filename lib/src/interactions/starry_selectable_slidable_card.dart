import 'package:flutter/material.dart';

import '../theme/starry_application_tokens.dart';
import 'starry_slidable_drawer.dart';
import 'starry_swipe_action.dart';

/// Token-driven selectable card with trailing swipe actions.
///
/// Owns the complete visual and interaction shell: surface, border, elevation,
/// rounded clipping, selected/hover/focus/pressed states and the action drawer.
/// Consumers provide only business content and actions.
class StarrySelectableSlidableCard extends StatelessWidget {
  const StarrySelectableSlidableCard({
    required this.child,
    required this.actions,
    required this.onTap,
    super.key,
    this.selected = false,
    this.padding,
  });

  final Widget child;
  final List<StarrySwipeAction> actions;
  final VoidCallback onTap;
  final bool selected;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final t = context.starryTokens;
    final radius = BorderRadius.circular(t.radius.xl);
    final backgroundColor = selected
        ? t.semantic.brand.withValues(alpha: t.opacity.selectedSurface)
        : t.semantic.surface;
    final borderColor = selected ? t.semantic.brandStrong : t.semantic.border;

    final card = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: t.elevation.level2,
      ),
      child: Material(
        color: t.semantic.surface,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: radius,
            border: Border.all(
              color: borderColor,
              width: t.controlMetrics.restBorderWidth,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return t.semantic.brand.withValues(
                  alpha: t.opacity.statePressed,
                );
              }
              if (states.contains(WidgetState.focused)) {
                return t.semantic.brand.withValues(alpha: t.opacity.stateFocus);
              }
              if (states.contains(WidgetState.hovered)) {
                return t.semantic.brand.withValues(alpha: t.opacity.stateHover);
              }
              return null;
            }),
            child: Padding(
              padding: padding ?? EdgeInsets.all(t.spacing.s3),
              child: child,
            ),
          ),
        ),
      ),
    );

    return StarrySlidableDrawer(
      actions: actions,
      borderRadius: radius,
      backgroundColor: backgroundColor,
      child: card,
    );
  }
}
