import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Starry design-system tokens carried as a [ThemeExtension].
///
/// Color scales, semantic roles, radius, elevation and chart palette are all
/// spec-exact values extracted from the design source. Access at runtime via
/// `Theme.of(context).extension<StarryTokens>()!`.
@immutable
class StarryColorScale {
  const StarryColorScale({
    required this.s50,
    required this.s100,
    required this.s200,
    required this.s300,
    required this.s400,
    required this.s500,
    required this.s600,
    required this.s700,
    required this.s800,
    required this.s900,
  });

  final Color s50;
  final Color s100;
  final Color s200;
  final Color s300;
  final Color s400;
  final Color s500;
  final Color s600;
  final Color s700;
  final Color s800;
  final Color s900;

  /// Ordered light-to-dark list for palette rendering.
  List<Color> get stops =>
      [s50, s100, s200, s300, s400, s500, s600, s700, s800, s900];

  static StarryColorScale lerp(
      StarryColorScale a, StarryColorScale b, double t) {
    return StarryColorScale(
      s50: Color.lerp(a.s50, b.s50, t)!,
      s100: Color.lerp(a.s100, b.s100, t)!,
      s200: Color.lerp(a.s200, b.s200, t)!,
      s300: Color.lerp(a.s300, b.s300, t)!,
      s400: Color.lerp(a.s400, b.s400, t)!,
      s500: Color.lerp(a.s500, b.s500, t)!,
      s600: Color.lerp(a.s600, b.s600, t)!,
      s700: Color.lerp(a.s700, b.s700, t)!,
      s800: Color.lerp(a.s800, b.s800, t)!,
      s900: Color.lerp(a.s900, b.s900, t)!,
    );
  }
}

/// Semantic (role) colors that flip between light and dark themes.
@immutable
class StarrySemanticColors {
  const StarrySemanticColors({
    required this.brand,
    required this.brandStrong,
    required this.onBrand,
    required this.background,
    required this.backgroundSecondary,
    required this.backgroundTertiary,
    required this.surface,
    required this.surfaceVariant,
    required this.border,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.successBg,
    required this.success,
    required this.successStrong,
    required this.warningBg,
    required this.warning,
    required this.warningStrong,
    required this.errorBg,
    required this.error,
    required this.errorStrong,
    required this.infoBg,
    required this.info,
    required this.infoStrong,
  });

  final Color brand;
  final Color brandStrong;
  final Color onBrand;
  final Color background;
  final Color backgroundSecondary;
  final Color backgroundTertiary;
  final Color surface;
  final Color surfaceVariant;
  final Color border;
  final Color borderStrong;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;
  final Color successBg;
  final Color success;
  final Color successStrong;
  final Color warningBg;
  final Color warning;
  final Color warningStrong;
  final Color errorBg;
  final Color error;
  final Color errorStrong;
  final Color infoBg;
  final Color info;
  final Color infoStrong;

  static StarrySemanticColors lerp(
      StarrySemanticColors a, StarrySemanticColors b, double t) {
    Color l(Color x, Color y) => Color.lerp(x, y, t)!;
    return StarrySemanticColors(
      brand: l(a.brand, b.brand),
      brandStrong: l(a.brandStrong, b.brandStrong),
      onBrand: l(a.onBrand, b.onBrand),
      background: l(a.background, b.background),
      backgroundSecondary: l(a.backgroundSecondary, b.backgroundSecondary),
      backgroundTertiary: l(a.backgroundTertiary, b.backgroundTertiary),
      surface: l(a.surface, b.surface),
      surfaceVariant: l(a.surfaceVariant, b.surfaceVariant),
      border: l(a.border, b.border),
      borderStrong: l(a.borderStrong, b.borderStrong),
      textPrimary: l(a.textPrimary, b.textPrimary),
      textSecondary: l(a.textSecondary, b.textSecondary),
      textTertiary: l(a.textTertiary, b.textTertiary),
      textDisabled: l(a.textDisabled, b.textDisabled),
      successBg: l(a.successBg, b.successBg),
      success: l(a.success, b.success),
      successStrong: l(a.successStrong, b.successStrong),
      warningBg: l(a.warningBg, b.warningBg),
      warning: l(a.warning, b.warning),
      warningStrong: l(a.warningStrong, b.warningStrong),
      errorBg: l(a.errorBg, b.errorBg),
      error: l(a.error, b.error),
      errorStrong: l(a.errorStrong, b.errorStrong),
      infoBg: l(a.infoBg, b.infoBg),
      info: l(a.info, b.info),
      infoStrong: l(a.infoStrong, b.infoStrong),
    );
  }
}

