import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../theme/starry_tokens.dart';
import 'starry_page_top_bar.dart';

/// Starry UI collapsing sliver header.
///
/// A [SliverPersistentHeader] that pairs the [StarryPageTopBar] toolbar chrome
/// (leading / trailing action strips) with an optional expandable region. When
/// an [expandedBackground] widget is supplied the header grows to
/// [expandedHeight] and cross-fades that layer out as the user scrolls; the
/// title glyph slides up into the collapsed toolbar. Without an expanded
/// background it behaves as a plain pinned toolbar at [collapsedHeight].
///
/// Unlike the app's original `SliverPageTopBar`, starry_ui owns no chrome-color
/// tokens, no `SystemUiOverlayStyle` management and no `Hero` coupling: the host
/// injects any expanded backdrop as a plain [Widget], and every color, height,
/// padding and text style resolves from [StarryTokens]. Actions reuse
/// [StarryTopBarActionItem] / [StarryPageTopBar] so their shell, press-scale and
/// focus highlight stay identical to the fixed top bar.
class StarrySliverPageTopBar extends StatelessWidget {
  const StarrySliverPageTopBar({
    super.key,
    this.title,
    this.titleText,
    this.subtitle,
    this.subtitleText,
    this.leftActions = const <StarryTopBarActionItem>[],
    this.rightActions = const <StarryTopBarActionItem>[],
    this.leading,
    this.showDefaultBack = false,
    this.showDivider = false,
    this.expandedHeight = defaultExpandedHeight,
    this.collapsedHeight = defaultCollapsedHeight,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.backgroundColor,
    this.expandedBackground,
    this.expandedForegroundColor,
  }) : assert(title == null || titleText == null),
       assert(subtitle == null || subtitleText == null),
       assert(!snap || floating, 'snap requires floating = true');

  /// Default expanded toolbar content height (excluding the safe-area inset).
  static const double defaultExpandedHeight = 240;

  /// Default collapsed toolbar content height (excluding the safe-area inset).
  static const double defaultCollapsedHeight = 72;

  /// Custom title widget. Mutually exclusive with [titleText].
  final Widget? title;

  /// Convenience plain-text title. Mutually exclusive with [title].
  final String? titleText;

  /// Custom subtitle widget. Mutually exclusive with [subtitleText].
  final Widget? subtitle;

  /// Convenience plain-text subtitle. Mutually exclusive with [subtitle].
  final String? subtitleText;

  /// Leading (start-aligned) actions.
  final List<StarryTopBarActionItem> leftActions;

  /// Trailing (end-aligned) actions.
  final List<StarryTopBarActionItem> rightActions;

  /// Explicit leading widget; when set it replaces [leftActions].
  final Widget? leading;

  /// Whether to inject a default back affordance ahead of [leftActions] when
  /// the enclosing route can be popped. A non-null [leading] overrides it.
  final bool showDefaultBack;

  /// Whether to fade in a hairline bottom divider as the header collapses.
  final bool showDivider;

  /// Expanded toolbar content height. Defaults to [defaultExpandedHeight].
  final double expandedHeight;

  /// Collapsed toolbar content height. Defaults to [defaultCollapsedHeight].
  final double collapsedHeight;

  /// Whether the header stays pinned when fully collapsed.
  final bool pinned;

  /// Whether the header floats back in on reverse scroll.
  final bool floating;

  /// Whether the header snaps open/closed. Requires [floating].
  final bool snap;

  /// Background fill. Defaults to `semantic.surface`.
  final Color? backgroundColor;

  /// Optional expandable backdrop, cross-faded out as the header collapses.
  /// Supplying it enables the expanded region (up to [expandedHeight]).
  final Widget? expandedBackground;

  /// Optional caller-supplied foreground colour for the floating chrome.
  ///
  /// **Why a raw [Color], not a token/tone:** [expandedBackground] is an
  /// arbitrary opaque backdrop the host injects (photo, gradient, artwork).
  /// starry_ui cannot sample its pixels, so it cannot derive a legible glyph
  /// colour from it — the host that chose the backdrop is the only party that
  /// knows which foreground reads against it. This parameter is that single,
  /// minimal seam: the host picks the colour, starry_ui owns only the fade
  /// mechanics and the backing scrim.
  ///
  /// **Readability contract (component-owned):** when an [expandedBackground] is
  /// present, the flat chrome (title / subtitle / flat-action glyphs) floats over
  /// a *constant* media scrim (`semantic.mediaOverlayEnd`) painted behind the
  /// chrome strip, and its foreground is held at a single value across the whole
  /// scroll interval — the value of this parameter when supplied, otherwise the
  /// semantic `semantic.onMedia` token. The foreground is NOT linearly lerped
  /// with the fading backdrop: a lockstep blend collapses through a near-identical
  /// mid-grey midpoint (contrast ~1.5), which is unreadable. Holding both the
  /// scrim strength and the foreground constant keeps the foreground/backing
  /// contrast at a known high value at every scroll point.

