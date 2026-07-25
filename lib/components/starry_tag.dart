import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// 标签语义状态：默认 / 成功 / 警告 / 错误。
enum StarryTagStatus { neutral, success, warning, error }

/// Starry UI 的状态标签（Tag / Chip）。使用语义色 token 的 bg / strong 对，
/// 保证文字在浅底上有足够对比。
class StarryTag extends StatelessWidget {
  const StarryTag({
    super.key,
    required this.label,
    this.status = StarryTagStatus.neutral,
  });

  final String label;
  final StarryTagStatus status;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).extension<StarryTokens>()!.semantic;
    late final Color bg;
    late final Color fg;
    switch (status) {
      case StarryTagStatus.neutral:
        bg = s.surfaceVariant;
        fg = s.textSecondary;
      case StarryTagStatus.success:
        bg = s.successBg;
        fg = s.successStrong;
      case StarryTagStatus.warning:
        bg = s.warningBg;
        fg = s.warningStrong;
      case StarryTagStatus.error:
        bg = s.errorBg;
        fg = s.errorStrong;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}
