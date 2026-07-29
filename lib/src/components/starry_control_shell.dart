import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// Shared control-shell primitive for Starry controls.
///
/// Provides a single source of truth for the control-shell visual language
/// (fill / radius / elevation / active-border) so inputs, selectors, and chrome
/// buttons stay identical without committing to any specific animation
/// strategy. This is the control-family analogue of the card family's
/// [StarrySurface]/[StarryInputShell] primitives.
///
/// Token wiring (all derived from [StarryTokens]):
/// * fill            -> `semantic.surface`
/// * active border   -> `semantic.brand`
/// * radius          -> `radius.lg`
/// * elevation       -> `elevation.level2`
/// * border width    -> `controlMetrics.focusBorderWidth`
/// * inner radius    -> `radius.lg - controlMetrics.innerRadiusDelta`
///
/// The press micro-interaction ([pressDuration]/[pressCurve]) has no design
/// token and stays an internal primitive constant.
class StarryControlShell extends StatelessWidget {
  const StarryControlShell({
    required this.child,
    super.key,
    this.isActive = false,
    this.constraints,
    this.padding,
    this.width,
    this.height,
    this.backgroundColor,
    this.shellBoxShadow,
    this.shellBorderRadius,
    this.shellBorderSide,
    this.shape = BoxShape.rectangle,
    this.alignment,
  });

  /// Duration of the press-scale micro-interaction. No design token exists for
  /// this transient affordance, so it stays an internal primitive constant.
  static const Duration pressDuration = Duration(milliseconds: 200);

  /// Curve of the press-scale micro-interaction. See [pressDuration].
  static const Curve pressCurve = Curves.easeOutCubic;

  /// Outer border radius of the shell, derived from `radius.lg`.
  static BorderRadius borderRadius(StarryTokens t) =>
      BorderRadius.circular(t.radius.lg);

  /// Inner border radius for content clipped inside a bordered shell.
  /// Geometrically `radius.lg - innerRadiusDelta` (the border width).
  static BorderRadius innerBorderRadius(StarryTokens t) =>
      BorderRadius.circular(t.radius.lg - t.controlMetrics.innerRadiusDelta);

  /// Icon extent that matches the shell's control language (`iconMd`).
  static double iconSize(StarryTokens t) => t.controlMetrics.iconMd;

  /// Horizontal content padding for single-line controls (`spacing.s5`).
  static EdgeInsets horizontalPadding(StarryTokens t) =>
      EdgeInsets.symmetric(horizontal: t.spacing.s5);

  /// Usable content height inside a bordered single-line control: the control
  /// height minus the top and bottom border (`controlHeight - 2 * focusBorderWidth`).
  static double singleLineContentHeight(StarryTokens t) =>
      t.controlMetrics.controlHeight - t.controlMetrics.focusBorderWidth * 2;

  /// The active/rest border side.
  ///
  /// The width stays [StarryControlMetrics.focusBorderWidth] in both states so
  /// activating the highlight never changes the control's measured size; only
  /// the color toggles between `semantic.brand` and transparent.
  static BorderSide activeBorderSide(
    BuildContext context, {
    bool isActive = true,
  }) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    return BorderSide(
      color: isActive ? t.semantic.brand : Colors.transparent,
      width: t.controlMetrics.focusBorderWidth,
    );
  }

  /// The shell decoration shared by the static and animated variants.
  static BoxDecoration decoration(
    BuildContext context, {
    bool isActive = false,
    Color? backgroundColor,
    List<BoxShadow>? boxShadow,
    BorderRadius? borderRadius,
    BorderSide? borderSide,
    BoxShape shape = BoxShape.rectangle,
  }) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    return BoxDecoration(
      color: backgroundColor ?? t.semantic.surface,
      borderRadius: shape == BoxShape.circle
          ? null
          : (borderRadius ?? StarryControlShell.borderRadius(t)),
      shape: shape,
      boxShadow: boxShadow ?? t.elevation.level2,
      border: Border.fromBorderSide(
        borderSide ?? activeBorderSide(context, isActive: isActive),
      ),
    );
  }

  /// Wraps [child] in the press-scale micro-interaction.
  static Widget pressable({required bool isPressed, required Widget child}) {
    return AnimatedScale(
      scale: isPressed ? 0.95 : 1.0,
      duration: pressDuration,
      curve: pressCurve,
      child: child,
    );
  }

  final Widget child;
  final bool isActive;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  /// Fill color. Defaults to `semantic.surface` when null.
  final Color? backgroundColor;
  final List<BoxShadow>? shellBoxShadow;
  final BorderRadius? shellBorderRadius;
  final BorderSide? shellBorderSide;
  final BoxShape shape;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      constraints: constraints,
      padding: padding,
      alignment: alignment,
      decoration: decoration(
        context,
        isActive: isActive,
        backgroundColor: backgroundColor,
        boxShadow: shellBoxShadow,
        borderRadius: shellBorderRadius,
        borderSide: shellBorderSide,
        shape: shape,
      ),
      child: child,
    );
  }
}

