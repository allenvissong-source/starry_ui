import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    this.fieldKey,
  }) : expands = false,
       header = null,
       toolbar = null,
       maxLength = null,
       maxLengthEnforcement = MaxLengthEnforcement.enforced;

  /// 占满父级给定高度的写作面板，底部保留工具栏和字符计数。
  ///
  /// [header] 渲染在正文输入之上、同一个输入壳内部，用于把标题写进写作面板，
  /// 而不是另起一张卡片。
  const StarryTextArea.composer({
    super.key,
    this.label,
    this.hint,
    this.enabled = true,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.fieldKey,
    this.header,
    this.toolbar,
    this.maxLength,
    this.maxLengthEnforcement = MaxLengthEnforcement.enforced,
  }) : minLines = 1,
       maxLines = 1,
       expands = true;

  final String? label;
  final String? hint;
  final int minLines;
  final int maxLines;
  final bool enabled;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;

  /// 内部 [TextField] 的 key，供调用方稳定定位正文输入框（写作面板还包含
  /// 标题等其它输入时尤其需要）。
  final Key? fieldKey;
  final bool expands;
  final Widget? header;
  final Widget? toolbar;
  final int? maxLength;
  final MaxLengthEnforcement maxLengthEnforcement;

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
      key: widget.fieldKey,
      controller: controller,
      focusNode: focusNode,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      minLines: widget.expands ? null : widget.minLines,
      maxLines: widget.expands ? null : widget.maxLines,
      expands: widget.expands,
      maxLength: widget.maxLength,
      maxLengthEnforcement: widget.maxLengthEnforcement,
      textAlignVertical: TextAlignVertical.top,
      keyboardType: TextInputType.multiline,
      style: (widget.expands ? t.typography.bodyLarge : t.typography.bodyMedium)
          .textStyle
          .copyWith(color: s.textPrimary),
      decoration: InputDecoration(
        // The shell owns the fill, the border and the horizontal padding, so
        // the field inside it must contribute none of the three.
        isCollapsed: true,
        border: InputBorder.none,
        hintText: widget.hint,
        hintStyle: t.typography.bodyMedium.textStyle.copyWith(
          color: s.textDisabled,
        ),
        contentPadding: widget.expands && widget.header != null
            ? EdgeInsets.zero
            : EdgeInsets.symmetric(vertical: t.spacing.s3),
        counterText: '',
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
      borderRadius: widget.expands ? t.radius.lg : t.radius.xxl,
      // 大型写作面板在浅色背景上仍需明确边界，聚焦后沿用输入家族的品牌色。
      borderColor: widget.expands && !isFocused ? s.border : null,
      child: widget.expands
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.header != null)
                  Padding(
                    padding: EdgeInsets.only(
                      top: t.spacing.s5,
                      bottom: t.spacing.s3,
                    ),
                    child: widget.header,
                  ),
                Expanded(child: field),
                Padding(
                  padding: EdgeInsets.only(bottom: t.spacing.s3),
                  child: Row(
                    children: [
                      if (widget.toolbar != null)
                        Expanded(child: widget.toolbar!)
                      else
                        const Spacer(),
                      if (widget.maxLength != null)
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: controller,
                          builder: (context, value, _) => Text(
                            '${value.text.characters.length} / ${widget.maxLength}',
                            style: t.typography.bodySmall.textStyle.copyWith(
                              color: s.textSecondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            )
          : field,
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
        if (widget.expands) Expanded(child: shell) else shell,
      ],
    );
  }
}
