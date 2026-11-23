import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import 'starry_reference_card.dart';

@UseCase(name: 'Default', type: StarryReferenceCard)
Widget defaultStarryReferenceCard(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(24),
    child: StarryReferenceCard(
      title: 'Design system guidelines',
      description: 'starry_ui usage and token reference.',
      typeLabel: 'DOC',
      onTap: () {},
    ),
  );
}

@UseCase(name: 'Removable', type: StarryReferenceCard)
Widget removableStarryReferenceCard(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(24),
    child: StarryReferenceCard(
      title: 'Attached reference',
      description: 'Tap the corner badge to remove.',
      typeLabel: 'PDF',
      leadingIcon: Icons.picture_as_pdf_outlined,
      onTap: () {},
      onRemove: () {},
    ),
  );
}
