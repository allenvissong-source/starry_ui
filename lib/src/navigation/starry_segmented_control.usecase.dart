import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import 'starry_segmented_control.dart';

@UseCase(name: 'Two segments', type: StarrySegmentedControl)
Widget twoStarrySegmentedControl(BuildContext context) {
  return const _SegmentedDemo(labels: <String>['On', 'Off']);
}

@UseCase(name: 'Three segments', type: StarrySegmentedControl)
Widget threeStarrySegmentedControl(BuildContext context) {
  return const _SegmentedDemo(labels: <String>['Day', 'Week', 'Month']);
}

@UseCase(name: 'Playground', type: StarrySegmentedControl)
Widget playgroundStarrySegmentedControl(BuildContext context) {
  final count = context.knobs.intOrNull.slider(
    label: 'Segments',
    initialValue: 4,
    min: 2,
    max: 6,
  );
  final labels = List<String>.generate(count ?? 4, (i) => 'Tab ${i + 1}');
  return _SegmentedDemo(labels: labels);
}

class _SegmentedDemo extends StatefulWidget {
  const _SegmentedDemo({required this.labels});

  final List<String> labels;

  @override
  State<_SegmentedDemo> createState() => _SegmentedDemoState();
}

class _SegmentedDemoState extends State<_SegmentedDemo> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final index = _selected.clamp(0, widget.labels.length - 1);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 360,
          child: StarrySegmentedControl(
            labels: widget.labels,
            selectedIndex: index,
            onChanged: (i) => setState(() => _selected = i),
          ),
        ),
      ),
    );
  }
}
