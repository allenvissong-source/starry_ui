import 'package:flutter/material.dart';
import 'field_feedback.dart';
import 'starry_text_field.dart';

enum StarryNumberFieldError { required, invalidInteger, belowMin, aboveMax }

/// Every edit, including invalid/unfinished text, is reported to the owner.
/// An invalid result has no value; callers must check [isValid] before saving.
class StarryNumberFieldResult {
  const StarryNumberFieldResult({
    required this.text,
    required this.value,
    this.error,
  });

  final String text;
  final int? value;
  final StarryNumberFieldError? error;
  bool get isValid => error == null;
}

/// Nullable integer input built on the standard text-field shell.
///
/// No clamping or silent reversion takes place. The owner receives a result
/// for every edit, and supplies localized error messages (including the
/// business meaning of an empty value through [hint]/[helperText]).
/// Values must be exactly representable on native and Web (±(2^53 − 1)).
class StarryNumberField extends StatefulWidget {
  const StarryNumberField({
    required this.value,
    required this.onChanged,
    required this.errorTextBuilder,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.nullable = true,
    this.min,
    this.max,
    this.enabled = true,
    this.readOnly = false,
    this.focusNode,
    this.onSubmitted,
    super.key,
  }) : assert(min == null || max == null || min <= max);

  final int? value;
  final ValueChanged<StarryNumberFieldResult> onChanged;
  final String Function(StarryNumberFieldError error) errorTextBuilder;
  final ValueChanged<StarryNumberFieldResult>? onSubmitted;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final bool nullable;
  final int? min;
  final int? max;
  final bool enabled;
  final bool readOnly;
  final FocusNode? focusNode;

  @override
  State<StarryNumberField> createState() => _StarryNumberFieldState();
}

class _StarryNumberFieldState extends State<StarryNumberField> {
  late final TextEditingController _controller;
  static final _integer = RegExp(r'^[+-]?[0-9]+$');
  // IEEE-754's largest exact integer; prevents Web parsing from silently
  // rounding an edit that native Dart could represent.
  static final _maxExactInteger = BigInt.from(9007199254740991);

  StarryNumberFieldResult _parse(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return StarryNumberFieldResult(
        text: text,
        value: null,
        error: widget.nullable ? null : StarryNumberFieldError.required,
      );
    }
    final parsed = _integer.hasMatch(trimmed) ? BigInt.tryParse(trimmed) : null;
    final number = parsed == null || parsed.abs() > _maxExactInteger
        ? null
        : parsed.toInt();
    final error = number == null
        ? StarryNumberFieldError.invalidInteger
        : widget.min != null && number < widget.min!
        ? StarryNumberFieldError.belowMin
        : widget.max != null && number > widget.max!
        ? StarryNumberFieldError.aboveMax
        : null;
    return StarryNumberFieldResult(
      text: text,
      value: error == null ? number : null,
      error: error,
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value?.toString() ?? '');
  }

  @override
  void didUpdateWidget(StarryNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final result = _parse(_controller.text);
    if (widget.value != oldWidget.value &&
        (!result.isValid || widget.value != result.value)) {
      _controller.text = widget.value?.toString() ?? '';
    }
    if (widget.min != oldWidget.min ||
        widget.max != oldWidget.max ||
        widget.nullable != oldWidget.nullable) {
      final result = _parse(_controller.text);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onChanged(result);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = _parse(_controller.text);
    final error = result.error == null
        ? widget.errorText
        : widget.errorTextBuilder(result.error!);
    final field = StarryTextField(
      controller: _controller,
      focusNode: widget.focusNode,
      label: widget.label,
      hint: widget.hint,
      validationState: error == null
          ? StarryTextFieldState.none
          : StarryTextFieldState.error,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      keyboardType: TextInputType.numberWithOptions(
        signed: widget.min == null || widget.min! < 0,
      ),
      onChanged: (text) {
        setState(() {});
        widget.onChanged(_parse(text));
      },
      onSubmitted: (text) => widget.onSubmitted?.call(_parse(text)),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        field,
        StarryFieldFeedback(
          message: error ?? widget.helperText,
          hasError: error != null,
        ),
      ],
    );
  }
}