/// Corner-radius scale (logical pixels).
@immutable
class StarryRadius {
  const StarryRadius();
  final double none = 0;
  final double xs = 4;
  final double sm = 8;
  final double md = 12;
  final double lg = 16;
  final double xl = 20;
  final double xxl = 28;
  final double full = 999;
}

/// Elevation ramp, expressed as ready-to-use shadow lists (4 levels).
@immutable
class StarryElevation {
  const StarryElevation({
    required this.level1,
    required this.level2,
    required this.level3,
    required this.level4,
  });

  final List<BoxShadow> level1;
  final List<BoxShadow> level2;
  final List<BoxShadow> level3;
  final List<BoxShadow> level4;

  List<List<BoxShadow>> get levels => [level1, level2, level3, level4];

  static const StarryElevation light = StarryElevation(
    // shadow/sm: 0 1 2 · 5%  +  0 1 1 · 3%
    level1: [
      BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
      BoxShadow(color: Color(0x08000000), blurRadius: 1, offset: Offset(0, 1)),
    ],
    // shadow/md: 0 4 16 -4 · 10%  +  0 2 4 -2 · 6%
    level2: [
      BoxShadow(
          color: Color(0x1A000000),
          blurRadius: 16,
          spreadRadius: -4,
          offset: Offset(0, 4)),
      BoxShadow(
          color: Color(0x0F000000),
          blurRadius: 4,
          spreadRadius: -2,
          offset: Offset(0, 2)),
    ],
    // shadow/lg: 0 8 24 -6 · 12%  +  0 4 8 -4 · 8%
    level3: [
      BoxShadow(
          color: Color(0x1F000000),
          blurRadius: 24,
          spreadRadius: -6,
          offset: Offset(0, 8)),
      BoxShadow(
          color: Color(0x14000000),
          blurRadius: 8,
          spreadRadius: -4,
          offset: Offset(0, 4)),
    ],
    // shadow/xl: 0 24 64 -16 · 25%  +  0 12 28 -12 · 15%
    level4: [
      BoxShadow(
          color: Color(0x40000000),
          blurRadius: 64,
          spreadRadius: -16,
          offset: Offset(0, 24)),
      BoxShadow(
          color: Color(0x26000000),
          blurRadius: 28,
          spreadRadius: -12,
          offset: Offset(0, 12)),
    ],
  );

  static const StarryElevation dark = StarryElevation(
    // shadow/sm: 0 1 2 · 50%
    level1: [
      BoxShadow(color: Color(0x80000000), blurRadius: 2, offset: Offset(0, 1)),
    ],
    // shadow/md: 0 4 16 -4 · 55%  +  0 2 4 -2 · 45%
    level2: [
      BoxShadow(
          color: Color(0x8C000000),
          blurRadius: 16,
          spreadRadius: -4,
          offset: Offset(0, 4)),
      BoxShadow(
          color: Color(0x73000000),
          blurRadius: 4,
          spreadRadius: -2,
          offset: Offset(0, 2)),
    ],
    // shadow/lg: 0 8 24 -6 · 60%  +  0 4 8 -4 · 50%
    level3: [
      BoxShadow(
          color: Color(0x99000000),
          blurRadius: 24,
          spreadRadius: -6,
          offset: Offset(0, 8)),
      BoxShadow(
          color: Color(0x80000000),
          blurRadius: 8,
          spreadRadius: -4,
          offset: Offset(0, 4)),
    ],
    // shadow/xl: 0 24 64 -16 · 65%  +  brand ring 10% (#AA99FF)
    level4: [
      BoxShadow(
          color: Color(0xA6000000),
          blurRadius: 64,
          spreadRadius: -16,
          offset: Offset(0, 24)),
      BoxShadow(
          color: Color(0x1AAA99FF),
          blurRadius: 28,
          spreadRadius: -12,
          offset: Offset(0, 12)),
    ],
  );

