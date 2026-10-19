import 'package:flutter/widgets.dart';

/// Immutable entry model shared by the anchored overlay and bottom-sheet
/// action surfaces.
///
/// The model carries no business semantics: callers supply the id, label,
/// optional keywords for filtering, a leading icon [WidgetBuilder], selection
/// and disabled state, an optional group title, and — when the item opens a
/// second-level list — [children]. Tapping an item without [children] and
/// [onActivate] null renders it as a non-activating row.
@immutable
class StarryActionItem {
  const StarryActionItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.keywords = const [],
    this.leadingBuilder,
    this.selected = false,
    this.disabled = false,
    this.group,
    this.children,
    this.onActivate,
    this.matchSubtitleInFilter = true,
  });

  /// Stable identifier used by the surface to match items across rebuilds.
  final String id;

  /// Primary label, always required.
  final String title;

  /// Optional secondary line.
  final String? subtitle;

  /// Extra search terms matched by the list filter, case-insensitive.
  final List<String> keywords;

  /// Builds the leading icon widget. The package does not pin an icon font;
  /// callers decide which glyph to show.
  final WidgetBuilder? leadingBuilder;

  /// Whether the item is currently selected; rendered as a check/selected
  /// affordance and exposed in semantics.
  final bool selected;

  /// Disabled rows are dimmed and ignore activation and keyboard focus.
  final bool disabled;

  /// Optional group title. Items with the same non-null [group] are collected
  /// under one non-activating header, in first-appearance order. Items with a
  /// null group render in an ungrouped section at the top.
  final String? group;

  /// When non-empty, tapping the item opens these as a same-panel sub-page
  /// instead of invoking [onActivate].
  final List<StarryActionItem>? children;

  /// Invoked when the item is activated. Ignored while [disabled].
  final VoidCallback? onActivate;

  /// When false, [matchesFilter] ignores [subtitle] (used by slash-command
  /// tokens, where filtering must hit the command id/title/keywords, not a
  /// descriptive sentence that happens to contain the fragment).
  final bool matchSubtitleInFilter;

  /// True when the item opens a sub-page rather than acting immediately.
  bool get hasChildren => children != null && children!.isNotEmpty;

  StarryActionItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    List<String>? keywords,
    WidgetBuilder? leadingBuilder,
    bool? selected,
    bool? disabled,
    String? group,
    List<StarryActionItem>? children,
    VoidCallback? onActivate,
    bool? matchSubtitleInFilter,
  }) {
    return StarryActionItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      keywords: keywords ?? this.keywords,
      leadingBuilder: leadingBuilder ?? this.leadingBuilder,
      selected: selected ?? this.selected,
      disabled: disabled ?? this.disabled,
      group: group ?? this.group,
      children: children ?? this.children,
      onActivate: onActivate ?? this.onActivate,
      matchSubtitleInFilter:
          matchSubtitleInFilter ?? this.matchSubtitleInFilter,
    );
  }

  /// Case-insensitive hit test over title, subtitle and keywords used by the
  /// list filter. An empty query matches every item.
  bool matchesFilter(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;
    if (title.toLowerCase().contains(needle)) return true;
    if (matchSubtitleInFilter) {
      final hay = subtitle?.toLowerCase();
      if (hay != null && hay.contains(needle)) return true;
    }
    for (final keyword in keywords) {
      if (keyword.toLowerCase().contains(needle)) return true;
    }
    return false;
  }
}

/// One rendered section of an action list. [title] is null for the
/// ungrouped section; such a section renders without a header.
@immutable
class StarryActionGroup {
  const StarryActionGroup({required this.title, required this.items});

  /// Group header text, or null when the items are ungrouped.
  final String? title;

  /// Activable rows inside this group.
  final List<StarryActionItem> items;
}

/// Groups [items] in first-appearance order: ungrouped items first (title
/// null), then each non-null [StarryActionItem.group] section. Empty groups
/// are dropped, so filtering can yield no section at all.
List<StarryActionGroup> groupStarryActionItems(List<StarryActionItem> items) {
  final ungrouped = <StarryActionItem>[];
  final order = <String>[];
  final buckets = <String, List<StarryActionItem>>{};
  for (final item in items) {
    final group = item.group;
    if (group == null) {
      ungrouped.add(item);
      continue;
    }
    (buckets[group] ??= <StarryActionItem>[]).add(item);
    if (!order.contains(group)) order.add(group);
  }
  final groups = <StarryActionGroup>[
    if (ungrouped.isNotEmpty) StarryActionGroup(title: null, items: ungrouped),
  ];
  for (final title in order) {
    final bucket = buckets[title]!;
    if (bucket.isNotEmpty) {
      groups.add(StarryActionGroup(title: title, items: bucket));
    }
  }
  return groups;
}

/// Returns [items] filtered by [query] (see [StarryActionItem.matchesFilter])
/// and re-grouped with [groupStarryActionItems], dropping groups left empty by
/// the filter.
List<StarryActionGroup> filterAndGroupStarryActionItems(
  List<StarryActionItem> items,
  String query,
) {
  final filtered = items.where((item) => item.matchesFilter(query)).toList();
  return groupStarryActionItems(filtered);
}
