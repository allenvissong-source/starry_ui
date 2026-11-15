import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';
import '../components/starry_surface.dart';
import 'starry_section_header.dart';
import 'starry_glass_panel.dart';

enum StarryContentSectionVariant { solid, frosted }

/// Sets the default section material for a subtree, without changing the app's
/// global theme. An explicit section [StarryContentSection.variant] wins.
class StarryContentSectionTheme extends InheritedTheme {
  const StarryContentSectionTheme({
    required this.variant,
    required super.child,
    super.key,
  });

  final StarryContentSectionVariant variant;

  static StarryContentSectionVariant of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<StarryContentSectionTheme>()
          ?.variant ??
      StarryContentSectionVariant.solid;

  @override
  bool updateShouldNotify(StarryContentSectionTheme oldWidget) =>
      variant != oldWidget.variant;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      StarryContentSectionTheme(variant: variant, child: child);
}

/// A quiet, left-aligned content section with a lightly elevated surface.
/// Titles use the shared section header; visual values come from Starry tokens.
class StarryContentSection extends StatelessWidget {
  const StarryContentSection({
    required this.child,
    this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.headerSpacing,
    this.variant,
    super.key,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;

  /// Gap between the section header and [child]. Defaults to `spacing.s4`.
  /// Sections whose first child is a tall control can tighten this so the
  /// control's internal padding does not add a second header gap.
  final double? headerSpacing;

  /// Defaults to the nearest [StarryContentSectionTheme], otherwise solid.
  /// Frosted changes only the backdrop; text and layout stay opaque and stable.
  final StarryContentSectionVariant? variant;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    // Body copy is deliberately a step below the section title: one size
    // smaller and in the secondary text tone, so titles stay the scan
    // anchors and long passages read as content rather than emphasis.
    final content = DefaultTextStyle.merge(
      style: t.typography.bodyMedium.textStyle.copyWith(
        color: t.semantic.textSecondary,
        fontWeight: FontWeight.w400,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null && title!.isNotEmpty) ...[
            StarrySectionHeader(
              title: title,
              subtitle: subtitle,
              icon: icon,
              trailing: trailing,
              compact: true,
              emphasis: true,
              titleFontWeight: FontWeight.w500,
            ),
            SizedBox(height: headerSpacing ?? t.spacing.s4),
          ],
          child,
        ],
      ),
    );
    if ((variant ?? StarryContentSectionTheme.of(context)) ==
        StarryContentSectionVariant.frosted) {
      // No drop shadow: the section floats on the page's own photograph, and
      // an elevation shadow would read as a detached card over the image.
      return StarryGlassPanel(
        borderRadius: t.radius.md,
        // Content glass is deliberately more transparent and less blurred
        // than media glass so the photographic backdrop reads through it.
        blurSigma: t.glass.contentBlurSigma,
        surfaceOpacity: t.glass.contentSurfaceOpacity,
        // Match StarrySurface's border inset so switching material does not
        // move the content or change the section height.
        padding: EdgeInsets.all(t.spacing.s5 + t.controlMetrics.borderThin),
        boxShadow: const [],
        child: content,
      );
    }
    return StarrySurface(
      borderRadius: BorderRadius.circular(t.radius.md),
      padding: EdgeInsets.all(t.spacing.s5),
      child: content,
    );
  }
}
