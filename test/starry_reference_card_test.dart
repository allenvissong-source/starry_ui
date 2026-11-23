import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

Widget _host(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: Center(child: child)),
  );
}

/// An [ImageProvider] that always fails, to exercise `errorBuilder`.
class _FailingImageProvider extends ImageProvider<Object> {
  const _FailingImageProvider();

  @override
  Future<Object> obtainKey(ImageConfiguration configuration) async => this;

  @override
  ImageStreamCompleter loadImage(Object key, ImageDecoderCallback decode) {
    final controller = StreamController<ImageChunkEvent>();
    return MultiFrameImageStreamCompleter(
      codec: Future<Codec>.error(Exception('synthetic load failure')),
      chunkEvents: controller.stream,
      scale: 1,
    );
  }
}

void main() {
  group('StarryReferenceCard coverImage failure fallback', () {
    testWidgets('falls back to leadingIcon when coverImage fails to load', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const SizedBox(
            width: 360,
            child: StarryReferenceCard(
              title: 'Note',
              description: 'A referenced note.',
              coverImage: _FailingImageProvider(),
              leadingIcon: Icons.insert_drive_file_outlined,
            ),
          ),
        ),
      );
      // Let the (failing) image resolution complete and rebuild.
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.insert_drive_file_outlined), findsOneWidget);
    });
  });
}
