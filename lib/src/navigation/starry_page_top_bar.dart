import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../components/starry_control_shell.dart';
import '../theme/starry_tokens.dart';

/// Visual weight of a [StarryTopBarActionItem].
///
/// * [elevated] — renders inside a [StarryRoundIconShell] so the action reads as
///   a raised circular chrome button (the default top-bar affordance).
/// * [flat] — a borderless circular hit area whose fill only appears on
///   hover / press, for lower-emphasis inline actions.
enum StarryTopBarActionStyle { elevated, flat }

/// Optional hover micro-motion applied to an action icon.
///
/// * [none] — the icon stays put.
/// * [backHoverShift] — nudges the glyph slightly left on hover (back arrows).
/// * [plusHoverRotate] — rotates the glyph a quarter turn on hover (add / plus).
enum StarryTopBarIconMotion { none, backHoverShift, plusHoverRotate }

/// Horizontal hover nudge (logical px) for [StarryTopBarIconMotion.backHoverShift].
const double _kBackHoverShiftX = -1.5;

/// Rotation (turns) applied on hover for [StarryTopBarIconMotion.plusHoverRotate].
const double _kPlusHoverTurns = 0.25;

/// A single action rendered in a [StarryPageTopBar]'s leading or trailing slot.
///
/// Icons are supplied as **injected widgets** ([icon]) — starry_ui does not own
/// an icon-font pipeline, so the host passes any [Icon] / [ImageIcon] / custom
/// glyph it likes. The icon inherits the top-bar's token-driven color and size
/// unless the injected widget sets them explicitly. Use [StarryTopBarActionItem.custom]
/// to drop a fully bespoke widget (e.g. an avatar) into the strip without the
/// standard button chrome.
class StarryTopBarActionItem {
  const StarryTopBarActionItem({
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.style = StarryTopBarActionStyle.elevated,
    this.semanticLabel,
    this.motion = StarryTopBarIconMotion.none,
  }) : child = null;

  /// A fully custom action widget rendered as-is (optionally wrapped with a
  /// [Tooltip] / [Semantics] button label). No button chrome is applied.
  const StarryTopBarActionItem.custom({
    required Widget this.child,
    this.tooltip = '',
    this.semanticLabel,
  }) : icon = const SizedBox.shrink(),
       onPressed = null,
       style = StarryTopBarActionStyle.elevated,
       motion = StarryTopBarIconMotion.none;

  /// Injected icon widget for standard (non-custom) actions.
  final Widget icon;

  /// Tooltip / accessible hint. Empty string suppresses the tooltip.
  final String tooltip;

  /// Tap handler. When null the action renders disabled (dimmed, non-tappable).
  final VoidCallback? onPressed;

  /// Visual weight of the action button.
  final StarryTopBarActionStyle style;

  /// Optional accessibility label; falls back to [tooltip] when null.
  final String? semanticLabel;

  /// Optional hover micro-motion for the icon glyph.
  final StarryTopBarIconMotion motion;

  /// Custom child for [StarryTopBarActionItem.custom]; null for standard items.
  final Widget? child;

  /// Whether this item was built via [StarryTopBarActionItem.custom].
  bool get isCustom => child != null;
}

/// Starry UI page top bar.
///
/// A fixed-height chrome header with a centered [title] (or [titleText]) and
/// optional leading / trailing action strips. It is a [PreferredSizeWidget], so
/// it can be used directly as a `Scaffold.appBar`. Icons are injected as widgets
/// via [StarryTopBarActionItem] — there is no icon-font dependency.
///
/// Every color, height, padding, radius and text style resolves from
/// [StarryTokens]. Elevated actions reuse [StarryRoundIconShell] so their
/// circular shell, press-scale and focus highlight stay identical to the rest of
/// the control family.
class StarryPageTopBar extends StatelessWidget implements PreferredSizeWidget {
  const StarryPageTopBar({
    super.key,
    this.title,
    this.titleText,
    this.leftActions = const <StarryTopBarActionItem>[],
    this.rightActions = const <StarryTopBarActionItem>[],
    this.showDefaultBack = false,
    this.showDivider = false,
    this.height = defaultHeight,
    this.bottomPadding,
    this.backgroundColor,
    this.foregroundColor,
    this.centerTitle = true,
    this.leading,
    this.systemOverlayStyle,
  }) : assert(title == null || titleText == null);

