import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// Starry UI 开关。开态使用品牌色轨道，关态使用中性描边，禁用降透明度。
class StarrySwitch extends StatelessWidget {
  const StarrySwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).extension<StarryTokens>()!.semantic;
    final control = Switch(
      value: value,
      onChanged: onChanged,
      activeThumbColor: Colors.white,
      activeTrackColor: s.brand,
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: s.textDisabled,
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => value ? s.brand : s.border,
      ),
    );
    if (label == null) return control;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        control,
        const SizedBox(width: 8),
        Text(label!, style: TextStyle(color: s.textPrimary, fontSize: 14)),
      ],
    );
  }
}
