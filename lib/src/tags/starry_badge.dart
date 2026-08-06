import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// Overlay position of a [StarryBadge] relative to its child.
enum StarryBadgePosition { topEnd, topStart, bottomEnd, bottomStart }

/// Count / dot badge overlaid on top of a child widget (icon, avatar, ...).
///
/// Colors default to the [StarryTokens] error role; supply
/// [backgroundColor] / [textColor] to override.
class StarryBadge extends StatelessWidget {
  const StarryBadge({
    required this.child,
    super.key,
    this.count,
    this.maxCount = 99,
    this.showDot = false,
    this.show = true,
    this.backgroundColor,
    this.textColor,
    this.position = StarryBadgePosition.topEnd,
    this.offset,
    this.dotSize,
    this.animate = true,
  });

  /// Minimum extent of the count pill. Sits between `spacing.s4` (16) and
  /// `spacing.s5` (20); no spacing token matches, so it is a named local
  /// constant for this single geometry.
  static const double _kCountBadgeMinSize = 18;

  /// Line height for the compact count/label glyph. The 1.0 (tight) line
  /// height pairs with tabular figures so the pill hugs the digit height.
  /// A single-point typographic intent, not a reusable line-height token.
  static const double _kCompactDigitLineHeight = 1;

  /// Widget the badge is anchored to.
  final Widget child;

  /// Numeric value to render. Ignored when [showDot] is true.
  final int? count;

  /// Cap after which the badge renders `maxCount+`.
  final int maxCount;

  /// Render a small dot instead of a number.
  final bool showDot;

  /// Master visibility switch.
  final bool show;

  /// Badge fill; defaults to the error role.
  final Color? backgroundColor;

  /// Badge text color; defaults to white for contrast on error red.
  final Color? textColor;

  /// Corner the badge is pinned to.
  final StarryBadgePosition position;

  /// Extra positional offset.
  final Offset? offset;

  /// Dot diameter when [showDot] is true. Defaults to
  /// [StarryIndicator.dotSm] when null.
  final double? dotSize;

  /// Animate the badge in with a scale.
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final effectiveBgColor = backgroundColor ?? t.semantic.error;
    final effectiveTextColor = textColor ?? t.semantic.onError;

    final shouldShow = show && (showDot || (count != null && count! > 0));

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        child,
        if (shouldShow)
          Positioned(
            top: _getTop(t),
            bottom: _getBottom(t),
            left: _getLeft(t),
            right: _getRight(t),
            child: _buildBadge(
              context,
              effectiveBgColor: effectiveBgColor,
              effectiveTextColor: effectiveTextColor,
            ),
          ),
      ],
    );
  }

  double? _getTop(StarryTokens t) {
    // Overhang the anchored corner by one grid step (4dp).
    final pin = -t.spacing.s1;
    final baseOffset = offset?.dy ?? 0;
    switch (position) {
      case StarryBadgePosition.topEnd:
      case StarryBadgePosition.topStart:
        return pin + baseOffset;
      case StarryBadgePosition.bottomEnd:
      case StarryBadgePosition.bottomStart:
        return null;
    }
  }

  double? _getBottom(StarryTokens t) {
    final pin = -t.spacing.s1;
    final baseOffset = offset?.dy ?? 0;
    switch (position) {
      case StarryBadgePosition.topEnd:
      case StarryBadgePosition.topStart:
        return null;
      case StarryBadgePosition.bottomEnd:
      case StarryBadgePosition.bottomStart:
        return pin + baseOffset;
    }
  }

  double? _getLeft(StarryTokens t) {
    final pin = -t.spacing.s1;
    final baseOffset = offset?.dx ?? 0;
    switch (position) {
      case StarryBadgePosition.topStart:
      case StarryBadgePosition.bottomStart:
        return pin + baseOffset;
      case StarryBadgePosition.topEnd:
      case StarryBadgePosition.bottomEnd:
        return null;
    }
  }

  double? _getRight(StarryTokens t) {
    final pin = -t.spacing.s1;
    final baseOffset = offset?.dx ?? 0;
    switch (position) {
      case StarryBadgePosition.topEnd:
      case StarryBadgePosition.bottomEnd:
        return pin + baseOffset;
      case StarryBadgePosition.topStart:
      case StarryBadgePosition.bottomStart:
        return null;
    }
  }

  Widget _buildBadge(
    BuildContext context, {
    required Color effectiveBgColor,
    required Color effectiveTextColor,
  }) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    Widget badge;

    if (showDot) {
      final effectiveDotSize = dotSize ?? t.indicator.dotSm;
      badge = Container(
        width: effectiveDotSize,
        height: effectiveDotSize,
        decoration: BoxDecoration(
          color: effectiveBgColor,
          shape: BoxShape.circle,
        ),
      );
    } else {
      final displayCount = count! > maxCount ? '$maxCount+' : '$count';

      badge = Container(
        constraints: const BoxConstraints(
          minWidth: _kCountBadgeMinSize,
          minHeight: _kCountBadgeMinSize,
        ),
        padding: EdgeInsets.symmetric(horizontal: t.spacing.s1),
        decoration: BoxDecoration(
          color: effectiveBgColor,
          borderRadius: BorderRadius.circular(t.radius.full),
        ),
        alignment: Alignment.center,
        child: Text(
          displayCount,
          style: t.typography.labelSmall.textStyle.copyWith(
            color: effectiveTextColor,
            fontWeight: FontWeight.w600,
            height: _kCompactDigitLineHeight,
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          ),
        ),
      );
    }

    // Screen-reader label so the badge is not conveyed by color/number alone.
    final semanticsLabel = showDot
        ? 'New notification'
        : (count! > maxCount ? 'More than $maxCount' : '$count');
    badge = Semantics(container: true, label: semanticsLabel, child: badge);

    if (animate) {
      // Real entry animation: scale from 0 -> 1 when the badge appears.
      badge = TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: t.motion.durationShort,
        curve: t.motion.easingStandard,
        child: badge,
        builder: (context, value, child) =>
            Transform.scale(scale: value, child: child),
      );
    }

    return badge;
  }
}
