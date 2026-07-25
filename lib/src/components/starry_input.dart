import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// Starry UI 单行输入框。统一圆角、聚焦描边与占位色，接入语义 token。
class StarryInput extends StatelessWidget {
  const StarryInput({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.controller,
    this.onChanged,
  });

  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final bool enabled;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;
    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(t.radius.md),
          borderSide: BorderSide(color: c),
        );
    return TextField(
      controller: controller,
      enabled: enabled,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        errorText: errorText,
        filled: true,
        fillColor: enabled ? s.surface : s.surfaceVariant,
        hintStyle: TextStyle(color: s.textDisabled),
        enabledBorder: border(s.border),
        focusedBorder: border(s.brand),
        disabledBorder: border(s.border),
        errorBorder: border(s.error),
        focusedErrorBorder: border(s.error),
      ),
    );
  }
}
