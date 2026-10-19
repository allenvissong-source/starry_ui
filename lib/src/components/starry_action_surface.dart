import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/starry_responsive.dart';
import '../theme/starry_tokens.dart';
import 'starry_action_item.dart';
import 'starry_action_list.dart';

/// Preferred resting width of an action surface. Component-local geometry
/// (not a design token); clamped to the viewport with safe margins.
const double kStarryActionSurfaceWidth = 320;

/// Unified entry for the chat action surfaces: one item list renders as an
/// anchored floating panel on medium-and-up layouts and as a bottom sheet on
/// compact layouts, with second-level lists opened as same-panel sub-pages.
///
/// Business data, routing and item semantics stay with the caller; this entry
/// only decides form, positioning, sub-page stack and focus handling.
class StarryActionSurface {
  const StarryActionSurface._();

  // One anchored panel per OverlayState: opening a new panel dismisses only
  // the entry registered for THIS overlay, so other overlays/windows are
  // never cancelled by a panel they did not host.
  static final Map<OverlayState, OverlayEntry> _anchoredByOverlay = {};

  static void _dismissInOverlay(OverlayState overlay) {
    final entry = _anchoredByOverlay.remove(overlay);
    if (entry != null && entry.mounted) {
      entry.remove();
    }
  }

  /// Opens the surface. [anchorRect] is the trigger rect in global
  /// coordinates; it is only used by the anchored form. [onItemSelected]
  /// fires for leaf activations and the surface closes afterwards.
  ///
  /// When [externalFilterQuery] is provided, the root list filters itself
  /// against this listenable (the caller's text field IS the filter input,
  /// e.g. the chat composer). The built-in root filter field is hidden in
  /// that mode; sub-pages remain searchable internally.
  static Future<void> show({
    required BuildContext context,
    required List<StarryActionItem> items,
    required Rect anchorRect,
    required ValueChanged<StarryActionItem> onItemSelected,
    String? title,

    /// Optional root-level primary actions, shown horizontally above the list.
    List<StarryActionItem> primaryActions = const [],

    /// Shows the root filter; sub-pages always remain searchable.
    bool showFilter = true,

    /// External filter query listenable. When non-null, the root list filters
    /// items by this text (case-insensitive: command id, title, subtitle and
    /// keywords) and the built-in root filter field is suppressed.
    ValueListenable<String>? externalFilterQuery,

    /// Optional external keyboard driver wired to the root list in
    /// external-filter mode (the caller keeps focus and drives navigation).
    /// Ignored by the internal autofocus/Plus path.
    StarryActionListController? externalController,

    /// Optional root item id the panel opens directly at (its children render
    /// as a sub-page with back navigation). Unknown id or an item without
    /// children falls back to the root list.
    String? initialSectionId,

    /// Localized filter-field placeholder; the generic English fallback is
    /// used when null. The component never hardcodes the caller's language.
    String? filterPlaceholder,

    /// Localized empty-state label; the generic English fallback is used when
    /// null.
    String? emptyLabel,
  }) async {
    final previousFocus = FocusManager.instance.primaryFocus;
    final sizeClass = context.starryWindowSizeClass;
    Future<void> restoreFocus() async {
      // Wait a frame so the list's autofocus has been released by the time we
      // give focus back.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        previousFocus?.requestFocus();
      });
    }

    if (sizeClass == StarryWindowSizeClass.compact) {
      final tokens = Theme.of(context).extension<StarryTokens>()!;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        enableDrag: true,
        backgroundColor: tokens.semantic.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(tokens.radius.lg),
          ),
        ),
        builder: (sheetContext) {
          return SafeArea(
            top: false,
            child: _StarryActionPanel(
              items: items,
              title: title,
              primaryActions: primaryActions,
              showFilter: showFilter,
              externalFilterQuery: externalFilterQuery,
              externalController: externalController,
              initialSectionId: initialSectionId,
              filterPlaceholder: filterPlaceholder,
              emptyLabel: emptyLabel,
              onItemSelected: (item) {
                Navigator.of(sheetContext).pop();
                onItemSelected(item);
              },
              onClose: () => Navigator.of(sheetContext).pop(),
            ),
          );
        },
      );
      await restoreFocus();
    } else {
      final overlay = Overlay.of(context);
      final closed = Completer<void>();
      late final OverlayEntry entry;
      void close() {
        final mine = identical(_anchoredByOverlay[overlay], entry);
        if (!mine) {
          // Stale handle: a newer panel owns this overlay. Finish only this own
          // awaiter so the caller does not hang; never remove the newer entry.
          if (!closed.isCompleted) closed.complete();
          return;
        }
        _anchoredByOverlay.remove(overlay);
        if (entry.mounted) entry.remove();
        if (!closed.isCompleted) closed.complete();
      }

      // Dismiss only the panel hosted by THIS overlay; other overlays/windows
      // keep their own surface open.
      _dismissInOverlay(overlay);

      // [anchorRect] arrives in global screen coordinates (public contract). The
      // anchored panel is positioned inside this overlay's own coordinate space
      // (Positioned.local), so convert the global rect to overlay-local via the
      // overlay RenderBox before placing it. A missing/unlaid-out overlay box
      // cannot yield a legal local rect: fail closed with a stable error rather
      // than feeding the global rect into local coordinates or assuming an
      // origin of (0,0).
      final rawBox = overlay.context.findRenderObject();
      if (rawBox is! RenderBox || !rawBox.hasSize) {
        throw StateError('action_surface_overlay_not_laid_out');
      }
      final localAnchor = Rect.fromPoints(
        rawBox.globalToLocal(anchorRect.topLeft),
        rawBox.globalToLocal(anchorRect.bottomRight),
      );

      entry = OverlayEntry(
        builder: (overlayContext) => _AnchoredSurface(
          anchorRect: localAnchor,
          onClose: close,
          panel: _StarryActionPanel(
            items: items,
            title: title,
            primaryActions: primaryActions,
            showFilter: showFilter,
            externalFilterQuery: externalFilterQuery,
            externalController: externalController,
            initialSectionId: initialSectionId,
            filterPlaceholder: filterPlaceholder,
            emptyLabel: emptyLabel,
            onItemSelected: (item) {
              close();
              onItemSelected(item);
            },
            onClose: close,
          ),
        ),
      );
      overlay.insert(entry);
      _anchoredByOverlay[overlay] = entry;
      await closed.future;
      await restoreFocus();
    }
  }
}

