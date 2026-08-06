import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import 'package:widgetbook/widgetbook.dart';

import '../theme/starry_tokens.dart';
import 'starry_toggle_icon_button.dart';

@UseCase(name: 'Playground', type: StarryToggleIconButton)
Widget playgroundStarryToggleIconButton(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  final enabled = context.knobs.boolean(label: 'Enabled', initialValue: true);
  return Center(
    child: Padding(
      padding: EdgeInsets.all(t.spacing.s6),
      child: _ToggleHost(enabled: enabled),
    ),
  );
}

class _ToggleHost extends StatefulWidget {
  const _ToggleHost({required this.enabled});
  final bool enabled;
  @override
  State<_ToggleHost> createState() => _ToggleHostState();
}

class _ToggleHostState extends State<_ToggleHost> {
  bool _selected = false;
  @override
  Widget build(BuildContext context) {
    return StarryToggleIconButton(
      icon: Icons.bookmark_border,
      selectedIcon: Icons.bookmark,
      selected: _selected,
      tooltip: 'Bookmark',
      enabled: widget.enabled,
      onChanged: (v) => setState(() => _selected = v),
    );
  }
}
