import 'package:flutter/material.dart';

import '../components/starry_control_shell.dart';
import '../theme/starry_tokens.dart';

/// Animated selection frame that toggles a fill / border / elevation around
/// [child] based on [isSelected].
///
/// The rest state is fully transparent (no fill, transparent border, no
/// shadow). The selected state is token-driven by default:
/// * fill    -> `semantic.surface`
/// * border  -> [StarryControlShell.activeBorderSide] (`semantic.brand` at
///   `controlMetrics.focusBorderWidth`)
/// * shadow  -> `elevation.level2`
/// * radius  -> `radius.lg`
/// The transition runs over `motion.durationShort`.
///
/// The visual overrides ([selectedColor], [selectedBorderColor],
/// [selectedShadow], [borderRadius]) exist for callers that render a genuinely
/// different selection language on top of the same show/hide + animation
/// mechanics — e.g. a circular focus ring on a round button, or a tab chip with
/// a bespoke elevation. When omitted every value falls back to the tokens
/// above, so ordinary callers get the standard selection frame for free.
class StarrySelectedHighlight extends StatelessWidget {
  const StarrySelectedHighlight({
    required this.child,
    required this.isSelected,
    super.key,
    this.padding,
    this.borderRadius,
    this.selectedColor,
    this.selectedBorderColor,
    this.selectedShadow,
  });

  /// The framed content.
  final Widget child;

  /// Whether the selection frame is shown.
  final bool isSelected;

  /// Inner padding applied in both states so toggling never shifts [child].
  final EdgeInsetsGeometry? padding;

  /// Corner radius of the frame. Defaults to `radius.lg`.
  final BorderRadiusGeometry? borderRadius;

  /// Selected-state fill. Defaults to `semantic.surface`.
  final Color? selectedColor;

  /// Selected-state border color. Defaults to the brand active border.
  final Color? selectedBorderColor;

  /// Selected-state shadow. Defaults to `elevation.level2`.
  final List<BoxShadow>? selectedShadow;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final resolvedRadius = borderRadius ?? BorderRadius.circular(t.radius.lg);
    final border = isSelected
        ? StarryControlShell.activeBorderSide(
            context,
            color: selectedBorderColor,
          )
        : BorderSide(
            color: Colors.transparent,
            width: t.controlMetrics.focusBorderWidth,
          );

    return AnimatedContainer(
      duration: t.motion.durationShort,
      curve: StarryControlShell.pressCurve,
      padding: padding,
      decoration: BoxDecoration(
        color: isSelected
            ? (selectedColor ?? t.semantic.surface)
            : Colors.transparent,
        borderRadius: resolvedRadius,
        boxShadow: isSelected ? (selectedShadow ?? t.elevation.level2) : null,
        border: Border.fromBorderSide(border),
      ),
      child: child,
    );
  }
}
