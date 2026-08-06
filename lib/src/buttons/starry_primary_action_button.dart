import 'package:flutter/material.dart';

import 'starry_button.dart';

/// Page-level primary action button (bottom-of-page / form submit).
///
/// A thin, opinionated wrapper over [StarryButton]: it pins the filled brand
/// variant, defaults to full width, and enables the press-scale
/// micro-interaction so the primary CTA feels physically pressable. It exists
/// so call sites express intent ("this is *the* page action") without repeating
/// the `variant / fullWidth / pressScale` triad.
///
/// Unlike the legacy main-app control it does **not** hand-tune a 52px height —
/// the height folds to [StarryButton]'s token `controlHeight` (48) so every
/// button in the system shares one vertical rhythm. All color / radius /
/// typography come from the underlying token-driven [StarryButton].
class StarryPrimaryActionButton extends StatelessWidget {
  const StarryPrimaryActionButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.loading = false,
    this.enabled = true,
    this.fullWidth = true,
  });

  /// Button text.
  final String label;

  /// Tap callback. When null (or [enabled] is false) the button is disabled.
  final VoidCallback? onPressed;

  /// Optional leading icon.
  final IconData? icon;

  /// Whether to show the inline loading spinner (also disables the tap).
  final bool loading;

  /// Explicit enable flag — equivalent to passing a null [onPressed], provided
  /// as extra control for call sites that keep the callback around.
  final bool enabled;

  /// Whether the button fills its slot width. Defaults to true for the classic
  /// full-bleed page action; set false to size to content.
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = enabled ? onPressed : null;
    return StarryButton(
      label: label,
      onPressed: effectiveOnPressed,
      icon: icon,
      loading: loading,
      fullWidth: fullWidth,
      pressScale: true,
    );
  }
}
