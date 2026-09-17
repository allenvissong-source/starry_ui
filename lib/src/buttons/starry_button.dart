import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';
import '../components/starry_control_shell.dart';

/// Button hierarchy: primary / secondary brand / tonal / text / neutral. All
/// variants share one token-driven base and only swap the color pair + fill.
///
/// [StarryButtonVariant.text] is the low-emphasis *brand* transparent button;
/// [StarryButtonVariant.neutral] is the same transparent fill but uses the
/// neutral secondary-text foreground — for secondary actions that should not
/// read as brand-colored at all.
enum StarryButtonVariant { filled, secondary, tonal, text, neutral, destructive }

/// Content layout of a [StarryButton].
///
/// - [inline]: icon (if any) and label sit side by side in a `Row` — the
///   default, height-pinned capsule/rectangle button.
/// - [stacked]: icon sits *above* the label in a `Column`; the button sizes to
///   its content height (with a ≥`controlHeight` floor for the tap target)
///   instead of the single-line pinned height. Use this for compact
///   icon-over-label affordances (e.g. a message action).
enum StarryButtonLayout { inline, stacked }

/// Starry UI's brand button. Fully token-driven (color / height / radius /
/// icon size / spacing / typography come from [StarryTokens]); exposes an
/// accessible [Semantics] node and an inline loading state.
class StarryButton extends StatefulWidget {
  const StarryButton({
    required this.label,
    super.key,
    this.onPressed,
    this.variant = StarryButtonVariant.filled,
    this.icon,
    this.loading = false,
    this.fullWidth = false,
    this.pill = true,
    this.pressScale = false,
    this.layout = StarryButtonLayout.inline,
  }) : height = null;

  /// Concentric nested capsule button (AGENTS.md §1.5.2) — the *only* public
  /// way to give a [StarryButton] a reduced height. Use this (never a
  /// hand-tuned height) to cap a pill input/shell: it binds the reduced visible
  /// [height] to [MaterialTapTargetSize.shrinkWrap] internally, so the button's
  /// *layout* box tracks its visible capsule and cannot inflate the host
  /// control past `controlHeight`. [pill] defaults to true (capsule-in-capsule)
  /// and [fullWidth] is forced off — the button fills its slot by layout, and a
  /// forced width would break the uniform concentric gap.
  ///
  /// Pass [height] as the shell's concentric inner height
  /// (`StarryInputShell.concentricInnerHeight`), measured in the shell's
  /// interior frame (inside the 2px focus border). Because there is no public
  /// height setter that keeps the default `padded` tap target, the
  /// "reduced height + padded" asymmetry trap is unrepresentable.
  const StarryButton.concentric({
    required this.label,
    required this.height,
    super.key,
    this.onPressed,
    this.variant = StarryButtonVariant.filled,
    this.icon,
    this.loading = false,
    this.pill = true,
    this.pressScale = false,
    this.layout = StarryButtonLayout.inline,
  }) : fullWidth = false;

  final String label;
  final VoidCallback? onPressed;
  final StarryButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final bool fullWidth;

  /// Whether the button renders as a stadium/pill (perfect semicircle ends,
  /// independent of height). Defaults to `true`: the brand button is a capsule,
  /// matching [StarryInputShell]'s `pill` shell so a trailing button caps a pill
  /// input concentrically. Set to `false` for a `radius.md` rounded rectangle.
  final bool pill;

  /// When true the button plays the shared press-scale micro-interaction
  /// (`StarryControlShell.pressable`, scale 0.95) on pointer-down. Off by
  /// default so ordinary buttons keep their static footprint; enable for a
  /// high-emphasis CTA that should feel physically "pressable". The scale is
  /// suppressed while disabled or loading.
  final bool pressScale;

  /// Content arrangement — see [StarryButtonLayout]. Defaults to
  /// [StarryButtonLayout.inline] so existing call sites are unchanged.
  final StarryButtonLayout layout;

  /// Visual height of the button's capsule/rectangle, set only via
  /// [StarryButton.concentric]; the default constructor leaves it null so a
  /// standalone button always renders at `controlMetrics.controlHeight` (48)
  /// with a ≥48 [MaterialTapTargetSize.padded] tap target (AGENTS.md §1.5.6).
  /// A non-null (reduced) height comes exclusively from the concentric factory,
  /// which pairs it with [MaterialTapTargetSize.shrinkWrap] so the layout box
  /// tracks the visible capsule and cannot inflate the host control past
  /// `controlHeight` (AGENTS.md §1.5.2). Keeping this field settable only by the
  /// factory makes the "reduced height + padded" asymmetry unrepresentable.
  final double? height;

  @override
  State<StarryButton> createState() => _StarryButtonState();
}

