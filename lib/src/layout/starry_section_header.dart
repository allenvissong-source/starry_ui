import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// Visual tone for the [StarrySectionHeader] title.
enum StarrySectionHeaderTone {
  /// Primary emphasis title (strongest text tone).
  primary,

  /// Muted title (secondary/subdued text tone).
  muted,
}

/// A vertical section header composed of an optional title, description and
/// child content. Used to introduce a group of related settings/content.
class StarrySectionHeader extends StatelessWidget {
  const StarrySectionHeader({
    super.key,
    this.title,
    this.description,
    this.child,
    this.contentPadding,
    this.bottomSpacing = 0,
    this.tone = StarrySectionHeaderTone.primary,
  }) : assert(
          title != null || description != null || child != null,
          'StarrySectionHeader requires at least one of title, description or child.',
        );

  /// Section title.
  final String? title;

  /// Supporting description shown below the title.
  final String? description;

  /// Arbitrary child content shown below the description.
  final Widget? child;

  /// Padding applied around [child]. Defaults to [EdgeInsets.zero].
  final EdgeInsetsGeometry? contentPadding;

  /// Trailing vertical spacing appended after all content.
  final double bottomSpacing;

  /// Title emphasis tone.
  final StarrySectionHeaderTone tone;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<StarryTokens>()!;
    final s = tokens.semantic;

    final titleColor = tone == StarrySectionHeaderTone.primary
        ? s.textPrimary
        : s.textSecondary;

    final children = <Widget>[];

    if (title != null) {
      children.add(
        Padding(
          padding: EdgeInsets.fromLTRB(
            tokens.spacing.s3,
            tokens.spacing.s4,
            tokens.spacing.s3,
            tokens.spacing.s1,
          ),
          child: Text(
            title!,
            style: tokens.typography.labelLarge.textStyle.copyWith(
              color: titleColor,
            ),
          ),
        ),
      );
    }

    if (description != null) {
      children.add(
        Padding(
          padding: EdgeInsets.fromLTRB(
            tokens.spacing.s3,
            0,
            tokens.spacing.s3,
            tokens.spacing.s3,
          ),
          child: Text(
            description!,
            style: tokens.typography.bodySmall.textStyle.copyWith(
              color: s.textSecondary,
            ),
          ),
        ),
      );
    }

    if (child != null) {
      children.add(
        Padding(
          padding: contentPadding ?? EdgeInsets.zero,
          child: child,
        ),
      );
    }

    if (bottomSpacing > 0) {
      children.add(SizedBox(height: bottomSpacing));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}
