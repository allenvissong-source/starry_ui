import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';
import 'starry_surface.dart';

/// Starry surface container with optional interaction and elevation.
///
/// Composes the private [StarrySurface] primitive (the single source of truth
/// for the card family's fill/radius/border/elevation) and adds the card's
/// standard `spacing.s5` interior padding.
class StarryCard extends StatelessWidget {
  const StarryCard({
    required this.child,
    super.key,
    this.onTap,
    this.elevated = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    return StarrySurface(
      padding: EdgeInsets.all(t.spacing.s5),
      elevated: elevated,
      onTap: onTap,
      child: child,
    );
  }
}