  static StarryElevation lerp(StarryElevation a, StarryElevation b, double t) {
    List<BoxShadow> l(List<BoxShadow> x, List<BoxShadow> y) =>
        BoxShadow.lerpList(x, y, t) ?? x;
    return StarryElevation(
      level1: l(a.level1, b.level1),
      level2: l(a.level2, b.level2),
      level3: l(a.level3, b.level3),
      level4: l(a.level4, b.level4),
    );
  }
}

/// A single type-ramp entry (size + line height in logical pixels).
@immutable
class StarryTextStyleToken {
  const StarryTextStyleToken(this.size, this.lineHeight);

  final double size;
  final double lineHeight;

  /// Line height expressed as a Flutter `height` multiple of the font size.
  double get heightFactor => lineHeight / size;

  /// Ready-to-use [TextStyle] with size + relative line height applied.
  TextStyle get textStyle => TextStyle(fontSize: size, height: heightFactor);

  static StarryTextStyleToken lerp(
      StarryTextStyleToken a, StarryTextStyleToken b, double t) {
    return StarryTextStyleToken(
      lerpDouble(a.size, b.size, t)!,
      lerpDouble(a.lineHeight, b.lineHeight, t)!,
    );
  }
}

/// Type ramp (display → label). Values are spec-exact size/lineHeight pairs
/// and are shared across light & dark themes.
@immutable
class StarryTypography {
  const StarryTypography({
    required this.displayLarge,
    required this.displayMedium,
    required this.displaySmall,
    required this.headlineLarge,
    required this.headlineMedium,
    required this.headlineSmall,
    required this.titleLarge,
    required this.titleMedium,
    required this.titleSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
  });

  final StarryTextStyleToken displayLarge;
  final StarryTextStyleToken displayMedium;
  final StarryTextStyleToken displaySmall;
  final StarryTextStyleToken headlineLarge;
  final StarryTextStyleToken headlineMedium;
  final StarryTextStyleToken headlineSmall;
  final StarryTextStyleToken titleLarge;
  final StarryTextStyleToken titleMedium;
  final StarryTextStyleToken titleSmall;
  final StarryTextStyleToken bodyLarge;
  final StarryTextStyleToken bodyMedium;
  final StarryTextStyleToken bodySmall;
  final StarryTextStyleToken labelLarge;
  final StarryTextStyleToken labelMedium;
  final StarryTextStyleToken labelSmall;

  static const StarryTypography standard = StarryTypography(
    displayLarge: StarryTextStyleToken(57, 64),
    displayMedium: StarryTextStyleToken(45, 52),
    displaySmall: StarryTextStyleToken(36, 44),
    headlineLarge: StarryTextStyleToken(32, 40),
    headlineMedium: StarryTextStyleToken(28, 36),
    headlineSmall: StarryTextStyleToken(24, 32),
    titleLarge: StarryTextStyleToken(22, 28),
    titleMedium: StarryTextStyleToken(16, 24),
    titleSmall: StarryTextStyleToken(14, 20),
    bodyLarge: StarryTextStyleToken(16, 24),
    bodyMedium: StarryTextStyleToken(14, 20),
    bodySmall: StarryTextStyleToken(12, 16),
    labelLarge: StarryTextStyleToken(14, 20),
    labelMedium: StarryTextStyleToken(12, 16),
    labelSmall: StarryTextStyleToken(11, 16),
  );

