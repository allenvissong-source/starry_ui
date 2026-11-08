import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';
import 'starry_surface.dart';

/// Shared focus, ink and semantics for the inline disclosure family.
class StarryDisclosureTrigger extends StatefulWidget {
  const StarryDisclosureTrigger({
    required this.child,
    required this.expanded,
    required this.onTap,
    required this.radius,
    this.enabled = true,
    this.focusNode,
    this.onKeyEvent,
    this.value,
    this.color,
    this.elevated = true,
    super.key,
  });

  final Widget child;
  final bool expanded;
  final bool enabled;
  final VoidCallback onTap;
  final BorderRadius radius;
  final FocusNode? focusNode;
  final KeyEventResult Function(FocusNode, KeyEvent)? onKeyEvent;
  final String? value;
  final Color? color;
  final bool elevated;

  @override
  State<StarryDisclosureTrigger> createState() =>
      _StarryDisclosureTriggerState();
}

class _StarryDisclosureTriggerState extends State<StarryDisclosureTrigger> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    return Semantics(
      button: true,
      enabled: widget.enabled,
      expanded: widget.expanded,
      value: widget.value,
      onTap: widget.enabled ? widget.onTap : null,
      child: Focus(
        canRequestFocus: false,
        onKeyEvent: widget.onKeyEvent,
        child: StarrySurface(
          color: widget.color,
          borderRadius: widget.radius,
          elevated: widget.elevated,
          child: DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              borderRadius: widget.radius,
              border: _focused
                  ? Border.all(
                      color: t.semantic.brandStrong,
                      width: t.controlMetrics.focusBorderWidth,
                    )
                  : null,
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: widget.radius,
                focusNode: widget.focusNode,
                canRequestFocus: widget.enabled,
                onFocusChange: (focused) => setState(() => _focused = focused),
                onTap: widget.enabled ? widget.onTap : null,
                excludeFromSemantics: true,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
