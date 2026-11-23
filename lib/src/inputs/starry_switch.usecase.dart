import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import 'package:widgetbook/widgetbook.dart';

import '../theme/starry_tokens.dart';
import 'starry_switch.dart';

/// Stateful wrapper so the Widgetbook switch actually toggles.
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
      onChanged: widget.enabled ? (v) => setState(() => _value = v) : null,
    );
  }
}

@UseCase(name: 'Playground', type: StarrySwitch)
Widget playgroundStarrySwitch(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SwitchDemo(
          initial: context.knobs.boolean(
            label: 'Initial value',
            initialValue: true,
          ),
          enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
          label: context.knobs.stringOrNull(
            label: 'Label',
            initialValue: '接收通知',
          ),
        ),
      ],
    ),
  );
}

@UseCase(name: 'States', type: StarrySwitch)
Widget statesStarrySwitch(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: Wrap(
      spacing: t.spacing.s4,
      runSpacing: t.spacing.s4,
      children: const <Widget>[
        StarrySwitch(value: true, label: '开 (可用)'),
        StarrySwitch(value: false, label: '关 (可用)'),
        StarrySwitch(value: true, onChanged: null, label: '开 (禁用)'),
        StarrySwitch(value: false, onChanged: null, label: '关 (禁用)'),
      ],
    ),
  );
}