  /// Ordered ramp for palette/spec rendering: (name, token) pairs.
  List<(String, StarryTextStyleToken)> get ramp => [
        ('displayLarge', displayLarge),
        ('displayMedium', displayMedium),
        ('displaySmall', displaySmall),
        ('headlineLarge', headlineLarge),
        ('headlineMedium', headlineMedium),
        ('headlineSmall', headlineSmall),
        ('titleLarge', titleLarge),
        ('titleMedium', titleMedium),
        ('titleSmall', titleSmall),
        ('bodyLarge', bodyLarge),
        ('bodyMedium', bodyMedium),
        ('bodySmall', bodySmall),
        ('labelLarge', labelLarge),
        ('labelMedium', labelMedium),
        ('labelSmall', labelSmall),
      ];

  static StarryTypography lerp(
      StarryTypography a, StarryTypography b, double t) {
    StarryTextStyleToken l(StarryTextStyleToken x, StarryTextStyleToken y) =>
        StarryTextStyleToken.lerp(x, y, t);
    return StarryTypography(
      displayLarge: l(a.displayLarge, b.displayLarge),
      displayMedium: l(a.displayMedium, b.displayMedium),
      displaySmall: l(a.displaySmall, b.displaySmall),
      headlineLarge: l(a.headlineLarge, b.headlineLarge),
      headlineMedium: l(a.headlineMedium, b.headlineMedium),
      headlineSmall: l(a.headlineSmall, b.headlineSmall),
      titleLarge: l(a.titleLarge, b.titleLarge),
      titleMedium: l(a.titleMedium, b.titleMedium),
      titleSmall: l(a.titleSmall, b.titleSmall),
      bodyLarge: l(a.bodyLarge, b.bodyLarge),
      bodyMedium: l(a.bodyMedium, b.bodyMedium),
      bodySmall: l(a.bodySmall, b.bodySmall),
      labelLarge: l(a.labelLarge, b.labelLarge),
      labelMedium: l(a.labelMedium, b.labelMedium),
      labelSmall: l(a.labelSmall, b.labelSmall),
    );
  }
}

/// Spacing scale (logical pixels, 4-based rhythm).
@immutable
class StarrySpacing {
  const StarrySpacing();
  // 4px base, 11-step scale (spec 05 · 间距 Spacing). Named by numeric key.
  final double s0 = 0;
  final double s1 = 4;
  final double s2 = 8;
  final double s3 = 12;
  final double s4 = 16;
  final double s5 = 20;
  final double s6 = 24;
  final double s8 = 32;
  final double s10 = 40;
  final double s12 = 48;
  final double s16 = 64;

  /// Ordered (name, value) pairs for spec rendering.
  List<(String, double)> get steps => [
        ('spacing/0', s0),
        ('spacing/1', s1),
        ('spacing/2', s2),
        ('spacing/3', s3),
        ('spacing/4', s4),
        ('spacing/5', s5),
        ('spacing/6', s6),
        ('spacing/8', s8),
        ('spacing/10', s10),
        ('spacing/12', s12),
        ('spacing/16', s16),
      ];
}

/// Motion durations and easing curves.
@immutable
class StarryMotion {
  const StarryMotion({
    required this.durationShort,
    required this.durationMedium,
    required this.durationLong,
    required this.easingStandard,
    required this.easingEmphasized,
  });

  final Duration durationShort;
  final Duration durationMedium;
  final Duration durationLong;
  final Curve easingStandard;
  final Curve easingEmphasized;

  static const StarryMotion standard = StarryMotion(
    durationShort: Duration(milliseconds: 150),
    durationMedium: Duration(milliseconds: 300),
    durationLong: Duration(milliseconds: 500),
    easingStandard: Cubic(0.2, 0, 0, 1),
    easingEmphasized: Cubic(0.2, 0, 0, 1),
  );

  static StarryMotion lerp(StarryMotion a, StarryMotion b, double t) {
    return t < 0.5 ? a : b;
  }
}

