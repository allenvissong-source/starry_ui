import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';
import 'editable_state_mixin.dart';
import 'input_shell.dart';

/// Starry UI 多行文本域。与 [StarryTextField] 共享视觉语言，支持固定行数。
///
/// The shell is [StarryInputShell], the same one [StarryTextField] and
/// [StarrySearchInput] use, so the input family's geometry (min height, radius,
/// fill, focus border, horizontal padding, rest→focus elevation lift) comes from
/// one place. Before this it painted its own [OutlineInputBorder] through
/// `starryInputBorder`, which meant a second, silently divergent definition of
/// the same visual language: its radius was `radius.md` against the family's
/// `radius.xxl`, and it had no elevation response to focus at all.
class StarryTextArea extends StatefulWidget {
  const StarryTextArea({
    super.key,
    this.label,
    this.hint,
    this.minLines = 3,
    this.maxLines = 6,
    this.enabled = true,
    this.controller,
    this.focusNode,
    this.onChanged,
  });

  final String? label;
  final String? hint;
  final int minLines;
  final int maxLines;
  final bool enabled;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;

  @override
  State<StarryTextArea> createState() => _StarryTextAreaState();
}

class _StarryTextAreaState extends State<StarryTextArea>
    with StarryEditableStateMixin<StarryTextArea> {
  @override
  TextEditingController? get configuredController => widget.controller;

  @override
  FocusNode? get configuredFocusNode => widget.focusNode;

  @override
  void didUpdateWidget(covariant StarryTextArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    syncEditableConfig();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;

    final field = TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      keyboardType: TextInputType.multiline,
      style: t.typography.bodyMedium.textStyle.copyWith(color: s.textPrimary),
      decoration: InputDecoration(
        // The shell owns the fill, the border and the horizontal padding, so
        // the field inside it must contribute none of the three.
        isCollapsed: true,
        border: InputBorder.none,
        hintText: widget.hint,
        hintStyle: t.typography.bodyMedium.textStyle.copyWith(
          color: s.textDisabled,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: t.spacing.s3),
      ),
    );

    // A text area is multi-line by definition, so it takes the family's
    // rounded-rectangle corner (`radius.xxl`) rather than the single-line pill.
    // This is the same value [StarryTextField] settles on once it grows past one
    // line, which is what makes the two shapes consistent rather than merely
    // similar.
    final shell = StarryInputShell(
      focused: isFocused,
      enabled: widget.enabled,
      borderRadius: t.radius.xxl,
      child: field,
    );

    final label = widget.label;
    if (label == null) return shell;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: t.spacing.s2),
          child: Text(
            label,
            style: t.typography.labelLarge.textStyle.copyWith(
              color: widget.enabled ? s.textSecondary : s.textDisabled,
            ),
          ),
        ),
        shell,
      ],
    );
  }
}