/// Shared panel body: holds the sub-page breadcrumb stack and the list.
class _StarryActionPanel extends StatefulWidget {
  const _StarryActionPanel({
    required this.items,
    required this.onItemSelected,
    required this.onClose,
    this.title,
    this.primaryActions = const [],
    this.showFilter = true,
    this.externalFilterQuery,
    this.externalController,
    this.initialSectionId,
    this.filterPlaceholder,
    this.emptyLabel,
  });

  final List<StarryActionItem> primaryActions;
  final bool showFilter;
  final List<StarryActionItem> items;
  final ValueChanged<StarryActionItem> onItemSelected;
  final VoidCallback onClose;
  final String? title;
  final ValueListenable<String>? externalFilterQuery;
  final StarryActionListController? externalController;
  final String? initialSectionId;
  final String? filterPlaceholder;
  final String? emptyLabel;

  @override
  State<_StarryActionPanel> createState() => _StarryActionPanelState();
}

class _StarryActionPanelState extends State<_StarryActionPanel> {
  late final List<List<StarryActionItem>> _stack = [widget.items];
  final List<String> _stackTitles = [];

  @override
  void initState() {
    super.initState();
    for (final item in widget.items) {
      if (item.id == widget.initialSectionId && item.hasChildren) {
        _stack.add(item.children!);
        _stackTitles.add(item.title);
        break;
      }
    }
  }

  bool get _isSubPage => _stack.length > 1;

  /// When an external filter query drives the root list, suppress the
  /// built-in root filter field (the caller's text field IS the filter).
  bool get _rootUsesExternalFilter =>
      widget.externalFilterQuery != null && !_isSubPage;

  void _handleItemSelected(StarryActionItem item) {
    if (item.hasChildren) {
      setState(() {
        _stack.add(item.children!);
        _stackTitles.add(item.title);
      });
      return;
    }
    widget.onItemSelected(item);
  }

  /// Esc / scrim / drag: leave the sub-page first, close only at root.
  void _handleClose() {
    if (_isSubPage) {
      setState(() {
        _stack.removeLast();
        _stackTitles.removeLast();
      });
      return;
    }
    widget.onClose();
  }

