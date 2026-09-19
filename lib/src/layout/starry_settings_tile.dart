import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';
import '../inputs/starry_switch.dart';

/// A single settings row rendered on the Starry design-system tokens.
///
/// Three intents are exposed via named constructors:
/// * [StarrySettingsTile.navigation] — a tappable row with a trailing chevron.
/// * [StarrySettingsTile.value] — a row showing a trailing value string.
/// * [StarrySettingsTile.toggle] — a row whose trailing control is a
///   [StarrySwitch].
///
/// The default constructor is the fully-flexible form (custom trailing widget,
/// explicit chevron/divider, etc.). Foreground defaults to `textTertiary`;
/// `destructive` swaps it to `semantic.error`. Selection tints the background
/// with the brand color at the `accentSurface` opacity. All spacing, radius,
/// typography, and motion come from [StarryTokens]; no `ColorScheme` lookups.
class StarrySettingsTile extends StatefulWidget {
  const StarrySettingsTile({
    required this.title,
    super.key,
    this.titleMaxLines,
    this.titleOverflow,
    this.subtitle,
    this.subtitleMaxLines,
    this.subtitleOverflow,
    this.leading,
    this.trailing,
    this.trailingText,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.selected = false,
    this.destructive = false,
    this.dense = false,
    this.showChevron = false,
    this.showDivider = false,
    this.contentPadding,
    this.backgroundColor,
    this.foregroundColor,
    this.semanticsLabel,
    this.minHeight,
    this.titleWeight,
    this.toggleValue,
    this.onToggleChanged,
  });

  const StarrySettingsTile.navigation({
    required this.title,
    super.key,
    this.titleMaxLines,
    this.titleOverflow,
    this.subtitle,
    this.subtitleMaxLines,
    this.subtitleOverflow,
    this.leading,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.selected = false,
    this.destructive = false,
    this.dense = false,
    this.showDivider = false,
    this.contentPadding,
    this.backgroundColor,
    this.foregroundColor,
    this.semanticsLabel,
    this.minHeight,
    this.showChevron = true,
  }) : trailing = null,
       trailingText = null,
       titleWeight = null,
       toggleValue = null,
       onToggleChanged = null;

  const StarrySettingsTile.value({
    required this.title,
    required this.trailingText,
    super.key,
    this.titleMaxLines,
    this.titleOverflow,
    this.subtitle,
    this.subtitleMaxLines,
    this.subtitleOverflow,
    this.leading,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.selected = false,
    this.destructive = false,
    this.dense = false,
    this.showChevron = true,
    this.showDivider = false,
    this.contentPadding,
    this.backgroundColor,
    this.foregroundColor,
    this.semanticsLabel,
    this.minHeight,
  }) : trailing = null,
       titleWeight = null,
       toggleValue = null,
       onToggleChanged = null;

  const StarrySettingsTile.toggle({
    required this.title,
    required bool value,
    required ValueChanged<bool>? onChanged,
    super.key,
    this.titleMaxLines,
    this.titleOverflow,
    this.subtitle,
    this.subtitleMaxLines,
    this.subtitleOverflow,
    this.leading,
    this.enabled = true,
    this.selected = false,
    this.destructive = false,
    this.dense = false,
    this.showDivider = false,
    this.contentPadding,
    this.backgroundColor,
    this.foregroundColor,
    this.semanticsLabel,
    this.minHeight,
  }) : trailing = null,
       trailingText = null,
       titleWeight = null,
       onTap = null,
       onLongPress = null,
       showChevron = false,
       toggleValue = value,
       onToggleChanged = onChanged;

  final String title;
  final int? titleMaxLines;
  final TextOverflow? titleOverflow;
  final String? subtitle;
  final int? subtitleMaxLines;
  final TextOverflow? subtitleOverflow;
  final Widget? leading;
  final Widget? trailing;
  final String? trailingText;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  final bool selected;
  final bool destructive;
  final bool dense;
  final bool showChevron;
  final bool showDivider;
  final EdgeInsetsGeometry? contentPadding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? semanticsLabel;
  final double? minHeight;

