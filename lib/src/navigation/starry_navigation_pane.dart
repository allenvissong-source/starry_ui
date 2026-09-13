import 'package:flutter/material.dart';

import '../layout/starry_settings_tile.dart';
import '../theme/starry_tokens.dart';

/// A single entry inside a [StarryNavigationPane].
@immutable
class StarryNavigationItem {
  const StarryNavigationItem({
    required this.id,
    required this.label,
    required this.icon,
    this.enabled = true,
    this.trailing,
  });

  /// Stable identity used for selection matching.
  final String id;

  /// Visible label.
  final String label;

  /// Leading glyph.
  final IconData icon;

  /// Whether the entry can be selected. Disabled entries stay visible but are
  /// dimmed and exposed as disabled in the semantics tree.
  final bool enabled;

  /// Optional trailing affordance (badge, counter, …).
  final Widget? trailing;
}

/// A titled group of [StarryNavigationItem]s.
@immutable
class StarryNavigationSection {
  const StarryNavigationSection({required this.items, this.title});

  /// Optional group heading.
  final String? title;

  /// Entries in display order.
  final List<StarryNavigationItem> items;
}

/// A vertical navigation pane for master/detail surfaces.
///
/// Rows reuse [StarrySettingsTile] with the chevron suppressed: in a
/// master/detail layout the selected state — not a "go to a new page" chevron —
/// is the correct affordance. The pane owns no navigation or business logic; it
/// reports the tapped [StarryNavigationItem.id] and renders whichever
/// [selectedId] the host passes back.
class StarryNavigationPane extends StatelessWidget {
  const StarryNavigationPane({
    required this.sections,
    required this.selectedId,
    required this.onItemSelected,
    super.key,
    this.header,
    this.footer,
  });

  /// Grouped entries in display order.
  final List<StarryNavigationSection> sections;

  /// Currently active entry id, or null when nothing is selected.
  final String? selectedId;

  /// Invoked with the tapped entry id. Disabled entries never fire.
  final ValueChanged<String> onItemSelected;

  /// Optional content pinned above the groups (avatar block, title, …).
  final Widget? header;

  /// Optional content appended after the groups.
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;

    final children = <Widget>[];
    if (header != null) children.add(header!);

    for (final section in sections) {
      if (section.title != null) {
        children.add(
          Padding(
            // A pane group label is not a page-level section header: it must
            // read as a quiet caption above its items, not compete with them.
            // `StarrySectionHeader` is fixed at labelLarge (same size as the
            // item labels) and reserves a full row of height, which erases the
            // hierarchy and costs ~40px per group in a 256pt rail.
            padding: EdgeInsets.fromLTRB(
              t.spacing.s4,
              t.spacing.s3,
              t.spacing.s4,
              t.spacing.s1,
            ),
            child: Text(
              section.title!,
              style: t.typography.bodySmall.textStyle.copyWith(
                color: t.semantic.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }
      for (final item in section.items) {
        children.add(
          Padding(
            // Horizontal inset only: the row already reserves `minTouchTarget`
            // vertically, so extra vertical padding would inflate the pane
            // without enlarging the hit area.
            padding: EdgeInsets.symmetric(horizontal: t.spacing.s2),
            child: StarrySettingsTile(
              title: item.label,
              leading: Icon(item.icon),
              trailing: item.trailing,
              enabled: item.enabled,
              selected: item.enabled && item.id == selectedId,
              dense: true,
              showChevron: false,
              // `heightMd`, not `minTouchTarget`: this pane is desktop-only
              // (pointer input), where the 48pt finger-touch floor buys
              // nothing and costs 4pt per row across a long list. Rows remain
              // gapless, so the hit areas still tile continuously.
              minHeight: t.controlMetrics.heightMd,
              // One step lighter than the settings-list default: a dozen
              // medium-weight labels stacked in a narrow rail read as noise.
              // Selection still steps up a weight, so the active row stands
              // out more, not less.
              titleWeight: FontWeight.w400,
              onTap: item.enabled ? () => onItemSelected(item.id) : null,
            ),
          ),
        );
      }
    }

    if (footer != null) children.add(footer!);

    return Material(
      color: t.semantic.surface,
      child: ListView(
        padding: EdgeInsets.symmetric(vertical: t.spacing.s2),
        children: children,
      ),
    );
  }
}
