import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';
import '../components/starry_control_shell.dart';

/// Private brand focus-shell shared by Starry text inputs.
///
/// A thin wrapper over [StarryAnimatedControlShell] (the single source of truth
/// for the control-shell visual language). It only adds the input-family
/// specifics on top: the rest→focus elevation lift (`level1`→`level2`) and the
/// input radius fallback (`radius.lg`), plus the concentric-inset helpers.
/// The border rule itself is delegated to
/// [StarryControlShell.activeBorderSide].
///
/// Token wiring (all derived from [StarryTokens]):
///   * min height  → `controlMetrics.controlHeight` (48)
///   * radius      → caller-provided token (defaults to `radius.lg` = 16)
///   * focus border→ `controlMetrics.focusBorderWidth` (2), color `brand`
///   * fill        → `semantic.surface` (or `backgroundSecondary` when disabled)
///   * horizontal  → `spacing.s5` (20)
///   * motion      → `motion.durationShort` / `motion.easingStandard`
///   * elevation   → `elevation.level1` at rest, lifts to `level2` on focus
///
/// A constant [StarryControlMetrics.focusBorderWidth] border is always painted
/// (transparent at rest) so activating focus/validation never changes the
/// control's measured size. No consumer owns hardcoded shell styling.
class StarryInputShell extends StatelessWidget {
  const StarryInputShell({
    required this.child,
    required this.focused,
    super.key,
    this.enabled = true,
    this.borderColor,
    this.borderRadius,
    this.pill = false,
    this.trailingPadding,
    this.soft = false,
  });

  final Widget child;
  final bool focused;
  final bool enabled;

  /// Quiet ("soft") visual variant. When true the shell reads at a lower
  /// contrast: a thinner rest/focus border (`controlMetrics.restBorderWidth`)
  /// that is a neutral `semantic.border` at rest and `semantic.brand` on focus,
  /// plus a light quiet fill (`semantic.backgroundSecondary`) instead of the
  /// default `semantic.surface`. Softness is expressed entirely through solid
  /// color/width tokens — no manufactured alpha — so it stays fully
  /// token-driven. Defaults to false, leaving the standard shell unchanged.
  final bool soft;

  /// Corner radius token for the shell. When null the shell falls back to
  /// `radius.lg`. A fixed-height control passed `radius.full` renders as a
  /// pill (Flutter clamps the radius to half the height).
  final double? borderRadius;

  /// When true the shell renders as a stadium/pill (perfect semicircle ends,
  /// independent of height) via [StadiumBorder]. This is the semantic way to
  /// express "maximally round" — it needs no magic radius and does not rely on
  /// Flutter clamping a large [borderRadius] down to half the height. Takes
  /// precedence over [borderRadius].
  final bool pill;

  /// Overrides the trailing (end-side) horizontal padding. When null both sides
  /// use [endPadding]. Set to [concentricGap] when a real-width trailing
  /// capsule button must nest concentrically inside a pill shell (AGENTS.md
  /// §1.5.2): the button then lands, by real layout, exactly [concentricGap]
  /// from the shell border — no translate, no overflow, no clipping.
  final double? trailingPadding;

  /// Persistent border color (e.g. validation states). When non-null it is
  /// painted in both rest and focus states. When null the border is
  /// transparent at rest and `semantic.brand` on focus.
  final Color? borderColor;

  /// The shell's horizontal end padding — the single source of truth shared by
  /// [build] and by trailing controls that need to reason about it.
  static double endPadding(StarryTokens t) => t.spacing.s5;

  /// Horizontal shift that pulls a trailing corner-cap control (e.g. a clear
  /// button) out of the shell's end padding so its icon optically centers on
  /// the round end of a pill — at `controlHeight / 2` from the border edge —
  /// instead of floating [endPadding] inside it.
  ///
  /// A trailing [IconButton] sized to `minTouchTarget` centers its icon at
  /// `endPadding + minTouchTarget / 2` from the edge, whereas the semicircle
  /// center is at `controlHeight / 2`. The difference below reclaims exactly
  /// that gap and stays correct if the touch-target / control heights ever
  /// diverge.
  static double endCapNudge(StarryTokens t) =>
      endPadding(t) +
      (t.controlMetrics.minTouchTarget - t.controlMetrics.controlHeight) / 2;

