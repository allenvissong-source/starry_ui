import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import '../../starry_ui.dart';

const _tabs = [
  StarryTab(value: 'details', label: '详情', icon: Icons.description_outlined),
  StarryTab(value: 'entries', label: '条目', count: 12),
  StarryTab(value: 'media', label: '媒体', icon: Icons.image_outlined),
  StarryTab(value: 'history', label: '历史', enabled: false),
];

@UseCase(name: 'All Variants', type: StarryTabBar)
Widget allVariantsStarryTabBar(BuildContext context) {
  final t = context.starryTokens;
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _TabsDemo(),
        SizedBox(height: t.spacing.s4),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: SizedBox(
            width: t.controlMetrics.controlHeight * 4,
            child: const _TabsDemo(),
          ),
        ),
        SizedBox(height: t.spacing.s4),
        const StarryTabBar(tabs: _tabs, value: 'details', onChanged: null),
      ],
    ),
  );
}

@UseCase(name: 'Playground', type: StarryTabBar)
Widget playgroundStarryTabBar(BuildContext context) {
  final t = context.starryTokens;
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: _TabsDemo(
      enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
    ),
  );
}

class _TabsDemo extends StatefulWidget {
  const _TabsDemo({this.enabled = true});
  final bool enabled;
  @override
  State<_TabsDemo> createState() => _TabsDemoState();
}

class _TabsDemoState extends State<_TabsDemo> {
  String _value = 'details';
  @override
  Widget build(BuildContext context) => StarryTabBar<String>(
    tabs: _tabs,
    value: _value,
    onChanged: widget.enabled
        ? (value) => setState(() => _value = value)
        : null,
  );
}
