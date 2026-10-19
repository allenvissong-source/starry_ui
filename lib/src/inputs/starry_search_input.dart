import 'dart:async';

import 'package:flutter/material.dart';

import '../buttons/starry_button.dart';
import '../theme/starry_tokens.dart';
import 'input_shell.dart';
import 'editable_state_mixin.dart';
import 'field_clear_button.dart';

/// Default input-inactivity debounce before [StarrySearchInput.onChanged]
/// fires. This is an interaction-timing value (how long a typing pause counts
/// as "settled"), not a visual-motion duration, so it is a named file-local
/// constant rather than a `motion.*` token.
const int _kDefaultSearchDebounceMs = 300;

/// Visual density of [StarrySearchInput]. Both values come from the shared
/// control-height scale; consumers choose a semantic size instead of passing a
/// numeric height.
enum StarrySearchInputSize {
  /// Standard search field (`controlMetrics.heightLg`, 48px).
  standard,

  /// One step smaller (`controlMetrics.heightMd`, 44px), intended for hub
  /// headers and dense navigation surfaces.
  compact,
}

/// Token-driven search input consolidating the legacy `SearchInput`
/// (debounce / clear) and `SearchCapsule` (search button / focus ring).
///
/// Behavior:
///   * [onChanged] fires after [debounceMs] of inactivity.
///   * The clear affordance empties the field and fires an empty [onChanged]
///     (so consumers reset results) plus [onClear].
///   * An optional trailing search button ([onSearch]) submits immediately.
///   * Submitting via the keyboard (`TextInputAction.search`) calls [onSearch]
///     when provided, otherwise [onSubmitted].
///
/// Exposes a `searchbox` semantics node. Fully token-driven — no hardcoded
/// colors, sizes or motion; the brand focus-shell is shared with
/// [StarryInputShell].
class StarrySearchInput extends StatefulWidget {
  const StarrySearchInput({
    super.key,
    this.controller,
    this.focusNode,
    this.hint,
    this.semanticLabel,
    this.onChanged,
    this.onSubmitted,
    this.onSearch,
    this.onClear,
    this.searchButtonText,
    this.autofocus = false,
    this.enabled = true,
    this.showClearButton = true,
    this.debounceMs = _kDefaultSearchDebounceMs,
    this.soft = false,
    this.size = StarrySearchInputSize.standard,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hint;

  /// Accessibility label for the search field's `searchbox` semantics node.
  final String? semanticLabel;

  /// Fired after [debounceMs] of inactivity, and immediately (empty) on clear.
  final ValueChanged<String>? onChanged;

  /// Fired on keyboard submit when no [onSearch] is provided.
  final ValueChanged<String>? onSubmitted;

  /// When provided, renders a trailing search button and is invoked on both the
  /// button tap and keyboard submit.
  final VoidCallback? onSearch;

  final VoidCallback? onClear;
  final String? searchButtonText;
  final bool autofocus;
  final bool enabled;
  final bool showClearButton;
  final int debounceMs;

  /// Quiet ("soft") visual variant, forwarded to [StarryInputShell.soft]. When
  /// true the field also uses a neutral (`semantic.textSecondary`) hint so the
  /// whole control reads at lower contrast. Defaults to false, leaving the
  /// standard appearance unchanged.
  final bool soft;

  /// Tokenized visual size. Defaults to the existing 48px control height.
  final StarrySearchInputSize size;

  @override
  State<StarrySearchInput> createState() => _StarrySearchInputState();
}

class _StarrySearchInputState extends State<StarrySearchInput>
    with StarryEditableStateMixin<StarrySearchInput> {
  Timer? _debounce;

  @override
  TextEditingController? get configuredController => widget.controller;

  @override
  FocusNode? get configuredFocusNode => widget.focusNode;

  @override
  void attachControllerListeners(TextEditingController controller) {
    controller.addListener(_handleTextChange);
  }

  @override
  void detachControllerListeners(TextEditingController controller) {
    controller.removeListener(_handleTextChange);
  }

  @override
  void didUpdateWidget(covariant StarrySearchInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    syncEditableConfig();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _handleTextChange() {
    if (widget.onChanged == null) return;
    _debounce?.cancel();
    _debounce = Timer(
      Duration(milliseconds: widget.debounceMs),
      () => widget.onChanged?.call(controller.text),
    );
  }

  void _handleClear() {
    _debounce?.cancel();
    controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  void _handleSubmit(String value) {
    _debounce?.cancel();
    if (widget.onSearch != null) {
      widget.onSearch!.call();
    } else {
      widget.onSubmitted?.call(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;
    final controlHeight = switch (widget.size) {
      StarrySearchInputSize.standard => t.controlMetrics.heightLg,
      StarrySearchInputSize.compact => t.controlMetrics.heightMd,
    };
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final canClear =
            widget.showClearButton && widget.enabled && value.text.isNotEmpty;
        final wantsSearchButton =
            widget.onSearch != null && widget.searchButtonText != null;
        return LayoutBuilder(
          builder: (context, constraints) {
            final direction = Directionality.of(context);
            final buttonTextPainter = TextPainter(
              text: TextSpan(
                text: widget.searchButtonText,
                style: t.typography.labelLarge.textStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              textDirection: direction,
              maxLines: 1,
            )..layout();
            final baseChromeWidth =
                2 * StarryInputShell.endPadding(t) +
                t.controlMetrics.iconMd +
                t.spacing.s3;
            final searchButtonWidth =
                buttonTextPainter.width + 2 * t.spacing.s4;
            buttonTextPainter.dispose();
            final searchButtonRequiredWidth =
                baseChromeWidth +
                t.controlMetrics.minTouchTarget +
                t.spacing.s2 +
                searchButtonWidth +
                StarryInputShell.concentricGap(t);
            final showSearchButton =
                wantsSearchButton &&
                (!constraints.hasBoundedWidth ||
                    constraints.maxWidth >= searchButtonRequiredWidth);
            final leadingIconRequiredWidth =
                baseChromeWidth + t.controlMetrics.minTouchTarget;
            final showLeadingIcon =
                !constraints.hasBoundedWidth ||
                constraints.maxWidth >= leadingIconRequiredWidth;
            final clearIsLast = canClear && !showSearchButton;
            final nudge =
                StarryInputShell.endCapNudge(t, controlHeight: controlHeight) *
                (direction == TextDirection.rtl ? -1 : 1);
            return StarryInputShell(
              focused: isFocused,
              enabled: widget.enabled,
              pill: true,
              soft: widget.soft,
              controlHeight: controlHeight,
              // With a real-width trailing button, collapse the end padding to the
              // concentric gap so the button nests inside the pill by real layout
              // (AGENTS.md §1.5.2) — no translate, no overflow.
              trailingPadding: showSearchButton
                  ? StarryInputShell.concentricGap(t)
                  : null,
              child: Row(
                children: <Widget>[
                  if (showLeadingIcon) ...<Widget>[
                    Icon(
                      Icons.search,
                      size: t.controlMetrics.iconMd,
                      color: s.textTertiary,
                    ),
                    SizedBox(width: t.spacing.s3),
                  ],
                  Expanded(
                    child: Semantics(
                      textField: true,
                      label: widget.semanticLabel,
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        enabled: widget.enabled,
                        autofocus: widget.autofocus,
                        textInputAction: TextInputAction.search,
                        onSubmitted: _handleSubmit,
                        textAlignVertical: TextAlignVertical.center,
                        style: t.typography.bodyMedium.textStyle.copyWith(
                          color: s.textPrimary,
                        ),
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: widget.hint,
                          hintStyle: t.typography.bodyMedium.textStyle.copyWith(
                            color: s.textSecondary,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: t.spacing.s3,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (canClear)
                    StarryFieldClearButton(
                      onPressed: _handleClear,
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).deleteButtonTooltip,
                      translateX: clearIsLast ? nudge : 0,
                      controlHeight: controlHeight,
                    ),
                  if (showSearchButton) ...<Widget>[
                    SizedBox(width: t.spacing.s2),
                    // Concentric capsule-in-capsule (AGENTS.md §1.5.2): inner
                    // height = interiorHeight − 2·gap (interior frame, inside the
                    // 2px focus border), StadiumBorder ⇒ inner radius =
                    // interiorHeight/2 − gap, sharing the shell's inner centers.
                    // The shell's `trailingPadding` (= gap) places it. The
                    // `.concentric` factory binds this reduced height to
                    // shrinkWrap, so its layout box stays 36 and can't inflate the
                    // pill past controlHeight — keeping all four visible gaps a
                    // uniform `gap` (§1.5.2). The default constructor cannot take
                    // a height, so this asymmetry trap is unrepresentable.
                    StarryButton.concentric(
                      label: widget.searchButtonText!,
                      height: StarryInputShell.concentricInnerHeight(
                        t,
                        controlHeight: controlHeight,
                      ),
                      onPressed: widget.enabled ? widget.onSearch : null,
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}
