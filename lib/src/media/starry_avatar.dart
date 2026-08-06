import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// Preset avatar diameters (logical pixels). Mirrors the shipped avatar tiers
/// used across profile, feed and identity surfaces. Use [StarryAvatar.customSize]
/// only when a call site genuinely needs an off-ramp size.
enum StarryAvatarSize {
  xs(24),
  small(32),
  medium(40),
  large(48),
  xl(64),
  xxl(80);

  const StarryAvatarSize(this.diameter);

  /// Diameter in logical pixels.
  final double diameter;
}

/// Outline shape of a [StarryAvatar].
enum StarryAvatarShape {
  /// Perfect circle (diameter / 2 corner radius).
  circle,

  /// Rounded square using `radius.lg`.
  rounded,
}

/// Starry UI avatar primitive: a fixed-size circular or rounded image with a
/// deterministic fallback chain and an optional outline.
///
/// This is a *pure render* primitive — it takes a ready [ImageProvider] and
/// does no URL resolution, signing or network caching (those are business
/// concerns owned by the consuming app). It renders the first available of:
/// the image, then [fallbackText] initials, then [fallbackIcon], then a person
/// glyph — so it always paints something inside its box.
///
/// The [bordered] toggle draws an outer ring (default `semantic.brand`,
/// `controlMetrics.borderThin` wide); it is off by default so existing avatar
/// call sites are unchanged.
class StarryAvatar extends StatelessWidget {
  const StarryAvatar({
    super.key,
    this.imageProvider,
    this.fallbackText,
    this.fallbackIcon,
    this.size = StarryAvatarSize.medium,
    this.customSize,
    this.shape = StarryAvatarShape.circle,
    this.bordered = false,
    this.borderColor,
    this.borderWidth,
    this.backgroundColor,
    this.foregroundColor,
    this.onTap,
    this.heroTag,
  });

  /// Fallback-glyph extent as a fraction of the avatar diameter, matching the
  /// visual weight of the initials tier it stands in for.
  static const double _kFallbackIconSizeRatio = 0.6;

  /// Foreground image. When null (or it fails to decode) the fallback chain
  /// takes over.
  final ImageProvider? imageProvider;

  /// Text whose initials are shown when there is no image. See [_initials].
  final String? fallbackText;

  /// Glyph shown when there is neither an image nor usable [fallbackText].
  /// Defaults to [Icons.person] when null.
  final IconData? fallbackIcon;

  /// Preset diameter tier. Ignored when [customSize] is non-null.
  final StarryAvatarSize size;

  /// Explicit diameter override (logical pixels). Wins over [size].
  final double? customSize;

  /// Circle (default) or rounded square.
  final StarryAvatarShape shape;

  /// Whether to draw an outer ring. Off by default.
  final bool bordered;

  /// Ring color when [bordered] is true. Defaults to `semantic.brand`.
  final Color? borderColor;

  /// Ring width when [bordered] is true. Defaults to
  /// `controlMetrics.borderThin`.
  final double? borderWidth;

  /// Fill behind the fallback content. Defaults to `semantic.surfaceVariant`.
  final Color? backgroundColor;

  /// Ink for the fallback initials / icon. Defaults to `semantic.textSecondary`.
  final Color? foregroundColor;

  /// Optional tap handler. When set the avatar becomes a button for a11y.
  final VoidCallback? onTap;

  /// Optional [Hero] tag wrapping the avatar for shared-element transitions.
  final Object? heroTag;

  /// Resolve initials from [fallbackText]: a single token yields its first two
  /// letters, two or more tokens yield the first letter of the first two
  /// tokens. Returns null when there is nothing usable.
  String? _initials() {
    final text = fallbackText?.trim();
    if (text == null || text.isEmpty) return null;
    final parts = text
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return null;
    if (parts.length == 1) {
      final single = parts.first;
      return (single.length >= 2 ? single.substring(0, 2) : single)
          .toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;
    final double diameter = customSize ?? size.diameter;
    final Color bg = backgroundColor ?? s.surfaceVariant;
    final Color fg = foregroundColor ?? s.textSecondary;

    final double radiusValue = shape == StarryAvatarShape.circle
        ? diameter / 2
        : t.radius.lg;
    final BorderRadius borderRadius = BorderRadius.circular(radiusValue);

    // Fallback content painted behind (and revealed instead of) the image.
    final String? initials = _initials();
    final Widget fallback = Center(
      child: initials != null
          ? Text(
              initials,
              style: t.typography.labelMedium.textStyle.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
              ),
            )
          : Icon(
              fallbackIcon ?? Icons.person,
              size: diameter * _kFallbackIconSizeRatio,
              color: fg,
            ),
    );

    Widget content = DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: borderRadius,
        border: bordered
            ? Border.all(
                color: borderColor ?? s.brand,
                width: borderWidth ?? t.controlMetrics.borderThin,
              )
            : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            fallback,
            if (imageProvider != null)
              Image(
                image: imageProvider!,
                fit: BoxFit.cover,
                // On decode error we simply keep the fallback layer painted
                // beneath — returning an empty box reveals it.
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
          ],
        ),
      ),
    );

    content = SizedBox.square(dimension: diameter, child: content);

    if (heroTag != null) {
      content = Hero(tag: heroTag!, child: content);
    }

    if (onTap != null) {
      content = Semantics(
        button: true,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            customBorder: RoundedRectangleBorder(borderRadius: borderRadius),
            child: content,
          ),
        ),
      );
    }

    return content;
  }
}
