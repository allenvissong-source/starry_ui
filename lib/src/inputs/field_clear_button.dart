import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';
import 'input_shell.dart';

/// Shared trailing "clear" (×) affordance for editable inputs.
///
/// [StarryTextField] and [StarrySearchInput] rendered a byte-identical clear
/// IconButton — same `minTouchTarget`-wide / `interiorHeight`-tall tap box,
/// `shrinkWrap` tap target (so it can't inflate the height-pinned shell past
/// `controlHeight`, AGENTS.md §1.5.2), `iconMd` glyph in `textTertiary`, and
/// `Icons.clear`. This widget is that single source of truth. It is an
/// implementation detail of `lib/src/inputs/` and is intentionally NOT exported
/// from the public barrel.
///
/// The two hosts only differ in the tooltip and in how far the button is nudged
/// toward the shell's rounded end when it is the rightmost affordance, so both
/// are caller-supplied: [tooltip] and [translateX]. When [translateX] is zero
/// no `Transform` is inserted, keeping the non-nudged path identical to a bare
/// button.
class StarryFieldClearButton extends StatelessWidget {
  const StarryFieldClearButton({
    super.key,
    required this.onPressed,
    required this.tooltip,
    this.translateX = 0,
  });

  /// Invoked when the affordance is tapped.
  final VoidCallback onPressed;

  /// Accessibility tooltip (hosts differ: an app-supplied string vs the
  /// platform `deleteButtonTooltip`).
  final String tooltip;

  /// Horizontal shift applied to the whole button (glyph + ink ripple together)
  /// when it is the rightmost affordance and must reach the shell's shared end
  /// inset / rounded end. Zero inserts no `Transform`.
  final double translateX;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;
    final button = IconButton(
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      // Width keeps a comfortable horizontal tap zone (minTouchTarget); height
      // is capped to the shell interior (controlHeight − 2·border) so a 48-tall
      // child never inflates the height-pinned shell past controlHeight
      // (AGENTS.md §1.5.2「可视高 ≠ 布局高」).
      constraints: BoxConstraints.tightFor(
        width: t.controlMetrics.minTouchTarget,
        height: StarryInputShell.interiorHeight(t),
      ),
      // The default IconButton tap target is `padded`, which adds 48×48 hit
      // padding *outside* `constraints` and would force the shell past
      // controlHeight. `shrinkWrap` makes the layout box honor `constraints`.
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      iconSize: t.controlMetrics.iconMd,
      color: s.textTertiary,
      icon: const Icon(Icons.clear),
      onPressed: onPressed,
    );
    if (translateX == 0) return button;
    return Transform.translate(offset: Offset(translateX, 0), child: button);
  }
}