  /// Toolbar content height (excluding the bottom breathing room).
  static const double defaultHeight = 48;

  /// Bottom breathing room below the toolbar.
  ///
  /// Mirrors `spacing.s6` (= 24). Kept as a compile-time constant because it is
  /// the pre-layout estimate consumed by [preferredSize], which has no
  /// [BuildContext] and therefore cannot resolve the live token. The painted
  /// value in [build] resolves from `spacing.s6` so the toolbar tracks the
  /// active theme.
  static const double defaultBottomPadding = 24;

  /// Diameter of the standard circular action button.
  static const double actionButtonSize = 40;

  /// Custom title widget. Mutually exclusive with [titleText].
  final Widget? title;

  /// Convenience plain-text title. Mutually exclusive with [title].
  final String? titleText;

  /// Leading (start-aligned) actions.
  final List<StarryTopBarActionItem> leftActions;

  /// Trailing (end-aligned) actions.
  final List<StarryTopBarActionItem> rightActions;

  /// Whether to inject a default back affordance at the start of the leading
  /// strip.
  ///
  /// When `true` and the current route can be popped
  /// ([Navigator.canPop] == true), a back arrow is prepended before
  /// [leftActions]. An explicit [leading] still overrides everything (matching
  /// the leading-precedence contract), so the default back button only appears
  /// when [leading] is null. Icons stay font-free: the arrow is a plain
  /// [Icons.arrow_back_ios_new] widget with the shared [backHoverShift] motion.
  final bool showDefaultBack;

  /// Whether to paint a hairline divider along the bottom edge.
  final bool showDivider;

  /// Toolbar content height. Defaults to [defaultHeight].
  final double height;

  /// Bottom breathing room. When null, resolves to `spacing.s6` at build time
  /// (mirrored by [defaultBottomPadding] for the context-less [preferredSize]).
  final double? bottomPadding;

  /// Background fill. Defaults to `semantic.surface`.
  final Color? backgroundColor;

  /// Optional override for the title and action-icon foreground colour.
  ///
  /// The title always adopts this when non-null. The leading/trailing action
  /// glyphs adopt it **only in `flat` style**: an `elevated` action owns an
  /// opaque `surface` shell and keeps the token `textPrimary` glyph regardless
  /// of this value (contrast protection - a white overlay glyph on a white
  /// elevated shell is 1:1). Defaults to null so existing callers are
  /// unchanged; the collapsing sliver bar passes it (with `flat` actions) to
  /// keep its icons legible over an expanded backdrop.
  final Color? foregroundColor;

  /// Whether to center the title within the toolbar.
  final bool centerTitle;

  /// Explicit leading widget; when set it replaces [leftActions].
  final Widget? leading;

  /// Explicit status-bar / navigation-bar overlay style.
  ///
  /// When non-null the top bar is wrapped in an
  /// [AnnotatedRegion]<[SystemUiOverlayStyle]> so the surrounding system
  /// chrome adopts this style. When null no annotation is emitted — starry_ui
  /// intentionally does **not** derive an overlay style from the background
  /// color, keeping the component free of any host color-heuristic dependency.
  final SystemUiOverlayStyle? systemOverlayStyle;

  @override
  Size get preferredSize =>
      Size.fromHeight(height + (bottomPadding ?? defaultBottomPadding));

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;
    final media = MediaQuery.of(context);
    final safeTop = media.padding.top;
    final effectiveBackground = backgroundColor ?? s.surface;
    final effectiveBottomPadding = bottomPadding ?? t.spacing.s6;
    final totalHeight = safeTop + height + effectiveBottomPadding;

    final effectiveTitle =
        title ??
        (titleText != null
            ? Text(titleText!, overflow: TextOverflow.ellipsis)
            : null);

