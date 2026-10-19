import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/starry_tokens.dart';
import 'starry_action_item.dart';

/// External keyboard driver for a [StarryActionList] that renders without its
/// own focus (external-filter mode, e.g. the chat composer drives navigation).
///
/// While unattached every method is a no-op, so a caller may hold one long-lived
/// and hand it to a panel for its open lifetime. Attach happens when the list
/// builds; detach on dispose releases the references so the callbacks cannot
/// outlive the panel.
class StarryActionListController {
  VoidCallback? _moveUp;
  VoidCallback? _moveDown;
  VoidCallback? _activate;
  VoidCallback? _close;

  /// True once a live list has registered its navigation callbacks.
  bool get isAttached => _activate != null;

  /// Called by the list on build; replaces any previously attached delegate.
  void attach({
    required VoidCallback moveUp,
    required VoidCallback moveDown,
    required VoidCallback activate,
    required VoidCallback close,
  }) {
    _moveUp = moveUp;
    _moveDown = moveDown;
    _activate = activate;
    _close = close;
  }

  /// Called by the list on dispose; drops every callback.
  void detach() {
    _moveUp = null;
    _moveDown = null;
    _activate = null;
    _close = null;
  }

  void moveUp() => _moveUp?.call();
  void moveDown() => _moveDown?.call();
  void activate() => _activate?.call();
  void close() => _close?.call();
}

/// A keyboard-navigable, filterable, grouped list of [StarryActionItem]s.
///
/// Shared by the anchored overlay and the bottom-sheet action surfaces:
/// - Up/down move the active row (wrapping), skipping disabled rows.
/// - Enter activates the current row; Escape invokes [onClose].
/// - Typing in the built-in filter field narrows the list by
///   `title + subtitle + keywords`; empty groups disappear.
/// - Group headers are non-activating visual separators.
///
/// The widget owns no surface chrome: callers wrap it with the surface
/// container and constrain its height.
class StarryActionList extends StatefulWidget {
  const StarryActionList({
    required this.items,
    required this.onItemSelected,
    this.onClose,
    this.showFilter = true,
    this.autofocus = true,
    this.controller,
    this.filterPlaceholder,
    this.emptyLabel,
    super.key,
  });

  /// Items rendered at the current panel level.
  final List<StarryActionItem> items;

  /// Called when a non-disabled row is activated (tap or Enter).
  final ValueChanged<StarryActionItem> onItemSelected;

  /// Called on Escape. The surface closes itself; the list never decides
  /// that on its own.
  final VoidCallback? onClose;

  /// Whether the built-in filter field is shown.
  final bool showFilter;

  /// Whether the list shell requests focus on first build.
  final bool autofocus;

  /// Optional external driver: lets a focus-holding caller (the composer) move
  /// the highlight, activate the current row and close the panel when the
  /// list itself has no focus (external-filter mode). Ignored when null, so
  /// the internal autofocus/Plus path keeps its default behavior.
  final StarryActionListController? controller;

  /// Placeholder for the built-in filter field. Callers supply localized
  /// text; when null the generic English fallback is used so the component
  /// never hardcodes a language a business assembly cannot override.
  final String? filterPlaceholder;

  /// Empty-state copy shown when no item matches the filter. Callers supply
  /// localized text; falls back to the generic English label when null.
  final String? emptyLabel;

  @override
  State<StarryActionList> createState() => _StarryActionListState();
}

class _StarryActionListState extends State<StarryActionList> {
  final _focusNode = FocusNode();
  final _filterController = TextEditingController();
  final _scrollController = ScrollController();
  final _rowKeys = <String, GlobalKey>{};
  var _query = '';
  var _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _filterController.addListener(_onFilterChanged);
    widget.controller?.attach(
      moveUp: () => _move(-1),
      moveDown: () => _move(1),
      activate: _activateCurrent,
      close: () => widget.onClose?.call(),
    );
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    widget.controller?.detach();
    _filterController
      ..removeListener(_onFilterChanged)
      ..dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onFilterChanged() {
    if (_filterController.text == _query) return;
    setState(() {
      _query = _filterController.text;
      _activeIndex = 0;
    });
  }

  List<StarryActionGroup> get _groups =>
      filterAndGroupStarryActionItems(widget.items, _query);

  /// All rows that can receive focus, in render order.
  List<StarryActionItem> get _activable {
    final result = <StarryActionItem>[];
    for (final group in _groups) {
      result.addAll(group.items.where((item) => !item.disabled));
    }
    return result;
  }

