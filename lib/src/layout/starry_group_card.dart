import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// A rounded container that stacks [children] vertically, optionally inserting
/// thin dividers between them. Supports an opaque surface (default) or a
/// frosted-glass fill. Shadow is opt-in via [boxShadow] (flat by default).
class StarryGroupCard extends StatelessWidget {
  const StarryGroupCard({
    required this.children,
    super.key,
    this.margin,
    this.padding,
    this.borderRadius,
    this.showDividers = true,
    this.dividerColor,
    this.frosted = false,
    this.blurSigma = 8,
    this.tintColor,
    this.backgroundColor,
    this.boxShadow,
    this.elevated = false,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry? margin;

  /// Inner padding. Defaults to symmetric vertical [StarrySpacing.s2].
  final EdgeInsetsGeometry? padding;

  /// Corner radius. Defaults to [StarryRadius.lg].
  final double? borderRadius;

  final bool showDividers;
  final Color? dividerColor;

  /// When true, renders a blurred frosted-glass fill instead of an opaque one.
  final bool frosted;
  final double blurSigma;

  /// Tint color used when [frosted] is true. Defaults to a translucent surface.
  final Color? tintColor;

  /// Opaque background color used when not [frosted]. Defaults to the surface.
  final Color? backgroundColor;

  /// Drop shadow. Null (default) renders a flat card; pass
  /// `tokens.elevation.level2` for the standard white-card shadow.
  final List<BoxShadow>? boxShadow;

  /// When true (and [boxShadow] is null), applies the standard card shadow
  /// (`tokens.elevation.level2`). Ignored when [boxShadow] is provided.
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<StarryTokens>()!;
    final s = tokens.semantic;
    final radius = borderRadius ?? tokens.radius.lg;
    final effectivePadding =
        padding ?? EdgeInsets.symmetric(vertical: tokens.spacing.s2);
    final effectiveDividerColor = dividerColor ?? s.border;
    final effectiveBackground = backgroundColor ?? s.surface;
    final effectiveTint =
        tintColor ?? s.surface.withValues(alpha: tokens.opacity.accentSurface);
    final effectiveShadow =
        boxShadow ?? (elevated ? tokens.elevation.level2 : null);

    final body = _buildBody(effectivePadding, effectiveDividerColor);

    final Widget card = frosted
        ? ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: effectiveTint,
                  borderRadius: BorderRadius.circular(radius),
                ),
                child: body,
              ),
            ),
          )
        : DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              boxShadow: effectiveShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Material(
                color: effectiveBackground,
                clipBehavior: Clip.antiAlias,
                child: body,
              ),
            ),
          );

    return Container(margin: margin, child: card);
  }

  Widget _buildBody(EdgeInsetsGeometry effectivePadding, Color dividerColor) {
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (showDividers && i != children.length - 1) {
        items.add(Container(height: 1, color: dividerColor));
      }
    }
    return Padding(
      padding: effectivePadding,
      child: Column(mainAxisSize: MainAxisSize.min, children: items),
    );
  }
}

/// A padded [Divider] intended to separate rows inside a [StarryGroupCard].
class StarryGroupDivider extends StatelessWidget {
  const StarryGroupDivider({super.key, this.padding, this.color});

  /// Horizontal inset. Defaults to symmetric horizontal [StarrySpacing.s4].
  final EdgeInsetsGeometry? padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<StarryTokens>()!;
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: tokens.spacing.s4),
      child: Divider(color: color ?? tokens.semantic.border),
    );
  }
}

/// A right-aligned text action button intended as a trailing row inside a
/// [StarryGroupCard] group.
class StarryGroupAction extends StatelessWidget {
  const StarryGroupAction({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<StarryTokens>()!;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.spacing.s4,
        0,
        tokens.spacing.s4,
        tokens.spacing.s3,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton(onPressed: onPressed, child: Text(label)),
      ),
    );
  }
}
