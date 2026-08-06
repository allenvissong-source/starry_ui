import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// Private surface primitive: the single source of truth for the Starry card
/// family's container styling.
///
/// Resolves purely from [StarryTokens]:
///   * fill      → [color] ?? `semantic.surface`
///   * radius    → [borderRadius] ?? `radius.lg`
///   * border    → solid [borderColor] ?? `semantic.border`
///   * elevation → `elevation.level2` when [elevated], else none
///
/// This is the card-family equivalent of the input family's private shell: both
/// [StarryCard] and [StarryExpandableCard] compose it so the card surface can
/// never re-diverge. Not exported from the package barrel.
class StarrySurface extends StatelessWidget {
  const StarrySurface({
    required this.child,
    super.key,
    this.color,
    this.borderRadius,
    this.borderColor,
    this.elevated = true,
    this.padding,
    this.onTap,
    this.clipBehavior = Clip.none,
  });

  final Widget child;

  /// Surface fill. Defaults to `semantic.surface`.
  final Color? color;

  /// Corner radius. Defaults to `radius.lg`.
  final BorderRadius? borderRadius;

  /// Border color. Defaults to `semantic.border`.
  final Color? borderColor;

  /// Whether to paint the `elevation.level2` drop shadow.
  final bool elevated;

  /// Interior padding. When null the surface adds no padding.
  final EdgeInsetsGeometry? padding;

  /// Tap handler. When non-null the surface wraps its content in a
  /// button-semantic [InkWell] whose ink is clipped to the resolved radius.
  final VoidCallback? onTap;

  /// Clip behavior for the surface container (e.g. `Clip.antiAlias` to clip an
  /// expanding child to the rounded corners).
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;
    final radius = borderRadius ?? BorderRadius.circular(t.radius.lg);

    final content = Container(
      padding: padding,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: color ?? s.surface,
        borderRadius: radius,
        border: Border.all(color: borderColor ?? s.border),
        boxShadow: elevated ? t.elevation.level2 : null,
      ),
      child: child,
    );

    if (onTap == null) return content;

    return Semantics(
      button: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: content,
        ),
      ),
    );
  }
}
