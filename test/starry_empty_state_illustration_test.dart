import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

Widget _host(Widget child, {bool dark = false, double scale = 1}) {
  return MaterialApp(
    theme: dark ? AppTheme.dark() : AppTheme.light(),
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: Scaffold(body: child),
      ),
    ),
  );
}

void main() {
  testWidgets('bundled artwork decodes and copy is below the decorative image', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.runAsync(() async {
      final data = await rootBundle.load(
        'packages/${StarryIllustration.packageName}/${StarryIllustration.noContent.assetPath}',
      );
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      expect(frame.image.width, 768);
      expect(frame.image.height, 768);
      frame.image.dispose();
      codec.dispose();
    });
    await tester.pumpWidget(
      _host(
        const StarryEmptyState(
          illustration: StarryIllustration.noContent,
          title: '这里还没有内容',
        ),
      ),
    );
    await tester.runAsync(() async {
      await precacheImage(
        const AssetImage(
          'assets/illustrations/states/empty/no_content.webp',
          package: 'starry_ui',
        ),
        tester.element(find.byType(StarryEmptyState)),
      );
    });
    await tester.pumpAndSettle();
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.excludeFromSemantics, isTrue);
    expect(find.byType(RawImage), findsOneWidget);
    expect(tester.widget<RawImage>(find.byType(RawImage)).image, isNotNull);
    expect(
      tester.getTopLeft(find.text('这里还没有内容')).dy,
      greaterThan(tester.getBottomLeft(find.byType(Image)).dy),
    );
    expect(find.bySemanticsLabel('这里还没有内容'), findsOneWidget);
    expect(find.byIcon(Icons.inbox_outlined), findsNothing);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('illustrated empty state supports sliver intrinsic sizing', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: StarryEmptyState(
                illustration: StarryIllustration.noContent,
                title: 'No content',
              ),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No content'), findsOneWidget);
    expect(tester.getSize(find.byType(Image)).width, greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'short narrow windows retain readable copy and reachable actions',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(240, 200);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      var pressed = false;
      for (final dark in [false, true]) {
        await tester.pumpWidget(
          _host(
            StarryEmptyState(
              illustration: StarryIllustration.noContent,
              title: 'No content is available in this library yet',
              message: 'Create something to begin.',
              action: StarryButton(
                label: 'Create',
                onPressed: () => pressed = true,
              ),
            ),
            dark: dark,
            scale: 2,
          ),
        );
        await tester.pumpAndSettle();
        final imageSize = tester.getSize(find.byType(Image));
        expect(imageSize.width, imageSize.height);
        expect(imageSize.height, lessThanOrEqualTo(100));
        await tester.ensureVisible(find.text('Create'));
        await tester.tap(find.text('Create'));
        expect(pressed, isTrue);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      }
    },
  );
}