    final List<Widget> leftWidgets;
    if (leading != null) {
      leftWidgets = <Widget>[leading!];
    } else {
      leftWidgets = <Widget>[
        if (showDefaultBack && Navigator.of(context).canPop())
          _buildDefaultBackAction(context),
        ...leftActions.map(_buildAction),
      ];
    }
    final rightWidgets = rightActions.map(_buildAction).toList(growable: false);

    final leadingWidget = leftWidgets.isEmpty
        ? null
        : _TopBarActionStrip(
            items: leftWidgets,
            alignment: MainAxisAlignment.start,
          );
    final trailingWidget = rightWidgets.isEmpty
        ? null
        : _TopBarActionStrip(
            items: rightWidgets,
            alignment: MainAxisAlignment.end,
          );

    final Widget bar = Material(
      color: effectiveBackground,
      child: SizedBox(
        height: totalHeight,
        child: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                top: safeTop,
                left: t.spacing.s6,
                right: t.spacing.s6,
              ),
              child: SizedBox(
                height: height + effectiveBottomPadding,
                child: NavigationToolbar(
                  leading: leadingWidget,
                  middle: _TopBarTitleSlot(title: effectiveTitle),
                  trailing: trailingWidget,
                  centerMiddle: centerTitle,
                ),
              ),
            ),
            if (showDivider)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: s.border)),
                  ),
                  child: SizedBox(height: t.controlMetrics.borderThin),
                ),
              ),
          ],
        ),
      ),
    );

    if (systemOverlayStyle != null) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: systemOverlayStyle!,
        child: bar,
      );
    }
    return bar;
  }

  Widget _buildAction(StarryTopBarActionItem item) {
    if (item.isCustom) {
      Widget child = item.child!;
      if (item.tooltip.isNotEmpty) {
        child = Tooltip(message: item.tooltip, child: child);
      }
      if (item.semanticLabel != null) {
        child = Semantics(
          button: true,
          label: item.semanticLabel,
          child: child,
        );
      }
      return child;
    }
    return _TopBarActionButton(item: item, foregroundColor: foregroundColor);
  }

  /// Builds the default back affordance injected when [showDefaultBack] is set
  /// and the route can be popped. Uses a font-free [Icons.arrow_back_ios_new]
  /// glyph, the localized back tooltip and the shared [backHoverShift] motion,
  /// so it stays visually identical to a host-supplied back action.
  Widget _buildDefaultBackAction(BuildContext context) {
    return _buildAction(
      StarryTopBarActionItem(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: () => Navigator.of(context).maybePop(),
        motion: StarryTopBarIconMotion.backHoverShift,
      ),
    );
  }
}

/// Token-driven title text style for the top bar.
///
/// Library-visible (not exported) so [StarrySliverPageTopBar]'s collapsed
/// title reuses the exact same style, keeping every navigation top bar
/// visually consistent.
TextStyle topBarTitleStyle(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return t.typography.labelLarge.textStyle.copyWith(
    color: t.semantic.textSecondary,
    fontWeight: FontWeight.bold,
    letterSpacing: t.letterSpacing.widest,
  );
}

class _TopBarTitleSlot extends StatelessWidget {
  const _TopBarTitleSlot({required this.title});

  final Widget? title;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: topBarTitleStyle(context),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      child: title ?? const SizedBox.shrink(),
    );
  }
}

class _TopBarActionStrip extends StatelessWidget {
  const _TopBarActionStrip({required this.items, required this.alignment});

  final List<Widget> items;
  final MainAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: alignment == MainAxisAlignment.end,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: alignment,
        children: <Widget>[
          for (var index = 0; index < items.length; index++) ...<Widget>[
            if (index > 0) SizedBox(width: t.spacing.s2),
            items[index],
          ],
        ],
      ),
    );
  }
}

class _TopBarActionButton extends StatefulWidget {
  const _TopBarActionButton({required this.item, this.foregroundColor});

  final StarryTopBarActionItem item;
  final Color? foregroundColor;

  @override
  State<_TopBarActionButton> createState() => _TopBarActionButtonState();
}