  /// **Fully collapsed is NOT a plain surface bar:** the scrim layer at the
  /// chrome strip stays painted for the whole scroll interval (it is gated on
  /// `expandedBackground != null`, not on `progress < 1`). So even when the
  /// backdrop has faded out completely (`progress = 1`), the pinned strip still
  /// sits over the media scrim with the media foreground - it does not revert
  /// to a default surface-coloured bar. A caller that genuinely wants a plain
  /// surface bar must not pass [expandedBackground] at all.
  ///
  /// **Honest limitation:** this parameter accepts an arbitrary raw colour, and
  /// starry_ui only guarantees contrast for the semantic token path
  /// (`onMedia` over the scrim). A caller-supplied raw colour that is itself a
  /// poor fit for the scrim backing is the caller's responsibility; the
  /// component never re-derives it and never claims otherwise.
  ///
  /// **Elevated actions are excluded:** an elevated action owns an opaque
  /// `surface` shell, so its glyph always pairs with that shell via
  /// `semantic.textPrimary` and never adopts this colour (no white-on-white).
  ///
  /// **Coverage:** applies to the plain-text [title]/[subtitle] and the glyphs
  /// of *flat* standard actions. A `title`/`subtitle` widget with its own
  /// `TextStyle`, a `StarryTopBarActionItem.custom` child, or an elevated
  /// action's own shell keep their own colours and are deliberately NOT
  /// overridden.
  final Color? expandedForegroundColor;

  @override
  Widget build(BuildContext context) {
    final safeTopInset = MediaQuery.of(context).padding.top;
    final t = Theme.of(context).extension<StarryTokens>()!;
    final hasExpanded = expandedBackground != null;
    final effectiveCollapsedHeight = safeTopInset + collapsedHeight;
    final effectiveExpandedHeight = hasExpanded
        ? math.max(
            safeTopInset + expandedHeight,
            effectiveCollapsedHeight + t.spacing.s6,
          )
        : effectiveCollapsedHeight;

    return SliverPersistentHeader(
      pinned: pinned,
      floating: floating,
      delegate: _StarrySliverPageTopBarDelegate(
        title: title,
        titleText: titleText,
        subtitle: subtitle,
        subtitleText: subtitleText,
        leftActions: leftActions,
        rightActions: rightActions,
        leading: leading,
        showDefaultBack: showDefaultBack,
        showDivider: showDivider,
        minHeight: effectiveCollapsedHeight,
        maxHeight: effectiveExpandedHeight,
        safeTopInset: safeTopInset,
        collapsedHeight: collapsedHeight,
        snap: snap,
        snapDuration: t.motion.durationShort,
        backgroundColor: backgroundColor,
        expandedBackground: hasExpanded ? expandedBackground : null,
        expandedForegroundColor: expandedForegroundColor,
      ),
    );
  }
}

class _StarrySliverPageTopBarDelegate extends SliverPersistentHeaderDelegate {
  /// Pixel travel the collapsed title rises over as the header folds.
  /// A single-point visual micro-adjustment, not a cross-component reuse
  /// quantity, so it stays a named local constant rather than a token.
  static const double _kTitleRiseTravel = 10;

  _StarrySliverPageTopBarDelegate({
    required this.title,
    required this.titleText,
    required this.subtitle,
    required this.subtitleText,
    required this.leftActions,
    required this.rightActions,
    required this.leading,
    required this.showDefaultBack,
    required this.showDivider,
    required this.minHeight,
    required this.maxHeight,
    required this.safeTopInset,
    required this.collapsedHeight,
    required this.snap,
    required this.snapDuration,
    required this.backgroundColor,
    required this.expandedBackground,
    this.expandedForegroundColor,
  });

  final Widget? title;
  final String? titleText;
  final Widget? subtitle;
  final String? subtitleText;
  final List<StarryTopBarActionItem> leftActions;
  final List<StarryTopBarActionItem> rightActions;
  final Widget? leading;
  final bool showDefaultBack;
  final bool showDivider;
  final double minHeight;
  final double maxHeight;
  final double safeTopInset;
  final double collapsedHeight;
  final bool snap;
  final Duration snapDuration;
  final Color? backgroundColor;
  final Widget? expandedBackground;
  final Color? expandedForegroundColor;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  FloatingHeaderSnapConfiguration? get snapConfiguration => snap
      ? FloatingHeaderSnapConfiguration(
          curve: Curves.easeOut,
          duration: snapDuration,
        )
      : null;

  @override
  PersistentHeaderShowOnScreenConfiguration? get showOnScreenConfiguration =>
      snap
      ? PersistentHeaderShowOnScreenConfiguration(
          minShowOnScreenExtent: minExtent,
          maxShowOnScreenExtent: maxExtent,
        )
      : null;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;
    final hasExpanded = expandedBackground != null;
    final toolbarHeight = safeTopInset + collapsedHeight;
    final progressDenominator = math.max(1.0, maxExtent - minExtent);
    final progress = (shrinkOffset / progressDenominator).clamp(0.0, 1.0);
    final visualProgress = hasExpanded ? progress : 1.0;
    final effectiveBackground = backgroundColor ?? s.surface;

    final tokenTitleColor = topBarTitleStyle(context).color!;
    final tokenSubtitleColor = _sliverSubtitleStyle(context).color!;
    final hasExpandedFg = expandedForegroundColor != null;

