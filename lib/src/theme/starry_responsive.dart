import 'package:flutter/material.dart';

import 'starry_tokens.dart';

/// Signature for [StarryResponsiveBuilder.builder].
///
/// Receives the resolved [StarryWindowSizeClass] for the available layout
/// width plus the raw [BoxConstraints] so callers can still branch on exact
/// dimensions when a size class is not granular enough.
typedef StarryResponsiveWidgetBuilder =
    Widget Function(
      BuildContext context,
      StarryWindowSizeClass sizeClass,
      BoxConstraints constraints,
    );

/// Context-level access to the Starry responsive standard.
///
/// This is the single supported entry point for reading the active window
/// size class from a [BuildContext]. It resolves against the theme-carried
/// [StarryBreakpoints] (via [StarryTokens]) using the physical/page width from
/// [MediaQuery]. For layout-local decisions that must respect a parent's
/// constraint (e.g. a pane inside a split view), prefer [StarryResponsiveBuilder]
/// which keys off the [LayoutBuilder] constraint width instead.
extension StarryResponsiveContext on BuildContext {
  /// The design-system breakpoints carried on the current theme.
  ///
  /// Falls back to a const [StarryBreakpoints] when no [StarryTokens] extension
  /// is present, so this never throws in a themeless test harness.
  StarryBreakpoints get starryBreakpoints =>
      Theme.of(this).extension<StarryTokens>()?.breakpoints ??
      const StarryBreakpoints();

  /// The active [StarryWindowSizeClass] for the current page width.
  ///
  /// Uses `MediaQuery.sizeOf(context).width`, matching the Material 3 window
  /// size-class semantics documented on [StarryWindowSizeClass].
  StarryWindowSizeClass get starryWindowSizeClass =>
      starryBreakpoints.resolve(MediaQuery.sizeOf(this).width);
}

/// Rebuilds against the available layout width and hands the caller the
/// resolved [StarryWindowSizeClass].
///
/// Wraps a [LayoutBuilder] so the size class reflects the *constraint* width
/// the widget is laid out in — the correct signal for a sub-region such as a
/// detail pane, master/detail split, or any box narrower than the page. For
/// whole-page decisions, `context.starryWindowSizeClass` (page width) is
/// simpler.
class StarryResponsiveBuilder extends StatelessWidget {
  const StarryResponsiveBuilder({required this.builder, super.key});

  final StarryResponsiveWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final breakpoints = context.starryBreakpoints;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        return builder(context, breakpoints.resolve(width), constraints);
      },
    );
  }
}
