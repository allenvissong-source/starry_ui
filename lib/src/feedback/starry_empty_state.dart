import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// Starry UI empty-state placeholder.
///
/// Shown when a list / page has no data. All spacing, colors and typography
/// resolve from [StarryTokens]; the default icon is [Icons.inbox_outlined].
class StarryEmptyState extends StatelessWidget {
  const StarryEmptyState({
    super.key,
    this.icon,
    this.title,
    this.message,
    this.action,
  });

  /// Custom leading icon. When null a default [Icons.inbox_outlined] is shown.
  final Widget? icon;

  /// Primary title line.
  final String? title;

  /// Secondary description line.
  final String? message;

  /// Optional call-to-action rendered below the message.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(t.spacing.s4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null)
              IconTheme(
                data: IconThemeData(color: s.textTertiary, size: t.spacing.s16),
                child: icon!,
              )
            else
              Icon(
                Icons.inbox_outlined,
                size: t.spacing.s16,
                color: s.textTertiary,
              ),
            SizedBox(height: t.spacing.s4),
            if (title != null)
              Text(
                title!,
                style: t.typography.titleMedium.textStyle.copyWith(
                  color: s.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            if (message != null) ...<Widget>[
              SizedBox(height: t.spacing.s2),
              Text(
                message!,
                style: t.typography.bodySmall.textStyle.copyWith(
                  color: s.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...<Widget>[
              SizedBox(height: t.spacing.s6),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