  void _move(int delta) {
    final activable = _activable;
    if (activable.isEmpty) return;
    setState(() {
      _activeIndex = (_activeIndex + delta) % activable.length;
    });
    final id = activable[_activeIndex.clamp(0, activable.length - 1)].id;
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureRowVisible(id));
  }

  void _ensureRowVisible(String id) {
    final key = _rowKeys[id];
    if (key?.currentContext == null) return;
    final t = Theme.of(context).extension<StarryTokens>()!;
    Scrollable.ensureVisible(
      key!.currentContext!,
      duration: t.motion.durationShort,
      alignment: 0.5,
    );
  }

  void _activateCurrent() {
    final activable = _activable;
    if (activable.isEmpty) return;
    final index = _activeIndex.clamp(0, activable.length - 1);
    widget.onItemSelected(activable[index]);
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    // While the IME is composing (pinyin / kana / hanja), arrow and Enter
    // belong to the candidate window; never treat them as list navigation.
    final composing = _filterController.value.isComposingRangeValid;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowDown:
        if (composing) return KeyEventResult.ignored;
        _move(1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
        if (composing) return KeyEventResult.ignored;
        _move(-1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.numpadEnter:
        if (composing) return KeyEventResult.ignored;
        _activateCurrent();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.escape:
        if (composing) return KeyEventResult.ignored;
        widget.onClose?.call();
        return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final groups = _groups;
    final activable = _activable;
    final activeId = activable.isEmpty
        ? null
        : activable[_activeIndex.clamp(0, activable.length - 1)].id;

    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      onKeyEvent: _handleKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showFilter) _buildFilterField(context, t),
          Flexible(
            child: groups.isEmpty
                ? _buildEmpty(context, t)
                : ListView(
                    controller: _scrollController,
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(vertical: t.spacing.s1),
                    children: [
                      for (final group in groups) ...[
                        if (group.title != null)
                          _buildGroupHeader(context, t, group.title!),
                        for (final item in group.items)
                          _buildRow(
                            context,
                            t,
                            item,
                            focused: item.id == activeId,
                          ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterField(BuildContext context, StarryTokens t) {
    final s = t.semantic;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        t.spacing.s3,
        t.spacing.s2,
        t.spacing.s3,
        t.spacing.s1,
      ),
      child: TextField(
        controller: _filterController,
        style: t.typography.bodyMedium.textStyle.copyWith(color: s.textPrimary),
        decoration: InputDecoration(
          isDense: true,
          constraints: BoxConstraints(minHeight: t.controlMetrics.heightMd),
          hintText: widget.filterPlaceholder ?? 'Type to filter',
          hintStyle: t.typography.bodyMedium.textStyle.copyWith(
            color: s.textTertiary,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: t.controlMetrics.iconMd,
            color: s.textTertiary,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(t.radius.sm),
            borderSide: BorderSide(
              color: s.border,
              width: t.controlMetrics.restBorderWidth,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(t.radius.sm),
            borderSide: BorderSide(
              color: s.border,
              width: t.controlMetrics.restBorderWidth,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(t.radius.sm),
            borderSide: BorderSide(
              color: s.brand,
              width: t.controlMetrics.focusBorderWidth,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, StarryTokens t) {
    final s = t.semantic;
    return Padding(
      padding: EdgeInsets.all(t.spacing.s5),
      child: Text(
        widget.emptyLabel ?? 'No matching items',
        style: t.typography.bodyMedium.textStyle.copyWith(
          color: s.textSecondary,
        ),
      ),
    );
  }

  Widget _buildGroupHeader(BuildContext context, StarryTokens t, String title) {
    final s = t.semantic;
    return Semantics(
      header: true,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          t.spacing.s4,
          t.spacing.s3,
          t.spacing.s4,
          t.spacing.s1,
        ),
        child: Text(
          title.toUpperCase(),
          style: t.typography.labelSmall.textStyle.copyWith(
            color: s.textTertiary,
            letterSpacing: t.letterSpacing.wide,
          ),
        ),
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    StarryTokens t,
    StarryActionItem item, {
    required bool focused,
  }) {
    final s = t.semantic;
    final rowKey = _rowKeys.putIfAbsent(item.id, () => GlobalKey());

    final rowContent = Row(
      children: [
        if (item.leadingBuilder != null) ...[
          IconTheme.merge(
            data: IconThemeData(
              size: t.controlMetrics.iconMd,
              color: s.textSecondary,
            ),
            child: item.leadingBuilder!(context),
          ),
          SizedBox(width: t.spacing.s3),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.typography.bodyMedium.textStyle.copyWith(
                  color: s.textPrimary,
                ),
              ),
              if (item.subtitle != null) ...[
                SizedBox(height: t.spacing.s1),
                Text(
                  item.subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.typography.bodySmall.textStyle.copyWith(
                    color: s.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(width: t.spacing.s3),
        if (item.selected)
          Icon(Icons.check, size: t.controlMetrics.iconSm, color: s.brand)
        else if (item.hasChildren)
          Icon(
            Icons.chevron_right,
            size: t.controlMetrics.iconMd,
            color: s.textTertiary,
          ),
      ],
    );

    final row = InkWell(
      key: rowKey,
      onTap: item.disabled ? null : () => widget.onItemSelected(item),
      child: Container(
        constraints: BoxConstraints(minHeight: t.controlMetrics.controlHeight),
        padding: EdgeInsets.symmetric(horizontal: t.spacing.s4),
        decoration: BoxDecoration(
          color: focused
              ? s.brand.withValues(alpha: t.opacity.selectedSurface)
              : null,
          border: focused
              ? Border.all(
                  color: s.brand,
                  width: t.controlMetrics.focusBorderWidth,
                )
              : null,
        ),
        alignment: Alignment.centerLeft,
        child: rowContent,
      ),
    );

    return Semantics(
      button: true,
      enabled: !item.disabled,
      selected: item.selected,
      label: item.title,
      child: item.disabled
          ? Opacity(opacity: t.opacity.disabledContent, child: row)
          : row,
    );
  }
}