  /// Uniform gap for a real-width trailing capsule button nested concentrically
  /// inside the pill shell (AGENTS.md §1.5.2 胶囊套胶囊). The button is inset by
  /// this on all four sides, so both ends stay perfect semicircles sharing the
  /// shell's centers — no clipping.
  static double concentricGap(StarryTokens t) => t.spacing.s1;

  /// Usable interior height of the shell — the box *inside* the always-painted
  /// [StarryControlMetrics.focusBorderWidth] border. The border insets the
  /// child on every side (`ShapeBorder.dimensions`), so the interior the child
  /// actually lays out in is `controlHeight − 2·border`, not `controlHeight`.
  /// Any concentric-inset math must reason in this frame or the visible white
  /// channel ends up narrower vertically than the horizontal [trailingPadding]
  /// (which is itself applied inside the border).
  static double interiorHeight(StarryTokens t) =>
      t.controlMetrics.controlHeight - 2 * t.controlMetrics.focusBorderWidth;

  /// Visual height of a capsule button nested concentrically inside the pill
  /// shell: `interiorHeight − 2·gap`. Measured in the shell's *interior* frame
  /// (inside the border) so the visible white channel is a uniform
  /// [concentricGap] on all four sides — matching the horizontal
  /// [trailingPadding] (= gap), which is likewise applied inside the border.
  /// With [StadiumBorder] this yields inner radius `interiorHeight/2 − gap`,
  /// exactly concentric with the shell's inner (visible) edge.
  static double concentricInnerHeight(StarryTokens t) =>
      interiorHeight(t) - 2 * concentricGap(t);

  /// Diameter of a *circle* nested concentrically inside the pill shell with a
  /// uniform [concentricGap] on all four sides (AGENTS.md §1.5.2 胶囊套圆). A
  /// circle is a `width == height` stadium, so its diameter equals the nested
  /// capsule's inner height (`interiorHeight − 2·gap`) and its radius is
  /// `interiorHeight/2 − gap` — exactly concentric with the shell's inner edge.
  /// Use with
  /// `CircleBorder()` (or an equal-side `StadiumBorder`), never a
  /// `RoundedRectangleBorder(radius: …)` which is clamped by
  /// `min(r, w/2, h/2)`. Unlike a nested capsule (which fills horizontally by
  /// layout), a circle only fills vertically — the caller must center it and
  /// keep the same [concentricGap] on the left/right to stay concentric.
  static double concentricCircleDiameter(StarryTokens t) =>
      concentricInnerHeight(t);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;
    final double end = trailingPadding ?? endPadding(t);
    // Soft variant: a constant thinner border (no layout shift within the
    // widget) whose color is neutral at rest and brand on focus, over a light
    // quiet fill. Standard variant delegates to the shared active-border rule
    // (transparent at rest, brand on focus) over the surface fill.
    final BorderSide shellSide = soft
        ? BorderSide(
            color: borderColor ?? (focused ? s.brand : s.border),
            width: t.controlMetrics.restBorderWidth,
          )
        : StarryControlShell.activeBorderSide(
            context,
            isActive: focused,
            color: borderColor,
          );
    final Color fill = enabled
        ? (soft ? s.backgroundSecondary : s.surface)
        : s.backgroundSecondary;
    return StarryAnimatedControlShell(
      shellBorderSide: shellSide,
      backgroundColor: fill,
      shellBoxShadow: focused ? t.elevation.level2 : t.elevation.level1,
      pill: pill,
      shellBorderRadius: pill
          ? null
          : BorderRadius.circular(borderRadius ?? t.radius.lg),
      constraints: BoxConstraints(minHeight: t.controlMetrics.controlHeight),
      padding: EdgeInsetsDirectional.only(start: endPadding(t), end: end),
      child: child,
    );
  }
}
