import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';
import 'starry_card.dart';

/// A tappable option card that presents an action with a leading icon badge,
/// a title, a supporting description, and a trailing chevron.
///
/// Composes [StarryCard] (which owns the surface fill, `radius.lg`, border,
/// `elevation.level2`, `spacing.s5` padding, and — when [onTap] is provided —
/// the button-semantic [InkWell]). This widget only lays out the interior row.
///
/// When [enabled] is `false` the card drops its elevation, disables the tap
/// handler, and dims its content to [StarryOpacity.disabledContent] while still
/// exposing a disabled button in the semantics tree.
class StarryActionOptionCard extends StatelessWidget {
  const StarryActionOptionCard({
    required this.icon,
    required this.title,
    required this.description,
    super.key,
    this.onTap,
    this.enabled = true,
  });

  /// Glyph shown inside the circular leading badge.
  final IconData icon;

  /// Primary line, rendered with `typography.titleSmall`.
  final String title;

  /// Secondary line, rendered with `typography.bodySmall`.
  final String description;

  /// Invoked on tap. Ignored when [enabled] is `false`.
  final VoidCallback? onTap;

  /// Whether the card is interactive. When `false` the card is flat, dimmed,
  /// and non-tappable.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;

    final row = Row(
      children: [
        Container(
          width: t.spacing.s10,
          height: t.spacing.s10,
          decoration: BoxDecoration(
            color: s.brand,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: t.controlMetrics.iconLg,
            color: s.onBrand,
          ),
        ),
        SizedBox(width: t.spacing.s4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: t.typography.titleSmall.textStyle.copyWith(
                  color: s.textPrimary,
                ),
              ),
              SizedBox(height: t.spacing.s1),
              Text(
                description,
                style: t.typography.bodySmall.textStyle.copyWith(
                  color: s.textSecondary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: t.spacing.s3),
        Icon(
          Icons.arrow_forward_ios,
          size: t.controlMetrics.iconSm,
          color: s.textTertiary,
        ),
      ],
    );

    final content = enabled
        ? row
        : Opacity(opacity: t.opacity.disabledContent, child: row);

    final card = StarryCard(
      onTap: enabled ? onTap : null,
      elevated: enabled,
      child: content,
    );

    if (enabled) return card;
    return Semantics(button: true, enabled: false, child: card);
  }
}
