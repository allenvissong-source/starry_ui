import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';
import 'starry_avatar.dart';

/// Density of a [StarryIdentityRow] — drives avatar size and name typography.
///
/// - [feed]: compact 28px avatar with a `labelMedium` name — the in-feed byline.
/// - [compact]: 32px avatar with a `bodyMedium` name.
/// - [regular]: 40px avatar with a heavier `bodyMedium` name — the default,
///   used for profile headers and prominent bylines.
enum StarryIdentityDensity { feed, compact, regular }

/// Starry UI identity row: an avatar next to a name (+ optional inline badges),
/// with an optional subtitle line and a trailing action slot.
///
/// It *composes* [StarryAvatar] (it does not re-implement avatar rendering):
/// pass an [avatarImage] and/or [avatarFallbackText] and the row builds the
/// avatar at the density's size. When [subtitle] is null the row is a single
/// line (name only); a non-null [subtitle] stacks a second line below the name
/// (for a handle, timestamp, …). [badges] is a generic widget list rendered
/// inline after the name — business code supplies `StarryBadge` / `StarryTag`
/// (or anything else); the row does not bind any business badge model.
class StarryIdentityRow extends StatelessWidget {
  const StarryIdentityRow({
    required this.name,
    super.key,
    this.subtitle,
    this.avatarImage,
    this.avatarFallbackText,
    this.density = StarryIdentityDensity.regular,
    this.badges = const <Widget>[],
    this.trailing,
    this.onTap,
  });

  /// Primary display name.
  final String name;

  /// Optional secondary line (handle / timestamp / …). Non-null → two lines.
  final String? subtitle;

  /// Image for the composed [StarryAvatar]. Falls back to [avatarFallbackText]
  /// initials when null / failed.
  final ImageProvider? avatarImage;

  /// Fallback text for the composed [StarryAvatar]'s initials.
  final String? avatarFallbackText;

  /// Row density — see [StarryIdentityDensity].
  final StarryIdentityDensity density;

  /// Inline widgets rendered after the name (e.g. `StarryBadge` / `StarryTag`).
  final List<Widget> badges;

  /// Trailing action slot (e.g. a follow button).
  final Widget? trailing;

  /// Optional tap handler for the identity (avatar + text) region.
  final VoidCallback? onTap;

  double get _avatarDiameter {
    switch (density) {
      case StarryIdentityDensity.feed:
        return StarryAvatarSize.xs.diameter;
      case StarryIdentityDensity.compact:
        return StarryAvatarSize.small.diameter;
      case StarryIdentityDensity.regular:
        return StarryAvatarSize.medium.diameter;
    }
  }

  TextStyle _nameStyle(StarryTokens t) {
    switch (density) {
      case StarryIdentityDensity.feed:
        return t.typography.labelMedium.textStyle.copyWith(
          color: t.semantic.textPrimary,
          fontWeight: FontWeight.w600,
        );
      case StarryIdentityDensity.compact:
        return t.typography.bodyMedium.textStyle.copyWith(
          color: t.semantic.textPrimary,
          fontWeight: FontWeight.w600,
        );
      case StarryIdentityDensity.regular:
        return t.typography.bodyMedium.textStyle.copyWith(
          color: t.semantic.textPrimary,
          fontWeight: FontWeight.w700,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;

    final Widget avatar = StarryAvatar(
      imageProvider: avatarImage,
      fallbackText: avatarFallbackText,
      customSize: _avatarDiameter,
    );

    final Widget nameLine = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textHeightBehavior: const TextHeightBehavior(
              applyHeightToFirstAscent: false,
              applyHeightToLastDescent: false,
            ),
            style: _nameStyle(t),
          ),
        ),
        for (final badge in badges) ...<Widget>[
          SizedBox(width: t.spacing.s1),
          badge,
        ],
      ],
    );

    final Widget textColumn = ConstrainedBox(
      constraints: BoxConstraints(minHeight: _avatarDiameter),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            nameLine,
            if (subtitle != null) ...<Widget>[
              SizedBox(height: t.spacing.s1 / 2),
              Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
                style: t.typography.bodySmall.textStyle.copyWith(
                  color: s.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    Widget identity = Row(
      children: <Widget>[
        avatar,
        SizedBox(width: t.spacing.s2),
        Expanded(child: textColumn),
      ],
    );

    if (onTap != null) {
      identity = Semantics(
        button: true,
        label: name,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(t.radius.sm),
            child: identity,
          ),
        ),
      );
    }

    if (trailing == null) return identity;

    return Row(
      children: <Widget>[
        Expanded(child: identity),
        SizedBox(width: t.spacing.s2),
        trailing!,
      ],
    );
  }
}
