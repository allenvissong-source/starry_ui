import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// Starry UI page scaffold wrapper.
///
/// Applies a standard page padding (default `spacing.s4`), a surface
/// background and optional [SafeArea] handling around [child].
class StarryPageWrapper extends StatelessWidget {
  const StarryPageWrapper({
    required this.child,
    super.key,
    this.padding,
    this.safeArea = true,
    this.backgroundColor,
  });

  /// Page content.
  final Widget child;

  /// Content padding. Defaults to `spacing.s4` on all sides.
  final EdgeInsets? padding;

  /// Whether to wrap the content in a [SafeArea].
  final bool safeArea;

  /// Background color. Defaults to `semantic.surface`.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;

    Widget content = Container(
      color: backgroundColor ?? t.semantic.surface,
      padding: padding ?? EdgeInsets.all(t.spacing.s4),
      child: child,
    );

    if (safeArea) {
      content = SafeArea(child: content);
    }

    return content;
  }
}