class _TopBarActionButtonState extends State<_TopBarActionButton> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;
    final item = widget.item;
    final isEnabled = item.onPressed != null;
    final isElevated = item.style == StarryTopBarActionStyle.elevated;
    final opacity = isEnabled ? 1.0 : t.opacity.disabledContent;

    // Pair the glyph with whatever backing actually sits behind it:
    //  * An [elevated] action owns an opaque `surface` shell, so its glyph must
    //    be the token `textPrimary` that pairs with that shell. It must NOT
    //    blindly adopt an overlay foreground — doing so renders e.g. a white
    //    glyph on a white surface shell (1:1) whenever the overlay is chosen for
    //    the floating chrome.
    //  * A [flat] action has no shell of its own: it floats directly over the
    //    bar's backing, so it may adopt the overlay foreground (when supplied).
    final Color iconColor = isElevated
        ? s.textPrimary
        : (widget.foregroundColor ?? s.textPrimary);
    final Widget icon = IconTheme(
      data: IconThemeData(color: iconColor, size: t.controlMetrics.iconLg),
      child: _AnimatedActionIcon(
        motion: item.motion,
        hovered: _hovered,
        child: item.icon,
      ),
    );

    Widget button;
    if (isElevated) {
      button = StarryRoundIconShell(
        size: StarryPageTopBar.actionButtonSize,
        isActive: _focused || _pressed,
        onTap: item.onPressed,
        semanticsLabel: item.semanticLabel ?? item.tooltip,
        child: Opacity(opacity: opacity, child: icon),
      );
    } else {
      final Color flatFill = _pressed || _hovered
          ? s.surfaceVariant
          : Colors.transparent;
      final List<BoxShadow> focusShadow = (_focused || _pressed)
          ? <BoxShadow>[
              BoxShadow(
                color: s.brand,
                spreadRadius: t.controlMetrics.focusBorderWidth,
              ),
            ]
          : const <BoxShadow>[];
      button = AnimatedContainer(
        duration: t.motion.durationShort,
        curve: t.motion.easingStandard,
        width: StarryPageTopBar.actionButtonSize,
        height: StarryPageTopBar.actionButtonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: flatFill,
          boxShadow: focusShadow.isEmpty ? null : focusShadow,
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: item.onPressed,
            onHighlightChanged: (value) => setState(() => _pressed = value),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            child: Center(
              child: Opacity(opacity: opacity, child: icon),
            ),
          ),
        ),
      );
    }

    button = AnimatedScale(
      duration: t.motion.durationShort,
      curve: t.motion.easingStandard,
      scale: _pressed && isEnabled ? t.motion.pressedScale : 1.0,
      child: button,
    );

    if (item.tooltip.isNotEmpty) {
      button = Tooltip(message: item.tooltip, child: button);
    }

    // The elevated variant already exposes button semantics via
    // StarryRoundIconShell; only wrap the flat variant to avoid double nodes.
    final Widget detector = FocusableActionDetector(
      enabled: isEnabled,
      mouseCursor: isEnabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onShowFocusHighlight: (value) => setState(() => _focused = value),
      onShowHoverHighlight: (value) => setState(() => _hovered = value),
      child: button,
    );

    if (isElevated) {
      return detector;
    }
    return Semantics(
      button: true,
      label: item.semanticLabel ?? item.tooltip,
      enabled: isEnabled,
      child: detector,
    );
  }
}

class _AnimatedActionIcon extends StatelessWidget {
  const _AnimatedActionIcon({
    required this.motion,
    required this.hovered,
    required this.child,
  });

  final StarryTopBarIconMotion motion;
  final bool hovered;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final double dx = switch (motion) {
      StarryTopBarIconMotion.backHoverShift => hovered ? _kBackHoverShiftX : 0,
      _ => 0,
    };
    final double turns = switch (motion) {
      StarryTopBarIconMotion.plusHoverRotate =>
        hovered ? _kPlusHoverTurns : 0.0,
      _ => 0.0,
    };

    return AnimatedSlide(
      duration: t.motion.durationShort,
      curve: t.motion.easingStandard,
      offset: Offset(dx / StarryPageTopBar.actionButtonSize, 0),
      child: AnimatedRotation(
        duration: t.motion.durationShort,
        curve: t.motion.easingStandard,
        turns: turns,
        child: child,
      ),
    );
  }
}
