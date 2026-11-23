import 'package:flutter/material.dart';

import '../feedback/starry_looping_animations.dart';
import '../theme/starry_tokens.dart';

/// Emphasis AI entry-point button.
///
/// A circular, brand-gradient affordance that wires up the token layer's
/// emphasis glow halo ([StarryFocusMetrics]) as a resting emphasis, coloured
/// from `semantic.brand`. It presses with the shared scale micro-interaction
/// and, when [busy], twinkles the sparkle glyph itself instead of overlaying a
/// spinner — the "thinking" beat reads as the star breathing between
/// `opacity.busyContent` and full ink, on the `motion.durationSlower` cycle.
///
/// The default glyph is a built-in sparkle ([Icons.auto_awesome]); callers may
/// override it with [icon] to use their own AI asset. The design system does
/// not ship an app image dependency.
class StarryAiButton extends StatefulWidget {
  const StarryAiButton({
    super.key,
    this.onTap,
    this.icon = Icons.auto_awesome,
    this.size,
    this.busy = false,
    this.backgroundColor,
    this.semanticLabel,
  });

  /// Tap handler. When null (or [busy]), the button is non-interactive.
  final VoidCallback? onTap;

  /// Foreground glyph. Defaults to a built-in sparkle so the DS carries no
  /// app asset dependency.
  final IconData icon;

  /// Diameter of the circular button. When null, resolves to
  /// `controlMetrics.controlHeight` (the standard 48 control extent).
  final double? size;

  /// "Thinking" state: twinkles the glyph and blocks taps.
  final bool busy;

  /// Optional override for the brand gradient fill (e.g. a flat brand tint).
  final Color? backgroundColor;

  /// Accessible label. Falls back to a generic "AI" when null.
  final String? semanticLabel;

  @override
  State<StarryAiButton> createState() => _StarryAiButtonState();
}

class _StarryAiButtonState extends State<StarryAiButton> {
  bool _pressed = false;

  /// Glyph extent as a fraction of the button [StarryAiButton.size]. No design
  /// token matches this ratio, so it stays a named local constant.
  static const double _kGlyphSizeRatio = 0.5;

  void _setPressed(bool value) {
    if (_pressed != value) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;
    final focus = t.focus;
    final interactive = widget.onTap != null && !widget.busy;
    final double size = widget.size ?? t.controlMetrics.controlHeight;

    // Resting emphasis: the reserved glow halo, coloured from semantic.brand.
    final glow = <BoxShadow>[
      BoxShadow(
        color: s.brand.withValues(alpha: focus.glowAlpha),
        blurRadius: focus.glowBlurRadius,
        spreadRadius: focus.glowSpreadRadius,
        offset: focus.glowOffset,
      ),
    ];

    final decoration = widget.backgroundColor != null
        ? BoxDecoration(
            color: widget.backgroundColor,
            shape: BoxShape.circle,
            boxShadow: glow,
          )
        : BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [t.brand.gradientStart, t.brand.gradientEnd],
            ),
            shape: BoxShape.circle,
            boxShadow: glow,
          );

    final glyphSize = size * _kGlyphSizeRatio;
    final foreground = Colors
        .white; // hardcode-allow: AI 入口渐变背景上的规范前景色,当前无独立白色语义令牌,不修改全局 onBrand 以避免扩大影响面
    final Widget glyph = Icon(widget.icon, size: glyphSize, color: foreground);

    // Busy reads as the sparkle twinkling, not a spinner: opacity breathes
    // between `opacity.busyContent` and full ink on the shared looping
    // primitive, whose default cycle is the `motion.durationSlower` token.
    // Under the platform "reduce motion" setting the glyph rests at the dimmed
    // end instead, so the state stays legible without movement.
    final bool reduceMotion = MediaQuery.of(context).disableAnimations;
    final Widget content;
    if (!widget.busy) {
      content = glyph;
    } else if (reduceMotion) {
      content = Opacity(opacity: t.opacity.busyContent, child: glyph);
    } else {
      content = StarryPulsingWidget(
        minOpacity: t.opacity.busyContent,
        child: glyph,
      );
    }

    Widget button = AnimatedScale(
      scale: _pressed ? t.motion.pressedScale : 1.0,
      duration: t.motion.durationShort,
      curve: t.motion.easingStandard,
      child: Container(
        width: size,
        height: size,
        decoration: decoration,
        child: Center(child: content),
      ),
    );

    if (interactive) {
      button = GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        child: button,
      );
    }

    return Semantics(
      button: true,
      enabled: interactive,
      label: widget.semanticLabel ?? 'AI',
      child: ExcludeSemantics(child: button),
    );
  }
}
