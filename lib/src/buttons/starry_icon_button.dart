import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// Visual variants supported by [StarryIconButton].
enum StarryIconButtonVariant { standard, filled, filledTonal, outlined }

/// Token-driven icon-only button with an accessible label and a 48 dp target.
class StarryIconButton extends StatelessWidget {
  const StarryIconButton({
    required IconData this.icon,
    required this.tooltip,
    super.key,
    this.onPressed,
    this.variant = StarryIconButtonVariant.standard,
    this.size = kMinInteractiveDimension,
    this.enabled = true,
    this.selected = false,
  }) : customIcon = null;

  const StarryIconButton.custom({
    required Widget this.customIcon,
    required this.tooltip,
    super.key,
    this.onPressed,
    this.variant = StarryIconButtonVariant.standard,
    this.size = kMinInteractiveDimension,
    this.enabled = true,
    this.selected = false,
  }) : icon = null;

  final IconData? icon;
  final Widget? customIcon;
  final VoidCallback? onPressed;

  /// Localized accessible label and hover/long-press tooltip.
  final String tooltip;

  final StarryIconButtonVariant variant;
  final double size;
  final bool enabled;

  /// Whether the button renders its "on"/active look. When true (and enabled)
  /// the icon adopts the filled active pair (`onBrand` on `brand`) regardless of
  /// [variant], so a toggleable affordance (e.g. a bookmark or a selected
  /// persona action) can express its selected state without a bespoke widget.
  /// Defaults to false, so existing (stateless) icon buttons are unchanged. The
  /// `selected` state is also surfaced to assistive tech via [Semantics.selected].
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final effectiveSize = size < kMinInteractiveDimension
        ? kMinInteractiveDimension
        : size;
    final iconSize = t.controlMetrics.iconLg;
    final effectiveOnPressed = enabled ? onPressed : null;
    final radius = BorderRadius.circular(t.radius.full);
    final (foreground, background, border) = _resolveColors(t);

    final iconWidget = icon != null
        ? Icon(icon, size: iconSize, color: foreground)
        : IconTheme(
            data: IconThemeData(size: iconSize, color: foreground),
            child: SizedBox.square(dimension: iconSize, child: customIcon),
          );

    Widget button = SizedBox.square(
      dimension: effectiveSize,
      child: Material(
        color: background ?? t.semantic.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: border == null ? BorderSide.none : BorderSide(color: border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: effectiveOnPressed,
          borderRadius: radius,
          child: Center(child: iconWidget),
        ),
      ),
    );

    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        enabled: effectiveOnPressed != null,
        selected: selected,
        label: tooltip,
        child: ExcludeSemantics(child: button),
      ),
    );
  }

  (Color, Color?, Color?) _resolveColors(StarryTokens t) {
    final s = t.semantic;

    if (!enabled || onPressed == null) {
      return (s.textDisabled, s.backgroundSecondary, s.border);
    }

    // Selected wins over the variant's rest palette: an "on" toggle reads as a
    // solid brand fill in every variant (token-driven, no hard-coded colors).
    if (selected) {
      return (s.onBrand, s.brand, null);
    }

    switch (variant) {
      case StarryIconButtonVariant.standard:
        return (s.textSecondary, s.surface, null);
      case StarryIconButtonVariant.filled:
        return (s.onBrand, s.brand, null);
      case StarryIconButtonVariant.filledTonal:
        return (s.brandStrong, s.surfaceVariant, null);
      case StarryIconButtonVariant.outlined:
        return (s.textSecondary, s.surface, s.borderStrong);
    }
  }
}
