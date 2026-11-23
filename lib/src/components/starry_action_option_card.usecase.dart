import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import 'starry_action_option_card.dart';

@UseCase(name: 'Default', type: StarryActionOptionCard)
Widget defaultStarryActionOptionCard(BuildContext context) {
  return Center(
    child: SizedBox(
      width: 360,
      child: StarryActionOptionCard(
        icon: Icons.auto_awesome,
        title: 'Create with AI',
        description: 'Generate a draft from a short prompt.',
        onTap: () {},
      ),
    ),
  );
}

@UseCase(name: 'Disabled', type: StarryActionOptionCard)
Widget disabledStarryActionOptionCard(BuildContext context) {
  return Center(
    child: SizedBox(
      width: 360,
      child: StarryActionOptionCard(
        icon: Icons.lock_outline,
        title: 'Premium action',
        description: 'Upgrade to unlock this option.',
        enabled: false,
        onTap: () {},
      ),
    ),
  );
}

@UseCase(name: 'Playground', type: StarryActionOptionCard)
Widget playgroundStarryActionOptionCard(BuildContext context) {
  final enabled = context.knobs.boolean(label: 'Enabled', initialValue: true);
  final title = context.knobs.string(
    label: 'Title',
    initialValue: 'Import assets',
  );
  final description = context.knobs.string(
    label: 'Description',
    initialValue: 'Bring in files from your device.',
  );
  return Center(
    child: SizedBox(
      width: 360,
      child: StarryActionOptionCard(
        icon: Icons.upload_file_outlined,
        title: title,
        description: description,
        enabled: enabled,
        onTap: () {},
      ),
    ),
  );
}