/// Brand-custom colors that flip between light and dark themes.
@immutable
class StarryBrandColors {
  const StarryBrandColors({
    required this.brandGold,
    required this.characterCardBg,
    required this.feedCardBg,
    required this.feedDivider,
    required this.gradientStart,
    required this.gradientEnd,
  });

  final Color brandGold;
  final Color characterCardBg;
  final Color feedCardBg;
  final Color feedDivider;
  final Color gradientStart;
  final Color gradientEnd;

  static StarryBrandColors lerp(
      StarryBrandColors a, StarryBrandColors b, double t) {
    Color l(Color x, Color y) => Color.lerp(x, y, t)!;
    return StarryBrandColors(
      brandGold: l(a.brandGold, b.brandGold),
      characterCardBg: l(a.characterCardBg, b.characterCardBg),
      feedCardBg: l(a.feedCardBg, b.feedCardBg),
      feedDivider: l(a.feedDivider, b.feedDivider),
      gradientStart: l(a.gradientStart, b.gradientStart),
      gradientEnd: l(a.gradientEnd, b.gradientEnd),
    );
  }
}

@immutable
class StarryTokens extends ThemeExtension<StarryTokens> {
  const StarryTokens({
    required this.purple,
    required this.blue,
    required this.gray,
    required this.mint,
    required this.coral,
    required this.semantic,
    required this.radius,
    required this.elevation,
    required this.chart,
    required this.typography,
    required this.spacing,
    required this.motion,
    required this.brand,
  });

  final StarryColorScale purple;
  final StarryColorScale blue;
  final StarryColorScale gray;
  final StarryColorScale mint;
  final StarryColorScale coral;
  final StarrySemanticColors semantic;
  final StarryRadius radius;
  final StarryElevation elevation;

  /// Categorical chart palette (chart1..chart8).
  final List<Color> chart;

  /// Type ramp (spec-exact font size / line height).
  final StarryTypography typography;

  /// Spacing scale (4-based rhythm).
  final StarrySpacing spacing;

  /// Motion durations and easing curves.
  final StarryMotion motion;

  /// Brand-custom colors (gold accent, card backgrounds, gradient).
  final StarryBrandColors brand;

  // ---- Spec-exact color scales (shared across light & dark) ----
  static const StarryColorScale _purple = StarryColorScale(
    s50: Color(0xFFF5F5FF),
    s100: Color(0xFFEDEBFF),
    s200: Color(0xFFDBD6FF),
    s300: Color(0xFFC7BAFF),
    s400: Color(0xFFAB99FF),
    s500: Color(0xFF9178F5),
    s600: Color(0xFF7A5CE8),
    s700: Color(0xFF6642D1),
    s800: Color(0xFF5238A8),
    s900: Color(0xFF402E82),
  );

  // Blue 50-700 are spec-exact; 800/900 extrapolated for scale parity.
  static const StarryColorScale _blue = StarryColorScale(
    s50: Color(0xFFF0F7FF),
    s100: Color(0xFFE0F0FF),
    s200: Color(0xFFC2DEFF),
    s300: Color(0xFF99C4FF),
    s400: Color(0xFF70A8FF),
    s500: Color(0xFF4F8CF7),
    s600: Color(0xFF3373E6),
    s700: Color(0xFF245CC7),
    s800: Color(0xFF1B4699),
    s900: Color(0xFF132F66),
  );

  static const StarryColorScale _gray = StarryColorScale(
    s50: Color(0xFFF7F7FA),
    s100: Color(0xFFF0F0F5),
    s200: Color(0xFFE3E3EB),
    s300: Color(0xFFC9C9D6),
    s400: Color(0xFFA3A3B8),
    s500: Color(0xFF7A7A94),
    s600: Color(0xFF575770),
    s700: Color(0xFF3D3D4D),
    s800: Color(0xFF292933),
    s900: Color(0xFF17171C),
  );

