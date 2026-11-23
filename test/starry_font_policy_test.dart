import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

void main() {
  test(
    'Web shares text font; native typography keeps its existing families',
    () {
      expect(
        StarryTypography.fontFamilyDisplay,
        kIsWeb ? 'Starry Sans Core' : 'packages/starry_ui/Outfit',
      );
      expect(
        StarryTypography.fontFamilyBody,
        kIsWeb ? 'Starry Sans Core' : 'packages/starry_ui/Inter',
      );
      expect(
        StarryTypography.fontFamilyCjk,
        kIsWeb ? 'Starry Sans Core' : 'packages/starry_ui/MiSans',
      );
      expect(
        StarryTypography.fontFamilyEmoji,
        kIsWeb ? 'Twemoji' : 'packages/starry_ui/Twemoji',
      );
      for (final typography in [
        StarryTokens.light.typography,
        StarryTokens.dark.typography,
      ]) {
        expect(
          typography.bodyMedium.textStyle.fontFamily,
          StarryTypography.fontFamilyBody,
        );
        expect(
          typography.titleLarge.textStyle.fontFamily,
          StarryTypography.fontFamilyDisplay,
        );
      }
    },
  );
}
