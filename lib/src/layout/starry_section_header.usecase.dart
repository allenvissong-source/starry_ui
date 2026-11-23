import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import 'starry_section_header.dart';

@UseCase(name: 'Primary', type: StarrySectionHeader)
Widget primaryStarrySectionHeader(BuildContext context) {
  return const Padding(
    padding: EdgeInsets.all(24),
    child: StarrySectionHeader(
      title: 'General',
      description: 'Account and appearance preferences.',
    ),
  );
}

@UseCase(name: 'Muted', type: StarrySectionHeader)
Widget mutedStarrySectionHeader(BuildContext context) {
  return const Padding(
    padding: EdgeInsets.all(24),
    child: StarrySectionHeader(
      title: 'Advanced',
      description: 'Developer-only settings.',
      tone: StarrySectionHeaderTone.muted,
    ),
  );
}

@UseCase(name: 'With child', type: StarrySectionHeader)
Widget childStarrySectionHeader(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(24),
    child: StarrySectionHeader(
      title: 'Notifications',
      description: 'Control how you get notified.',
      bottomSpacing: 12,
      child: FilledButton(onPressed: () {}, child: const Text('Manage')),
    ),
  );
}
