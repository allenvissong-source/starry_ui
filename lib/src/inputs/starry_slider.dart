import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// A token-wired Slider with an optional header row (title, trailing widget,
/// and a value pill).
///
/// Wraps Material's [Slider] inside a [SliderTheme] whose track, thumb, and
/// overlay colors are resolved from [StarryTokens]. Every visual dimension that
/// has no dedicated token (track height, thumb radius, thumb elevation) is a
/// named constant on this widget rather than an inline magic number.
///
/// The full [Slider] behavioral API is preserved: [min]/[max]/[divisions]/
/// [label]/[secondaryTrackValue]/[semanticFormatterCallback]/[onChangeStart]/
/// [onChangeEnd]/[allowedInteraction]/[focusNode]/[autofocus]. Color entry
/// points ([activeTrackColor]/[inactiveTrackColor]/[thumbColor]/[overlayColor])
/// default to tokens but may be overridden.
class StarrySlider extends StatelessWidget {
  const StarrySlider({
    required this.value,
    super.key,
    this.onChanged,
    this.min = 0,
    this.max = 100,
    this.divisions,
    this.label,
    this.title,
    this.titleTextStyle,
    this.valueText,
    this.valueSemanticsLabel,
    this.valueFormatter,
    this.headerTrailing,
    this.leftLabel,
    this.centerLabel,
    this.rightLabel,
    this.secondaryTrackValue,
    this.semanticFormatterCallback,
    this.onChangeStart,
    this.onChangeEnd,
    this.allowedInteraction,
    this.focusNode,
    this.autofocus = false,
    this.showThumb = true,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.thumbColor,
    this.overlayColor,
  })  : assert(min <= max, 'min must be <= max'),
        assert(
          secondaryTrackValue == null ||
              (secondaryTrackValue >= min && secondaryTrackValue <= max),
          'secondaryTrackValue must be within [min, max]',
        );

  /// Height of the slider track.
  static const double trackHeight = 8;

  /// Radius of the thumb when [showThumb] is true.
  static const double thumbRadius = 10;

  /// Elevation of the thumb when [showThumb] is true.
  static const double thumbElevation = 4;

  final double value;
  final double min;
  final double max;
  final ValueChanged<double>? onChanged;
  final int? divisions;
  final String? label;
  final String? title;
  final TextStyle? titleTextStyle;
  final String? valueText;
  final String? valueSemanticsLabel;

  /// Formats [value] for the header value pill when [valueText] is not given.
  ///
  /// Ignored when [valueText] is non-null (explicit text wins).
  final String Function(double value)? valueFormatter;
  final Widget? headerTrailing;

  /// Optional bottom label row rendered below the track. Each column is only
  /// laid out when its label is non-null; if all three are null the row is
  /// omitted entirely.
  final String? leftLabel;
  final String? centerLabel;
  final String? rightLabel;
  final double? secondaryTrackValue;
  final String Function(double value)? semanticFormatterCallback;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;
  final SliderInteraction? allowedInteraction;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool showThumb;
  final Color? activeTrackColor;
  final Color? inactiveTrackColor;
  final Color? thumbColor;
  final Color? overlayColor;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;

    final effectiveValue = value.clamp(min, max).toDouble();
    final effectiveSecondaryTrackValue =
        secondaryTrackValue?.clamp(min, max).toDouble();

    final titleStyle = titleTextStyle ??
        t.typography.titleSmall.textStyle.copyWith(
          color: s.textPrimary,
          fontWeight: FontWeight.w500,
        );
    final valueStyle = t.typography.labelSmall.textStyle.copyWith(
      color: s.textSecondary,
      fontWeight: FontWeight.w600,
    );

    final resolvedValueText = valueText ?? valueFormatter?.call(effectiveValue);
    final hasBottomLabels =
        leftLabel != null || centerLabel != null || rightLabel != null;

    final resolvedActiveTrackColor = activeTrackColor ?? s.brand;
    final resolvedInactiveTrackColor = inactiveTrackColor ?? s.surfaceVariant;
    final resolvedThumbColor =
        showThumb ? (thumbColor ?? s.surface) : Colors.transparent;
    final resolvedOverlayColor = showThumb
        ? (overlayColor ?? s.brand.withValues(alpha: t.opacity.selectedSurface))
        : Colors.transparent;
    final resolvedThumbShape = showThumb
        ? const RoundSliderThumbShape(
            enabledThumbRadius: thumbRadius,
            elevation: thumbElevation,
          )
        : const RoundSliderThumbShape(enabledThumbRadius: 0, elevation: 0);
    final resolvedDisabledTrackColor =
        showThumb ? null : resolvedInactiveTrackColor;

    final slider = SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: trackHeight,
        activeTrackColor: resolvedActiveTrackColor,
        inactiveTrackColor: resolvedInactiveTrackColor,
        disabledActiveTrackColor: resolvedDisabledTrackColor,
        disabledInactiveTrackColor: resolvedDisabledTrackColor,
        thumbColor: resolvedThumbColor,
        overlayColor: resolvedOverlayColor,
        thumbShape: resolvedThumbShape,
      ),
      child: Slider(
        value: effectiveValue,
        min: min,
        max: max,
        divisions: divisions,
        label: label,
        secondaryTrackValue: effectiveSecondaryTrackValue,
        semanticFormatterCallback: semanticFormatterCallback,
        onChangeStart: onChangeStart,
        onChangeEnd: onChangeEnd,
        allowedInteraction: allowedInteraction,
        focusNode: focusNode,
        autofocus: autofocus,
        onChanged: onChanged,
      ),
    );

    if (title == null && valueText == null && headerTrailing == null) {
      return slider;
    }
    if (title == null &&
        resolvedValueText == null &&
        headerTrailing == null &&
        !hasBottomLabels) {
      return slider;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null ||
            resolvedValueText != null ||
            headerTrailing != null) ...[
          Row(
          children: [
            if (title != null)
              Expanded(child: Text(title!, style: titleStyle))
            else
              const Spacer(),
            if (headerTrailing != null) ...[
              headerTrailing!,
              SizedBox(width: t.spacing.s2),
            ],
            if (resolvedValueText != null)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: t.spacing.s3,
                  vertical: t.spacing.s1,
                ),
                decoration: BoxDecoration(
                  color: s.surfaceVariant,
                  borderRadius: BorderRadius.circular(t.radius.full),
                  border: Border.all(color: s.border),
                ),
                child: Text(
                  resolvedValueText,
                  semanticsLabel: valueSemanticsLabel,
                  style: valueStyle,
                ),
              ),
          ],
          ),
          SizedBox(height: t.spacing.s3),
        ],
        slider,
        if (hasBottomLabels) ...[
          SizedBox(height: t.spacing.s1),
          Row(
            children: [
              if (leftLabel != null) Text(leftLabel!, style: valueStyle),
              const Spacer(),
              if (centerLabel != null) Text(centerLabel!, style: valueStyle),
              const Spacer(),
              if (rightLabel != null) Text(rightLabel!, style: valueStyle),
            ],
          ),
        ],
      ],
    );
  }
}
