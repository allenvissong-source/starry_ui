import 'package:flutter/material.dart';

import '../inputs/starry_text_field.dart';
import '../inputs/field_feedback.dart';
import '../theme/starry_tokens.dart';
import 'starry_dialog.dart';

/// A small text-input dialog using the shared shell and field.
///
/// Validation and the returned value use the exact entered text. The caller
/// decides whether empty/whitespace is allowed; this component never trims it.
class StarryInputDialog extends StatefulWidget {
  const StarryInputDialog({
    required this.title,
    required this.fieldLabel,
    required this.confirmLabel,
    required this.cancelLabel,
    this.initialValue = '',
    this.hint,
    this.helperText,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    super.key,
  }) : assert(maxLines > 0),
       assert(maxLength == null || maxLength > 0);

  final String title;
  final String fieldLabel;
  final String confirmLabel;
  final String cancelLabel;
  final String initialValue;
  final String? hint;
  final String? helperText;
  final int maxLines;
  final int? maxLength;
  final String? Function(String value)? validator;

  static Future<String?> show({
    required BuildContext context,
    required String title,
    required String fieldLabel,
    required String confirmLabel,
    required String cancelLabel,
    String initialValue = '',
    String? hint,
    String? helperText,
    int maxLines = 1,
    int? maxLength,
    String? Function(String value)? validator,
    bool barrierDismissible = true,
    bool useRootNavigator = true,
  }) => StarryDialog.show<String>(
    context: context,
    barrierDismissible: barrierDismissible,
    useRootNavigator: useRootNavigator,
    builder: (_) => StarryInputDialog(
      title: title,
      fieldLabel: fieldLabel,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      initialValue: initialValue,
      hint: hint,
      helperText: helperText,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
    ),
  );

  @override
  State<StarryInputDialog> createState() => _StarryInputDialogState();
}

class _StarryInputDialogState extends State<StarryInputDialog> {
  late final _controller = TextEditingController(text: widget.initialValue);
  final _focusNode = FocusNode();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text;
    final error = widget.validator?.call(value);
    if (error != null) {
      setState(() => _error = error);
      _focusNode.requestFocus();
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    return StarryDialog(
      title: widget.title,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StarryTextField(
            controller: _controller,
            focusNode: _focusNode,
            autofocus: true,
            label: widget.fieldLabel,
            hint: widget.hint,
            validationState: _error == null
                ? StarryTextFieldState.none
                : StarryTextFieldState.error,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            textInputAction: widget.maxLines == 1
                ? TextInputAction.done
                : TextInputAction.newline,
            onSubmitted: widget.maxLines == 1 ? (_) => _submit() : null,
            onChanged: (_) {
              if (_error != null) {
                setState(
                  () => _error = widget.validator?.call(_controller.text),
                );
              }
            },
          ),
          StarryFieldFeedback(
            message: _error ?? widget.helperText,
            hasError: _error != null,
            counter: widget.maxLength == null
                ? null
                : ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _controller,
                    builder: (_, value, _) => Text(
                      '${value.text.characters.length}/${widget.maxLength}',
                      style: t.typography.labelLarge.textStyle.copyWith(
                        color: t.semantic.textSecondary,
                      ),
                    ),
                  ),
          ),
        ],
      ),
      actions: [
        StarryDialogAction(
          label: widget.cancelLabel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        StarryDialogAction(
          label: widget.confirmLabel,
          primary: true,
          onPressed: _submit,
        ),
      ],
    );
  }
}
