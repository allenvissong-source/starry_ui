import 'package:flutter/material.dart';

import '../buttons/starry_button.dart';
import '../buttons/starry_text_button.dart';
import '../theme/starry_tokens.dart';

/// Starry UI error state for a whole surface or an embedded section.
///
/// A presentation-only failure surface: it renders an error icon, a title, an
/// optional message, an optional collapsible technical detail block, and an
/// optional retry call-to-action. It carries **no** exception-classification or
/// i18n logic — the host maps its domain error to [icon] / [title] / [message]
/// / [details] and supplies a localized [retryLabel]. The retry affordance is a
/// [StarryButton] (filled variant) so it inherits the brand button's
/// token-driven height, radius and press micro-interaction.
///
/// Every color, spacing, radius and text style resolves from [StarryTokens];
/// the error icon tint comes from the semantic error token
/// ([StarrySemanticColors]).
class StarryErrorWidget extends StatelessWidget {
  const StarryErrorWidget({
    super.key,
    this.icon,
    this.title,
    this.message,
    this.details,
    this.onRetry,
    this.retryLabel = 'Retry',
    this.showDetails = false,
  }) : _compact = false;

  /// Inline feedback that takes only the space it needs in the parent list.
  const StarryErrorWidget.compact({
    required String this.title,
    super.key,
    this.icon,
    this.message,
    this.onRetry,
    this.retryLabel = 'Retry',
  }) : _compact = true,
       details = null,
       showDetails = false;

  final bool _compact;

  /// Leading error icon. When null a default [Icons.error_outline] is shown,
  /// tinted with the semantic error color.
  final Widget? icon;

  /// Primary title line (e.g. "Something went wrong").
  final String? title;

  /// Secondary human-readable description of the failure.
  final String? message;

  /// Optional technical detail (stack / code) shown in a monospace block when
  /// [showDetails] is true and this is non-null.
  final String? details;

  /// Retry callback. When null the retry button is omitted entirely.
  final VoidCallback? onRetry;

  /// Label for the retry button. Host supplies the localized string.
  final String retryLabel;

  /// Whether to render the [details] block. Ignored when [details] is null.
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    if (_compact) return _buildCompact(t);
    final s = t.semantic;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(t.spacing.s4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null)
              IconTheme(
                data: IconThemeData(color: s.error, size: t.spacing.s16),
                child: icon!,
              )
            else
              Icon(Icons.error_outline, size: t.spacing.s16, color: s.error),
            if (title != null) ...<Widget>[
              SizedBox(height: t.spacing.s4),
              Text(
                title!,
                style: t.typography.titleMedium.textStyle.copyWith(
                  color: s.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
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
            if (showDetails && details != null) ...<Widget>[
              SizedBox(height: t.spacing.s2),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: s.surfaceVariant,
                  borderRadius: BorderRadius.circular(t.radius.md),
                ),
                child: Padding(
                  padding: EdgeInsets.all(t.spacing.s3),
                  child: Text(
                    details!,
                    style: t.typography.bodySmall.textStyle.copyWith(
                      color: s.textSecondary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ],
            if (onRetry != null) ...<Widget>[
              SizedBox(height: t.spacing.s6),
              StarryButton(
                label: retryLabel,
                onPressed: onRetry,
                icon: Icons.refresh,
                pressScale: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompact(StarryTokens t) {
    final description = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconTheme(
          data: IconThemeData(
            color: t.semantic.errorStrong,
            size: t.controlMetrics.iconLg,
          ),
          child: icon ?? const Icon(Icons.error_outline),
        ),
        SizedBox(width: t.spacing.s2),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title!,
                style: t.typography.bodyMedium.textStyle.copyWith(
                  color: t.semantic.textPrimary,
                ),
              ),
              if (message != null) ...[
                SizedBox(height: t.spacing.s1),
                Text(
                  message!,
                  style: t.typography.bodySmall.textStyle.copyWith(
                    color: t.semantic.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.semantic.errorBg,
        borderRadius: BorderRadius.circular(t.radius.md),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: t.spacing.s3,
          vertical: onRetry == null ? t.spacing.s3 : t.spacing.s1,
        ),
        child: OverflowBar(
          alignment: MainAxisAlignment.spaceBetween,
          spacing: t.spacing.s2,
          overflowSpacing: t.spacing.s1,
          overflowAlignment: OverflowBarAlignment.start,
          children: [
            description,
            if (onRetry != null)
              StarryTextButton(label: retryLabel, onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
