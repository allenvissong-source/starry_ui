import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/starry_tokens.dart';

/// A destination rendered by [StarrySideNavigationRail].
///
/// The rail owns presentation only. [id] is an opaque identity returned to the
/// host when the item is activated; routing and application state stay outside
/// the design system.
@immutable
class StarrySideNavigationItem {
  const StarrySideNavigationItem({
    required this.id,
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.enabled = true,
  });

  /// Stable identity used for selection matching and activation callbacks.
  final String id;

  /// Visible and semantic label.
  final String label;

  /// Monochrome artwork for the resting state.
  ///
  /// The rail constrains and tints this widget. Material icons, image icons,
  /// raster assets, and SVG widgets are all supported.
  final Widget icon;

  /// Optional artwork used while this destination is selected.
  final Widget? selectedIcon;

  /// Whether the destination can receive focus and activation.
  final bool enabled;
}

/// A narrow, icon-over-label navigation rail for top-level destinations.
///
/// Visual geometry, color, focus, and motion are entirely token-driven. The
/// component deliberately owns no routing, localization, or feature visibility
/// logic; hosts provide the visible items and selected identity.
class StarrySideNavigationRail extends StatelessWidget {
  const StarrySideNavigationRail({
    required this.items,
    required this.selectedId,
    required this.onItemSelected,
    super.key,
    this.collapsed = false,
    this.header,
    this.footer,
  });

  final List<StarrySideNavigationItem> items;
  final String? selectedId;
  final ValueChanged<String> onItemSelected;
  final bool collapsed;
  final Widget? header;
  final Widget? footer;

  static double widthFor(StarryTokens t) =>
      t.controlMetrics.heightLg + t.spacing.s6;

  static double itemExtentFor(StarryTokens t) => widthFor(t);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final duration = reduceMotion ? Duration.zero : t.motion.durationShort;

    return AnimatedContainer(
      width: collapsed ? t.spacing.s0 : widthFor(t),
      duration: duration,
      curve: t.motion.easingStandard,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: t.semantic.surface,
        border: Border(
          right: BorderSide(
            color: t.semantic.border,
            width: t.controlMetrics.borderThin,
          ),
        ),
      ),
      child: collapsed
          ? const SizedBox.shrink()
          : Column(
              children: [
                ?header,
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: t.spacing.s2),
                    itemCount: items.length,
                    itemExtent: itemExtentFor(t),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _StarrySideNavigationButton(
                        item: item,
                        selected: item.id == selectedId,
                        onTap: () => onItemSelected(item.id),
                      );
                    },
                  ),
                ),
                if (footer != null) ...[
                  Divider(
                    height: t.controlMetrics.borderThin,
                    thickness: t.controlMetrics.borderThin,
                    color: t.semantic.border,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: t.spacing.s2),
                    child: footer!,
                  ),
                ],
              ],
            ),
    );
  }
}

class _StarrySideNavigationButton extends StatefulWidget {
  const _StarrySideNavigationButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final StarrySideNavigationItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_StarrySideNavigationButton> createState() =>
      _StarrySideNavigationButtonState();
}

class _StarrySideNavigationButtonState
    extends State<_StarrySideNavigationButton> {
  bool _pressed = false;
  bool _showFocus = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  void _activate() {
    if (!widget.item.enabled) return;
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final duration = reduceMotion ? Duration.zero : t.motion.durationShort;
    final color = !widget.item.enabled
        ? t.semantic.textDisabled
        : widget.selected
        ? t.semantic.brand
        : t.semantic.textSecondary;
    final icon = widget.selected
        ? widget.item.selectedIcon ?? widget.item.icon
        : widget.item.icon;

    return FocusableActionDetector(
      enabled: widget.item.enabled,
      mouseCursor: widget.item.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            _activate();
            return null;
          },
        ),
      },
      onShowFocusHighlight: (value) {
        if (_showFocus == value) return;
        setState(() => _showFocus = value);
      },
      child: Semantics(
        button: true,
        enabled: widget.item.enabled,
        selected: widget.selected,
        label: widget.item.label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: widget.item.enabled ? (_) => _setPressed(true) : null,
          onTapUp: widget.item.enabled ? (_) => _setPressed(false) : null,
          onTapCancel: widget.item.enabled ? () => _setPressed(false) : null,
          onTap: widget.item.enabled ? _activate : null,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: t.spacing.s2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _showFocus ? t.semantic.brand : Colors.transparent,
                      width: t.controlMetrics.focusBorderWidth,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(t.spacing.s1),
                    child: AnimatedScale(
                      key: ValueKey<String>('${widget.item.id}-icon-scale'),
                      scale: _pressed ? t.motion.pressedScale : 1,
                      duration: duration,
                      curve: t.motion.easingStandard,
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                        child: SizedBox.square(
                          dimension: t.controlMetrics.iconXl,
                          child: FittedBox(fit: BoxFit.contain, child: icon),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: t.spacing.s1),
                Text(
                  widget.item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.typography.labelSmall.textStyle.copyWith(
                    decoration: TextDecoration.none,
                    color: color,
                    fontWeight: widget.selected
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
