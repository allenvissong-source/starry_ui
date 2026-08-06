import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// MD3 state-layer mechanism for Starry controls.
///
/// Replaces the old "state x property" combinatorial matrix (e.g. a 36-slot
/// interaction table) with a single base color plus fixed opacity steps that
/// are stacked at runtime. The opacity steps live on [StarryOpacity]
/// (`stateHover` / `stateFocus` / `statePressed` / `stateDragged`) and are
/// fixed across light / dark themes, per MD3 semantics.
///
/// Two forms are provided:
///
/// * [overlayColor] — the **preferred** form. Returns a
///   `WidgetStateProperty<Color?>` to hand to a Material control's own
///   `overlayColor` (`InkWell.overlayColor`, `ButtonStyle.overlayColor`, ...).
///   Letting the Material control paint the overlay avoids the double-overlay
///   pitfall where a manually-stacked layer and the InkWell's own overlay both
///   render (a hover reading ~16% instead of the intended ~8%).
///
/// * [StarryStateLayer] widget — the secondary form, for **bare**
///   `GestureDetector`-style controls that self-paint and have no Material
///   overlay of their own. It paints a single resolved overlay over [child].
///
/// In both forms the overlay color is the semantic foreground color at the
/// matching [StarryOpacity] step (neutral controls use `textPrimary`,
/// selected / active controls use `brand`). When `disabled` the overlay is
/// **not** stacked — this mutual exclusion is handled inside this component so
/// callers never have to special-case it.
///
/// Focus is intentionally NOT expressed as a state-layer-only affordance: on a
/// frosted-glass background an 8–10% tint can be imperceptible, which fails
/// accessibility. Callers should stack the focus state layer ([stateFocus])
/// *on top of* the existing focus ring drawn from [StarryFocusMetrics]
/// (glow / ring), rather than relying on the tint alone.
class StarryStateLayer extends StatelessWidget {
  const StarryStateLayer({
    required this.child,
    super.key,
    this.hovered = false,
    this.focused = false,
    this.pressed = false,
    this.dragged = false,
    this.disabled = false,
    this.selected = false,
    this.baseColor,
    this.borderRadius,
  });

  /// The content the overlay is painted over.
  final Widget child;

  /// Whether the control is hovered. Maps to [StarryOpacity.stateHover].
  final bool hovered;

  /// Whether the control is focused. Maps to [StarryOpacity.stateFocus].
  final bool focused;

  /// Whether the control is pressed. Maps to [StarryOpacity.statePressed].
  final bool pressed;

  /// Whether the control is being dragged. Maps to
  /// [StarryOpacity.stateDragged].
  final bool dragged;

  /// Whether the control is disabled. When true no overlay is painted.
  final bool disabled;

  /// Whether the control is selected / active. Selects the `brand` base color
  /// instead of the neutral `textPrimary`.
  final bool selected;

  /// Overrides the semantic base color. Defaults to `brand` when [selected],
  /// otherwise `textPrimary`.
  final Color? baseColor;

  /// Corner radius of the painted overlay. Defaults to a rectangle.
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final overlay = resolve(
      t,
      hovered: hovered,
      focused: focused,
      pressed: pressed,
      dragged: dragged,
      disabled: disabled,
      selected: selected,
      baseColor: baseColor,
    );

    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        child,
        if (overlay != null)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: overlay,
                  borderRadius: borderRadius,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Resolves the highest-priority active state to its overlay color, or
  /// `null` when no overlay should paint (disabled, or fully at rest).
  ///
  /// Priority mirrors MD3: pressed > dragged > focused > hovered. Disabled
  /// short-circuits to `null` so the overlay is never stacked on a disabled
  /// control.
  static Color? resolve(
    StarryTokens t, {
    bool hovered = false,
    bool focused = false,
    bool pressed = false,
    bool dragged = false,
    bool disabled = false,
    bool selected = false,
    Color? baseColor,
  }) {
    if (disabled) return null;
    final base = baseColor ?? (selected ? t.semantic.brand : t.semantic.textPrimary);
    final double? alpha;
    if (pressed) {
      alpha = t.opacity.statePressed;
    } else if (dragged) {
      alpha = t.opacity.stateDragged;
    } else if (focused) {
      alpha = t.opacity.stateFocus;
    } else if (hovered) {
      alpha = t.opacity.stateHover;
    } else {
      alpha = null;
    }
    if (alpha == null) return null;
    return base.withValues(alpha: alpha);
  }

  /// Preferred form: a [WidgetStateProperty] to feed a Material control's own
  /// `overlayColor` (InkWell / ButtonStyle). Painting through the Material
  /// control's overlay avoids double-stacking with a manual layer.
  ///
  /// [base] defaults to `brand` when [selected], otherwise `textPrimary`. The
  /// `disabled` state resolves to [Colors.transparent] (no overlay).
  static WidgetStateProperty<Color?> overlayColor(
    StarryTokens t, {
    Color? base,
    bool selected = false,
  }) {
    final resolved = base ?? (selected ? t.semantic.brand : t.semantic.textPrimary);
    return WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return Colors.transparent;
      }
      if (states.contains(WidgetState.pressed)) {
        return resolved.withValues(alpha: t.opacity.statePressed);
      }
      if (states.contains(WidgetState.dragged)) {
        return resolved.withValues(alpha: t.opacity.stateDragged);
      }
      if (states.contains(WidgetState.focused)) {
        return resolved.withValues(alpha: t.opacity.stateFocus);
      }
      if (states.contains(WidgetState.hovered)) {
        return resolved.withValues(alpha: t.opacity.stateHover);
      }
      return Colors.transparent;
    });
  }
}
