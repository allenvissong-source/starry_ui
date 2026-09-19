import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import 'starry_asset_card.dart';

@UseCase(name: 'Empty', type: StarryAssetCard)
Widget emptyStarryAssetCard(BuildContext context) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: 200,
        height: 200,
        child: StarryAssetCard(
          title: 'Add cover',
          emptyIcon: Icons.add_photo_alternate_outlined,
          onTap: () {},
        ),
      ),
    ),
  );
}

@UseCase(name: 'With media', type: StarryAssetCard)
Widget mediaStarryAssetCard(BuildContext context) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: 200,
        height: 200,
        child: StarryAssetCard(
          title: 'Mountain vista',
          emptyIcon: Icons.image_outlined,
          onTap: () {},
          media: const ColoredBox(
            color: Color(0xFF6B8CB0),
          ), // hardcode-allow: Widgetbook 演示用占位色块，代表业务图片媒体，非设计语义色
        ),
      ),
    ),
  );
}
