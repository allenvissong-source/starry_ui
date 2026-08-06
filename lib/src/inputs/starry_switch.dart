import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';
import '../components/starry_control_shell.dart';

/// Finite size tiers for [StarrySwitch].
///
/// The tiers are token-derived (see [_StarrySwitchState._scaleFor]) rather than
/// arbitrary width/height so the switch stays on the control-metrics scale.
enum StarrySwitchSize {
  /// Default size, aligned with the current control height (`heightLg`).
  standard,

  /// Denser size, aligned with the `heightSm` control-metric semantic.
  compact,
}

/// Starry UI switch. On-state uses the brand track, off-state a neutral
/// outline; disabled dims via the platform's default opacity. Thumb color
/// uses the on-brand token so it stays legible on the brand track.
///
/// Keyboard: the underlying Material [Switch] keeps its native Space/Enter
/// toggle. When the switch holds focus a unified focus ring is drawn around it
/// using [StarryControlShell.activeBorderSide] (a [BorderSide] whose width is
/// constant and whose color toggles to `semantic.brand`), so focusing never
/// shifts layout.
class StarrySwitch extends StatefulWidget {
  const StarrySwitch({
    required this.value,
    super.key,
    this.onChanged,
    this.label,
    this.size = StarrySwitchSize.standard,
    this.focusNode,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;

  /// Size tier. Defaults to [StarrySwitchSize.standard].
  final StarrySwitchSize size;

  /// Optional external focus node. When null an internal node is used. The node
  /// is attached to the underlying [Switch] so native keyboard toggling stays
  /// available.
  final FocusNode? focusNode;

  @override
  State<StarrySwitch> createState() => _StarrySwitchState();
}

class _StarrySwitchState extends State<StarrySwitch> {
  FocusNode? _internalNode;
  bool _focused = false;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_internalNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(StarrySwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _internalNode)?.removeListener(_handleFocusChange);
      _focusNode.addListener(_handleFocusChange);
      _handleFocusChange();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _internalNode?.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    final focused = _focusNode.hasFocus;
    if (focused != _focused) {
      setState(() => _focused = focused);
    }
  }

  /// Scale factor for the size tier, expressed as a ratio of control-metric
  /// tokens so no arbitrary dimension is introduced. `standard` renders at the
  /// switch's native size; `compact` shrinks it by the `heightSm / heightLg`
  /// ratio.
  double _scaleFor(StarryTokens t) {
    switch (widget.size) {
      case StarrySwitchSize.standard:
        return 1.0;
      case StarrySwitchSize.compact:
        return t.controlMetrics.heightSm / t.controlMetrics.heightLg;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;
    final control = Switch(
      value: widget.value,
      onChanged: widget.onChanged,
      focusNode: _focusNode,
      activeThumbColor: s.onBrand,
      activeTrackColor: s.brand,
      inactiveThumbColor: s.onBrand,
      inactiveTrackColor: s.textDisabled,
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => widget.value ? s.brand : s.border,
      ),
    );

    // Unified focus ring: a stadium border whose width is constant and whose
    // color toggles to `semantic.brand` when focused, so it never shifts
    // layout. A token gap (`spacing.s1`) keeps the ring outside the track.
    final ringed = Container(
      padding: EdgeInsets.all(t.spacing.s1),
      decoration: ShapeDecoration(
        shape: StadiumBorder(
          side: StarryControlShell.activeBorderSide(
            context,
            isActive: _focused,
          ),
        ),
      ),
      child: control,
    );

    final scale = _scaleFor(t);
    final sized = scale == 1.0
        ? ringed
        : Transform.scale(scale: scale, child: ringed);

    if (widget.label == null) return sized;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        sized,
        SizedBox(width: t.spacing.s2),
        Text(
          widget.label!,
          style: t.typography.bodyMedium.textStyle.copyWith(
            color: s.textPrimary,
          ),
        ),
      ],
    );
  }
}
