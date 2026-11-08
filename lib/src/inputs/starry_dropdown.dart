import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../components/disclosure_trigger.dart';
import '../components/starry_surface.dart';
import '../theme/starry_tokens.dart';

/// Half-turn rotation applied to the dropdown chevron between the collapsed and
/// expanded states (0 → 0.5 turns = 180°).
const double _kChevronFlipTurns = 0.5;

/// Deflates every corner of [outer] by [borderWidth], giving the radius of the
/// surface's *inner* edge (`inner = outer − borderWidth`, the concentric-radius
/// rule). A full-bleed child clipped to this path stays inside the 1px border
/// stroke instead of painting over it at the rounded corners.
BorderRadius _innerBorderRadius(BorderRadius outer, double borderWidth) {
  Radius deflate(Radius radius) => Radius.elliptical(
    math.max(0.0, radius.x - borderWidth),
    math.max(0.0, radius.y - borderWidth),
  );
  return BorderRadius.only(
    topLeft: deflate(outer.topLeft),
    topRight: deflate(outer.topRight),
    bottomLeft: deflate(outer.bottomLeft),
    bottomRight: deflate(outer.bottomRight),
  );
}

/// A single selectable option for [StarryDropdown].
///
/// [value] is the payload handed back through [StarryDropdown.onSelected];
/// [label] is what shows in both the collapsed trigger (when selected) and the
/// expanded option row. An optional leading [icon] renders before the label.
class StarryDropdownItem<T> {
  const StarryDropdownItem({
    required this.value,
    required this.label,
    this.icon,
    this.enabled = true,
  });

  /// Payload returned when this option is chosen.
  final T value;

  /// Text shown in the trigger and the option row.
  final String label;

  /// Optional leading icon rendered before [label].
  final Widget? icon;
  final bool enabled;
}

/// Starry UI inline-expand dropdown selector (内联展开式 · 实底).
///
/// This is *not* a floating overlay menu: selecting a value expands a solid
/// rounded-rectangle option panel *inline* directly below the trigger, pushing
/// following content down — the same split disclosure motion as
/// [StarryExpandableCard], but the body is a list of selectable rows.
///
///   * the trigger is a fixed-height (`controlMetrics.controlHeight` = 48) pill
///     row whose corner radius uses the textfield invariant
///     `max(radius.xxl, controlHeight / 2)` (= 28), so it reads exactly as tall
///     and as round as a single-line [StarryTextField];
///   * expanding detaches an option panel into its own rounded-rectangle
///     surface (`radius.xxl` = 28) below the trigger, separated by `spacing.s3`;
///   * every row is a full-width, `controlHeight`-tall [InkWell] menu item; the
///     selected row is tinted (`semantic.surfaceVariant`) with a brand check;
///   * choosing a row fills the label back into the trigger and collapses.
///
/// Colors, radius, spacing and motion all resolve from [StarryTokens]. Both the
/// trigger and the panel delegate to the shared [StarrySurface] primitive so
/// fill, border and elevation stay in lockstep with [StarryExpandableCard].
///
/// The value can be driven externally via [value] (controlled) or left to the
/// widget's own state (uncontrolled); [onSelected] always fires on a choice.
///
/// Example:
/// ```dart
/// StarryDropdown<String>(
///   hint: '请选择',
///   value: selected,
///   items: const <StarryDropdownItem<String>>[
///     StarryDropdownItem(value: 'a', label: '选项 A'),
///     StarryDropdownItem(value: 'b', label: '选项 B'),
///   ],
///   onSelected: (v) => setState(() => selected = v),
/// )
/// ```
class StarryDropdown<T> extends StatefulWidget {
  const StarryDropdown({
    required this.items,
    required this.onSelected,
    super.key,
    this.value,
    this.valueIsControlled = false,
    this.hint,
    this.initiallyExpanded = false,
    this.expanded,
    this.focusNode,
    this.onExpansionChanged,
    this.enabled = true,
    this.backgroundColor,
    this.borderRadius,
    this.animationDuration,
    this.elevated = true,
  });

