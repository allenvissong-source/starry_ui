import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import 'starry_group_card.dart';
import 'starry_settings_tile.dart';

@UseCase(name: 'Default', type: StarryGroupCard)
Widget defaultStarryGroupCard(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(24),
    child: StarryGroupCard(
      children: <Widget>[
        StarrySettingsTile.navigation(title: 'Profile', onTap: () {}),
        StarrySettingsTile.value(
          title: 'Language',
          trailingText: 'English',
          onTap: () {},
        ),
        StarrySettingsTile.navigation(title: 'About', onTap: () {}),
      ],
    ),
  );
}

@UseCase(name: 'Elevated with action', type: StarryGroupCard)
Widget elevatedStarryGroupCard(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(24),
    child: StarryGroupCard(
      elevated: true,
      children: <Widget>[
        StarrySettingsTile.navigation(title: 'Members', onTap: () {}),
        const StarryGroupDivider(),
        StarryGroupAction(label: 'Add member', onPressed: () {}),
      ],
    ),
  );
}

@UseCase(name: 'Frosted', type: StarryGroupCard)
Widget frostedStarryGroupCard(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(24),
    child: StarryGroupCard(
      frosted: true,
      children: <Widget>[
        StarrySettingsTile.navigation(title: 'Frosted A', onTap: () {}),
        StarrySettingsTile.navigation(title: 'Frosted B', onTap: () {}),
      ],
    ),
  );
}
