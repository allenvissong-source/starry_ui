import 'package:flutter/material.dart';

import '../components/starry_control_shell.dart';
import '../interactions/starry_state_layer.dart';
import '../layout/starry_glass_panel.dart';
import '../theme/starry_tokens.dart';

/// A single tab entry for [StarryDockBar].
///
/// Either supply an [icon]/[activeIcon] pair (Material glyphs) or a
/// [customIcon]/[activeCustomIcon] pair (arbitrary widgets, e.g. asset icons).
@immutable
class StarryNavItem {
  const StarryNavItem({
    required this.label,
    this.icon,
    this.activeIcon,
    this.customIcon,
    this.activeCustomIcon,
  });

  final String label;
  final IconData? icon;
  final IconData? activeIcon;
  final Widget? customIcon;
  final Widget? activeCustomIcon;
}

/// The floating dock navigation bar.
///
/// Migrated from the app's former `AppDockBar`. Interaction state is expressed
/// through the MD3 state-layer mechanism ([StarryStateLayer]) rather than a
/// state x property matrix:
///
/// * rest icon     -> `semantic.textSecondary` (≈ onSurfaceVariant, MD3)
/// * focus icon    -> `semantic.textSecondary` + focus state layer (0.10) +
///   focus ring drawn from [StarryFocusMetrics] (MD3)
/// * selected icon -> `semantic.brand` (Starry brand deviation, NOT MD3)
///
/// The frosted-glass container reuses [StarryGlassPanel]. Sizes come from the
/// control-metric tokens (`heightLg` = 48) and spacing tokens (`s3` = 12).
///
/// An optional [leading] widget (e.g. a [StarryRoundActionButton]) renders
/// before the pill, separated by `spacing.s3`.
class StarryDockBar extends StatelessWidget {
  const StarryDockBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    super.key,
    this.leading,
  });

  final List<StarryNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Optional leading affordance rendered before the tab pill.
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final h = t.controlMetrics.heightLg;
    final iconSize = t.controlMetrics.iconMd;
    final radius = BorderRadius.circular(h / 2);

    return SizedBox(
      height: h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          if (leading != null) ...<Widget>[
            leading!,
            SizedBox(width: t.spacing.s3),
          ],
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                boxShadow: t.elevation.glass,
              ),
              child: StarryGlassPanel(
                borderRadius: h / 2,
                padding: EdgeInsets.zero,
                child: SizedBox(
                  height: h,
                  child: Row(
                    children: <Widget>[
                      for (int i = 0; i < items.length; i++)
                        Expanded(
                          child: _DockTabButton(
                            item: items[i],
                            isSelected: i == currentIndex,
                            iconSize: iconSize,
                            onTap: () => onTap(i),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DockTabButton extends StatefulWidget {
  const _DockTabButton({
    required this.item,
    required this.isSelected,
    required this.iconSize,
    required this.onTap,
  });

  final StarryNavItem item;
  final bool isSelected;
  final double iconSize;
  final VoidCallback onTap;

  @override
  State<_DockTabButton> createState() => _DockTabButtonState();
}

class _DockTabButtonState extends State<_DockTabButton> {
  bool _pressed = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final radius = BorderRadius.circular(t.controlMetrics.heightLg / 2);

    // Selected controls tint with brand (Starry brand deviation); neutral
    // controls use the secondary text color (MD3 onSurfaceVariant analogue).
    final baseColor =
        widget.isSelected ? t.semantic.brand : t.semantic.textSecondary;

    return Padding(
      padding: EdgeInsets.all(t.spacing.s1),
      child: SizedBox.expand(
        child: Semantics(
          button: true,
          selected: widget.isSelected,
          label: widget.item.label,
          child: StarryControlShell.pressable(
            context: context,
            isPressed: _pressed,
            child: FocusableActionDetector(
              mouseCursor: SystemMouseCursors.click,
              onShowFocusHighlight: (value) =>
                  setState(() => _focused = value),
              child: DecoratedBox(
                // Focus ring stacked under the state layer so the affordance
                // stays visible on the frosted-glass backdrop.
                decoration: BoxDecoration(
                  borderRadius: radius,
                  border: Border.all(
                    color: _focused
                        ? t.semantic.brand
                        : Colors.transparent,
                    width: t.controlMetrics.focusBorderWidth,
                  ),
                  boxShadow: _focused
                      ? <BoxShadow>[
                          BoxShadow(
                            color: t.semantic.brand
                                .withValues(alpha: t.focus.glowAlpha),
                            blurRadius: t.focus.glowBlurRadius,
                            spreadRadius: t.focus.glowSpreadRadius,
                            offset: t.focus.glowOffset,
                          ),
                        ]
                      : null,
                ),
                child: Material(
                  type: MaterialType.transparency,
                  borderRadius: radius,
                  child: InkWell(
                    onTap: widget.onTap,
                    onHighlightChanged: (value) =>
                        setState(() => _pressed = value),
                    borderRadius: radius,
                    // MD3 state layer fed to the Material overlay (avoids the
                    // double-overlay pitfall of a manual layer + InkWell).
                    overlayColor: StarryStateLayer.overlayColor(
                      t,
                      base: baseColor,
                      selected: widget.isSelected,
                    ),
                    child: Center(
                      child: _buildTabContent(context, t, baseColor),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(
    BuildContext context,
    StarryTokens t,
    Color color,
  ) {
    final item = widget.item;
    final isSelected = widget.isSelected;
    final iconSize = widget.iconSize;

    Widget? iconWidget;
    if (item.customIcon != null) {
      final icon = isSelected
          ? (item.activeCustomIcon ?? item.customIcon!)
          : item.customIcon!;
      iconWidget = IconTheme(
        data: IconThemeData(color: color, size: iconSize),
        child: SizedBox(width: iconSize, height: iconSize, child: icon),
      );
    } else if (item.icon != null) {
      iconWidget = Icon(
        isSelected ? (item.activeIcon ?? item.icon!) : item.icon!,
        size: iconSize,
        color: color,
      );
    }

    if (iconWidget == null) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        iconWidget,
        SizedBox(height: t.spacing.s0 + 2),
        Text(
          item.label,
          style: t.typography.labelSmall.textStyle.copyWith(
            color: color,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            height: 1.1,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
