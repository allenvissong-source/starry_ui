import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';
import 'disclosure_trigger.dart';
import 'starry_surface.dart';

/// Half-turn rotation applied to the disclosure chevron between the
/// collapsed and expanded states (0 → 0.5 turns = 180°).
const double _kChevronFlipTurns = 0.5;

/// Starry UI expandable / collapsible disclosure.
///
/// Rendered as a *split* control (分体式), not one merged card:
///   * the header is a fixed-height (`controlMetrics.controlHeight` = 48) pill
///     row whose corner radius uses the same textfield invariant
///     `max(radius.xxl, controlHeight / 2)` (= 28), so it reads exactly as tall
///     and as round as a single-line [StarryTextField];
///   * when expanded the children detach into their own rounded-rectangle
///     surface (`radius.xxl` = 28) below the header, separated by `spacing.s3`.
///
/// Colors, radius, spacing and motion all resolve from [StarryTokens]. Both
/// surfaces delegate to the shared [StarrySurface] primitive so the fill,
/// border and elevation stay in lockstep with [StarryCard].
///
/// Example:
/// ```dart
/// StarryExpandableCard(
///   header: Text('高级选项'),
///   initiallyExpanded: false,
///   children: [Text('A'), Text('B')],
/// )
/// ```
class StarryExpandableCard extends StatefulWidget {
  const StarryExpandableCard({
    required this.header,
    required this.children,
    super.key,
    this.initiallyExpanded = false,
    this.expanded,
    this.onExpansionChanged,
    this.headerActions,
    this.focusNode,
    this.trailing,
    this.headerPadding,
    this.childrenPadding,
    this.backgroundColor,
    this.borderRadius,
    this.animationDuration,
    this.maintainState = false,
    this.elevated = true,
  });

  /// Header content.
  final Widget header;

  /// Widgets revealed when expanded.
  final List<Widget> children;

  /// Whether the card starts expanded.
  final bool initiallyExpanded;

  /// Controlled expansion. When supplied, taps request a change through
  /// [onExpansionChanged]; only the owner's next value changes the panel.
  final bool? expanded;

  /// Independent actions beside the disclosure. Tapping them does not toggle
  /// the panel and they never rotate with [trailing].
  final Widget? headerActions;

  /// Caller-owned focus node for the disclosure button.
  final FocusNode? focusNode;

  /// Called when the expansion state toggles.
  final ValueChanged<bool>? onExpansionChanged;

  /// Custom trailing icon (rotated with the expansion animation).
  final Widget? trailing;

  /// Header horizontal padding. Defaults to `spacing.s5` left/right (the header
  /// height is pinned to `controlMetrics.controlHeight`, so vertical padding is
  /// not used).
  final EdgeInsetsGeometry? headerPadding;

  /// Children area padding. Defaults to `spacing.s5` left/right/bottom.
  final EdgeInsetsGeometry? childrenPadding;

  /// Background color for both the header pill and the detached content panel.
  /// Defaults to `semantic.surface`.
  final Color? backgroundColor;

  /// Corner radius of the detached content panel. Defaults to `radius.xxl`
  /// (= 28) so it matches the header pill. The
  /// header pill's radius is fixed to the textfield invariant
  /// (`max(radius.xxl, controlHeight / 2)`) and is not affected by this.
  final BorderRadius? borderRadius;

  /// Expansion animation duration. Defaults to `motion.durationMedium`.
  final Duration? animationDuration;

  /// Whether to keep children state while collapsed.
  final bool maintainState;

  /// Whether to paint the surface drop shadow (`elevation.level2`).
  final bool elevated;

  @override
  State<StarryExpandableCard> createState() => _StarryExpandableCardState();
}

