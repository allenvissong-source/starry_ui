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
    this.accent = false,
    this.trailing,
    this.compact = false,
    this.emphasis = false,
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

  /// 紧凑标题可放在卡片内部；默认仍使用设置页的分组间距。
  final bool compact;

  /// 在紧凑标题上再强调一级：字号从 labelLarge 提升到 titleMedium，并加
  /// 半粗字重。用于卡片内需要被快速扫读的分区标题。
  final bool emphasis;
  final bool accent;
  final Widget? trailing;

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
          padding: compact
              ? EdgeInsets.zero
              : EdgeInsets.fromLTRB(
                  tokens.spacing.s3,
                  tokens.spacing.s4,
                  tokens.spacing.s3,
                  tokens.spacing.s1,
                ),
          child: Row(
            children: [
              if (accent) ...[
                Container(
                  width: tokens.controlMetrics.borderThick,
                  height: tokens.controlMetrics.iconLg,
                  decoration: BoxDecoration(
                    color: s.brand,
                    borderRadius: BorderRadius.circular(tokens.radius.full),
                  ),
                ),
                SizedBox(width: tokens.spacing.s2),
              ],
              Expanded(
                child: Text(
                  title!,
                  style: emphasis
                      ? tokens.typography.titleMedium.textStyle.copyWith(
                          color: titleColor,
                          fontWeight: FontWeight.w600,
                        )
                      : tokens.typography.labelLarge.textStyle.copyWith(
                          color: titleColor,
                        ),
                ),
              ),
              ?trailing,
            ],
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
        Padding(padding: contentPadding ?? EdgeInsets.zero, child: child),
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