  /// The selectable options.
  final List<StarryDropdownItem<T>> items;

  /// Called with the chosen option's value.
  final ValueChanged<T> onSelected;

  /// Externally controlled selected value. When non-null the trigger reflects
  /// the matching item; when null the widget tracks selection internally.
  final T? value;

  /// Makes null a controlled empty selection. The default preserves existing
  /// uncontrolled callers that omit [value]; non-null values are controlled.
  final bool valueIsControlled;

  /// Controlled expansion; toggles request [onExpansionChanged] and wait for
  /// the owner to update this value.
  final bool? expanded;

  /// Caller-owned trigger focus node.
  final FocusNode? focusNode;

  /// Placeholder shown in the trigger while nothing is selected. Defaults to
  /// `'请选择'`.
  final String? hint;

  /// Whether the option panel starts expanded.
  final bool initiallyExpanded;

  /// Called when the panel toggles open/closed.
  final ValueChanged<bool>? onExpansionChanged;

  /// Whether the dropdown accepts interaction.
  final bool enabled;

  /// Fill for both the trigger pill and the option panel. Defaults to
  /// `semantic.surface`.
  final Color? backgroundColor;

  /// Corner radius of the detached option panel. Defaults to `radius.xxl`
  /// (= 28) so it matches the trigger pill. The
  /// trigger's radius is fixed to the textfield invariant
  /// (`max(radius.xxl, controlHeight / 2)`) and is not affected by this.
  final BorderRadius? borderRadius;

  /// Expansion animation duration. Defaults to `motion.durationMedium`.
  final Duration? animationDuration;

  /// Whether to paint the surface drop shadow (`elevation.level2`).
  final bool elevated;

  @override
  State<StarryDropdown<T>> createState() => _StarryDropdownState<T>();
}

