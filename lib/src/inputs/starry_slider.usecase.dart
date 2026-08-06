import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import 'starry_slider.dart';

@UseCase(name: 'Default', type: StarrySlider)
Widget defaultStarrySlider(BuildContext context) {
  return _StarrySliderDemo(
    builder: (value, onChanged) => StarrySlider(
      value: value,
      onChanged: onChanged,
    ),
  );
}

@UseCase(name: 'With header', type: StarrySlider)
Widget headerStarrySlider(BuildContext context) {
  return _StarrySliderDemo(
    builder: (value, onChanged) => StarrySlider(
      value: value,
      onChanged: onChanged,
      title: 'Temperature',
      valueText: '${value.round()}%',
    ),
  );
}

@UseCase(name: 'Playground', type: StarrySlider)
Widget playgroundStarrySlider(BuildContext context) {
  final divisions = context.knobs.intOrNull.slider(
    label: 'Divisions',
    initialValue: 10,
    min: 2,
    max: 20,
  );
  final showThumb = context.knobs.boolean(label: 'Show thumb', initialValue: true);
  final showHeader = context.knobs.boolean(label: 'Show header', initialValue: true);
  return _StarrySliderDemo(
    builder: (value, onChanged) => StarrySlider(
      value: value,
      onChanged: onChanged,
      divisions: divisions,
      showThumb: showThumb,
      title: showHeader ? 'Value' : null,
      valueText: showHeader ? value.round().toString() : null,
    ),
  );
}

class _StarrySliderDemo extends StatefulWidget {
  const _StarrySliderDemo({required this.builder});

  final Widget Function(double value, ValueChanged<double> onChanged) builder;

  @override
  State<_StarrySliderDemo> createState() => _StarrySliderDemoState();
}

class _StarrySliderDemoState extends State<_StarrySliderDemo> {
  double _value = 40;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 360,
          child: widget.builder(
            _value,
            (v) => setState(() => _value = v),
          ),
        ),
      ),
    );
  }
}
