import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// The backdrop on which a glass panel is used.
enum StarryGlassPanelVariant { media, content }

/// A frosted-glass container with a blurred, translucent surface.
///
/// Media panels use a bright on-media outline and a floating glass shadow.
/// Content panels use a quiet secondary surface and semantic border.
/// All colors, blur and shadows resolve from the design tokens.
class StarryGlassPanel extends StatelessWidget {
  const StarryGlassPanel({
    required this.child,
    this.borderRadius,
    this.padding,
    this.blurSigma,
    this.surfaceOpacity,
    this.borderOpacity,
    this.borderWidth,
    this.boxShadow,
    this.variant = StarryGlassPanelVariant.media,
    super.key,
  });

  /// Content painted on top of the glass surface.
  final Widget child;

  /// Content panels use a secondary surface and semantic border, without a
  /// floating shadow. Media panels retain their bright on-media outline.
  final StarryGlassPanelVariant variant;

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
  /// Only applies to the media variant; content uses the semantic border.
  final double? borderOpacity;

  /// Width of the hairline border.
  ///
  /// Defaults to `controlMetrics.borderThin` (1) when null.
  final double? borderWidth;

  /// Drop shadow painted under the panel.
  ///
  /// Defaults to `elevation.glass` (the diffuse floating-glass tier) when null.
  /// Pass an empty list to render a flat, shadowless panel — e.g. a subtle
  /// hairline card sitting on a solid page background where a drop shadow would
  /// read as noise rather than depth.
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final radius = BorderRadius.circular(borderRadius ?? t.radius.xxl);
    final resolvedBorderWidth = borderWidth ?? t.controlMetrics.borderThin;
    final resolvedPadding = padding ?? EdgeInsets.all(t.spacing.s8);
    final resolvedBlur = blurSigma ?? t.glass.blurSigma;
    final resolvedSurfaceOpacity = surfaceOpacity ?? t.glass.surfaceOpacity;
    final resolvedBorderOpacity = borderOpacity ?? t.glass.borderOpacity;
    final content = variant == StarryGlassPanelVariant.content;

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: resolvedBlur, sigmaY: resolvedBlur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color:
                (content ? t.semantic.backgroundSecondary : t.semantic.surface)
                    .withValues(alpha: resolvedSurfaceOpacity),
            borderRadius: radius,
            border: Border.all(
              color: content
                  ? t.semantic.border
                  : t.semantic.onMedia.withValues(alpha: resolvedBorderOpacity),
              width: resolvedBorderWidth,
            ),
            boxShadow: boxShadow ?? (content ? const [] : t.elevation.glass),
          ),
          child: Padding(padding: resolvedPadding, child: child),
        ),
      ),
    );
  }
}