    // The flat chrome floats over the *constant* media scrim painted behind the
    // chrome strip (see the `Positioned` scrim below), so its foreground is held
    // at a single value across the whole scroll interval: the caller-supplied
    // raw colour when provided, otherwise the semantic `onMedia` token (the
    // system's "foreground over media" colour). It is NOT lerped with the fading
    // backdrop — a lockstep linear blend of foreground and backdrop collapses
    // through a near-identical mid-grey midpoint (contrast ~1.5), which is
    // unreadable. Holding the scrim strength AND the foreground constant keeps
    // the foreground/backing contrast at a known high value at every progress.
    final Color? flatFg = hasExpanded
        ? (hasExpandedFg ? expandedForegroundColor : s.onMedia)
        : null;

    final resolvedTitleColor = flatFg ?? tokenTitleColor;
    final resolvedSubtitleColor = flatFg ?? tokenSubtitleColor;
    // Flat (non-elevated) actions may adopt the flat foreground; elevated
    // actions always pair with their own opaque surface shell (see
    // [StarryPageTopBar] / [StarrySliverPageTopBar.expandedForegroundColor]).
    final Color? resolvedActionColor = flatFg;

    final titleStyle = topBarTitleStyle(
      context,
    ).copyWith(color: resolvedTitleColor);
    final subtitleStyle = _sliverSubtitleStyle(
      context,
    ).copyWith(color: resolvedSubtitleColor);

    final titleWidget =
        title ??
        (titleText != null
            ? Text(titleText!, overflow: TextOverflow.ellipsis)
            : null);
    final subtitleWidget =
        subtitle ??
        (subtitleText != null
            ? Text(subtitleText!, overflow: TextOverflow.ellipsis)
            : null);

    return Material(
      color: effectiveBackground,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (hasExpanded)
            Positioned.fill(
              child: Opacity(opacity: 1 - progress, child: expandedBackground),
            ),
          // A CONSTANT media scrim behind the chrome strip. The flat foreground
          // (`onMedia` / caller colour) floats over this stable dark backing,
          // not over the fading photo: the scrim holds a fixed strength across
          // the whole scroll interval, so the foreground/backing contrast stays
          // at a known high value at every progress point instead of collapsing
          // through the mid-scroll midpoint. It is painted below the chrome
          // strip, whose elevated opaque `surface` shells cover it locally.
          if (hasExpanded)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: toolbarHeight,
              child: ColoredBox(color: s.mediaOverlayEnd),
            ),
          // Collapsed toolbar chrome — actions only; the title lives in the
          // expandable slot below so it can translate on collapse.
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: toolbarHeight,
            child: StarryPageTopBar(
              leftActions: leftActions,
              rightActions: rightActions,
              leading: leading,
              showDefaultBack: showDefaultBack,
              height: collapsedHeight,
              bottomPadding: 0.0,
              backgroundColor: Colors.transparent,
              foregroundColor: resolvedActionColor,
            ),
          ),
          Positioned(
            left: t.spacing.s6,
            right: t.spacing.s6,
            top: safeTopInset,
            height: collapsedHeight,
            child: IgnorePointer(
              child: Align(
                child: Transform.translate(
                  offset: Offset(0, (1 - visualProgress) * _kTitleRiseTravel),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      DefaultTextStyle(
                        style: titleStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        child: titleWidget ?? const SizedBox.shrink(),
                      ),
                      if (subtitleWidget != null) ...<Widget>[
                        SizedBox(height: t.spacing.s1),
                        DefaultTextStyle(
                          style: subtitleStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          child: subtitleWidget,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (showDivider)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Opacity(
                opacity: progress,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: s.border)),
                  ),
                  child: SizedBox(height: t.controlMetrics.borderThin),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _StarrySliverPageTopBarDelegate oldDelegate) {
    return title != oldDelegate.title ||
        titleText != oldDelegate.titleText ||
        subtitle != oldDelegate.subtitle ||
        subtitleText != oldDelegate.subtitleText ||
        leftActions != oldDelegate.leftActions ||
        rightActions != oldDelegate.rightActions ||
        leading != oldDelegate.leading ||
        showDefaultBack != oldDelegate.showDefaultBack ||
        showDivider != oldDelegate.showDivider ||
        minHeight != oldDelegate.minHeight ||
        maxHeight != oldDelegate.maxHeight ||
        safeTopInset != oldDelegate.safeTopInset ||
        collapsedHeight != oldDelegate.collapsedHeight ||
        snap != oldDelegate.snap ||
        snapDuration != oldDelegate.snapDuration ||
        backgroundColor != oldDelegate.backgroundColor ||
        expandedBackground != oldDelegate.expandedBackground ||
        expandedForegroundColor != oldDelegate.expandedForegroundColor;
  }
}

TextStyle _sliverSubtitleStyle(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return t.typography.labelMedium.textStyle.copyWith(
    color: t.semantic.textTertiary,
    fontWeight: FontWeight.w500,
    letterSpacing: t.letterSpacing.wider,
  );
}
