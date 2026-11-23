import 'package:flutter/material.dart';

import '../components/starry_control_shell.dart';

/// Wraps [child] in a tap-driven press-scale micro-interaction.
///
/// While the pointer is down the child settles to `motion.pressedScale` over
/// `motion.durationShort` (via [StarryControlShell.pressable]); releasing or
/// cancelling the tap returns it to full size. The scale, duration, and curve
/// are owned entirely by the motion tokens — there are no per-call overrides —
/// so every pressable surface in the app animates identically.
class StarryPressScale extends StatefulWidget {
  const StarryPressScale({required this.child, super.key, this.onTap});

  /// The content that scales on press.
  final Widget child;

  /// Invoked on a completed tap. When null the widget still animates on press
  /// but performs no action.
  final VoidCallback? onTap;

  @override
  State<StarryPressScale> createState() => _StarryPressScaleState();
}

class _StarryPressScaleState extends State<StarryPressScale> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: StarryControlShell.pressable(
        context: context,
        isPressed: _isPressed,
        child: widget.child,
      ),
    );
  }
}
