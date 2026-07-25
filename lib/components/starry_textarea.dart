import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// Starry UI 多行文本域。与 [StarryInput] 共享视觉语言，支持固定行数。
class StarryTextArea extends StatelessWidget {
  const StarryTextArea({
    super.key,
    this.label,
    this.hint,
    this.minLines = 3,
    this.maxLines = 6,
    this.enabled = true,
    this.controller,
    this.onChanged,
  });

  final String? label;
  final String? hint;
  final int minLines;
  final int maxLines;
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
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: true,
        filled: true,
        fillColor: enabled ? s.surface : s.surfaceVariant,
        hintStyle: TextStyle(color: s.textDisabled),
        enabledBorder: border(s.border),
        focusedBorder: border(s.brand),
        disabledBorder: border(s.border),
      ),
    );
  }
}
