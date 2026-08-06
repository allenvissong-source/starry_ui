import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// A frosted-glass container: a blurred, translucent surface with a bright
/// hairline border and a diffuse drop shadow.
///
/// The backdrop behind [child] is blurred ([blurSigma]) and tinted with the
/// theme surface at [surfaceOpacity]. The hairline border uses
/// `semantic.onMedia` (white in both themes, since a glass panel floats over
/// media/photographic backdrops) and the shadow uses the dedicated
/// `elevation.glass` tier. All colors and the shadow are token-driven.
class StarryGlassPanel extends StatelessWidget {
  const StarryGlassPanel({
    required this.child,
    this.borderRadius,
    this.padding,
    this.blurSigma,
    this.surfaceOpacity,
    this.borderOpacity,
    this.borderWidth,
    super.key,
  });

  /// Content painted on top of the glass surface.
  final Widget child;

  /// Corner radius of the panel (and its clip / border).
  ///
  /// Defaults to `radius.xxl` (28) when null.
  final double? borderRadius;

  /// Inner padding around [child].
  ///
  /// Defaults to `spacing.s8` (32) on all sides when null.
  final EdgeInsetsGeometry? padding;

  /// Gaussian blur sigma applied to the backdrop behind the panel.
  ///
  /// Defaults to `glass.blurSigma` (22) when null.
  final double? blurSigma;

  /// Alpha applied to the theme surface fill.
  ///
  /// Defaults to `glass.surfaceOpacity` (0.82) when null.
  final double? surfaceOpacity;

  /// Alpha applied to the `onMedia` hairline border color.
  ///
  /// Defaults to `glass.borderOpacity` (0.58) when null.
  final double? borderOpacity;

  /// Width of the hairline border.
  ///
  /// Defaults to `controlMetrics.borderThin` (1) when null.
  final double? borderWidth;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final radius = BorderRadius.circular(borderRadius ?? t.radius.xxl);
    final resolvedBorderWidth = borderWidth ?? t.controlMetrics.borderThin;
    final resolvedPadding = padding ?? EdgeInsets.all(t.spacing.s8);
    final resolvedBlur = blurSigma ?? t.glass.blurSigma;
    final resolvedSurfaceOpacity = surfaceOpacity ?? t.glass.surfaceOpacity;
    final resolvedBorderOpacity = borderOpacity ?? t.glass.borderOpacity;

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: resolvedBlur, sigmaY: resolvedBlur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: t.semantic.surface.withValues(alpha: resolvedSurfaceOpacity),
            borderRadius: radius,
            border: Border.all(
              color: t.semantic.onMedia.withValues(alpha: resolvedBorderOpacity),
              width: resolvedBorderWidth,
            ),
            boxShadow: t.elevation.glass,
          ),
          child: Padding(padding: resolvedPadding, child: child),
        ),
      ),
    );
  }
}
