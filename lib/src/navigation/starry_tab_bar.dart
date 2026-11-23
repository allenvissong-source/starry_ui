import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/starry_tokens.dart';

/// The visual skin of [StarryTabBar]. Both variants share selection, keyboard,
/// focus and semantics; only the painted affordance differs.
enum StarryTabBarVariant {
  /// Independent pills, one per tab. Suited to filter rows and section tabs.
  pill,

  /// Text tabs with a bottom indicator. Suited to page-level tab strips that
  /// sit directly above content.
  underline,
}

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
    this.variant = StarryTabBarVariant.pill,
    super.key,
  });

  final List<StarryTab<T>> tabs;
  final T value;
  final ValueChanged<T>? onChanged;
  final StarryTabBarVariant variant;

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
    final underline = widget.variant == StarryTabBarVariant.underline;
    if (tab.icon != null) {
      width +=
          (underline ? t.controlMetrics.iconSm : t.controlMetrics.iconMd) +
          t.spacing.s2;
    }
    if (tab.count != null) {
      final count = TextPainter(
        text: TextSpan(
          text: '${tab.count}',
          style: t.typography.labelSmall.textStyle,
        ),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      width +=
          count.width +
          (underline ? t.spacing.s1 : t.spacing.s2) * 2 +
          (underline ? t.spacing.s1 : t.spacing.s2);
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
        if (widget.variant == StarryTabBarVariant.pill &&
            constraints.hasBoundedWidth &&
            total <= constraints.maxWidth) {
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
          spacing: widget.variant == StarryTabBarVariant.pill
              ? t.spacing.s2
              : t.spacing.s0,
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
    final focused = _nodes[tab.value]!.hasFocus;
    final fg = !enabled
        ? t.semantic.textDisabled
        : selected
        ? t.semantic.textPrimary
        : t.semantic.textSecondary;
    final content = _tabContent(tab, t, fg, selected: selected);
    final body = widget.variant == StarryTabBarVariant.pill
        ? _pillTab(
            tab,
            t,
            selected: selected,
            enabled: enabled,
            focused: focused,
            content: content,
          )
        : _underlineTab(
            tab,
            t,
            selected: selected,
            enabled: enabled,
            focused: focused,
            content: content,
          );
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
          child: body,
        ),
      ),
    );
  }

  Widget _pillTab(
    StarryTab<T> tab,
    StarryTokens t, {
    required bool selected,
    required bool enabled,
    required bool focused,
    required Widget content,
  }) {
    return Material(
      color: selected ? t.semantic.surfaceVariant : t.semantic.surface,
      shape: StadiumBorder(
        side: BorderSide(
          color: focused
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
              child: content,
            ),
          ),
        ),
      ),
    );
  }

  Widget _underlineTab(
    StarryTab<T> tab,
    StarryTokens t, {
    required bool selected,
    required bool enabled,
    required bool focused,
    required Widget content,
  }) {
    final radius = BorderRadius.circular(t.radius.xs);
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: focused ? t.semantic.brandStrong : Colors.transparent,
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
        customBorder: RoundedRectangleBorder(borderRadius: radius),
        child: ExcludeSemantics(
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  // The indicator stays reserved when unselected so switching
                  // tabs never shifts the strip by a border width.
                  color: selected ? t.semantic.brand : Colors.transparent,
                  width: t.controlMetrics.borderThick,
                ),
              ),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: t.controlMetrics.minTouchTarget,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: t.spacing.s4,
                  vertical: t.spacing.s2,
                ),
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabContent(
    StarryTab<T> tab,
    StarryTokens t,
    Color foreground, {
    required bool selected,
  }) {
    final underline = widget.variant == StarryTabBarVariant.underline;
    final badgePadding = underline ? t.spacing.s1 : t.spacing.s2;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (tab.icon != null) ...[
          Icon(
            tab.icon,
            size: underline ? t.controlMetrics.iconSm : t.controlMetrics.iconMd,
            // The underline variant carries its selected state on the icon
            // colour and the bottom indicator; the pill variant uses the fill.
            color: underline && selected ? t.semantic.brand : foreground,
          ),
          SizedBox(width: t.spacing.s2),
        ],
        Flexible(
          child: Text(
            tab.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.typography.labelLarge.textStyle.copyWith(
              color: foreground,
            ),
          ),
        ),
        if (tab.count != null) ...[
          SizedBox(width: underline ? t.spacing.s1 : t.spacing.s2),
          if (underline)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: badgePadding,
                vertical: t.controlMetrics.borderThin,
              ),
              decoration: BoxDecoration(
                color: t.semantic.surfaceVariant,
                borderRadius: BorderRadius.circular(t.radius.full),
              ),
              child: Text(
                '${tab.count}',
                style: t.typography.labelSmall.textStyle.copyWith(
                  color: selected
                      ? t.semantic.textPrimary
                      : t.semantic.textSecondary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            )
          else
            Text(
              '${tab.count}',
              style: t.typography.labelSmall.textStyle.copyWith(
                color: foreground,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
        ],
      ],
    );
  }
}
