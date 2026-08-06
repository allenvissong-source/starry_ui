import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// Pulsing (opacity) looping animation.
///
/// Continuous fade in/out, commonly used for skeleton/placeholder loading.
///
/// Example:
/// ```dart
/// StarryPulsingWidget(
///   child: Container(height: 16),
/// )
/// ```
class StarryPulsingWidget extends StatefulWidget {
  const StarryPulsingWidget({
    required this.child,
    super.key,
    this.minOpacity = 0.4,
    this.maxOpacity = 1.0,
    this.duration,
    this.enabled = true,
  });

  /// Animated child.
  final Widget child;

  /// Minimum opacity.
  final double minOpacity;

  /// Maximum opacity.
  final double maxOpacity;

  /// Animation cycle duration. Defaults to `motion.durationSlower` (1200ms)
  /// when null.
  final Duration? duration;

  /// Whether the animation runs. When false the child renders statically at
  /// [maxOpacity].
  final bool enabled;

  @override
  State<StarryPulsingWidget> createState() => _StarryPulsingWidgetState();
}

/// Shared controller lifecycle for the looping-animation widgets
/// ([StarryPulsingWidget], [StarryRotatingWidget], [StarryScalingWidget]).
///
/// Owns the [AnimationController], its repeat/stop wiring, duration/enabled
/// reconciliation in [didUpdateWidget], and disposal. Subclasses supply the
/// per-cycle [cycleDuration] / [isEnabled] / [reverseOnRepeat] plus the active
/// and inactive builders; tween-owning subclasses use [onInit] /
/// [onDidUpdateWidget] to (re)build their [Animation] against [controller].
abstract class _LoopingAnimationState<T extends StatefulWidget> extends State<T>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  Duration? _lastDuration;
  bool? _lastEnabled;

  /// Duration of one animation cycle.
  Duration get cycleDuration;

  /// Whether the loop runs.
  bool get isEnabled;

  /// Whether [AnimationController.repeat] reverses at each cycle boundary.
  bool get reverseOnRepeat;

  /// Builds the running animation wrapping the widget's child.
  Widget buildActive(BuildContext context);

  /// Builds the static child shown when [isEnabled] is false.
  Widget buildInactive(BuildContext context);

  /// Hook run once after [controller] is created (before the first repeat).
  void onInit() {}

  /// Hook for reconciling subclass-owned state (e.g. tween bounds) after a
  /// widget update. The base already handles duration and enabled changes.
  void onDidUpdateWidget(covariant T oldWidget) {}

  @override
  void initState() {
    super.initState();
    // [cycleDuration] resolves against the theme, so it cannot be read here
    // (Theme.of is unavailable in initState). The controller starts without a
    // duration; [didChangeDependencies] — which runs before the first build —
    // installs the resolved duration and kicks off the loop.
    controller = AnimationController(vsync: this);
    _lastEnabled = isEnabled;
    onInit();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Duration resolved = cycleDuration;
    if (_lastDuration != resolved) {
      controller.duration = resolved;
      _lastDuration = resolved;
    }
    if (isEnabled && !controller.isAnimating) {
      controller.repeat(reverse: reverseOnRepeat);
    }
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_lastEnabled != isEnabled) {
      if (isEnabled) {
        controller.repeat(reverse: reverseOnRepeat);
      } else {
        controller.stop();
      }
      _lastEnabled = isEnabled;
    }
    if (_lastDuration != cycleDuration) {
      controller.duration = cycleDuration;
      _lastDuration = cycleDuration;
    }
    onDidUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isEnabled ? buildActive(context) : buildInactive(context);
  }
}

class _StarryPulsingWidgetState
    extends _LoopingAnimationState<StarryPulsingWidget> {
  late Animation<double> _animation;

  @override
  Duration get cycleDuration =>
      widget.duration ??
      Theme.of(context).extension<StarryTokens>()!.motion.durationSlower;

  @override
  bool get isEnabled => widget.enabled;

  @override
  bool get reverseOnRepeat => true;

  Animation<double> _buildTween() => Tween<double>(
    begin: widget.minOpacity,
    end: widget.maxOpacity,
  ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

  @override
  void onInit() => _animation = _buildTween();

  @override
  void onDidUpdateWidget(covariant StarryPulsingWidget oldWidget) {
    if (widget.minOpacity != oldWidget.minOpacity ||
        widget.maxOpacity != oldWidget.maxOpacity) {
      _animation = _buildTween();
    }
  }

  @override
  Widget buildInactive(BuildContext context) =>
      Opacity(opacity: widget.maxOpacity, child: widget.child);

  @override
  Widget buildActive(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(opacity: _animation.value, child: child);
      },
      child: widget.child,
    );
  }
}

/// Rotating looping animation.
///
/// Continuous rotation, commonly used for loading spinners.
///
/// Example:
/// ```dart
/// StarryRotatingWidget(
///   child: Icon(Icons.refresh),
/// )
/// ```
class StarryRotatingWidget extends StatefulWidget {
  const StarryRotatingWidget({
    required this.child,
    super.key,
    this.duration,
    this.enabled = true,
    this.clockwise = true,
  });

  /// Animated child.
  final Widget child;

  /// Duration of one full turn. Defaults to `motion.durationSlower` (1200ms)
  /// when null.
  final Duration? duration;

  /// Whether the animation runs.
  final bool enabled;

  /// Whether rotation is clockwise.
  final bool clockwise;

  @override
  State<StarryRotatingWidget> createState() => _StarryRotatingWidgetState();
}