class _StarryDropdownState<T> extends State<StarryDropdown<T>>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightFactor;
  late Animation<double> _iconTurns;

  // Drives the "boundary line extension" flourish: on selection the hairlines
  // directly above and below the chosen row sweep out from their short, text-
  // aligned inset to the full panel width. 0 = resting (short), 1 = fully
  // extended. Only the two boundaries flanking the selected row follow it;
  // every other boundary stays short.
  late AnimationController _lineController;
  late Animation<double> _lineExtend;

  bool _isExpanded = false;
  T? _value;
  final _triggerFocus = FocusNode();
  final Map<T, FocusNode> _optionFocus = {};
  final _panelScroll = ScrollController();
  // A short inline list remains content-sized; longer lists get a bounded
  // viewport and lazy rows rather than pushing every option into the page.
  static const _visibleOptionCount = 6;
  T? _pendingFocusValue;
  int _selectionEpoch = 0;

  T? get _effectiveValue =>
      widget.valueIsControlled || widget.value != null ? widget.value : _value;
  FocusNode get _focusNode => widget.focusNode ?? _triggerFocus;

  void _syncOptions() {
    assert(
      widget.items.map((item) => item.value).toSet().length ==
          widget.items.length,
      'Dropdown item values must be unique.',
    );
    final values = widget.items.map((item) => item.value).toSet();
    for (final value in _optionFocus.keys.toList()) {
      if (!values.contains(value)) _optionFocus.remove(value)!.dispose();
    }
    for (final item in widget.items) {
      _optionFocus.putIfAbsent(item.value, FocusNode.new);
    }
  }

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.expanded ?? widget.initiallyExpanded;
    _value = widget.value;
    _syncOptions();

    _controller = AnimationController(
      vsync: this,
      // Default duration is bound from tokens in didChangeDependencies; an
      // explicit animationDuration (when provided) wins there too.
      duration: widget.animationDuration,
    );

    _heightFactor = _controller;
    _iconTurns = _controller.drive(
      Tween<double>(begin: 0.0, end: _kChevronFlipTurns),
    );

    _lineController = AnimationController(
      vsync: this,
      // Convention: lightweight expand / line micro-interactions use
      // `motion.durationShort`; bound in didChangeDependencies once the theme
      // is available.
    );
    _lineExtend = _lineController;

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final t = Theme.of(context).extension<StarryTokens>()!;
    // Bind the token-driven default duration once the theme is available,
    // unless the caller pinned an explicit duration.
    _controller.duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : widget.animationDuration ?? t.motion.durationMedium;
    _heightFactor = _controller.drive(
      CurveTween(curve: t.motion.easingStandard),
    );
    _iconTurns = _heightFactor.drive(
      Tween<double>(begin: 0, end: _kChevronFlipTurns),
    );
    _lineExtend = _lineController.drive(
      CurveTween(curve: t.motion.easingEmphasized),
    );
    // Respect the platform "reduce motion" setting: collapse the line-extension
    // flourish to an instant state change so the boundaries still land on their
    // extended positions without an animated sweep.
    _lineController.duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : t.motion.durationShort;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = _isExpanded ? 1 : 0;
    }
  }

  @override
  void didUpdateWidget(StarryDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final selectionInvalidated =
        (!widget.enabled && oldWidget.enabled) ||
        (widget.value != oldWidget.value && widget.value != _value) ||
        widget.expanded != oldWidget.expanded;
    // Honor an externally controlled value change.
    if (widget.value != oldWidget.value) {
      _value = widget.value;
    }
    _syncOptions();
    if (selectionInvalidated) {
      _selectionEpoch++;
      _lineController.stop();
      _lineController.reset();
    }
    final next = widget.expanded ?? _isExpanded;
    if (next != _isExpanded) {
      _isExpanded = next;
      _animate();
    }
    _controller.duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : widget.animationDuration ??
              Theme.of(
                context,
              ).extension<StarryTokens>()!.motion.durationMedium;
  }

  @override
  void dispose() {
    _lineController.dispose();
    _controller.dispose();
    _triggerFocus.dispose();
    _panelScroll.dispose();
    for (final node in _optionFocus.values) {
      node.dispose();
    }
    super.dispose();
  }

  StarryDropdownItem<T>? get _selectedItem {
    for (final item in widget.items) {
      if (item.value == _effectiveValue) return item;
    }
    return null;
  }

  /// Index of the selected option within [StarryDropdown.items], or -1 when
  /// nothing is selected. Used to locate the two boundaries flanking the
  /// selected row for the extension flourish.
  int get _selectedIndex {
    for (int i = 0; i < widget.items.length; i++) {
      if (widget.items[i].value == _effectiveValue) return i;
    }
    return -1;
  }

  void _toggle() {
    if (!widget.enabled) return;
    _requestExpanded(!_isExpanded);
  }

  void _animate() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = _isExpanded ? 1 : 0;
    } else if (_isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _requestExpanded(bool next) {
    _selectionEpoch++;
    _lineController.stop();
    _lineController.reset();
    if (widget.expanded == null) {
      setState(() => _isExpanded = next);
      _animate();
    }
    widget.onExpansionChanged?.call(next);
    if (!next) _focusNode.requestFocus();
    if (!next) _pendingFocusValue = null;
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (!widget.enabled ||
        (event is! KeyDownEvent && event is! KeyRepeatEvent)) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape && _isExpanded) {
      _requestExpanded(false);
      return KeyEventResult.handled;
    }
    final backwards = key == LogicalKeyboardKey.arrowUp;
    if (!backwards &&
        key != LogicalKeyboardKey.arrowDown &&
        key != LogicalKeyboardKey.home &&
        key != LogicalKeyboardKey.end) {
      return KeyEventResult.ignored;
    }
    final available = widget.items.where((item) => item.enabled).toList();
    if (available.isEmpty) return KeyEventResult.handled;
    if (!_isExpanded) _requestExpanded(true);
    final focused = available.indexWhere(
      (item) => _optionFocus[item.value]!.hasFocus,
    );
    int index;
    if (key == LogicalKeyboardKey.home) {
      index = 0;
    } else if (key == LogicalKeyboardKey.end) {
      index = available.length - 1;
    } else if (focused < 0) {
      final selected = available.indexWhere(
        (item) => item.value == _effectiveValue,
      );
      index = selected >= 0 ? selected : (backwards ? available.length - 1 : 0);
    } else {
      index = (focused + (backwards ? -1 : 1)) % available.length;
    }
    final target = _optionFocus[available[index].value]!;
    if (_isExpanded && target.context?.mounted == true) {
      _focusOption(available[index].value);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_isExpanded || !widget.enabled) return;
        _focusOption(available[index].value);
      });
    }
    return KeyEventResult.handled;
  }

  void _focusOption(T value) {
    final target = _optionFocus[value];
    if (target == null) return;
    if (target.context?.mounted == true) {
      _pendingFocusValue = null;
      Scrollable.ensureVisible(target.context!);
      target.requestFocus();
    } else if (_panelScroll.hasClients) {
      final index = widget.items.indexWhere((item) => item.value == value);
      if (index < 0) return;
      final t = Theme.of(context).extension<StarryTokens>()!;
      _panelScroll.jumpTo(
        (index * t.controlMetrics.controlHeight).clamp(
          0.0,
          _panelScroll.position.maxScrollExtent,
        ),
      );
      _pendingFocusValue = null;
      target.requestFocus();
    } else {
      _pendingFocusValue = value;
      target.requestFocus();
    }
  }

  void _select(StarryDropdownItem<T> item) {
    if (!widget.enabled || !item.enabled || !_isExpanded) return;
    setState(() {
      _value = item.value;
    });
    widget.onSelected(item.value);
    final epoch = ++_selectionEpoch;
    // Play the confirming flourish first — the hairlines above and below the
    // chosen row sweep out to full width — then collapse the panel once it
    // finishes, so the extension is actually seen before the panel folds away.
    if (MediaQuery.disableAnimationsOf(context)) {
      _requestExpanded(false);
    } else {
      _lineController.forward(from: 0.0).orCancel.then((_) {
        if (!mounted || epoch != _selectionEpoch || !widget.enabled) return;
        _requestExpanded(false);
      }, onError: (Object _) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;
    final selected = _selectedItem;

    // Trigger pill: same height + corner invariant as a single-line textfield.
    // The corner takes max(radius.xxl, controlHeight / 2) so it stays a full
    // pill even if controlHeight ever changes (Skia clamps corner to
    // min(radius, height / 2)).
    final double triggerRadius = math.max(
      t.radius.xxl,
      t.controlMetrics.controlHeight / 2,
    );
    final Color labelColor = widget.enabled ? s.textPrimary : s.textDisabled;
    final Widget triggerLabel = selected == null
        ? Text(
            widget.hint ?? '请选择',
            style: t.typography.bodyLarge.textStyle.copyWith(
              color: widget.enabled ? s.textTertiary : s.textDisabled,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        : Text(
            selected.label,
            style: t.typography.bodyLarge.textStyle.copyWith(color: labelColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );

    final trigger = StarryDisclosureTrigger(
      color: widget.backgroundColor,
      radius: BorderRadius.circular(triggerRadius),
      elevated: widget.elevated,
      onTap: _toggle,
      enabled: widget.enabled,
      expanded: _isExpanded,
      value: selected?.label,
      focusNode: _focusNode,
      onKeyEvent: _handleKey,
      child: SizedBox(
        height: t.controlMetrics.controlHeight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: t.spacing.s5),
          child: Row(
            children: <Widget>[
              if (selected?.icon != null) ...<Widget>[
                IconTheme.merge(
                  data: IconThemeData(
                    size: t.controlMetrics.iconMd,
                    color: labelColor,
                  ),
                  child: selected!.icon!,
                ),
                SizedBox(width: t.spacing.s3),
              ],
              Expanded(child: triggerLabel),
              SizedBox(width: t.spacing.s3),
              RotationTransition(
                turns: _iconTurns,
                child: Icon(
                  Icons.expand_more,
                  size: t.controlMetrics.iconMd,
                  color: widget.enabled ? s.textTertiary : s.textDisabled,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Detached option panel: its own rounded-rectangle surface below the
    // trigger, revealed by the height-factor animation and cross-faded in. The
    // panel carries no padding of its own, so its height is exactly the option
    // rows plus their inter-row hairlines (N * controlHeight + (N-1) * 1px) with
    // no top/bottom slivers; each row spans the full width and carries its own
    // horizontal padding aligned with the trigger. The option list is clipped to
    // the concentric inner radius (outer − border width): a selected row's tint
    // is painted as a child above the surface decoration, so clipping it at the
    // outer path would let it cover the 1px border at the first/last row's
    // rounded corners.
    // Option rows are built only while the panel is not fully collapsed
    // (`_controller.value > 0`): a closed selector is just its trigger, and the
    // rows survive the collapse animation before dropping out of the tree.
    final BorderRadius panelBorderRadius =
        widget.borderRadius ?? BorderRadius.circular(t.radius.xxl);
    final BorderRadius panelInnerRadius = _innerBorderRadius(
      panelBorderRadius,
      t.controlMetrics.borderThin,
    );
    final panel = AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[_controller, _lineController]),
      builder: (context, _) {
        final double factor = _heightFactor.value;
        final bool open = _controller.value > 0;
        final Widget revealed = Align(
          alignment: Alignment.topCenter,
          heightFactor: factor,
          child: Opacity(
            opacity: factor,
            child: Padding(
              padding: EdgeInsets.only(top: t.spacing.s3),
              child: StarrySurface(
                color: widget.backgroundColor,
                borderRadius: panelBorderRadius,
                elevated: widget.elevated,
                child: ClipRRect(
                  borderRadius: panelInnerRadius,
                  child: IgnorePointer(
                    ignoring: !_isExpanded || !widget.enabled,
                    child: ExcludeFocus(
                      excluding: !_isExpanded || !widget.enabled,
                      child: ExcludeSemantics(
                        excluding: !_isExpanded,
                        child: Focus(
                          canRequestFocus: false,
                          onKeyEvent: _handleKey,
                          child: _buildPanelBody(open, t, s),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        // Clip the Align reveal overflow only while the panel is mid-animation;
        // once fully open (factor == 1) there is nothing to clip, so drop the
        // ClipRect and let the panel's rounded drop shadow render beyond its
        // box instead of being sliced into square corners at the bottom.
        return ClipRect(
          clipBehavior: factor < 1 ? Clip.hardEdge : Clip.none,
          child: revealed,
        );
      },
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[trigger, panel],
    );
  }

  /// Lazy, height-bounded rows with separators painted over the row seams.
  /// The boundaries flanking the selection extend during confirmation;
  /// separators do not consume layout height or pointer events.
  Widget _buildPanelBody(bool open, StarryTokens t, StarrySemanticColors s) {
    if (!open) {
      return const SizedBox.shrink();
    }

    final double rowHeight = t.controlMetrics.controlHeight;
    final double lineThickness = t.controlMetrics.borderThin;
    // Apple aligns a separator's LEFT end with the row's text origin (past the
    // leading indicator) and stops it a standard margin short of the right
    // wall, so at rest it reads as a short rule. Left inset = content pad (s5)
    // + indicator (iconMd) + gap (s3); right inset = content pad (s5).
    final double leadInset =
        t.spacing.s5 + t.controlMetrics.iconMd + t.spacing.s3;
    final double trailInset = t.spacing.s5;
    final int sel = _selectedIndex;
    final double extend = _lineExtend.value;

    if (_pendingFocusValue != null) {
      final value = _pendingFocusValue as T;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _isExpanded && widget.enabled) _focusOption(value);
      });
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: rowHeight * _visibleOptionCount),
      child: ListView.builder(
        controller: _panelScroll,
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemExtent: rowHeight,
        itemCount: widget.items.length,
        itemBuilder: (context, i) {
          final boundary = i + 1;
          final active = sel >= 0 && (boundary == sel || boundary == sel + 1);
          final p = active ? extend : 0.0;
          return Stack(
            fit: StackFit.expand,
            children: [
              _buildOption(
                widget.items[i],
                widget.items[i].value == _effectiveValue,
                t,
                s,
              ),
              if (boundary < widget.items.length)
                Positioned(
                  bottom: 0,
                  left: leadInset * (1 - p),
                  right: trailInset * (1 - p),
                  height: lineThickness,
                  child: IgnorePointer(child: ColoredBox(color: s.border)),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOption(
    StarryDropdownItem<T> item,
    bool isSelected,
    StarryTokens t,
    StarrySemanticColors s,
  ) {
    // Persistent single-select indicator: a leading radio that self-declares
    // "pick exactly one" even at rest (nothing selected, no hover). This is the
    // core cue distinguishing the dropdown from a free-content disclosure card
    // like StarryExpandableCard — the ring is always painted, not only on
    // interaction. Hollow `semantic.border` ring when unpicked; a solid
    // brand-filled disc when picked (no inner check glyph — the filled disc is
    // the whole "selected" signal).
    final double indicatorSize = t.controlMetrics.iconMd;
    final Widget indicator = Container(
      width: indicatorSize,
      height: indicatorSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? s.brand : Colors.transparent,
        border: Border.all(
          color: isSelected ? s.brand : s.border,
          width: t.controlMetrics.borderThin,
        ),
      ),
    );

    // Apple's grouped-list model: the interactive fill (selected background,
    // hover tint, tap ripple) is FULL-BLEED — it reaches both panel walls — so
    // its corners meet the panel edge with nothing bare beside them and the
    // inset hairline riding over the seam (drawn by [_buildPanelBody]) can never
    // open a step. Rows are laid out flush, each exactly [controlHeight] tall.
    final active = widget.enabled && item.enabled;
    final Widget content = Material(
      type: MaterialType.transparency,
      child: InkWell(
        focusNode: _optionFocus[item.value],
        canRequestFocus: active,
        onTap: active ? () => _select(item) : null,
        onFocusChange: (_) => setState(() {}),
        excludeFromSemantics: true,
        child: Container(
          height: t.controlMetrics.controlHeight,
          color: isSelected ? s.surfaceVariant : null,
          foregroundDecoration: _optionFocus[item.value]!.hasFocus
              ? BoxDecoration(
                  border: Border.all(
                    color: s.brandStrong,
                    width: t.controlMetrics.focusBorderWidth,
                  ),
                )
              : null,
          padding: EdgeInsets.symmetric(horizontal: t.spacing.s5),
          child: Row(
            children: <Widget>[
              indicator,
              SizedBox(width: t.spacing.s3),
              if (item.icon != null) ...<Widget>[
                IconTheme.merge(
                  data: IconThemeData(
                    size: t.controlMetrics.iconMd,
                    color: active ? s.textSecondary : s.textDisabled,
                  ),
                  child: item.icon!,
                ),
                SizedBox(width: t.spacing.s3),
              ],
              Expanded(
                child: Text(
                  item.label,
                  style: t.typography.bodyLarge.textStyle.copyWith(
                    color: active ? s.textPrimary : s.textDisabled,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      selected: isSelected,
      enabled: active,
      inMutuallyExclusiveGroup: true,
      onTap: active ? () => _select(item) : null,
      child: content,
    );
  }
}
