import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';
import 'input_border.dart';

/// Starry UI 多行文本域。与 [StarryTextField] 共享视觉语言，支持固定行数。
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
        fillColor: enabled ? s.surface : s.backgroundSecondary,
        hintStyle: t.typography.bodyMedium.textStyle.copyWith(
          color: s.textDisabled,
        ),
        constraints: BoxConstraints(
          minHeight: t.controlMetrics.controlHeight,
        ),
        enabledBorder: starryInputBorder(t, s.border),
        focusedBorder: starryInputBorder(
          t,
          s.brand,
          width: t.controlMetrics.focusBorderWidth,
        ),
        disabledBorder: starryInputBorder(t, s.border),
      ),
    );
  }
}
