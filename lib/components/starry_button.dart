import 'package:flutter/material.dart';

/// 按钮层级：主 / 次品牌 / 弱调 / 文本。复用同一套 M3 token，只切换底座。
enum StarryButtonVariant { filled, secondary, tonal, text }

/// Starry UI 的品牌按钮。基于 M3 的 Filled/Tonal/Text 按钮，统一圆角与内边距。
class StarryButton extends StatelessWidget {
  const StarryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = StarryButtonVariant.filled,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final StarryButtonVariant variant;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(label)],
          );

    switch (variant) {
      case StarryButtonVariant.filled:
        return FilledButton(onPressed: onPressed, child: child);
      case StarryButtonVariant.secondary:
        final scheme = Theme.of(context).colorScheme;
        return FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: scheme.secondary,
            foregroundColor: scheme.onSecondary,
          ),
          child: child,
        );
      case StarryButtonVariant.tonal:
        return FilledButton.tonal(onPressed: onPressed, child: child);
      case StarryButtonVariant.text:
        return TextButton(onPressed: onPressed, child: child);
    }
  }
}
