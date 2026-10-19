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
/// (the hidden/compact band); when expanded it renders the product's narrow
/// icon-over-label rail whose width is [widthFor].
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

  /// Expanded rail width. This is a product chrome dimension rather than a
  /// composition of spacing tokens: changing a spacing step must not silently
  /// triple the width of the primary navigation.
  static const double expandedWidth = 72;

  static double widthFor(StarryTokens tokens) => expandedWidth;

  @override
  Widget build(BuildContext context) {
    if (collapsed) return const SizedBox.shrink();
    final t = Theme.of(context).extension<StarryTokens>()!;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SizedBox(
        width: widthFor(t),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: ListView(
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
            ),
            if (footer case final footer?)
              Padding(
                key: const Key('starry-side-navigation-footer'),
                padding: EdgeInsets.only(
                  bottom: t.spacing.s4,
                  left: t.spacing.s2,
                  right: t.spacing.s2,
                ),
                child: footer,
              ),
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
      child: SizedBox(
        height: tokens.controlMetrics.heightXl + tokens.spacing.s4,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.spacing.s2,
            vertical: tokens.spacing.s1,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: tokens.controlMetrics.iconLg,
                height: tokens.controlMetrics.iconLg,
                child: item.icon,
              ),
              SizedBox(height: tokens.spacing.s1),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: tokens.typography.labelSmall.textStyle.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
