import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// A fixed-aspect media stage: the standard way to present an image/video in a
/// feed card with an optional bottom scrim + overlay content on top.
///
/// Layout:
///   * The stage is sized by [aspectRatio] (values `<= 0` are normalized to 1).
///   * [child] fills the stage (the media itself).
///   * When [overlay] is non-null it is pinned to the bottom over a downward
///     scrim gradient (`Colors.transparent` → `semantic.mediaOverlayEnd`) so
///     light overlay content stays legible over bright imagery.
///   * When [brightnessAnimation] is non-null the media brightness is driven by
///     the animation value (`1 + value * 0.06`), e.g. a subtle breathing pulse.
class StarryMediaStage extends StatelessWidget {
  const StarryMediaStage({
    required this.aspectRatio,
    required this.child,
    super.key,
    this.overlay,
    this.brightnessAnimation,
    this.overlayPadding = const EdgeInsets.fromLTRB(16, 24, 16, 12),
  });

  /// Aspect ratio of the stage. Values `<= 0` are normalized to `1`.
  final double aspectRatio;

  /// The media content, laid out to fill the stage.
  final Widget child;

  /// Optional content pinned to the bottom over a scrim gradient.
  final Widget? overlay;

  /// Optional brightness driver — the media brightness follows
  /// `1 + brightnessAnimation.value * 0.06`.
  final Animation<double>? brightnessAnimation;

  /// Padding around [overlay]. Defaults to `fromLTRB(16, 24, 16, 12)`.
  final EdgeInsetsGeometry overlayPadding;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final animation = brightnessAnimation;
    final media = animation == null
        ? child
        : AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return ColorFiltered(
                colorFilter: ColorFilter.matrix(
                  _brightnessMatrix(1 + animation.value * 0.06),
                ),
                child: child,
              );
            },
            child: child,
          );

    return AspectRatio(
      aspectRatio: aspectRatio <= 0 ? 1 : aspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          media,
          if (overlay != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: overlayPadding,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.transparent,
                      t.semantic.mediaOverlayEnd,
                    ],
                  ),
                ),
                child: overlay,
              ),
            ),
        ],
      ),
    );
  }

  static List<double> _brightnessMatrix(double value) {
    return <double>[
      value, 0, 0, 0, 0, //
      0, value, 0, 0, 0, //
      0, 0, value, 0, 0, //
      0, 0, 0, 1, 0, //
    ];
  }
}
