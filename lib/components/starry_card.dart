import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// Starry UI 卡片。表面色、文字、描边与圆角全部绑定语义 / 圆角 / 阴影 token，
/// 对应设计规范「07 · 组件预览」中的卡片：标题 + 正文 + 可选操作入口，
/// 阴影默认使用 shadow/md（elevation level2）。
class StarryCard extends StatelessWidget {
  const StarryCard({
    super.key,
    required this.title,
    this.body,
    this.actionLabel,
    this.onAction,
    this.elevated = true,
  });

  /// 卡片标题。
  final String title;

  /// 正文内容，可为空。
  final String? body;

  /// 底部操作入口文案（如「查看详情 →」），为空则不渲染。
  final String? actionLabel;

  /// 操作入口点击回调。
  final VoidCallback? onAction;

  /// 是否使用 shadow/md 阴影；false 时只保留描边（flat 卡片）。
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: s.surface,
        borderRadius: BorderRadius.circular(t.radius.lg),
        border: Border.all(color: s.border),
        boxShadow: elevated ? t.elevation.level2 : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: s.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (body != null) ...[
            const SizedBox(height: 8),
            Text(
              body!,
              style: TextStyle(
                color: s.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
          if (actionLabel != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: TextStyle(
                  color: s.brand,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
