import 'package:flutter/material.dart';

import '../interactions/starry_press_scale.dart';
import '../theme/starry_tokens.dart';
import 'starry_surface.dart';

/// A borderless, elevated feed/masonry card shell with pointer affordances.
///
/// It composes the card-family surface primitive with the shared motion
/// micro-interactions so a feed card can never re-diverge from the design
/// system:
///   * fill / radius / clip come from [StarrySurface] (borderless here — feed
///     cards carry no hairline);
///   * the drop shadow lifts from `elevation.level2` to `elevation.level3` while
///     hovered (all shadow tiers are tokens — no hand-computed alpha);
///   * the card scales up subtly on hover and shrinks on press
///     (`StarryPressScale`, driven by `motion.pressedScale`).
///
/// All motion parameters resolve from [StarryTokens]; there are no per-call
/// animation overrides.
class StarryMasonryCard extends StatefulWidget {
  const StarryMasonryCard({
    required this.child,
    super.key,
    this.onTap,
    this.borderRadius,
  });

  /// Card content, clipped to [borderRadius].
  final Widget child;

  /// Tap handler. Drives the press-scale interaction via [StarryPressScale].
  final VoidCallback? onTap;

  /// Corner radius. Defaults to `radius.lg`.
  final BorderRadius? borderRadius;

  @override
  State<StarryMasonryCard> createState() => _StarryMasonryCardState();
}

class _StarryMasonryCardState extends State<StarryMasonryCard> {
  static const double _hoverScale = 1.01;

  bool _hovered = false;

  void _setHovered(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final radius =
        widget.borderRadius ?? BorderRadius.circular(t.radius.lg);

    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: StarryPressScale(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _hovered ? _hoverScale : 1,
          duration: t.motion.durationMedium,
          curve: t.motion.easingStandard,
          child: AnimatedContainer(
            duration: t.motion.durationMedium,
            curve: t.motion.easingStandard,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: _hovered ? t.elevation.level3 : t.elevation.level2,
            ),
            child: StarrySurface(
              elevated: false,
              color: t.semantic.surface,
              borderColor: Colors.transparent,
              borderRadius: radius,
              clipBehavior: Clip.antiAlias,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
