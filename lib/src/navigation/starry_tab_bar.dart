import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/starry_tokens.dart';

/// A stable tab identity, independent of its position or translated label.
class StarryTab<T> {
  const StarryTab({
    required this.value,
    required this.label,
    this.icon,
    this.count,
    this.enabled = true,
  }) : assert(count == null || count >= 0);

  final T value;
  final String label;
  final IconData? icon;
  final int? count;
  final bool enabled;
}

/// Controlled page tabs with a roving keyboard focus and wrapping narrow
/// layouts. Arrow keys select the next enabled tab; Home/End select the ends.
/// The owner supplies the matching content panel and persists [value].
class StarryTabBar<T> extends StatefulWidget {
  const StarryTabBar({
    required this.tabs,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final List<StarryTab<T>> tabs;
  final T value;
  final ValueChanged<T>? onChanged;

  @override
  State<StarryTabBar<T>> createState() => _StarryTabBarState<T>();
}

class _StarryTabBarState<T> extends State<StarryTabBar<T>> {
  final Map<T, FocusNode> _nodes = {};

  void _syncNodes() {
    final values = widget.tabs.map((tab) => tab.value).toSet();
    assert(values.length == widget.tabs.length, 'Tab values must be unique.');
    assert(values.contains(widget.value), 'Selected tab must exist.');
    for (final value in _nodes.keys.toList()) {
      if (!values.contains(value)) _nodes.remove(value)!.dispose();
    }
    final enabled = widget.tabs.where((tab) => tab.enabled).toList();
    final selectedEnabled = enabled.any((tab) => tab.value == widget.value);
    for (final tab in widget.tabs) {
      final node = _nodes.putIfAbsent(tab.value, FocusNode.new);
      node.canRequestFocus = tab.enabled && widget.onChanged != null;
      node.skipTraversal = selectedEnabled
          ? tab.value != widget.value
          : enabled.isEmpty || tab.value != enabled.first.value;
    }
  }

  @override
  void initState() {
    super.initState();
    _syncNodes();
  }

  @override
  void didUpdateWidget(StarryTabBar<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncNodes();
  }

  @override
  void dispose() {
    for (final node in _nodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  KeyEventResult _handleKey(T value, KeyEvent event) {
    if ((event is! KeyDownEvent && event is! KeyRepeatEvent) ||
        widget.onChanged == null) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final backwards =
        key == LogicalKeyboardKey.arrowUp ||
        key ==
            (rtl
                ? LogicalKeyboardKey.arrowRight
                : LogicalKeyboardKey.arrowLeft);
    final forwards =
        key == LogicalKeyboardKey.arrowDown ||
        key ==
            (rtl
                ? LogicalKeyboardKey.arrowLeft
                : LogicalKeyboardKey.arrowRight);
    if (!backwards &&
        !forwards &&
        key != LogicalKeyboardKey.home &&
        key != LogicalKeyboardKey.end) {
      return KeyEventResult.ignored;
    }
    final available = widget.tabs.where((tab) => tab.enabled).toList();
    if (available.isEmpty) return KeyEventResult.handled;
    final index = available.indexWhere((tab) => tab.value == value);
    final next = key == LogicalKeyboardKey.home
        ? 0
        : key == LogicalKeyboardKey.end
        ? available.length - 1
        : (index + (backwards ? -1 : 1)) % available.length;
    final tab = available[next];
    _nodes[tab.value]!.requestFocus();
    widget.onChanged!(tab.value);
    return KeyEventResult.handled;
  }

  double _width(StarryTab<T> tab, StarryTokens t) {
    final painter = TextPainter(
      text: TextSpan(text: tab.label, style: t.typography.labelLarge.textStyle),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    var width =
        painter.width +
        t.spacing.s4 * 2 +
        t.controlMetrics.focusBorderWidth * 2;
    painter.dispose();
    if (tab.icon != null) width += t.controlMetrics.iconMd + t.spacing.s2;
    if (tab.count != null) {
      final count = TextPainter(
        text: TextSpan(
          text: '${tab.count}',
          style: t.typography.labelSmall.textStyle,
        ),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      width += count.width + t.spacing.s2 * 2 + t.spacing.s2;
      count.dispose();
    }
    return width < t.controlMetrics.minTouchTarget
        ? t.controlMetrics.minTouchTarget
        : width;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final widths = widget.tabs.map((tab) => _width(tab, t)).toList();
        final total =
            widths.fold<double>(0, (sum, width) => sum + width) +
            t.spacing.s2 * (widget.tabs.length - 1);
        if (constraints.hasBoundedWidth && total <= constraints.maxWidth) {
          return Row(
            children: [
              for (var i = 0; i < widget.tabs.length; i++) ...[
                if (i > 0) SizedBox(width: t.spacing.s2),
                Expanded(child: _tab(widget.tabs[i], t)),
              ],
            ],
          );
        }
        return Wrap(
          spacing: t.spacing.s2,
          runSpacing: t.spacing.s2,
          children: [
            for (var i = 0; i < widget.tabs.length; i++)
              SizedBox(
                width:
                    constraints.hasBoundedWidth &&
                        widths[i] > constraints.maxWidth
                    ? constraints.maxWidth
                    : widths[i],
                child: _tab(widget.tabs[i], t),
              ),
          ],
        );
      },
    );
  }

  Widget _tab(StarryTab<T> tab, StarryTokens t) {
    final selected = tab.value == widget.value;
    final enabled = tab.enabled && widget.onChanged != null;
    final fg = !enabled
        ? t.semantic.textDisabled
        : selected
        ? t.semantic.textPrimary
        : t.semantic.textSecondary;
    return Focus(
      canRequestFocus: false,
      onKeyEvent: (_, event) => _handleKey(tab.value, event),
      child: Semantics(
        button: true,
        selected: selected,
        enabled: enabled,
        inMutuallyExclusiveGroup: true,
        onTap: enabled ? () => widget.onChanged!(tab.value) : null,
        label: tab.label,
        value: tab.count == null ? null : '${tab.count}',
        child: Tooltip(
          message: tab.label,
          excludeFromSemantics: true,
          child: Material(
            color: selected ? t.semantic.surfaceVariant : t.semantic.surface,
            shape: StadiumBorder(
              side: BorderSide(
                color: _nodes[tab.value]!.hasFocus
                    ? t.semantic.brandStrong
                    : selected
                    ? t.semantic.borderStrong
                    : t.semantic.border,
                width: t.controlMetrics.focusBorderWidth,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              focusNode: _nodes[tab.value],
              canRequestFocus: enabled,
              onFocusChange: (_) => setState(() {}),
              onTap: enabled ? () => widget.onChanged!(tab.value) : null,
              excludeFromSemantics: true,
              customBorder: const StadiumBorder(),
              child: ExcludeSemantics(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: t.controlMetrics.minTouchTarget,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: t.spacing.s4,
                      vertical: t.spacing.s2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (tab.icon != null) ...[
                          Icon(
                            tab.icon,
                            size: t.controlMetrics.iconMd,
                            color: fg,
                          ),
                          SizedBox(width: t.spacing.s2),
                        ],
                        Flexible(
                          child: Text(
                            tab.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.typography.labelLarge.textStyle.copyWith(
                              color: fg,
                            ),
                          ),
                        ),
                        if (tab.count != null) ...[
                          SizedBox(width: t.spacing.s2),
                          Text(
                            '${tab.count}',
                            style: t.typography.labelSmall.textStyle.copyWith(
                              color: fg,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ],
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
}
