import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/starry_tokens.dart';
import 'input_shell.dart';
import 'editable_state_mixin.dart';
import 'field_clear_button.dart';

enum StarryTextFieldState { none, success, warning, error }

/// Token-driven text field with a brand focus-shell, validation, counter,
/// leading/trailing slots, accessible clearing and native multi-line growth.
///
/// Consolidates the legacy `AppTextField` (validation / counter / clear) and
/// `AiloreInputField` (brand shell / slots / auto-expand / formatters) into a
/// single greenfield component. All colors, sizes, motion and typography come
/// from [StarryTokens]; the field carries no hardcoded styling.
class StarryTextField extends StatefulWidget {
  const StarryTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.prefixIcon,
    this.leading,
    this.trailing,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.minLines,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.validationState = StarryTextFieldState.none,
    this.helperText,
    this.errorText,
    this.maxLength,
    this.showCounter = false,
    this.showClearButton = false,
    this.clearTooltip,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  }) : assert(
         !showClearButton || clearTooltip != null,
         'clearTooltip is required when showClearButton is true.',
       ),
       assert(
         leading == null || prefixIcon == null,
         'Provide either leading or prefixIcon, not both.',
       ),
       assert(
         maxLines == null || minLines == null || maxLines >= minLines,
         'maxLines must be >= minLines.',
       );

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;

  /// Convenience leading icon; rendered with `semantic.textTertiary`.
  final IconData? prefixIcon;

  /// Custom leading widget slot (mutually exclusive with [prefixIcon]).
  final Widget? leading;

  /// Custom trailing widget slot. Rendered after the clear/suffix affordances.
  final Widget? trailing;

  /// Convenience trailing icon; rendered with `semantic.textTertiary`.
  final IconData? suffixIcon;

  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;

  /// Multi-line growth bounds. The shell grows natively between [minLines] and
  /// [maxLines]; pass `maxLines: null` for unbounded growth.
  final int? minLines;
  final int? maxLines;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;

  final StarryTextFieldState validationState;
  final String? helperText;
  final String? errorText;
  final int? maxLength;

  /// Shows a `current/max` counter beneath the field (requires [maxLength]).
  final bool showCounter;

  final bool showClearButton;
  final String? clearTooltip;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;

  @override
  State<StarryTextField> createState() => _StarryTextFieldState();
}

