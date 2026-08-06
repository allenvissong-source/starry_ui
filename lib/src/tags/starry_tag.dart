import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// Semantic status of a tag: neutral / success / warning / error / accent.
///
/// [accent] is the brand-tinted "content type" pill (e.g. a feed card's
/// 角色卡 / 世界书 / Live2D label): a translucent brand scrim with brand-strong
/// ink. It is the on-surface counterpart of the [onMedia] pill — same compact
/// bold `labelSmall` treatment, but tinted for a solid surface instead of the
/// white media scrim.
enum StarryTagStatus { neutral, success, warning, error, accent }

/// Starry UI status tag (non-interactive label pill). Uses the semantic
/// `bg` / `strong` color pairs so text keeps enough contrast on the tint.
/// For interactive tags/filters use [StarryChip] instead.
class StarryTag extends StatelessWidget {
  const StarryTag({
    required this.label,
    super.key,
    this.status = StarryTagStatus.neutral,
    this.onMedia = false,
  });

  final String label;
  final StarryTagStatus status;

  /// Whether the tag sits on top of media (an image / video thumbnail) rather
  /// than a solid surface. When true it drops the status tint for a translucent
  /// light scrim (`white` at 18% alpha) with a light `white` label, and renders
  /// its text one step smaller and bolder (`labelSmall`, `w700`) — the compact
  /// "type pill" look. [status] is ignored in this mode (an on-media tag is
  /// always the neutral scrim). Defaults to false so ordinary status tags keep
  /// their tinted surface look.
  final bool onMedia;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;

    // On-media tags render as a translucent light scrim with a light label,
    // independent of [status]: white is the canonical on-media ink and the
    // scrim alpha comes from `opacity.mediaScrim` (the shared light media-overlay
    // step). Text is one step
    // smaller (labelSmall / xs) and bolder (w700) for legibility over imagery,
    // and the tag height stays content-driven via the padding below.
    if (onMedia) {
      // White scrim is a fixed media-overlay constant, not theme-derived.
      const scrim = Colors.white; // hardcode-allow: on-media 白色蒙层常量,无语义令牌
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: t.spacing.s3,
          vertical: t.spacing.s1,
        ),
        decoration: BoxDecoration(
          color: scrim.withValues(alpha: t.opacity.mediaScrim),
          borderRadius: BorderRadius.circular(t.radius.full),
        ),
        child: Text(
          label,
          style: t.typography.labelSmall.textStyle.copyWith(
            color: Colors
                .white, // hardcode-allow: on-media 文字用白色是图片上的规范墨色,不随主题变化,无对应语义令牌
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    // The brand-accent pill renders one step smaller and bolder (labelSmall /
    // w700) — the compact "type pill" treatment shared with [onMedia] — while
    // the four status tones keep the standard bodySmall / w600 label. Both the
    // tint (brand @ 12%) and the ink (brandStrong) are derived from the brand
    // role, so no dedicated token is introduced.
    late final Color bg;
    late final Color fg;
    late final TextStyle labelStyle;
    switch (status) {
      case StarryTagStatus.neutral:
        bg = s.surfaceVariant;
        fg = s.textSecondary;
        labelStyle = t.typography.bodySmall.textStyle.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        );
      case StarryTagStatus.success:
        bg = s.successBg;
        fg = s.successStrong;
        labelStyle = t.typography.bodySmall.textStyle.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        );
      case StarryTagStatus.warning:
        bg = s.warningBg;
        fg = s.warningStrong;
        labelStyle = t.typography.bodySmall.textStyle.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        );
      case StarryTagStatus.error:
        bg = s.errorBg;
        fg = s.errorStrong;
        labelStyle = t.typography.bodySmall.textStyle.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        );
      case StarryTagStatus.accent:
        bg = s.brand.withValues(alpha: t.opacity.accentSurface);
        fg = s.brandStrong;
        labelStyle = t.typography.labelSmall.textStyle.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        );
    }
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: t.spacing.s3,
        vertical: t.spacing.s1,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(t.radius.full),
      ),
      child: Text(label, style: labelStyle),
    );
  }
}
