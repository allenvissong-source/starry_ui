import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';
import 'starry_gradient_fallback.dart';

/// A full-bleed immersive backdrop: a hero image, a translucent brand
/// atmosphere overlay, and (optionally) two soft ambient glow orbs.
///
/// When [imageAsset] is null or fails to load, the background degrades
/// gracefully to a [StarryGradientFallback]. All colors are token-driven via
/// `StarryTokens.brand`.
class StarryImmersiveBackground extends StatelessWidget {
  const StarryImmersiveBackground({
    this.imageAsset,
    this.imageBundle,
    this.fit = BoxFit.cover,
    this.alignment = const Alignment(-0.55, -0.1),
    this.showAmbientGlows = true,
    this.atmosphereGradient,
    super.key,
  });

  /// Asset key of the hero image. When null the gradient fallback fills the
  /// backdrop instead.
  final String? imageAsset;

  /// Optional asset bundle the [imageAsset] is resolved against.
  final AssetBundle? imageBundle;

  /// How the hero image is inscribed into the backdrop.
  final BoxFit fit;

  /// Alignment of the hero image within the backdrop.
  final AlignmentGeometry alignment;

  /// Whether the two ambient glow orbs are painted.
  final bool showAmbientGlows;

  /// Overrides the translucent brand atmosphere gradient painted above the
  /// hero image. When null, a default brand recipe is used
  /// ([_defaultAtmosphereGradient]). Supplying a [Gradient] lets callers fully
  /// customize the atmosphere — including the number of color stops.
  final Gradient? atmosphereGradient;

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<StarryTokens>()!.brand;
    final asset = imageAsset;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (asset != null)
          Positioned.fill(
            child: Image.asset(
              asset,
              bundle: imageBundle,
              width: double.infinity,
              height: double.infinity,
              fit: fit,
              alignment: alignment,
              errorBuilder: (_, _, _) => const StarryGradientFallback(),
            ),
          )
        else
          const Positioned.fill(child: StarryGradientFallback()),
        _StarryAtmosphereOverlay(
          gradient: atmosphereGradient ?? _defaultAtmosphereGradient(brand),
        ),
        if (showAmbientGlows) ...[
          Positioned(
            left: _kPrimaryOrbLeft,
            bottom: _kPrimaryOrbBottom,
            child: _StarryGlowOrb(size: _kPrimaryOrbSize, color: brand.brandGlow),
          ),
          Positioned(
            right: _kAccentOrbRight,
            top: _kAccentOrbTop,
            child: _StarryGlowOrb(size: _kAccentOrbSize, color: brand.accentGlow),
          ),
        ],
      ],
    );
  }
}

class _StarryAtmosphereOverlay extends StatelessWidget {
  const _StarryAtmosphereOverlay({required this.gradient});

  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(decoration: BoxDecoration(gradient: gradient));
  }
}

/// The default translucent brand atmosphere gradient painted above the hero
/// image when [StarryImmersiveBackground.atmosphereGradient] is not supplied.
///
/// The three alpha stops are a bespoke, deliberately-tuned atmosphere recipe
/// for this backdrop (not a shared opacity token). hardcode-allow: these
/// values are the component's default look, overridable via `atmosphereGradient`.
LinearGradient _defaultAtmosphereGradient(StarryBrandColors brand) {
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      brand.primaryPale.withValues(alpha: 0.84), // hardcode-allow
      brand.primaryTint50.withValues(alpha: 0.66), // hardcode-allow
      brand.accentGradientEnd.withValues(alpha: 0.36), // hardcode-allow
    ],
  );
}

// Bespoke composition constants for the two ambient glow orbs. These are
// free-form decorative placement/size values with no semantic token
// equivalent; they intentionally bleed off-canvas (negative offsets) to feel
// organic. hardcode-allow: one-off layout composition, not a design token.
const double _kPrimaryOrbLeft = -120;
const double _kPrimaryOrbBottom = -180;
const double _kPrimaryOrbSize = 420;
const double _kAccentOrbRight = -90;
const double _kAccentOrbTop = -110;
const double _kAccentOrbSize = 340;

class _StarryGlowOrb extends StatelessWidget {
  const _StarryGlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final blurSigma =
        Theme.of(context).extension<StarryTokens>()!.glass.blurSigma;
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