  /// Overrides the resting title weight. Defaults to the settings-list weight
  /// (`w500`, or `w600` when selected). Dense navigation surfaces pass a
  /// lighter weight so a long list of labels reads calmly.
  final FontWeight? titleWeight;

  final bool? toggleValue;
  final ValueChanged<bool>? onToggleChanged;

  bool get isToggle => toggleValue != null;

  @override
  State<StarrySettingsTile> createState() => _StarrySettingsTileState();
}

class _StarrySettingsTileState extends State<StarrySettingsTile> {
  bool _pressed = false;

  bool get _canToggle => widget.enabled && widget.onToggleChanged != null;

  bool get _canInteract {
    if (widget.isToggle) return _canToggle;
    return widget.enabled &&
        (widget.onTap != null || widget.onLongPress != null);
  }

  void _handleTap() {
    if (widget.isToggle) {
      if (_canToggle) {
        widget.onToggleChanged!.call(!(widget.toggleValue ?? false));
      }
      return;
    }
    if (widget.enabled) {
      widget.onTap?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;
    const disabledAlpha = 0.45;
    final baseForeground =
        widget.foregroundColor ??
        (widget.destructive ? s.error : s.textTertiary);
    final effectiveForeground = widget.enabled
        ? baseForeground
        : baseForeground.withValues(alpha: disabledAlpha);
    final secondaryForeground = widget.enabled
        ? s.textTertiary
        : s.textTertiary.withValues(alpha: disabledAlpha);
    final effectiveBackground =
        widget.backgroundColor ??
        (widget.selected
            ? s.brand.withValues(alpha: t.opacity.accentSurface)
            : Colors.transparent);
    final effectivePadding =
        widget.contentPadding ??
        EdgeInsets.symmetric(
          horizontal: t.spacing.s4,
          vertical: widget.dense ? t.spacing.s3 : t.spacing.s4,
        );
    final restingWeight = widget.titleWeight ?? FontWeight.w500;
    // Selection always reads one step heavier than rest, whatever the caller
    // chose as its resting weight, so the cue survives a lighter override.
    final selectedWeight = _oneStepHeavier(restingWeight);
    final titleStyle = t.typography.labelLarge.textStyle.copyWith(
      color: effectiveForeground,
      fontWeight: widget.selected ? selectedWeight : restingWeight,
    );
    final subtitleStyle = t.typography.bodySmall.textStyle.copyWith(
      color: secondaryForeground,
    );
    final minHeight = widget.minHeight ?? 0;
    final trailingWidget = _buildTrailing(context, t, secondaryForeground);
    final semanticsValue = widget.toggleValue ?? false;
    final radius = BorderRadius.circular(t.radius.lg);

    final row = AnimatedScale(
      scale: _pressed && _canInteract ? t.motion.pressedScale : 1,
      duration: t.motion.durationShort,
      curve: t.motion.easingStandard,
      child: AnimatedContainer(
        duration: t.motion.durationShort,
        curve: t.motion.easingStandard,
        decoration: BoxDecoration(
          color: effectiveBackground,
          borderRadius: radius,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _canInteract ? _handleTap : null,
            onLongPress: widget.isToggle || !widget.enabled
                ? null
                : widget.onLongPress,
            onHighlightChanged: (value) => setState(() => _pressed = value),
            splashFactory: NoSplash.splashFactory,
            overlayColor: const WidgetStatePropertyAll(Colors.transparent),
            borderRadius: radius,
            child: Column(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: minHeight),
                  child: Padding(
                    padding: effectivePadding,
                    child: Row(
                      crossAxisAlignment: widget.subtitle == null
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.start,
                      children: [
                        if (widget.leading != null) ...[
                          IconTheme(
                            data: IconThemeData(
                              color: secondaryForeground,
                              size: t.spacing.s5,
                            ),
                            child: widget.leading!,
                          ),
                          SizedBox(width: t.spacing.s4),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.title,
                                maxLines:
                                    widget.titleMaxLines ??
                                    (widget.subtitle == null ? 1 : 2),
                                overflow:
                                    widget.titleOverflow ??
                                    TextOverflow.ellipsis,
                                style: titleStyle,
                              ),
                              if ((widget.subtitle ?? '').isNotEmpty) ...[
                                SizedBox(height: t.spacing.s1 / 2),
                                Text(
                                  widget.subtitle!,
                                  maxLines:
                                      widget.subtitleMaxLines ??
                                      (widget.dense ? 1 : 2),
                                  overflow:
                                      widget.subtitleOverflow ??
                                      TextOverflow.ellipsis,
                                  style: subtitleStyle,
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(width: t.spacing.s3),
                        if (trailingWidget != null)
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth:
                                  (MediaQuery.sizeOf(context).width * 0.45)
                                      .clamp(160.0, 320.0),
                            ),
                            child: Align(
                              alignment: Alignment.centerRight,
                              widthFactor: 1,
                              child: trailingWidget,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (widget.showDivider)
                  Padding(
                    padding: EdgeInsets.only(
                      left: widget.leading == null
                          ? t.spacing.s4
                          : t.spacing.s16 - t.spacing.s2,
                      right: t.spacing.s4,
                    ),
                    child: Divider(height: 1, thickness: 1, color: s.border),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!widget.isToggle) {
      return Semantics(
        button: widget.onTap != null || widget.onLongPress != null,
        enabled: widget.enabled,
        selected: widget.selected,
        label: widget.semanticsLabel,
        child: row,
      );
    }

    return MergeSemantics(
      child: Semantics(
        label: widget.semanticsLabel ?? widget.title,
        enabled: _canToggle,
        toggled: semanticsValue,
        onTap: _canToggle ? _handleTap : null,
        child: ExcludeSemantics(child: row),
      ),
    );
  }

  Widget? _buildTrailing(
    BuildContext context,
    StarryTokens t,
    Color secondaryForeground,
  ) {
    if (widget.isToggle) {
      return ExcludeSemantics(
        child: IgnorePointer(
          child: StarrySwitch(
            value: widget.toggleValue ?? false,
            onChanged: _canToggle ? widget.onToggleChanged : null,
          ),
        ),
      );
    }

    final children = <Widget>[];
    if (widget.trailing != null) {
      children.add(widget.trailing!);
    } else if ((widget.trailingText ?? '').isNotEmpty) {
      children.add(
        Text(
          widget.trailingText!,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.right,
          style: t.typography.bodySmall.textStyle.copyWith(
            color: secondaryForeground,
          ),
        ),
      );
    }

    if (widget.showChevron) {
      if (children.isNotEmpty) {
        children.add(SizedBox(width: t.spacing.s2));
      }
      children.add(
        Icon(
          Icons.chevron_right_rounded,
          size: t.spacing.s5,
          color: secondaryForeground.withValues(
            alpha: _canInteract ? 0.85 : 0.6,
          ),
        ),
      );
    }

    if (children.isEmpty) {
      return null;
    }

    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }
}

/// Next heavier step on the weight ramp, saturating at `w900`.
///
/// Explicit rather than index arithmetic: `FontWeight.index` is deprecated,
/// and an ordered map states the intent without depending on enum ordering.
FontWeight _oneStepHeavier(FontWeight weight) => switch (weight) {
  FontWeight.w100 => FontWeight.w200,
  FontWeight.w200 => FontWeight.w300,
  FontWeight.w300 => FontWeight.w400,
  FontWeight.w400 => FontWeight.w500,
  FontWeight.w500 => FontWeight.w600,
  FontWeight.w600 => FontWeight.w700,
  FontWeight.w700 => FontWeight.w800,
  _ => FontWeight.w900,
};
