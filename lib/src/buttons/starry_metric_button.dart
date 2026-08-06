import 'package:flutter/material.dart';

import '../foundations/starry_count_formatter.dart';
import '../theme/starry_tokens.dart';

/// Ink context for a [StarryMetricButton].
///
/// - [surface]: on a solid surface — neutral `textSecondary` ink, brand ink
///   when [StarryMetricButton.active].
/// - [onMedia]: on top of media (image/video) — white ink for legibility over
///   imagery, independent of active state.
enum StarryMetricTone { surface, onMedia }

/// A compact "icon + count" metric affordance (e.g. count, comment, share).
///
/// The count is formatted with [StarryCountFormatter.compact] by default; pass
/// [countFormatter] to override (e.g. for a non-zh locale). [active] swaps to
/// [activeIcon] (falling back to [icon] when null) and, on the [surface] tone,
/// tints the ink brand. Pass [activeColor] to override the active-state ink
/// with a specific semantic color (e.g. a red heart for "liked") regardless of
/// [tone]. [disabled] dims to 45% and blocks taps unless [allowDisabledTap] is
/// set; [loading] replaces the glyph with a small spinner.
class StarryMetricButton extends StatelessWidget {
  const StarryMetricButton({
    required this.icon,
    required this.count,
    required this.semanticLabel,
    super.key,
    this.activeIcon,
    this.active = false,
    this.disabled = false,
    this.loading = false,
    this.tone = StarryMetricTone.surface,
    this.allowDisabledTap = false,
    this.onTap,
    this.countFormatter,
    this.activeColor,
  });

  /// Glyph in the inactive state.
  final IconData icon;

  /// Glyph in the active state. Falls back to [icon] when null.
  final IconData? activeIcon;

  /// Raw count value (formatted by [countFormatter] / the compact default).
  final int count;

  /// Accessible label describing the metric.
  final String semanticLabel;

  /// Whether the metric is in its active (e.g. liked) state.
  final bool active;

  /// Dim + (usually) block interaction.
  final bool disabled;

  /// Replace the glyph with a spinner.
  final bool loading;

  /// Ink context — see [StarryMetricTone].
  final StarryMetricTone tone;

  /// Allow taps even while [disabled] (e.g. to surface a "not allowed" toast).
  final bool allowDisabledTap;

  /// Tap handler.
  final VoidCallback? onTap;

  /// Count formatter. Defaults to [StarryCountFormatter.compact].
  final String Function(int count)? countFormatter;

  /// Overrides the active-state ink (icon + count) with a specific color when
  /// non-null and [active] is true (e.g. a red heart for a "liked" metric).
  /// When null, the ink follows the default [tone] behavior.
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;

    final Color baseInk;
    switch (tone) {
      case StarryMetricTone.onMedia:
        baseInk = Colors
            .white; // hardcode-allow: on-media 墨色用白色是图片/视频上的规范墨色,不随主题变化,无对应语义令牌
      case StarryMetricTone.surface:
        baseInk = active ? s.brand : s.textSecondary;
    }

    final Color ink = (active && activeColor != null) ? activeColor! : baseInk;

    final double iconSize = t.controlMetrics.iconSm;
    final Widget leading = loading
        ? SizedBox.square(
            dimension: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: t.controlMetrics.borderThin,
              color: ink,
            ),
          )
        : Icon(
            active ? (activeIcon ?? icon) : icon,
            size: iconSize,
            color: ink,
          );

    final String Function(int) fmt =
        countFormatter ?? StarryCountFormatter.compact;

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        leading,
        SizedBox(width: t.spacing.s1),
        Text(
          fmt(count),
          style: t.typography.bodySmall.textStyle.copyWith(color: ink),
        ),
      ],
    );

    if (disabled) {
      content = Opacity(opacity: t.opacity.disabledContent, child: content);
    }

    final bool interactive = onTap != null && (!disabled || allowDisabledTap);

    return Semantics(
      button: true,
      enabled: interactive,
      label: semanticLabel,
      value: fmt(count),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: interactive ? onTap : null,
        child: ExcludeSemantics(child: content),
      ),
    );
  }
}
