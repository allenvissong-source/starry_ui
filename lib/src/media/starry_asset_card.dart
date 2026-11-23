import 'package:flutter/material.dart';

import '../interactions/starry_press_scale.dart';
import '../theme/starry_tokens.dart';

/// A tappable square-ish asset tile: a cover [media] widget under a bottom
/// gradient scrim with a single-line [title], falling back to a centered
/// [emptyIcon] when [media] is null.
///
/// The DS package does not know how to load app images, so the caller supplies
/// the already-built cover widget via [media] (e.g. an `Image`, a cached-network
/// image, or an app-specific media widget). When [media] is null the card shows
/// the [emptyIcon] placeholder and renders the title in a muted color.
class StarryAssetCard extends StatelessWidget {
  const StarryAssetCard({
    required this.title,
    required this.onTap,
    required this.emptyIcon,
    super.key,
    this.media,
  });

  final String title;
  final VoidCallback onTap;
  final IconData emptyIcon;

  /// The cover media widget. When null, [emptyIcon] is shown instead.
  final Widget? media;

  /// Height of the bottom title overlay band.
  static const double _overlayHeight = 48;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;
    final radius = BorderRadius.circular(t.radius.xl);
    final hasMedia = media != null;

    return StarryPressScale(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: t.elevation.level2,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Material(
            color: s.surface,
            child: InkWell(
              onTap: onTap,
              splashFactory: NoSplash.splashFactory,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  if (hasMedia)
                    media!
                  else
                    Center(
                      child: Icon(
                        emptyIcon,
                        size: t.spacing.s8,
                        color: s.textSecondary,
                      ),
                    ),
                  if (hasMedia)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: <Color>[
                              Colors.transparent,
                              s.mediaOverlayEnd,
                            ],
                            stops: const <double>[0.55, 1],
                          ),
                        ),
                      ),
                    ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      height: _overlayHeight,
                      alignment: Alignment.bottomLeft,
                      padding: EdgeInsets.fromLTRB(
                        t.spacing.s3,
                        t.spacing.s1,
                        t.spacing.s3,
                        t.spacing.s2,
                      ),
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.typography.labelMedium.textStyle.copyWith(
                          color: hasMedia ? s.onMedia : s.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: radius,
                          border: Border.all(color: s.border),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
