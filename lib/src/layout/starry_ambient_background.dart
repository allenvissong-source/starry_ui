import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// Token-driven ambient background used by application shells and auth pages.
///
/// The component owns the visual recipe while [StarryTokens] remains the only
/// source of colors. Product applications select a semantic [variant] and may
/// supply content, but do not carry their own gradient palette.
enum StarryAmbientBackgroundVariant { app, auth }

class StarryAmbientBackground extends StatelessWidget {
  const StarryAmbientBackground({
    super.key,
    this.variant = StarryAmbientBackgroundVariant.app,
    this.child,
  });

  const StarryAmbientBackground.auth({super.key, this.child})
    : variant = StarryAmbientBackgroundVariant.auth;

  final StarryAmbientBackgroundVariant variant;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<StarryTokens>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = switch (variant) {
      StarryAmbientBackgroundVariant.app => _AppAtmosphere(
        tokens: tokens,
        isDark: isDark,
      ),
      StarryAmbientBackgroundVariant.auth => _AuthAtmosphere(tokens: tokens),
    };

    if (child == null) return background;
    return Stack(fit: StackFit.expand, children: <Widget>[background, child!]);
  }
}

class _AppAtmosphere extends StatelessWidget {
  const _AppAtmosphere({required this.tokens, required this.isDark});

  final StarryTokens tokens;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final brand = tokens.brand;
    final semantic = tokens.semantic;
    final overlay = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[
        brand.gradientStart.withValues(alpha: isDark ? 0.36 : 0.28),
        brand.gradientEnd.withValues(alpha: isDark ? 0.18 : 0.10),
        semantic.background.withValues(alpha: 0),
      ],
      stops: const <double>[0, 0.34, 1],
    );

    if (!isDark) {
      return DecoratedBox(decoration: BoxDecoration(gradient: overlay));
    }
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        DecoratedBox(decoration: BoxDecoration(gradient: overlay)),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.4, -1),
              radius: 1.1,
              colors: <Color>[
                brand.brandGlow,
                brand.brandGlow.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthAtmosphere extends StatelessWidget {
  const _AuthAtmosphere({required this.tokens});

  final StarryTokens tokens;

  @override
  Widget build(BuildContext context) {
    final brand = tokens.brand;
    final semantic = tokens.semantic;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            brand.primaryPale,
            brand.primaryTint50,
            semantic.background,
          ],
          stops: const <double>[0, 0.35, 1],
        ),
      ),
    );
  }
}