  static const StarryColorScale _mint = StarryColorScale(
    s50: Color(0xFFEDFCFA),
    s100: Color(0xFFD4F7F0),
    s200: Color(0xFFA1EDDE),
    s300: Color(0xFF5EEBD4),
    s400: Color(0xFF36DEBD),
    s500: Color(0xFF1FC2A1),
    s600: Color(0xFF1C9C82),
    s700: Color(0xFF177863),
    s800: Color(0xFF145245),
    s900: Color(0xFF0F382E),
  );

  static const StarryColorScale _coral = StarryColorScale(
    s50: Color(0xFFFFEBF0),
    s100: Color(0xFFFFD6DE),
    s200: Color(0xFFFFB3C2),
    s300: Color(0xFFFF8AA1),
    s400: Color(0xFFFF7A99),
    s500: Color(0xFFF53D61),
    s600: Color(0xFFE31C45),
    s700: Color(0xFFAD1F3B),
    s800: Color(0xFF7D1C30),
    s900: Color(0xFF4F1721),
  );

  static const List<Color> _chart = [
    Color(0xFFAB99FF), // chart1 purple
    Color(0xFF70A8FF), // chart2 blue
    Color(0xFF3DD699), // chart3 mint
    Color(0xFFFFB021), // chart4 amber
    Color(0xFFFF6B61), // chart5 coral
    Color(0xFF21D4ED), // chart6 cyan
    Color(0xFFF573B5), // chart7 pink
    Color(0xFFA3A3B8), // chart8 gray
  ];

  // Brand-custom colors. brandGold is the design-system accent; card/divider
  // backgrounds and the brand gradient are tuned per brightness.
  static const StarryBrandColors _lightBrand = StarryBrandColors(
    brandGold: Color(0xFFCBA13A),
    characterCardBg: Color(0xFFF3F0FF),
    feedCardBg: Color(0xFFFFFFFF),
    feedDivider: Color(0xFFE3E3EB),
    gradientStart: Color(0xFFAB99FF),
    gradientEnd: Color(0xFF7A5CE8),
  );

  static const StarryBrandColors _darkBrand = StarryBrandColors(
    brandGold: Color(0xFFD8B44E),
    characterCardBg: Color(0xFF2A2440),
    feedCardBg: Color(0xFF1E1E26),
    feedDivider: Color(0xFF40404C),
    gradientStart: Color(0xFFB7A9FF),
    gradientEnd: Color(0xFF7A5CE8),
  );