  /// Filters [items] by [query] case-insensitively: the command id is matched
  /// literally, while title + subtitle + keywords go through
  /// [StarryActionItem.matchesFilter]. A leading '/' (slash-command style) is
  /// stripped first; a null/empty query returns all items.
  List<StarryActionItem> _filterItems(
    List<StarryActionItem> items,
    String query,
  ) {
    var needle = query.trim();
    if (needle.startsWith('/')) needle = needle.substring(1).trim();
    if (needle.isEmpty) return items;
    final lower = needle.toLowerCase();
    return items
        .where(
          (item) =>
              item.id.toLowerCase().contains(lower) ||
              item.matchesFilter(needle),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;
    final rawItems = _stack.last;

    return Material(
      color: Colors
          .transparent, // hardcode-allow: surface fill comes from sheet/overlay container
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              t.spacing.s2,
              t.spacing.s2,
              t.spacing.s2,
              t.spacing.s1,
            ),
            child: Row(
              children: [
                if (_isSubPage)
                  IconButton(
                    tooltip: 'Back',
                    icon: Icon(Icons.arrow_back, size: t.controlMetrics.iconMd),
                    color: s.textPrimary,
                    onPressed: _handleClose,
                  )
                else
                  SizedBox(width: t.spacing.s3),
                Expanded(
                  child: Text(
                    _isSubPage ? _stackTitles.last : (widget.title ?? ''),
                    style: t.typography.titleSmall.textStyle.copyWith(
                      color: s.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    size: t.controlMetrics.iconMd,
                  ),
                  color: s.textSecondary,
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),
          if (!_isSubPage && widget.primaryActions.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(t.spacing.s3),
              child: Row(
                children: [
                  for (final item in widget.primaryActions)
                    Expanded(
                      child: Semantics(
                        button: true,
                        enabled: !item.disabled,
                        label: item.title,
                        child: InkWell(
                          onTap: item.disabled
                              ? null
                              : () => widget.onItemSelected(item),
                          borderRadius: BorderRadius.circular(t.radius.sm),
                          child: Padding(
                            padding: EdgeInsets.all(t.spacing.s2),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: t.controlMetrics.controlHeight,
                                  child: Center(
                                    child: IconTheme.merge(
                                      data: IconThemeData(
                                        size: t.controlMetrics.iconMd,
                                      ),
                                      child:
                                          item.leadingBuilder?.call(context) ??
                                          const SizedBox.shrink(),
                                    ),
                                  ),
                                ),
                                Text(
                                  item.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: t.typography.bodyMedium.textStyle
                                      .copyWith(
                                        color: item.disabled
                                            ? s.textDisabled
                                            : s.textPrimary,
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
            ),
          Flexible(
            child: _rootUsesExternalFilter
                ? ValueListenableBuilder<String>(
                    valueListenable: widget.externalFilterQuery!,
                    builder: (context, query, _) {
                      final filtered = _filterItems(rawItems, query);
                      return StarryActionList(
                        showFilter: false,
                        autofocus: false,
                        controller: widget.externalController,
                        items: filtered,
                        emptyLabel: widget.emptyLabel,
                        onItemSelected: _handleItemSelected,
                        onClose: _handleClose,
                      );
                    },
                  )
                : StarryActionList(
                    showFilter: _isSubPage || widget.showFilter,
                    items: rawItems,
                    filterPlaceholder: widget.filterPlaceholder,
                    emptyLabel: widget.emptyLabel,
                    onItemSelected: _handleItemSelected,
                    onClose: _handleClose,
                  ),
          ),
        ],
      ),
    );
  }
}

/// Anchored overlay for medium-and-up layouts: click-catcher + positioned
/// panel that flips above the trigger when the lower space is tighter.
class _AnchoredSurface extends StatelessWidget {
  const _AnchoredSurface({
    required this.anchorRect,
    required this.panel,
    required this.onClose,
  });

  final Rect anchorRect;
  final Widget panel;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = constraints.biggest;
        final gap = t.spacing.s2;
        final availableBelow = viewport.height - anchorRect.bottom - gap;
        final availableAbove = anchorRect.top - gap;
        final placeBelow = availableBelow >= availableAbove;

        final panelWidth = math.min(
          kStarryActionSurfaceWidth,
          viewport.width - t.spacing.s4 * 2,
        );
        final horizontalMargin = t.spacing.s3;
        // Align the panel's left edge with the trigger and clamp it inside the
        // viewport margins so it never overflows the right edge; centering on
        // a right-edge button pushed the panel off-screen.
        final left = anchorRect.left
            .clamp(
              horizontalMargin,
              math.max(
                horizontalMargin,
                viewport.width - horizontalMargin - panelWidth,
              ),
            )
            .toDouble();
        final maxHeight = (placeBelow ? availableBelow : availableAbove)
            .clamp(t.controlMetrics.controlHeight, viewport.height * 0.7)
            .toDouble();

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: onClose,
                behavior: HitTestBehavior.opaque,
              ),
            ),
            Positioned(
              top: placeBelow ? anchorRect.bottom + gap : null,
              bottom: placeBelow
                  ? null
                  : viewport.height - anchorRect.top + gap,
              left: left,
              width: panelWidth,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxHeight),
                child: Container(
                  decoration: BoxDecoration(
                    color: s.surface,
                    borderRadius: BorderRadius.circular(t.radius.lg),
                    border: Border.all(
                      color: s.border,
                      width: t.controlMetrics.restBorderWidth,
                    ),
                    boxShadow: t.elevation.level2,
                  ),
                  child: panel,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