/// Animated variant of [StarryControlShell] for focus/open/selected states.
///
/// Transitions the shared [StarryControlShell.decoration] over
/// `motion.durationShort` with the standard easing.
class StarryAnimatedControlShell extends StatelessWidget {
  const StarryAnimatedControlShell({
    required this.child,
    super.key,
    this.isActive = false,
    this.constraints,
    this.padding,
    this.width,
    this.height,
    this.backgroundColor,
    this.shellBoxShadow,
    this.shellBorderRadius,
    this.shellBorderSide,
    this.shape = BoxShape.rectangle,
    this.alignment,
    this.duration,
    this.curve,
  });

  final Widget child;
  final bool isActive;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final List<BoxShadow>? shellBoxShadow;
  final BorderRadius? shellBorderRadius;
  final BorderSide? shellBorderSide;
  final BoxShape shape;
  final AlignmentGeometry? alignment;

  /// Transition duration. Defaults to `motion.durationShort` when null.
  final Duration? duration;

  /// Transition curve. Defaults to `motion.easingStandard` when null.
  final Curve? curve;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    return AnimatedContainer(
      duration: duration ?? t.motion.durationShort,
      curve: curve ?? t.motion.easingStandard,
      width: width,
      height: height,
      constraints: constraints,
      padding: padding,
      alignment: alignment,
      decoration: StarryControlShell.decoration(
        context,
        isActive: isActive,
        backgroundColor: backgroundColor,
        boxShadow: shellBoxShadow,
        borderRadius: shellBorderRadius,
        borderSide: shellBorderSide,
        shape: shape,
      ),
      child: child,
    );
  }
}

/// Round icon-button shell that speaks the same control-shell visual language
/// as the larger [StarryControlShell] family.
///
/// Composes [StarryControlShell.pressable] + [FocusableActionDetector] +
/// [StarryAnimatedControlShell] (circular) + [InkWell], exposing button
/// semantics and reacting to focus and press.
class StarryRoundIconShell extends StatefulWidget {
  const StarryRoundIconShell({
    required this.child,
    super.key,
    this.isActive = false,
    this.size,
    this.onTap,
    this.semanticsLabel,
  });

  final Widget child;
  final bool isActive;

  /// Diameter of the round shell. Defaults to `controlMetrics.controlHeight`.
  final double? size;
  final VoidCallback? onTap;
  final String? semanticsLabel;

  @override
  State<StarryRoundIconShell> createState() => _StarryRoundIconShellState();
}

class _StarryRoundIconShellState extends State<StarryRoundIconShell> {
  bool _focused = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final isActive = widget.isActive || _focused;
    final size = widget.size ?? t.controlMetrics.controlHeight;
    return Semantics(
      button: true,
      enabled: widget.onTap != null,
      label: widget.semanticsLabel,
      child: StarryControlShell.pressable(
        isPressed: _pressed,
        child: FocusableActionDetector(
          enabled: widget.onTap != null,
          onShowFocusHighlight: (value) => setState(() => _focused = value),
          child: StarryAnimatedControlShell(
            isActive: isActive,
            width: size,
            height: size,
            shape: BoxShape.circle,
            child: InkWell(
              onTap: widget.onTap,
              onHighlightChanged: (value) => setState(() => _pressed = value),
              customBorder: const CircleBorder(),
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Center(
                child: SizedBox(
                  width: StarryControlShell.iconSize(t) + 2,
                  height: StarryControlShell.iconSize(t) + 2,
                  child: Center(child: widget.child),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