class _StarryExpandableCardState extends State<StarryExpandableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightFactor;
  late Animation<double> _iconTurns;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.expanded ?? widget.initiallyExpanded;

    _controller = AnimationController(
      vsync: this,
      // Default duration is bound from tokens in didChangeDependencies; an
      // explicit animationDuration (when provided) wins there too.
      duration: widget.animationDuration,
    );

    _heightFactor = _controller;
    _iconTurns = _controller.drive(
      Tween<double>(begin: 0.0, end: _kChevronFlipTurns),
    );

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final t = Theme.of(context).extension<StarryTokens>()!;
    // Bind the token-driven default duration once the theme is available,
    // unless the caller pinned an explicit duration.
    _bindMotion(t);
  }

  void _bindMotion(StarryTokens t) {
    _controller.duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : widget.animationDuration ?? t.motion.durationMedium;
    _heightFactor = _controller.drive(
      CurveTween(curve: t.motion.easingStandard),
    );
    _iconTurns = _heightFactor.drive(
      Tween<double>(begin: 0, end: _kChevronFlipTurns),
    );
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = _isExpanded ? 1 : 0;
    }
  }

  @override
  void didUpdateWidget(StarryExpandableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _bindMotion(Theme.of(context).extension<StarryTokens>()!);
    if (widget.expanded != null && widget.expanded != _isExpanded) {
      _isExpanded = widget.expanded!;
      _animate();
    }
  }

  void _animate() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = _isExpanded ? 1 : 0;
    } else if (_isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    final next = !_isExpanded;
    if (widget.expanded == null) {
      setState(() => _isExpanded = next);
      _animate();
    }
    widget.onExpansionChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;

    // Header pill: same height + corner invariant as a single-line textfield.
    // The corner takes max(radius.xxl, controlHeight / 2) so it stays a full
    // pill even if controlHeight ever changes (Skia clamps corner to
    // min(radius, height / 2)).
    final double headerRadius = math.max(
      t.radius.xxl,
      t.controlMetrics.controlHeight / 2,
    );
    final header = StarryDisclosureTrigger(
      color: widget.backgroundColor,
      radius: BorderRadius.circular(headerRadius),
      elevated: widget.elevated,
      onTap: _toggle,
      expanded: _isExpanded,
      focusNode: widget.focusNode,
      child: SizedBox(
        height: t.controlMetrics.controlHeight,
        child: Padding(
          padding:
              widget.headerPadding ??
              EdgeInsets.symmetric(horizontal: t.spacing.s5),
          child: Row(
            children: <Widget>[
              Expanded(child: widget.header),
              SizedBox(width: t.spacing.s3),
              _buildTrailingIcon(s),
            ],
          ),
        ),
      ),
    );

    // Detached content panel: its own rounded-rectangle surface below the
    // header, revealed by the height-factor animation and cross-faded in.
    final content = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final hidden = _controller.value == 0;
        if (hidden && !widget.maintainState) {
          return const SizedBox.shrink();
        }
        final revealed = Align(
          alignment: Alignment.topCenter,
          heightFactor: _heightFactor.value,
          child: Opacity(
            opacity: _heightFactor.value,
            child: IgnorePointer(
              ignoring: !_isExpanded,
              child: ExcludeFocus(
                excluding: !_isExpanded,
                child: ExcludeSemantics(
                  excluding: !_isExpanded,
                  child: TickerMode(
                    enabled: !hidden,
                    child: Offstage(offstage: hidden, child: child),
                  ),
                ),
              ),
            ),
          ),
        );
        return ClipRect(
          clipBehavior: _heightFactor.value < 1 ? Clip.hardEdge : Clip.none,
          child: revealed,
        );
      },
      child: Padding(
        padding: EdgeInsets.only(top: t.spacing.s3),
        child: StarrySurface(
          color: widget.backgroundColor,
          borderRadius:
              widget.borderRadius ?? BorderRadius.circular(t.radius.xxl),
          elevated: widget.elevated,
          padding: widget.childrenPadding ?? EdgeInsets.all(t.spacing.s5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: widget.children,
          ),
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (widget.headerActions == null)
          header
        else
          Row(
            children: [
              Expanded(child: header),
              SizedBox(width: t.spacing.s2),
              widget.headerActions!,
            ],
          ),
        content,
      ],
    );
  }

  Widget _buildTrailingIcon(StarrySemanticColors s) {
    if (widget.trailing != null) {
      return RotationTransition(turns: _iconTurns, child: widget.trailing);
    }

    return RotationTransition(
      turns: _iconTurns,
      child: Icon(
        Icons.expand_more,
        color: s.textTertiary,
        size: Theme.of(
          context,
        ).extension<StarryTokens>()!.controlMetrics.iconMd,
      ),
    );
  }
}