class _StarryButtonState extends State<StarryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;
    final effectiveOnPressed = widget.loading ? null : widget.onPressed;
    final stacked = widget.layout == StarryButtonLayout.stacked;

    // Resolve the visible capsule height once. When a concentric [height] is
    // passed it MUST render at exactly that value so the nested capsule stays
    // concentric (AGENTS.md §1.5.2); otherwise fall back to the token height.
    final double resolvedHeight =
        widget.height ?? t.controlMetrics.controlHeight;

    // Resolve the color pair per variant, all from semantic tokens.
    late final Color background;
    late final Color foreground;
    switch (widget.variant) {
      case StarryButtonVariant.filled:
        background = s.brand;
        foreground = s.onBrand;
      case StarryButtonVariant.secondary:
        background = s.brandStrong;
        foreground = s.onBrand;
      case StarryButtonVariant.tonal:
        background = s.surfaceVariant;
        foreground = s.brandStrong;
      case StarryButtonVariant.text:
        background = Colors.transparent;
        foreground = s.brandStrong;
      case StarryButtonVariant.neutral:
        background = Colors.transparent;
        foreground = s.textSecondary;
      case StarryButtonVariant.destructive:
        background = s.error;
        foreground = s.onError;
    }

    final Widget content = widget.loading
        ? SizedBox.square(
            dimension: t.controlMetrics.iconLg,
            child: CircularProgressIndicator(
              strokeWidth: t.controlMetrics.borderThick,
              color: foreground,
            ),
          )
        : stacked
        ? Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (widget.icon != null) ...<Widget>[
                Icon(widget.icon, size: t.controlMetrics.iconMd),
                SizedBox(height: t.spacing.s1),
              ],
              Text(widget.label, textAlign: TextAlign.center),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (widget.icon != null) ...<Widget>[
                Icon(widget.icon, size: t.controlMetrics.iconMd),
                SizedBox(width: t.spacing.s2),
              ],
              Text(widget.label),
            ],
          );

    final style = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return widget.variant == StarryButtonVariant.text ||
                  widget.variant == StarryButtonVariant.tonal ||
                  widget.variant == StarryButtonVariant.neutral
              ? Colors.transparent
              : s.surfaceVariant;
        }
        return background;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return s.textDisabled;
        return foreground;
      }),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      elevation: WidgetStateProperty.all(0),
      // Height policy depends on [layout]:
      //   • inline: pin the *visible* capsule to exactly [resolvedHeight]
      //     (min == max) so a single-line button (and the concentric nesting
      //     case) cannot inflate. A lone `minimumSize` is not enough: the
      //     framework default
      // `VisualDensity.adaptivePlatformDensity` resolves to `compact` on
      // desktop/web and shrinks the material fill below the requested height,
      // so a concentric button ends up shorter than `controlHeight − 2·gap`
      // and its top/bottom gaps swell far past the horizontal gap (breaks the
      // uniform concentric inset of AGENTS.md §1.5.2). `standard` density plus a
      // fixed min/max height makes the token height authoritative.
      //   • stacked: the icon-over-label column is intrinsically multi-line, so
      //     pinning a single-line height would clip it. Keep [resolvedHeight]
      //     only as the *minimum* (tap-target floor) and let the content drive
      //     the height (no max).
      minimumSize: WidgetStateProperty.all(Size(0, resolvedHeight)),
      maximumSize: WidgetStateProperty.all(
        stacked
            ? const Size(double.infinity, double.infinity)
            : Size(double.infinity, resolvedHeight),
      ),
      visualDensity: VisualDensity.standard,
      // Tap-target policy depends on whether the caller shrank the button:
      //   • height == null (standalone button): keep the hit target ≥48 via
      //     [MaterialTapTargetSize.padded] — the padding sits *outside* the
      //     visible box, so ergonomics stay correct (AGENTS.md §1.5.6).
      //   • height != null (concentric nesting, AGENTS.md §1.5.2): use
      //     [MaterialTapTargetSize.shrinkWrap]. `padded` would re-inflate the
      //     button's *layout* box back to 48 even though the visible capsule is
      //     e.g. 36; that taller layout box then becomes the tallest child of
      //     the host Row, pushing the pill shell's interior to 48 (control
      //     grows past `controlHeight`) and swelling the vertical white channel
      //     to (48 − height)/2 while the horizontal gap stays at `gap` — the
      //     exact asymmetry §1.5.2 forbids. A concentric nested button cannot
      //     also be ≥48 tap-tall inside a 48 control without destroying the
      //     gap, so the explicit concentric height wins and the layout box
      //     tracks the visible capsule.
      tapTargetSize: widget.height == null
          ? MaterialTapTargetSize.padded
          : MaterialTapTargetSize.shrinkWrap,
      padding: WidgetStateProperty.all(
        stacked
            ? EdgeInsets.symmetric(
                horizontal: t.spacing.s3,
                vertical: t.spacing.s2,
              )
            : EdgeInsets.symmetric(horizontal: t.spacing.s4),
      ),
      textStyle: WidgetStateProperty.all(
        t.typography.labelLarge.textStyle.copyWith(fontWeight: FontWeight.w600),
      ),
      shape: WidgetStateProperty.all(
        widget.pill
            ? const StadiumBorder()
            : RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(t.radius.md),
              ),
      ),
    );

    Widget button = Semantics(
      button: true,
      label: widget.label,
      enabled: effectiveOnPressed != null,
      value: widget.loading ? 'Loading' : null,
      child: TextButton(
        onPressed: effectiveOnPressed,
        style: style,
        child: ExcludeSemantics(child: content),
      ),
    );

    // Press-scale micro-interaction: opt-in, and only while the button can
    // actually be pressed. A [Listener] tracks raw pointer up/down without
    // entering the gesture arena, so it never competes with the [TextButton]'s
    // own tap recognizer. Reuses the design-system's shared
    // [StarryControlShell.pressable] so the scale/curve/duration match every
    // other pressable Starry control.
    if (widget.pressScale && effectiveOnPressed != null) {
      button = Listener(
        onPointerDown: (_) => setState(() => _pressed = true),
        onPointerUp: (_) => setState(() => _pressed = false),
        onPointerCancel: (_) => setState(() => _pressed = false),
        child: StarryControlShell.pressable(
          context: context,
          isPressed: _pressed,
          child: button,
        ),
      );
    }

    return widget.fullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}
