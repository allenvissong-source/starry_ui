import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// A single swipe-revealed action.
///
/// Shared by [StarrySwipeable] and every widget built on top of it
/// (e.g. `StarryMessageList` rows and `StarrySlidableDrawer`).
class StarrySwipeAction {
  const StarrySwipeAction({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color foregroundColor;
}

/// Swipe-to-reveal container: drags [child] horizontally to expose a trailing
/// row of [actions].
///
/// The primitive hugs its [child]'s height (the child controls its own extent),
/// clips itself to [borderRadius], and paints the action row behind the content
/// so it is revealed as the content slides left. Releasing past the halfway
/// point — or with enough fling velocity — snaps the row fully open; otherwise
/// it settles closed. Tapping a revealed action closes the row and then fires
/// the action.
///
/// Action visuals adapt to the consumer:
/// * [actionPadding] / [actionBorderRadius] null → edge-to-edge blocks
///   (message-list style).
/// * both set → inset rounded chips (drawer style).
class StarrySwipeable extends StatefulWidget {
  const StarrySwipeable({
    required this.child,
    required this.actions,
    super.key,
    this.onTap,
    this.actionWidth = defaultActionWidth,
    this.borderRadius,
    this.backgroundColor,
    this.actionPadding,
    this.actionBorderRadius,
  });

  /// Default per-action reveal width.
  static const double defaultActionWidth = 72;

  /// Extra drag distance allowed past the fully-open position, producing a
  /// slight rubber-band overscroll. Interaction-feel constant (no design token).
  static const double overscrollSlack = 20;

  /// Fling velocity (logical px/s) above which a release snaps the row open
  /// regardless of drag distance. Interaction-feel constant (no design token).
  static const double swipeVelocityThreshold = 300;

  final Widget child;
  final List<StarrySwipeAction> actions;
  final VoidCallback? onTap;
  final double actionWidth;
  final BorderRadius? borderRadius;

  /// Opaque underlay painted behind the clipped content. Set it to the row's
  /// own surface color to avoid a one-pixel anti-alias fringe at the rounded
  /// corners (and to keep a row-level shadow from leaking past the clip). When
  /// null the clip has a transparent underlay.
  final Color? backgroundColor;
  final EdgeInsetsGeometry? actionPadding;
  final BorderRadius? actionBorderRadius;

  @override
  State<StarrySwipeable> createState() => _StarrySwipeableState();
}

class _StarrySwipeableState extends State<StarrySwipeable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;
  double _dragExtent = 0;

  double get _maxDrag => widget.actions.length * widget.actionWidth;
  bool get _isSwipeEnabled => widget.actions.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _animation = const AlwaysStoppedAnimation<double>(0);
    _controller.addListener(() {
      setState(() {
        _dragExtent = _animation.value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (!_isSwipeEnabled) {
      return;
    }
    setState(() {
      _dragExtent += details.primaryDelta ?? 0;
      if (_dragExtent > 0) {
        _dragExtent = 0;
      }
      final overscrollLimit = -_maxDrag - StarrySwipeable.overscrollSlack;
      if (_dragExtent < overscrollLimit) {
        _dragExtent = overscrollLimit;
      }
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (!_isSwipeEnabled) {
      return;
    }
    final shouldOpen = _dragExtent < -_maxDrag / 2 ||
        (details.primaryVelocity ?? 0) < -StarrySwipeable.swipeVelocityThreshold;
    _animateTo(shouldOpen ? -_maxDrag : 0);
  }

  void _animateTo(double target) {
    _animation = Tween<double>(
      begin: _dragExtent,
      end: target,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward(from: 0);
  }

  void _closeAndAction(VoidCallback action) {
    _animation = Tween<double>(
      begin: _dragExtent,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward(from: 0).then((_) => action());
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;

    // Swipe settle animation uses the medium motion token. Set here (rather
    // than in initState) so it resolves from the active theme's tokens.
    _controller.duration = t.motion.durationMedium;

    final resolvedRadius =
        widget.borderRadius ?? BorderRadius.circular(t.radius.lg);

    final content = Transform.translate(
      offset: Offset(_dragExtent, 0),
      child: GestureDetector(
        onHorizontalDragUpdate: _isSwipeEnabled ? _onHorizontalDragUpdate : null,
        onHorizontalDragEnd: _isSwipeEnabled ? _onHorizontalDragEnd : null,
        onTap: widget.onTap,
        child: widget.child,
      ),
    );

    final stack = Stack(
      children: <Widget>[
        if (_isSwipeEnabled)
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (final action in widget.actions)
                  _buildAction(context, action),
              ],
            ),
          ),
        content,
      ],
    );

    return ClipRRect(
      borderRadius: resolvedRadius,
      child: widget.backgroundColor == null
          ? stack
          : ColoredBox(color: widget.backgroundColor!, child: stack),
    );
  }

  Widget _buildAction(BuildContext context, StarrySwipeAction action) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final block = Container(
      width: widget.actionWidth,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: action.backgroundColor,
        borderRadius: widget.actionBorderRadius,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            action.icon,
            color: action.foregroundColor,
            size: t.controlMetrics.iconLg,
          ),
          SizedBox(height: t.spacing.s1 / 2),
          Text(
            action.label,
            textAlign: TextAlign.center,
            style: t.typography.labelSmall.textStyle.copyWith(
              color: action.foregroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
    return GestureDetector(
      onTap: () => _closeAndAction(action.onTap),
      child: widget.actionPadding == null
          ? block
          : Padding(padding: widget.actionPadding!, child: block),
    );
  }
}
