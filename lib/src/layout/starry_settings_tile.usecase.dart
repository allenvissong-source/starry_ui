import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import 'starry_settings_tile.dart';

@UseCase(name: 'Navigation', type: StarrySettingsTile)
Widget navigationStarrySettingsTile(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(24),
    child: StarrySettingsTile.navigation(
      title: 'Account',
      subtitle: 'Manage your profile',
      leading: const Icon(Icons.person_outline),
      onTap: () {},
    ),
  );
}

@UseCase(name: 'Value', type: StarrySettingsTile)
Widget valueStarrySettingsTile(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(24),
    child: StarrySettingsTile.value(
      title: 'Language',
      trailingText: 'English',
      leading: const Icon(Icons.language_outlined),
      onTap: () {},
    ),
  );
}

@UseCase(name: 'Toggle', type: StarrySettingsTile)
Widget toggleStarrySettingsTile(BuildContext context) {
  return const _ToggleTileDemo();
}

@UseCase(name: 'Destructive', type: StarrySettingsTile)
Widget destructiveStarrySettingsTile(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(24),
    child: StarrySettingsTile.navigation(
      title: 'Delete account',
      destructive: true,
      leading: const Icon(Icons.delete_outline),
      onTap: () {},
    ),
  );
}

class _ToggleTileDemo extends StatefulWidget {
  const _ToggleTileDemo();

  @override
  State<_ToggleTileDemo> createState() => _ToggleTileDemoState();
}

class _ToggleTileDemoState extends State<_ToggleTileDemo> {
  bool _on = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: StarrySettingsTile.toggle(
        title: 'Dark mode',
        subtitle: 'Use the dark theme',
        value: _on,
        onChanged: (v) => setState(() => _on = v),
      ),
    );
  }
}
