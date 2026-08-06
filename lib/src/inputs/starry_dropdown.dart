import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../components/starry_surface.dart';
import '../theme/starry_tokens.dart';

/// Half-turn rotation applied to the dropdown chevron between the collapsed and
/// expanded states (0 → 0.5 turns = 180°).
const double _kChevronFlipTurns = 0.5;

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
  });

  /// Payload returned when this option is chosen.
  final T value;

  /// Text shown in the trigger and the option row.
  final String label;

  /// Optional leading icon rendered before [label].
  final Widget? icon;
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
    this.hint,
    this.initiallyExpanded = false,
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

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _value = widget.value;

    _controller = AnimationController(
      vsync: this,
      // Default duration is bound from tokens in didChangeDependencies; an
      // explicit animationDuration (when provided) wins there too.
      duration: widget.animationDuration,
    );

    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeInOut));
    _iconTurns = _controller.drive(
      Tween<double>(
        begin: 0.0,
        end: _kChevronFlipTurns,
      ).chain(CurveTween(curve: Curves.easeInOut)),
    );

    _lineController = AnimationController(
      vsync: this,
      // Convention: lightweight expand / line micro-interactions use
      // `motion.durationShort`; bound in didChangeDependencies once the theme
      // is available.
    );
    _lineExtend = _lineController.drive(CurveTween(curve: Curves.easeOutCubic));

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
    if (widget.animationDuration == null) {
      _controller.duration = t.motion.durationMedium;
    }
    // Respect the platform "reduce motion" setting: collapse the line-extension
    // flourish to an instant state change so the boundaries still land on their
    // extended positions without an animated sweep.
    _lineController.duration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : t.motion.durationShort;
  }

  @override
  void didUpdateWidget(StarryDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Honor an externally controlled value change.
    if (widget.value != oldWidget.value) {
      _value = widget.value;
    }
  }

  @override
  void dispose() {
    _lineController.dispose();
    _controller.dispose();
    super.dispose();
  }

  StarryDropdownItem<T>? get _selectedItem {
    for (final item in widget.items) {
      if (item.value == _value) return item;
    }
    return null;
  }

  /// Index of the selected option within [StarryDropdown.items], or -1 when
  /// nothing is selected. Used to locate the two boundaries flanking the
  /// selected row for the extension flourish.
  int get _selectedIndex {
    for (int i = 0; i < widget.items.length; i++) {
      if (widget.items[i].value == _value) return i;
    }
    return -1;
  }

  void _toggle() {
    if (!widget.enabled) return;
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      widget.onExpansionChanged?.call(_isExpanded);
    });
  }

  void _select(StarryDropdownItem<T> item) {
    setState(() {
      _value = item.value;
    });
    widget.onSelected(item.value);
    // Play the confirming flourish first — the hairlines above and below the
    // chosen row sweep out to full width — then collapse the panel once it
    // finishes, so the extension is actually seen before the panel folds away.
    _lineController.forward(from: 0.0).whenComplete(() {
      if (!mounted) return;
      setState(() {
        _isExpanded = false;
        _controller.reverse();
        widget.onExpansionChanged?.call(false);
      });
    });
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

    final trigger = StarrySurface(
      color: widget.backgroundColor,
      borderRadius: BorderRadius.circular(triggerRadius),
      elevated: widget.elevated,
      onTap: widget.enabled ? _toggle : null,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: t.controlMetrics.controlHeight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: t.spacing.s5),
          child: Row(
            children: <Widget>[
              if (selected?.icon != null) ...<Widget>[
                selected!.icon!,
                SizedBox(width: t.spacing.s3),
              ],
              Expanded(child: triggerLabel),
              SizedBox(width: t.spacing.s3),
              RotationTransition(
                turns: _iconTurns,
                child: Icon(
                  Icons.expand_more,
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
    // horizontal padding aligned with the trigger. Clipped to the panel radius
    // so the first/last rows' tint and ink follow the rounded corners.
    // Option rows are built only while the panel is not fully collapsed
    // (`_controller.value > 0`): a closed selector is just its trigger, and the
    // rows survive the collapse animation before dropping out of the tree.
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
                borderRadius:
                    widget.borderRadius ?? BorderRadius.circular(t.radius.xxl),
                elevated: widget.elevated,
                clipBehavior: Clip.antiAlias,
                child: _buildPanelBody(open, t, s),
              ),
            ),
          ),
        );
        // Clip the Align reveal overflow only while the panel is mid-animation;
        // once fully open (factor == 1) there is nothing to clip, so drop the
        // ClipRect and let the panel's rounded drop shadow render beyond its
        // box instead of being sliced into square corners at the bottom.
        return factor < 1.0 ? ClipRect(child: revealed) : revealed;
      },
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[trigger, panel],
    );
  }

  /// Builds the option list plus its inter-row hairline overlay.
  ///
  /// Rows are laid out flush in a [Column] — each exactly [controlHeight] tall,
  /// so N rows measure exactly N * controlHeight with no filler bands — and the
  /// N-1 separators live in a sibling overlay [Stack] layer so they cost zero
  /// layout height and can each be addressed by index. Boundary `b` (1..N-1)
  /// rides the seam between row b-1 and row b at `y = b * controlHeight`. The
  /// two boundaries flanking the selected row (its top `b == sel` and its
  /// bottom `b == sel + 1`) extend toward the full panel width as the flourish
  /// runs 0 -> 1; every other boundary keeps the short, text-aligned inset.
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

    final List<Widget> lines = <Widget>[];
    for (int b = 1; b < widget.items.length; b++) {
      final bool active = sel >= 0 && (b == sel || b == sel + 1);
      final double p = active ? extend : 0.0;
      lines.add(
        Positioned(
          top: b * rowHeight - lineThickness,
          left: leadInset * (1 - p),
          right: trailInset * (1 - p),
          height: lineThickness,
          child: ColoredBox(color: s.border),
        ),
      );
    }

    return Stack(
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (int i = 0; i < widget.items.length; i++)
              _buildOption(
                widget.items[i],
                widget.items[i].value == _value,
                t,
                s,
              ),
          ],
        ),
        ...lines,
      ],
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
    final Widget content = Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => _select(item),
        child: Container(
          height: t.controlMetrics.controlHeight,
          color: isSelected ? s.surfaceVariant : null,
          padding: EdgeInsets.symmetric(horizontal: t.spacing.s5),
          child: Row(
            children: <Widget>[
              indicator,
              SizedBox(width: t.spacing.s3),
              if (item.icon != null) ...<Widget>[
                item.icon!,
                SizedBox(width: t.spacing.s3),
              ],
              Expanded(
                child: Text(
                  item.label,
                  style: t.typography.bodyLarge.textStyle.copyWith(
                    color: isSelected ? s.brand : s.textPrimary,
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

    return content;
  }
}
