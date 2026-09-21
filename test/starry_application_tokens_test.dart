import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

void main() {
  for (final brightness in Brightness.values) {
    test('application roles derive from StarryTokens in $brightness', () {
      final base = brightness == Brightness.light
          ? StarryTokens.light
          : StarryTokens.dark;
      final app = StarryApplicationTokens.from(base, brightness);
      final semantic = base.semantic;

      expect(app.surface.pageBg, semantic.background);
      expect(app.surface.cardBg, semantic.surface);
      expect(app.surface.border, semantic.border);
      expect(app.surface.shadow, semantic.shadow);
      expect(app.surface.scrim, semantic.scrim);
      expect(app.text.primary, semantic.textPrimary);
      expect(app.text.secondary, semantic.textSecondary);
      expect(app.text.onAccent, semantic.onBrand);
      expect(app.text.onMedia, semantic.onMedia);
      expect(app.interaction.focus.border, semantic.brandStrong);
      expect(app.chrome.topBar, semantic.surface);
      expect(app.chrome.systemOverlay, semantic.background);
      expect(app.feed.feedPlaceholder, semantic.surfaceVariant);
      expect(app.media.mediaFrameBorder, semantic.border);
      expect(app.media.mediaPlaceholderIcon, semantic.brand);
      expect(app.media.mediaScrim, semantic.mediaOverlayEnd);
      expect(app.media.mediaLabelText, semantic.onMedia);
      expect(app.code.codeText, semantic.textPrimary);
      expect(app.code.diffAdded.a, closeTo(base.opacity.accentSurface, 0.001));
      expect(app.metric.statCard, semantic.surface);
      expect(app.metric.progressValue, semantic.brandStrong);
      expect(app.status.success.fg, semantic.success);
      expect(app.status.error.fg, semantic.error);
    });
  }

  testWidgets('context exposes one foundational and one application token graph', (
    tester,
  ) async {
    late StarryTokens foundational;
    late StarryApplicationTokens application;
    const base = StarryTokens.light;
    final app = StarryApplicationTokens.from(base, Brightness.light);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: <ThemeExtension<dynamic>>[base, app],
        ),
        home: Builder(
          builder: (context) {
            foundational = context.starryTokens;
            application = context.starryApplicationTokens;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(foundational, same(base));
    expect(application, same(app));
  });
}