  static const StarrySemanticColors _lightSemantic = StarrySemanticColors(
    brand: Color(0xFFAA99FF),
    brandStrong: Color(0xFF9179F5),
    onBrand: Color(0xFF241B45),
    background: Color(0xFFFFFFFF),
    backgroundSecondary: Color(0xFFF7F7FA),
    backgroundTertiary: Color(0xFFEFEFF4),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF3F0FF),
    border: Color(0xFFE4E4EB),
    borderStrong: Color(0xFFC9C9D6),
    textPrimary: Color(0xFF17171D),
    textSecondary: Color(0xFF565670),
    textTertiary: Color(0xFF9C9CAD),
    textDisabled: Color(0xFFC9C9D6),
    successBg: Color(0xFFDCFCE7),
    success: Color(0xFF16A34A),
    successStrong: Color(0xFF15803D),
    warningBg: Color(0xFFFEF3C7),
    warning: Color(0xFFF59E0B),
    warningStrong: Color(0xFFB45309),
    errorBg: Color(0xFFFEE2E2),
    error: Color(0xFFEF4444),
    errorStrong: Color(0xFFDC2626),
    infoBg: Color(0xFFCFFAFE),
    info: Color(0xFF0891B2),
    infoStrong: Color(0xFF0E7490),
  );

  static const StarrySemanticColors _darkSemantic = StarrySemanticColors(
    brand: Color(0xFFB7A9FF),
    brandStrong: Color(0xFFAA99FF),
    onBrand: Color(0xFF241B45),
    background: Color(0xFF121217),
    backgroundSecondary: Color(0xFF1A1A21),
    backgroundTertiary: Color(0xFF222229),
    surface: Color(0xFF1E1E26),
    surfaceVariant: Color(0xFF2A2440),
    border: Color(0xFF2E2E38),
    borderStrong: Color(0xFF40404C),
    textPrimary: Color(0xFFF5F5F8),
    textSecondary: Color(0xFFA8A8BA),
    textTertiary: Color(0xFF6E6E7E),
    textDisabled: Color(0xFF484852),
    successBg: Color(0xFF0B2E1A),
    success: Color(0xFF4ADE80),
    successStrong: Color(0xFF86EFAC),
    warningBg: Color(0xFF2E2008),
    warning: Color(0xFFFBBF24),
    warningStrong: Color(0xFFFCD34D),
    errorBg: Color(0xFF2E0D0D),
    error: Color(0xFFF87171),
    errorStrong: Color(0xFFFCA5A5),
    infoBg: Color(0xFF08303A),
    info: Color(0xFF22D3EE),
    infoStrong: Color(0xFF67E8F9),
  );

  static const StarryTokens light = StarryTokens(
    purple: _purple,
    blue: _blue,
    gray: _gray,
    mint: _mint,
    coral: _coral,
    semantic: _lightSemantic,
    radius: StarryRadius(),
    elevation: StarryElevation.light,
    chart: _chart,
    typography: StarryTypography.standard,
    spacing: StarrySpacing(),
    motion: StarryMotion.standard,
    brand: _lightBrand,
  );

  static const StarryTokens dark = StarryTokens(
    purple: _purple,
    blue: _blue,
    gray: _gray,
    mint: _mint,
    coral: _coral,
    semantic: _darkSemantic,
    radius: StarryRadius(),
    elevation: StarryElevation.dark,
    chart: _chart,
    typography: StarryTypography.standard,
    spacing: StarrySpacing(),
    motion: StarryMotion.standard,
    brand: _darkBrand,
  );

  @override
  StarryTokens copyWith({
    StarryColorScale? purple,
    StarryColorScale? blue,
    StarryColorScale? gray,
    StarryColorScale? mint,
    StarryColorScale? coral,
    StarrySemanticColors? semantic,
    StarryRadius? radius,
    StarryElevation? elevation,
    List<Color>? chart,
    StarryTypography? typography,
    StarrySpacing? spacing,
    StarryMotion? motion,
    StarryBrandColors? brand,
  }) {
    return StarryTokens(
      purple: purple ?? this.purple,
      blue: blue ?? this.blue,
      gray: gray ?? this.gray,
      mint: mint ?? this.mint,
      coral: coral ?? this.coral,
      semantic: semantic ?? this.semantic,
      radius: radius ?? this.radius,
      elevation: elevation ?? this.elevation,
      chart: chart ?? this.chart,
      typography: typography ?? this.typography,
      spacing: spacing ?? this.spacing,
      motion: motion ?? this.motion,
      brand: brand ?? this.brand,
    );
  }

  @override
  StarryTokens lerp(ThemeExtension<StarryTokens>? other, double t) {
    if (other is! StarryTokens) return this;
    return StarryTokens(
      purple: StarryColorScale.lerp(purple, other.purple, t),
      blue: StarryColorScale.lerp(blue, other.blue, t),
      gray: StarryColorScale.lerp(gray, other.gray, t),
      mint: StarryColorScale.lerp(mint, other.mint, t),
      coral: StarryColorScale.lerp(coral, other.coral, t),
      semantic: StarrySemanticColors.lerp(semantic, other.semantic, t),
      radius: t < 0.5 ? radius : other.radius,
      elevation: StarryElevation.lerp(elevation, other.elevation, t),
      chart: [
        for (var i = 0; i < chart.length; i++)
          Color.lerp(chart[i], other.chart[i], t)!,
      ],
      typography: StarryTypography.lerp(typography, other.typography, t),
      spacing: t < 0.5 ? spacing : other.spacing,
      motion: StarryMotion.lerp(motion, other.motion, t),
      brand: StarryBrandColors.lerp(brand, other.brand, t),
    );
  }
}
