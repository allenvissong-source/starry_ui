import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

void main() {
  for (final dark in [false, true]) {
    testWidgets(
      'selected thumbnail border remains above opaque media: dark=$dark',
      (tester) async {
        final captureKey = GlobalKey();
        final tokens = dark ? StarryTokens.dark : StarryTokens.light;
        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? AppTheme.dark() : AppTheme.light(),
            home: Scaffold(
              body: Center(
                child: RepaintBoundary(
                  key: captureKey,
                  child: SizedBox(
                    width: 480,
                    height: 320,
                    child: StarryMediaPicker(
                      itemCount: 2,
                      mediaBuilder: (_, _) =>
                          const ColoredBox(color: Colors.red),
                      addLabel: 'Add',
                      cameraLabel: 'Camera',
                      galleryLabel: 'Gallery',
                      gridLabel: 'Grid',
                      removeLabel: 'Remove',
                      editLabel: 'Edit',
                      onAddFromCamera: () {},
                      onAddFromGallery: () {},
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        Future<void> expectBorder(String key) async {
          final tile = tester.getRect(find.byKey(ValueKey(key)));
          final boundaryRect = tester.getRect(find.byKey(captureKey));
          final boundary =
              captureKey.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 1);
          final bytes = (await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          ))!;
          final x = (tile.left - boundaryRect.left).round();
          final y = (tile.top - boundaryRect.top + tile.height / 4).round();
          final offset = (y * image.width + x) * 4;
          final expected = tokens.semantic.brand.toARGB32();
          for (var channel = 0; channel < 3; channel++) {
            expect(
              bytes.getUint8(offset + channel),
              closeTo((expected >> (16 - channel * 8)) & 255, 2),
            );
          }
          image.dispose();
        }

        await tester.runAsync(() => expectBorder('StarryMediaPicker.gridTile'));
        await tester.tap(
          find.byKey(const ValueKey('StarryMediaPicker.thumb.0')),
        );
        await tester.pumpAndSettle();
        await tester.runAsync(() => expectBorder('StarryMediaPicker.thumb.0'));
        expect(
          find.byKey(const ValueKey('StarryMediaPicker.preview')),
          findsOneWidget,
        );
        await tester.tap(
          find.byKey(const ValueKey('StarryMediaPicker.gridTile')),
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('StarryMediaPicker.grid')),
          findsOneWidget,
        );
      },
    );
  }
}
