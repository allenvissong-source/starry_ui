import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// One destination row in [StarrySideNavigationRail].
@immutable
class StarrySideNavigationItem {
  const StarrySideNavigationItem({
    required this.id,
    required this.label,
    required this.icon,
  });

  /// Stable destination id; echoed back via [StarrySideNavigationRail.onItemSelected].
  final String id;

  /// Human-readable destination label, rendered alongside the icon when expanded.
  final String label;

  /// Leading icon widget (asset image or glyph).
  final Widget icon;
}

/// Vertical side navigation rail.
///
/// The design-system component owns rail geometry and destination-row visuals;
/// the app adapter (e.g. `AppShellSideRail`) owns routing, auth, localization,
/// and feature visibility. When [collapsed] the rail collapses to zero width
/// (the hidden/compact band); when expanded it renders a fixed-width scrollable
/// list whose width is [widthFor].
class StarrySideNavigationRail extends StatelessWidget {
  const StarrySideNavigationRail({
    required this.collapsed,
    required this.items,
    required this.onItemSelected,
    super.key,
    this.selectedId,
    this.footer,
  });

  /// Hidden/compact band: the rail renders at zero width.
  final bool collapsed;

  /// Ordered root destinations.
  final List<StarrySideNavigationItem> items;

  /// Invoked with the tapped [StarrySideNavigationItem.id].
  final ValueChanged<String> onItemSelected;

  /// Id of the currently selected destination, if any.
  final String? selectedId;

  /// Optional footer rendered below the scrollable destinations (account
  /// actions, settings, theme toggle).
  final Widget? footer;

  /// Expanded rail width. Derived from the spacing/icon scale so it is identical
  /// across light/dark token instances.
  static double widthFor(StarryTokens tokens) =>
      tokens.spacing.s16 * 3 + tokens.controlMetrics.iconXl;

  @override
  Widget build(BuildContext context) {
    if (collapsed) return const SizedBox.shrink();
    final t = Theme.of(context).extension<StarryTokens>()!;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SizedBox(
        width: widthFor(t),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical: t.spacing.s2),
              children: <Widget>[
                for (final item in items)
                  _RailTile(
                    item: item,
                    selected: item.id == selectedId,
                    tokens: t,
                    onTap: () => onItemSelected(item.id),
                  ),
              ],
            ),
            ?footer,
          ],
        ),
      ),
    );
  }
}

class _RailTile extends StatelessWidget {
  const _RailTile({
    required this.item,
    required this.selected,
    required this.tokens,
    required this.onTap,
  });

  final StarrySideNavigationItem item;
  final bool selected;
  final StarryTokens tokens;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? tokens.semantic.brand
        : tokens.semantic.textSecondary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.s4,
          vertical: tokens.spacing.s3,
        ),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: tokens.controlMetrics.iconLg,
              height: tokens.controlMetrics.iconLg,
              child: IconTheme(
                data: IconThemeData(
                  color: color,
                  size: tokens.controlMetrics.iconLg,
                ),
                child: item.icon,
              ),
            ),
            SizedBox(width: tokens.spacing.s3),
            Expanded(
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tokens.typography.labelSmall.textStyle.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
