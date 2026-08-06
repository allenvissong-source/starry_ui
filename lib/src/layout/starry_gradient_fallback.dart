import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// A diagonal brand gradient used as a lightweight backdrop — e.g. the
/// placeholder shown while a hero image loads or fails.
///
/// The three stops are token-driven (`brand.primaryPale` → `brand.primaryTint50`
/// → `brand.accentGradientEnd`), so the fallback tracks the theme.
class StarryGradientFallback extends StatelessWidget {
  const StarryGradientFallback({super.key});

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<StarryTokens>()!.brand;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            brand.primaryPale,
            brand.primaryTint50,
            brand.accentGradientEnd,
          ],
        ),
      ),
    );
  }
}
