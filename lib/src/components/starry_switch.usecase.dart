import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import 'package:widgetbook/widgetbook.dart';

import 'starry_switch.dart';

/// 有状态包装，让 Widgetbook 里的开关可以真实切换。
class _SwitchDemo extends StatefulWidget {
  const _SwitchDemo({required this.initial, required this.enabled, this.label});

  final bool initial;
  final bool enabled;
  final String? label;

  @override
  State<_SwitchDemo> createState() => _SwitchDemoState();
}

class _SwitchDemoState extends State<_SwitchDemo> {
  late bool _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    return StarrySwitch(
      value: _value,
      label: widget.label,
      onChanged:
          widget.enabled ? (v) => setState(() => _value = v) : null,
    );
  }
}

@UseCase(name: 'Playground', type: StarrySwitch)
Widget playgroundStarrySwitch(BuildContext context) {
  return Center(
    child: _SwitchDemo(
      initial: context.knobs.boolean(label: 'Initial value', initialValue: true),
      enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
      label: context.knobs.stringOrNull(label: 'Label', initialValue: '接收通知'),
    ),
  );
}

@UseCase(name: 'States', type: StarrySwitch)
Widget statesStarrySwitch(BuildContext context) {
  return const Center(
    child: Wrap(
      spacing: 24,
      runSpacing: 16,
      children: [
        StarrySwitch(value: true, label: '开 (可用)'),
        StarrySwitch(value: false, label: '关 (可用)'),
        StarrySwitch(value: true, onChanged: null, label: '开 (禁用)'),
        StarrySwitch(value: false, onChanged: null, label: '关 (禁用)'),
      ],
    ),
  );
}