class _StarryTextFieldState extends State<StarryTextField>
    with StarryEditableStateMixin<StarryTextField> {
  @override
  TextEditingController? get configuredController => widget.controller;

  @override
  FocusNode? get configuredFocusNode => widget.focusNode;

  @override
  void didUpdateWidget(covariant StarryTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    syncEditableConfig();
  }

  void _handleClear() {
    controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;
    final borderColor = switch (widget.validationState) {
      StarryTextFieldState.none => null,
      StarryTextFieldState.success => s.success,
      StarryTextFieldState.warning => s.warning,
      StarryTextFieldState.error => s.error,
    };
    final message = widget.validationState == StarryTextFieldState.error
        ? widget.errorText
        : widget.helperText;
    final messageColor = widget.validationState == StarryTextFieldState.error
        ? s.error
        : s.textTertiary;
    // obscured input is inherently single-line.
    final effectiveMaxLines = widget.obscureText ? 1 : widget.maxLines;
    final effectiveMinLines = widget.obscureText ? null : widget.minLines;

    final leading =
        widget.leading ??
        (widget.prefixIcon == null
            ? null
            : Icon(
                widget.prefixIcon,
                size: t.controlMetrics.iconMd,
                color: s.textTertiary,
              ));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (widget.label != null) ...<Widget>[
          Text(
            widget.label!,
            style: t.typography.labelLarge.textStyle.copyWith(
              color: s.textSecondary,
            ),
          ),
          SizedBox(height: t.spacing.s2),
        ],
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            final canClear =
                widget.showClearButton &&
                widget.enabled &&
                !widget.readOnly &&
                value.text.isNotEmpty;
            // The clear button is the rightmost affordance only when no
            // `suffixIcon`/`trailing` follows it; that is the sole case that
            // needs an outward nudge to reach the shared end inset (below).
            final clearIsLast =
                canClear &&
                widget.suffixIcon == null &&
                widget.trailing == null;
            // Every trailing affordance shares one horizontal inset: the icon
            // sits flush to the shell's end padding, exactly where a bare
            // `suffixIcon` would. The clear button keeps a `minTouchTarget`-wide
            // tap zone with its glyph *centered* in the box, so the IconButton's
            // ink hover/splash circle stays centered on the "×" (an in-box
            // `alignment` would move only the glyph and leave the circle centered
            // on the box — an off-centre ripple). A centered glyph therefore
            // lands half a tap-slop `(minTouchTarget − iconMd)/2` further inside
            // than a bare `suffixIcon`; when the clear button is the rightmost
            // affordance we shift the *whole* button (glyph + ripple together)
            // outward by exactly that slop so it lines up on the shared inset.
            // No end-cap nudge onto the pill's round end — that iOS look is a
            // StarrySearchInput-only variant, not the general text field's rule.
            final clearEndNudge =
                (t.controlMetrics.minTouchTarget - t.controlMetrics.iconMd) / 2;
            final trailingChildren = <Widget>[
              if (canClear)
                StarryFieldClearButton(
                  onPressed: _handleClear,
                  tooltip: widget.clearTooltip!,
                  translateX: clearIsLast ? clearEndNudge : 0,
                ),
              if (widget.suffixIcon != null) ...<Widget>[
                if (canClear) SizedBox(width: t.spacing.s3),
                Icon(
                  widget.suffixIcon,
                  size: t.controlMetrics.iconMd,
                  color: s.textTertiary,
                ),
              ],
              if (widget.trailing != null) ...<Widget>[
                if (canClear || widget.suffixIcon != null)
                  SizedBox(width: t.spacing.s3),
                widget.trailing!,
              ],
            ];
            return StarryInputShell(
              focused: isFocused,
              enabled: widget.enabled,
              borderColor: borderColor,
              // A single fixed corner radius drives both shapes via Skia's clamp
              // (corner = min(radius, height / 2)):
              //   * single-line (height == controlHeight): half-height <= radius, so
              //     the corner clamps to a full pill;
              //   * multi-line (height grows): half-height > radius, so it settles
              //     into a fixed `radius.xxl` rounded rectangle.
              // Taking max(xxl, controlHeight / 2) makes "single line is always a
              // pill" an explicit invariant instead of relying on the incidental
              // fact that xxl (28) currently exceeds the half-height (24) — it stays
              // correct if controlHeight ever changes. No `pill` flag / no layout
              // measurement, and the shape transitions smoothly as the field grows.
              borderRadius: math.max(
                t.radius.xxl,
                t.controlMetrics.controlHeight / 2,
              ),
              child: Row(
                children: <Widget>[
                  if (leading != null) ...<Widget>[
                    leading,
                    SizedBox(width: t.spacing.s3),
                  ],
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      enabled: widget.enabled,
                      readOnly: widget.readOnly,
                      autofocus: widget.autofocus,
                      obscureText: widget.obscureText,
                      minLines: effectiveMinLines,
                      maxLines: effectiveMaxLines,
                      maxLength: widget.maxLength,
                      keyboardType: widget.keyboardType,
                      textInputAction: widget.textInputAction,
                      inputFormatters: widget.inputFormatters,
                      onChanged: widget.onChanged,
                      onSubmitted: widget.onSubmitted,
                      buildCounter: _noCounter,
                      textAlignVertical: TextAlignVertical.center,
                      style: t.typography.bodyMedium.textStyle.copyWith(
                        color: s.textPrimary,
                      ),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: widget.hint,
                        hintStyle: t.typography.bodyMedium.textStyle.copyWith(
                          color: s.textDisabled,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: t.spacing.s3,
                        ),
                      ),
                    ),
                  ),
                  if (trailingChildren.isNotEmpty) ...<Widget>[
                    // Mirror the leading gap (`s3`) so text-to-affordance
                    // spacing is symmetric on both ends.
                    SizedBox(width: t.spacing.s3),
                    ...trailingChildren,
                  ],
                ],
              ),
            );
          },
        ),
        if (message != null || (widget.showCounter && widget.maxLength != null))
          Padding(
            padding: EdgeInsets.only(top: t.spacing.s2),
            child: Row(
              children: <Widget>[
                if (message != null)
                  Expanded(
                    child: Text(
                      message,
                      style: t.typography.labelLarge.textStyle.copyWith(
                        color: messageColor,
                      ),
                    ),
                  )
                else
                  const Spacer(),
                if (widget.showCounter && widget.maxLength != null)
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller,
                    builder: (context, value, _) => Text(
                      '${value.text.characters.length}/${widget.maxLength}',
                      style: t.typography.labelLarge.textStyle.copyWith(
                        color: s.textTertiary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  static Widget? _noCounter(
    BuildContext context, {
    required int currentLength,
    required int? maxLength,
    required bool isFocused,
  }) => null;
}