class _StarryRotatingWidgetState
    extends _LoopingAnimationState<StarryRotatingWidget> {
  @override
  Duration get cycleDuration =>
      widget.duration ??
      Theme.of(context).extension<StarryTokens>()!.motion.durationSlower;

  @override
  bool get isEnabled => widget.enabled;

  @override
  bool get reverseOnRepeat => false;

  @override
  Widget buildInactive(BuildContext context) => widget.child;

  @override
  Widget buildActive(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final angle = widget.clockwise
            ? controller.value * 2 * math.pi
            : -controller.value * 2 * math.pi;
        return Transform.rotate(angle: angle, child: child);
      },
      child: widget.child,
    );
  }
}

/// Scaling (breathing) looping animation.
///
/// Continuous scale in/out, commonly used for heartbeat / breathing effects.
///
/// Example:
/// ```dart
/// StarryScalingWidget(
///   child: Icon(Icons.favorite),
/// )
/// ```
class StarryScalingWidget extends StatefulWidget {
  const StarryScalingWidget({
    required this.child,
    super.key,
    this.minScale = 0.9,
    this.maxScale = 1.0,
    this.duration,
    this.enabled = true,
  });

  /// Animated child.
  final Widget child;

  /// Minimum scale factor.
  final double minScale;

  /// Maximum scale factor.
  final double maxScale;

  /// Animation cycle duration. Defaults to `motion.durationSlow` (800ms) when
  /// null.
  final Duration? duration;

  /// Whether the animation runs.
  final bool enabled;

  @override
  State<StarryScalingWidget> createState() => _StarryScalingWidgetState();
}

class _StarryScalingWidgetState
    extends _LoopingAnimationState<StarryScalingWidget> {
  late Animation<double> _animation;

  @override
  Duration get cycleDuration =>
      widget.duration ??
      Theme.of(context).extension<StarryTokens>()!.motion.durationSlow;

  @override
  bool get isEnabled => widget.enabled;

  @override
  bool get reverseOnRepeat => true;

  Animation<double> _buildTween() => Tween<double>(
    begin: widget.minScale,
    end: widget.maxScale,
  ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

  @override
  void onInit() => _animation = _buildTween();

  @override
  void onDidUpdateWidget(covariant StarryScalingWidget oldWidget) {
    if (widget.minScale != oldWidget.minScale ||
        widget.maxScale != oldWidget.maxScale) {
      _animation = _buildTween();
    }
  }

  @override
  Widget buildInactive(BuildContext context) => widget.child;

  @override
  Widget buildActive(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(scale: _animation.value, child: child);
      },
      child: widget.child,
    );
  }
}

/// Breathing status dot.
///
/// A thin, token-driven composition of [StarryScalingWidget] (scale breathing)
/// and [StarryPulsingWidget] (opacity breathing) rendering a brand-colored
/// circle. The dot diameter comes from `indicator.dotMd`; the default
/// scale/opacity ranges reproduce the legacy `BreathingDot` (scale 0.7→1.1,
/// opacity 0.5→1.0) but are exposed as parameters. An optional [glow] (default
/// off) layers a token-derived halo — the `elevation.level2` shadow geometry
/// recolored to `semantic.brand` — so nothing is hardcoded.
class StarryBreathingDot extends StatelessWidget {
  const StarryBreathingDot({
    super.key,
    this.size,
    this.color,
    this.minScale = 0.7,
    this.maxScale = 1.1,
    this.minOpacity = 0.5,
    this.maxOpacity = 1.0,
    this.scaleDuration,
    this.opacityDuration,
    this.glow = false,
    this.enabled = true,
  });

  /// Dot diameter. Defaults to `indicator.dotMd` (12) when null.
  final double? size;

  /// Dot color. Defaults to `semantic.brand` when null.
  final Color? color;

  /// Minimum / maximum scale factor of the breathing cycle.
  final double minScale;
  final double maxScale;

  /// Minimum / maximum opacity of the breathing cycle.
  final double minOpacity;
  final double maxOpacity;

  /// Duration of the scale / opacity cycles. Default to `motion.durationSlow`
  /// (800ms) / `motion.durationSlower` (1200ms) when null.
  final Duration? scaleDuration;
  final Duration? opacityDuration;

  /// When true, layers a brand-colored glow halo behind the dot. Defaults to
  /// false.
  final bool glow;

  /// Whether the breathing animation runs. When false the dot renders
  /// statically at [maxScale] / [maxOpacity].
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final double diameter = size ?? t.indicator.dotMd;
    final Color dotColor = color ?? t.semantic.brand;
    final Duration resolvedScale = scaleDuration ?? t.motion.durationSlow;
    final Duration resolvedOpacity = opacityDuration ?? t.motion.durationSlower;

    // Glow: reuse the token elevation.level2 geometry (blur/spread/offset) but
    // recolor every layer to the brand color so the halo stays token-derived.
    final List<BoxShadow>? shadows = glow
        ? <BoxShadow>[
            for (final BoxShadow s in t.elevation.level2)
              BoxShadow(
                color: dotColor,
                blurRadius: s.blurRadius,
                spreadRadius: s.spreadRadius,
                offset: s.offset,
              ),
          ]
        : null;

    final Widget dot = Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: dotColor,
        shape: BoxShape.circle,
        boxShadow: shadows,
      ),
    );

    return StarryPulsingWidget(
      minOpacity: minOpacity,
      maxOpacity: maxOpacity,
      duration: resolvedOpacity,
      enabled: enabled,
      child: StarryScalingWidget(
        minScale: minScale,
        maxScale: maxScale,
        duration: resolvedScale,
        enabled: enabled,
        child: dot,
      ),
    );
  }
}
