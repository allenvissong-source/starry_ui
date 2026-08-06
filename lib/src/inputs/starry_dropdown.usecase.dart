import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../theme/starry_tokens.dart';
import 'starry_dropdown.dart';

const List<StarryDropdownItem<String>> _demoItems = <StarryDropdownItem<String>>[
  StarryDropdownItem<String>(value: 'a', label: '选项 A'),
  StarryDropdownItem<String>(value: 'b', label: '选项 B'),
  StarryDropdownItem<String>(value: 'c', label: '选项 C'),
  StarryDropdownItem<String>(value: 'd', label: '选项 D'),
  StarryDropdownItem<String>(value: 'e', label: '选项 E'),
];

@UseCase(name: 'All States', type: StarryDropdown)
Widget allStatesStarryDropdown(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _StatefulDropdownDemo(
          hint: '请选择',
          initiallyExpanded: false,
          items: _demoItems,
        ),
        SizedBox(height: t.spacing.s4),
        _StatefulDropdownDemo(
          hint: '请选择',
          initialValue: 'b',
          initiallyExpanded: true,
          items: _demoItems,
        ),
        SizedBox(height: t.spacing.s4),
        StarryDropdown<String>(
          hint: '已禁用',
          enabled: false,
          items: _demoItems,
          onSelected: (_) {},
        ),
      ],
    ),
  );
}

@UseCase(name: 'Playground', type: StarryDropdown)
Widget playgroundStarryDropdown(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: _StatefulDropdownDemo(
      hint: context.knobs.string(label: 'Hint', initialValue: '请选择'),
      initiallyExpanded:
          context.knobs.boolean(label: 'Initially expanded', initialValue: false),
      items: _demoItems,
    ),
  );
}

class _StatefulDropdownDemo extends StatefulWidget {
  const _StatefulDropdownDemo({
    required this.items,
    required this.hint,
    this.initialValue,
    this.initiallyExpanded = false,
  });

  final List<StarryDropdownItem<String>> items;
  final String hint;
  final String? initialValue;
  final bool initiallyExpanded;

  @override
  State<_StatefulDropdownDemo> createState() => _StatefulDropdownDemoState();
}

class _StatefulDropdownDemoState extends State<_StatefulDropdownDemo> {
  String? _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return StarryDropdown<String>(
      hint: widget.hint,
      value: _value,
      initiallyExpanded: widget.initiallyExpanded,
      items: widget.items,
      onSelected: (v) => setState(() => _value = v),
    );
  }
}
