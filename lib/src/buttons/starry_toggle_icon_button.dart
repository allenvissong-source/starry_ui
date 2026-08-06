import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// A circular toggle icon button whose *glyph and tint both swap* on select.
///
/// This is deliberately distinct from [StarryIconButton]'s `selected` flag,
/// which keeps one glyph and flips to a solid brand fill. A toggle here reads
/// as a low-emphasis tonal affordance (e.g. a bookmark): when [selected] it
/// shows [selectedIcon] on a translucent brand tint; when unselected it shows
/// [icon] on a neutral surface. The fill/tint animate on change via
/// `motion.durationMedium` / `motion.easingStandard`.
class StarryToggleIconButton extends StatelessWidget {
  const StarryToggleIconButton({
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.tooltip,
    super.key,
    this.onChanged,
    this.size = 28,
    this.enabled = true,
  });

  /// Glyph extent as a fraction of the button [size]. See the [size] doc.
  static const double _kGlyphSizeRatio = 0.58;

  /// Glyph shown in the unselected (off) state.
  final IconData icon;

  /// Glyph shown in the selected (on) state.
  final IconData selectedIcon;

  /// Current on/off state.
  final bool selected;

  /// Localized accessible label + hover/long-press tooltip.
  final String tooltip;

  /// Called with the *next* state when tapped. Null (or [enabled] false)
  /// disables the control.
  final ValueChanged<bool>? onChanged;

  /// Diameter of the circular button. The icon renders at ~58% of this.
  final double size;

  /// Whether the control is interactive.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;
    final bool interactive = enabled && onChanged != null;

    final Color background;
    final Color foreground;
    if (!interactive) {
      background = s.surfaceVariant;
      foreground = s.textDisabled;
    } else if (selected) {
      background = s.brand.withValues(alpha: t.opacity.selectedSurface);
      foreground = s.brand;
    } else {
      background = s.surfaceVariant;
      foreground = s.textTertiary;
    }

    final Widget button = AnimatedContainer(
      duration: t.motion.durationMedium,
      curve: t.motion.easingStandard,
      width: size,
      height: size,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Center(
        child: Icon(
          selected ? selectedIcon : icon,
          size: size * _kGlyphSizeRatio,
          color: foreground,
        ),
      ),
    );

    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        enabled: interactive,
        selected: selected,
        label: tooltip,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: interactive ? () => onChanged!(!selected) : null,
          child: ExcludeSemantics(child: button),
        ),
      ),
    );
  }
}
