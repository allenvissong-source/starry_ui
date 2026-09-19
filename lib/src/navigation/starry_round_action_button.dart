import 'package:flutter/material.dart';

import '../components/starry_control_shell.dart';
import '../interactions/starry_press_scale.dart';
import '../interactions/starry_selected_highlight.dart';
import '../theme/starry_tokens.dart';

/// A round, circular action button for chrome / navigation affordances.
///
/// Generalized from the app's former `AiRoundActionButton`: it carries no
/// business asset (the glyph is injected by the caller via [child], e.g. an
/// `Image.asset('ai.png')` at the app layer), and every color is token-driven
/// off [StarryTokens] instead of app-side interaction tokens:
///
/// * fill        -> `semantic.surface` (override via [backgroundColor])
/// * rest border -> `semantic.border` (override via [borderColor])
/// * focus ring  -> `semantic.brand` glow via [StarryFocusMetrics]
///   (override via [focusRingColor])
///
/// On focus the button stacks the focus ring ([StarryFocusMetrics] glow +
/// a brand border) so the affordance stays visible even on a frosted-glass
/// backdrop. The press micro-interaction reuses [StarryPressScale]; the ring
/// show/hide reuses [StarrySelectedHighlight]; the circular shell reuses
/// [StarryAnimatedControlShell].
class StarryRoundActionButton extends StatelessWidget {
  const StarryRoundActionButton({
    required this.child,
    super.key,
    this.onTap,
    this.size,
    this.backgroundColor,
    this.borderColor,
    this.focusRingColor,
    this.semanticsLabel,
  });

  /// The glyph rendered at the center of the button. Injected by the caller so
  /// the package carries no business asset.
  final Widget child;

  /// Invoked on a completed tap.
  final VoidCallback? onTap;

  /// Diameter of the button. Defaults to `controlMetrics.controlHeight` (48).
  final double? size;

  /// Fill color. Defaults to `semantic.surface`.
  final Color? backgroundColor;

  /// Rest-state border color. Defaults to `semantic.border`.
  final Color? borderColor;

  /// Focus-ring color. Defaults to `semantic.brand`.
  final Color? focusRingColor;

  /// Accessibility label for the button.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final size = this.size ?? t.controlMetrics.controlHeight;
    final resolvedBackground = backgroundColor ?? t.semantic.surface;
    final resolvedBorder = borderColor ?? t.semantic.border;
    final resolvedFocusRing = focusRingColor ?? t.semantic.brand;

    return Material(
      type: MaterialType.transparency,
      child: Focus(
        child: Builder(
          builder: (context) {
            final focused = Focus.of(context).hasFocus;
            final shadow = <BoxShadow>[
              ...t.elevation.level2,
              if (focused)
                BoxShadow(
                  color: resolvedFocusRing.withValues(alpha: t.focus.glowAlpha),
                  blurRadius: t.focus.glowBlurRadius,
                  spreadRadius: t.focus.glowSpreadRadius,
                  offset: t.focus.glowOffset,
                ),
            ];

            return StarryPressScale(
              child: StarrySelectedHighlight(
                isSelected: focused,
                borderRadius: BorderRadius.circular(size / 2),
                selectedColor: Colors.transparent,
                selectedShadow: <BoxShadow>[
                  BoxShadow(color: resolvedFocusRing),
                ],
                selectedBorderColor: resolvedFocusRing,
                child: InkWell(
                  key: const Key('starry-round-action-button'),
                  onTap: onTap,
                  customBorder: const CircleBorder(),
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Semantics(
                    button: true,
                    enabled: onTap != null,
                    label: semanticsLabel,
                    child: StarryAnimatedControlShell(
                      isActive: focused,
                      width: size,
                      height: size,
                      shape: BoxShape.circle,
                      backgroundColor: resolvedBackground,
                      shellBoxShadow: shadow,
                      shellBorderSide: BorderSide(
                        color: focused ? resolvedFocusRing : resolvedBorder,
                        width: focused
                            ? t.controlMetrics.focusBorderWidth
                            : t.controlMetrics.restBorderWidth,
                      ),
                      child: Center(
                        child: SizedBox(
                          width: t.controlMetrics.iconLg,
                          height: t.controlMetrics.iconLg,
                          child: Center(child: child),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
