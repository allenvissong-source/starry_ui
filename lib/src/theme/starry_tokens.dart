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
  List<Color> get stops => [
    s50,
    s100,
    s200,
    s300,
    s400,
    s500,
    s600,
    s700,
    s800,
    s900,
  ];

  static StarryColorScale lerp(
    StarryColorScale a,
    StarryColorScale b,
    double t,
  ) {
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
    required this.onError,
    required this.onMedia,
    required this.mediaOverlayEnd,
    required this.infoBg,
    required this.info,
    required this.infoStrong,
    required this.scrim,
    required this.shadow,
    required this.inverseSurface,
    required this.onInverseSurface,
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
  final Color onError;

  /// Foreground color painted on top of photographic / media surfaces
  /// (e.g. glass-panel hairline border, text over a hero image). White in
  /// both themes because media backdrops are treated as dark regardless of
  /// the app brightness.
  final Color onMedia;

  /// Opaque-tending end stop for the bottom scrim gradient painted over media
  /// (image/video) so light overlay content stays legible. The gradient starts
  /// transparent at the top and lands on this color at the bottom.
  final Color mediaOverlayEnd;
  final Color infoBg;
  final Color info;
  final Color infoStrong;

  /// Modal / dialog barrier scrim painted behind a modal route. Distinct from
  /// [mediaOverlayEnd] (which is the bottom gradient end over photographic
  /// media): this is the flat barrier dim used by `ColorScheme.scrim`.
  final Color scrim;

  /// Default elevation shadow colour used by `ColorScheme.shadow` (the single
  /// fallback Material reads; the per-level shadows live on [StarryElevation]).
  final Color shadow;

  /// Surface inverted against the active theme (e.g. snackbar / tooltip
  /// background): the opposite theme's surface. Pairs with [onInverseSurface].
  final Color inverseSurface;

  /// Content colour painted on [inverseSurface].
  final Color onInverseSurface;

  static StarrySemanticColors lerp(
    StarrySemanticColors a,
    StarrySemanticColors b,
    double t,
  ) {
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
      onError: l(a.onError, b.onError),
      onMedia: l(a.onMedia, b.onMedia),
      mediaOverlayEnd: l(a.mediaOverlayEnd, b.mediaOverlayEnd),
      infoBg: l(a.infoBg, b.infoBg),
      info: l(a.info, b.info),
      infoStrong: l(a.infoStrong, b.infoStrong),
      scrim: l(a.scrim, b.scrim),
      shadow: l(a.shadow, b.shadow),
      inverseSurface: l(a.inverseSurface, b.inverseSurface),
      onInverseSurface: l(a.onInverseSurface, b.onInverseSurface),
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
    required this.glass,
  });

  final List<BoxShadow> level1;
  final List<BoxShadow> level2;
  final List<BoxShadow> level3;
  final List<BoxShadow> level4;

  /// Diffuse glass-component shadow (single soft tier). Sits outside the
  /// numbered elevation ramp and is not part of [levels].
  final List<BoxShadow> glass;

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
        offset: Offset(0, 4),
      ),
      BoxShadow(
        color: Color(0x0F000000),
        blurRadius: 4,
        spreadRadius: -2,
        offset: Offset(0, 2),
      ),
    ],
    // shadow/lg: 0 8 24 -6 · 12%  +  0 4 8 -4 · 8%
    level3: [
      BoxShadow(
        color: Color(0x1F000000),
        blurRadius: 24,
        spreadRadius: -6,
        offset: Offset(0, 8),
      ),
      BoxShadow(
        color: Color(0x14000000),
        blurRadius: 8,
        spreadRadius: -4,
        offset: Offset(0, 4),
      ),
    ],
    // shadow/xl: 0 24 64 -16 · 25%  +  0 12 28 -12 · 15%
    level4: [
      BoxShadow(
        color: Color(0x40000000),
        blurRadius: 64,
        spreadRadius: -16,
        offset: Offset(0, 24),
      ),
      BoxShadow(
        color: Color(0x26000000),
        blurRadius: 28,
        spreadRadius: -12,
        offset: Offset(0, 12),
      ),
    ],
    // shadow/glass: 0 16 36 · 14%
    glass: [
      BoxShadow(
        color: Color(0x24000000),
        blurRadius: 36,
        offset: Offset(0, 16),
      ),
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
        offset: Offset(0, 4),
      ),
      BoxShadow(
        color: Color(0x73000000),
        blurRadius: 4,
        spreadRadius: -2,
        offset: Offset(0, 2),
      ),
    ],
    // shadow/lg: 0 8 24 -6 · 60%  +  0 4 8 -4 · 50%
    level3: [
      BoxShadow(
        color: Color(0x99000000),
        blurRadius: 24,
        spreadRadius: -6,
        offset: Offset(0, 8),
      ),
      BoxShadow(
        color: Color(0x80000000),
        blurRadius: 8,
        spreadRadius: -4,
        offset: Offset(0, 4),
      ),
    ],
    // shadow/xl: 0 24 64 -16 · 65%  +  brand ring 10% (#AA99FF)
    level4: [
      BoxShadow(
        color: Color(0xA6000000),
        blurRadius: 64,
        spreadRadius: -16,
        offset: Offset(0, 24),
      ),
      BoxShadow(
        color: Color(0x1AAA99FF),
        blurRadius: 28,
        spreadRadius: -12,
        offset: Offset(0, 12),
      ),
    ],
    // shadow/glass: 0 16 36 · 7% (dark halves the light opacity)
    glass: [
      BoxShadow(
        color: Color(0x12000000),
        blurRadius: 36,
        offset: Offset(0, 16),
      ),
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
      glass: l(a.glass, b.glass),
    );
  }
}

/// A single type-ramp entry (size + line height in logical pixels).
@immutable
class StarryTextStyleToken {
  const StarryTextStyleToken(this.size, this.lineHeight, {this.fontFamily});

  final double size;
  final double lineHeight;

  /// Primary font family for this ramp entry (Latin script). When null the
  /// platform default is used. CJK / emoji glyphs resolve through
  /// [StarryTypography.fontFamilyFallback].
  final String? fontFamily;

  /// Line height expressed as a Flutter `height` multiple of the font size.
  double get heightFactor => lineHeight / size;

  /// Ready-to-use [TextStyle] with size + relative line height + font families
  /// applied. Latin text uses [fontFamily]; CJK falls back to MiSans and emoji
  /// to Twemoji via [StarryTypography.fontFamilyFallback].
  TextStyle get textStyle => TextStyle(
    fontSize: size,
    height: heightFactor,
    fontFamily: fontFamily,
    fontFamilyFallback: StarryTypography.fontFamilyFallback,
  );

  static StarryTextStyleToken lerp(
    StarryTextStyleToken a,
    StarryTextStyleToken b,
    double t,
  ) {
    return StarryTextStyleToken(
      lerpDouble(a.size, b.size, t)!,
      lerpDouble(a.lineHeight, b.lineHeight, t)!,
      fontFamily: t < 0.5 ? a.fontFamily : b.fontFamily,
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

  /// Latin font family for display / headline / title ramp entries.
  static const String fontFamilyDisplay = 'Outfit';

  /// Latin font family for body / label ramp entries.
  static const String fontFamilyBody = 'Inter';

  /// Emoji font family (color glyphs).
  static const String fontFamilyEmoji = 'Twemoji';

  /// CJK font family (single track, differentiated by weight only).
  static const String fontFamilyCjk = 'MiSans';

  /// Shared fallback chain: CJK glyphs resolve to MiSans, emoji to Twemoji.
  /// Applied to every ramp entry so mixed CN / EN / emoji text renders
  /// correctly regardless of the primary Latin family.
  static const List<String> fontFamilyFallback = <String>[
    fontFamilyCjk,
    fontFamilyEmoji,
  ];

  static const StarryTypography standard = StarryTypography(
    displayLarge: StarryTextStyleToken(57, 64, fontFamily: fontFamilyDisplay),
    displayMedium: StarryTextStyleToken(45, 52, fontFamily: fontFamilyDisplay),
    displaySmall: StarryTextStyleToken(36, 44, fontFamily: fontFamilyDisplay),
    headlineLarge: StarryTextStyleToken(32, 40, fontFamily: fontFamilyDisplay),
    headlineMedium: StarryTextStyleToken(28, 36, fontFamily: fontFamilyDisplay),
    headlineSmall: StarryTextStyleToken(24, 32, fontFamily: fontFamilyDisplay),
    titleLarge: StarryTextStyleToken(22, 28, fontFamily: fontFamilyDisplay),
    titleMedium: StarryTextStyleToken(16, 24, fontFamily: fontFamilyDisplay),
    titleSmall: StarryTextStyleToken(14, 20, fontFamily: fontFamilyDisplay),
    bodyLarge: StarryTextStyleToken(16, 24, fontFamily: fontFamilyBody),
    bodyMedium: StarryTextStyleToken(14, 20, fontFamily: fontFamilyBody),
    bodySmall: StarryTextStyleToken(12, 16, fontFamily: fontFamilyBody),
    labelLarge: StarryTextStyleToken(14, 20, fontFamily: fontFamilyBody),
    labelMedium: StarryTextStyleToken(12, 16, fontFamily: fontFamilyBody),
    labelSmall: StarryTextStyleToken(11, 16, fontFamily: fontFamilyBody),
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
    StarryTypography a,
    StarryTypography b,
    double t,
  ) {
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

/// Primitive spacing scale — the static-const source of truth (logical pixels,
/// 4-based rhythm; spec 05 · 间距 Spacing). Named by numeric key.
///
/// This is the single numeric truth for spacing. [StarrySemanticSpacing] maps
/// UI roles onto these primitives, and the instance-layer [StarrySpacing]
/// forwards to them. Consumers that need compile-time constants (e.g. `static
/// const` layout values) must read from this static layer, not from a
/// `const StarrySpacing()` instance (instance-field access is not `const`).
abstract final class StarrySpacingTokens {
  static const double s0 = 0;
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s8 = 32;
  static const double s10 = 40;
  static const double s12 = 48;
  static const double s16 = 64;
}

/// Semantic spacing roles — the static-const role layer (role → primitive).
///
/// Names describe *purpose* (what the space is for), decoupled from the numeric
/// primitive. If a role's scale value changes later, only the mapping here
/// moves; call sites keep referring to the role. Use this layer wherever a
/// compile-time constant with semantic meaning is needed (const-safe); use the
/// instance [StarrySpacing] via `tokens.spacing.*` when the value should track
/// the active theme.
abstract final class StarrySemanticSpacing {
  /// Padding inside a component.
  static const double componentPadding = StarrySpacingTokens.s4;

  /// Padding inside a card.
  static const double cardPadding = StarrySpacingTokens.s4;

  /// Page-level edge padding.
  static const double pagePadding = StarrySpacingTokens.s4;

  /// Gap between form fields.
  static const double formFieldSpacing = StarrySpacingTokens.s4;

  /// Gap between list items.
  static const double listItemSpacing = StarrySpacingTokens.s3;

  /// Gap between content sections.
  static const double sectionSpacing = StarrySpacingTokens.s6;

  /// Outer margin (= page padding).
  static const double margin = pagePadding;

  /// Grid gutter (= list-item spacing).
  static const double gutter = listItemSpacing;
}

/// Spacing scale (logical pixels, 4-based rhythm).
@immutable
class StarrySpacing {
  const StarrySpacing();
  // 4px base, 11-step scale (spec 05 · 间距 Spacing). Named by numeric key.
  // Instance fields forward to [StarrySpacingTokens] (the static-const primitive
  // source of truth). Keep these as getters so `const StarrySpacing()` and the
  // ThemeExtension path stay intact while consumers that need compile-time
  // constants read from the static layer instead.
  double get s0 => StarrySpacingTokens.s0;
  double get s1 => StarrySpacingTokens.s1;
  double get s2 => StarrySpacingTokens.s2;
  double get s3 => StarrySpacingTokens.s3;
  double get s4 => StarrySpacingTokens.s4;
  double get s5 => StarrySpacingTokens.s5;
  double get s6 => StarrySpacingTokens.s6;
  double get s8 => StarrySpacingTokens.s8;
  double get s10 => StarrySpacingTokens.s10;
  double get s12 => StarrySpacingTokens.s12;
  double get s16 => StarrySpacingTokens.s16;

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

/// Letter-spacing (tracking) scale — logical pixels, applied directly to
/// [TextStyle.letterSpacing].
///
/// A small symmetric ramp around `normal` (0). Follows the same px-native
/// convention as [StarrySpacing] / typography sizes: values are ready to
/// assign, no per-site em × fontSize conversion. Used for eyebrow labels,
/// all-caps captions and emphasized titles where tracking carries meaning.
@immutable
class StarryLetterSpacing {
  const StarryLetterSpacing();

  /// Tightened tracking for large display headings (reserved).
  final double tight = -0.2;

  /// Default — no extra tracking (body text).
  final double normal = 0;

  /// Slightly opened tracking for sub-labels / secondary captions.
  final double wide = 0.3;

  /// Opened tracking for eyebrow labels and emphasized small caps.
  final double wider = 0.6;

  /// Widest tracking for all-caps titles / strong emphasis labels.
  final double widest = 1.2;

  /// Ordered (name, value) pairs for spec rendering.
  List<(String, double)> get steps => [
    ('letterSpacing/tight', tight),
    ('letterSpacing/normal', normal),
    ('letterSpacing/wide', wide),
    ('letterSpacing/wider', wider),
    ('letterSpacing/widest', widest),
  ];
}

/// Window size class produced by [StarryBreakpoints.resolve].
///
/// Semantics follow Material 3 Window Size Classes and are keyed off the
/// *available layout width* (e.g. `MediaQuery.sizeOf(context).width` or a
/// `LayoutBuilder` constraint), not the physical device width.
enum StarryWindowSizeClass { compact, medium, expanded, large, extraLarge }

/// Responsive breakpoints (logical pixels).
///
/// The four thresholds are the *entry points* of the next size class, matching
/// Material 3 Window Size Classes:
/// `compact < 600 · medium 600–840 · expanded 840–1200 · large 1200–1600 ·
/// extraLarge ≥ 1600`. Values are dimensions and do not flip between
/// light/dark. Feed a width into [resolve] to get the active size class.
@immutable
class StarryBreakpoints {
  const StarryBreakpoints();

  /// Entry point of `medium` (a width < this is `compact`).
  final double compact = 600;

  /// Entry point of `expanded`.
  final double medium = 840;

  /// Entry point of `large`.
  final double expanded = 1200;

  /// Entry point of `extraLarge`.
  final double large = 1600;

  /// Resolve an available layout [width] to its window size class.
  ///
  /// Lower bound inclusive, upper bound exclusive (e.g. exactly `600` is
  /// [StarryWindowSizeClass.medium]).
  StarryWindowSizeClass resolve(double width) {
    if (width < compact) return StarryWindowSizeClass.compact;
    if (width < medium) return StarryWindowSizeClass.medium;
    if (width < expanded) return StarryWindowSizeClass.expanded;
    if (width < large) return StarryWindowSizeClass.large;
    return StarryWindowSizeClass.extraLarge;
  }

  /// Ordered (name, value) pairs for spec rendering.
  List<(String, double)> get steps => [
    ('breakpoint/compact', compact),
    ('breakpoint/medium', medium),
    ('breakpoint/expanded', expanded),
    ('breakpoint/large', large),
  ];
}

/// Primitive control-metric scale — the static-const source of truth for the
/// intrinsic sizes of interactive controls (logical pixels; spec 08 · 控件度量).
///
/// Single numeric truth. [StarrySemanticControlMetrics] maps UI roles onto
/// these primitives, and the instance-layer [StarryControlMetrics] forwards to
/// them. Consumers needing compile-time constants read from this static layer.
abstract final class StarryControlMetricsTokens {
  // Control heights (5 tiers, 4pt rhythm).
  static const double heightXs = 32;
  static const double heightSm = 36;
  static const double heightMd = 44;
  static const double heightLg = 48;
  static const double heightXl = 56;

  // Icon sizes within controls (5 tiers).
  static const double iconXs = 14;
  static const double iconSm = 16;
  static const double iconMd = 18;
  static const double iconLg = 20;
  static const double iconXl = 24;

  // Stroke widths (2 tiers).
  static const double borderThin = 1;
  static const double borderThick = 2;
}

/// Semantic control-metric roles — the static-const role layer (role →
/// primitive).
///
/// Names describe *purpose*, decoupled from the numeric primitive. Roles that
/// happen to share a value today (e.g. [dividerThickness] and a border width
/// both == 2) are declared as INDEPENDENT roles pointing at their own
/// primitive: a future change to one primitive must not silently drag the
/// other. Use this layer wherever a compile-time constant with semantic meaning
/// is needed; use the instance [StarryControlMetrics] when the value should
/// track the active theme.
abstract final class StarrySemanticControlMetrics {
  /// Height of a single-line interactive control (input field / capsule).
  static const double singleLineControlHeight =
      StarryControlMetricsTokens.heightLg;

  /// Icon size rendered inside a control.
  static const double controlIconSize = StarryControlMetricsTokens.iconMd;

  /// Border width for the focused/active state.
  static const double activeBorderWidth =
      StarryControlMetricsTokens.borderThick;

  /// Thickness of a chrome divider line. Independent from any border-width
  /// role: a divider is a separator, not a control border — the equal value is
  /// a coincidence, not a binding.
  static const double dividerThickness = StarryControlMetricsTokens.borderThick;
}

/// Control metrics — intrinsic sizes of interactive controls.
///
/// A dedicated atomic dimension for a control's own fixed dimensions
/// (control height, icon size within controls, stroke widths). This is
/// distinct from `spacing` (gaps between things) and `radius` (corner
/// rounding). Values are logical pixels and do not flip between light/dark.
@immutable
class StarryControlMetrics {
  const StarryControlMetrics();

  // Control heights (5 tiers, 4pt rhythm) — spec 08 · 控件度量.
  // xs is the compact-control height (chips/small pills); equals the real
  // shipped chip height. sm/md/lg/xl step up for larger interactive controls.
  // Instance fields forward to [StarryControlMetricsTokens] (the static-const
  // primitive source of truth); kept as getters so `const StarryControlMetrics()`
  // and the ThemeExtension path stay intact.
  double get heightXs => StarryControlMetricsTokens.heightXs;
  double get heightSm => StarryControlMetricsTokens.heightSm;
  double get heightMd => StarryControlMetricsTokens.heightMd;
  double get heightLg => StarryControlMetricsTokens.heightLg;
  double get heightXl => StarryControlMetricsTokens.heightXl;

  // Icon sizes within controls (5 tiers).
  double get iconXs => StarryControlMetricsTokens.iconXs;
  double get iconSm => StarryControlMetricsTokens.iconSm;
  double get iconMd => StarryControlMetricsTokens.iconMd;
  double get iconLg => StarryControlMetricsTokens.iconLg;
  double get iconXl => StarryControlMetricsTokens.iconXl;

  // Stroke widths (2 tiers).
  double get borderThin => StarryControlMetricsTokens.borderThin;
  double get borderThick => StarryControlMetricsTokens.borderThick;

  // --- Semantic getters (read directly by components; derived, no new source) ---

  /// Default control height (single-line interactive controls).
  double get controlHeight => heightLg;

  /// Border width for the focused/active state.
  double get focusBorderWidth => borderThick;

  /// Border width for the rest state.
  double get restBorderWidth => borderThin;

  /// Delta subtracted from an outer radius to get the inner radius of a
  /// bordered control. Geometrically equals the border width, so it is
  /// derived from [borderThick] rather than defined as an independent value:
  /// `innerRadius = radius.lg - innerRadiusDelta`.
  double get innerRadiusDelta => borderThick;

  /// Minimum touch target (Material accessibility standard).
  double get minTouchTarget => heightLg;

  /// Ordered (name, value) pairs for spec rendering, grouped by facet.
  List<(String, double)> get steps => [
    ('control/height/xs', heightXs),
    ('control/height/sm', heightSm),
    ('control/height/md', heightMd),
    ('control/height/lg', heightLg),
    ('control/height/xl', heightXl),
    ('control/icon/xs', iconXs),
    ('control/icon/sm', iconSm),
    ('control/icon/md', iconMd),
    ('control/icon/lg', iconLg),
    ('control/icon/xl', iconXl),
    ('control/border/thin', borderThin),
    ('control/border/thick', borderThick),
  ];
}

/// Status-indicator / dot diameters (decorative, non-interactive).
///
/// Distinct from [StarryControlMetrics], which sizes *interactive* controls and
/// carries touch-target / 4pt-rhythm promises. A status dot is a small
/// decorative mark, so it gets its own dimension rather than borrowing a
/// control height. Two tiers unify the two dot sizes that were previously
/// hardcoded across the library.
@immutable
class StarryIndicator {
  const StarryIndicator();

  /// Small status dot (e.g. badge presence dot).
  final double dotSm = 8;

  /// Medium status dot (e.g. message-list unread dot).
  final double dotMd = 12;

  /// Ordered (name, value) pairs for spec rendering.
  List<(String, double)> get steps => [
    ('indicator/dot/sm', dotSm),
    ('indicator/dot/md', dotMd),
  ];
}

/// Motion durations and easing curves.
@immutable
class StarryMotion {
  const StarryMotion({
    required this.durationShort,
    required this.durationMedium,
    required this.durationLong,
    required this.durationSlow,
    required this.durationSlower,
    required this.easingStandard,
    required this.easingEmphasized,
    required this.pressedScale,
  });

  final Duration durationShort;
  final Duration durationMedium;
  final Duration durationLong;
  final Duration durationSlow;
  final Duration durationSlower;

  /// Standard easing for routine transitions (color, opacity, small moves).
  final Curve easingStandard;

  /// Emphasized easing for expressive, attention-drawing motion (page
  /// transitions, large element enter/exit). Steeper decelerate tail than
  /// [easingStandard].
  final Curve easingEmphasized;

  /// Scale factor applied to a control while it is pressed (tap-down feedback).
  /// A subtle shrink that reads as "pushed in"; controls animate back to 1.0
  /// on release.
  final double pressedScale;

  static const StarryMotion standard = StarryMotion(
    durationShort: Duration(milliseconds: 150),
    durationMedium: Duration(milliseconds: 300),
    durationLong: Duration(milliseconds: 500),
    durationSlow: Duration(milliseconds: 800),
    durationSlower: Duration(milliseconds: 1200),
    easingStandard: Cubic(0.2, 0, 0, 1),
    easingEmphasized: Cubic(0.05, 0.7, 0.1, 1.0),
    pressedScale: 0.95,
  );

  static StarryMotion lerp(StarryMotion a, StarryMotion b, double t) {
    return t < 0.5 ? a : b;
  }
}

/// Semantic opacity tokens for translucent surfaces and de-emphasized content.
///
/// These are discrete design decisions, not interpolated values, so [lerp]
/// snaps rather than blends.
@immutable
class StarryOpacity {
  const StarryOpacity({
    this.disabledContent = 0.38,
    this.busyContent = 0.35,
    this.selectedSurface = 0.10,
    this.accentSurface = 0.12,
    this.mediaScrim = 0.20,
    this.stateHover = 0.08,
    this.stateFocus = 0.10,
    this.statePressed = 0.10,
    this.stateDragged = 0.16,
    this.disabledContainer = 0.12,
  });

  /// Applied to a control's content (glyph/label) while it is disabled.
  /// MD3-aligned disabled-content step (was 0.45, tightened to the MD3 0.38).
  final double disabledContent;

  /// Applied to a control's content (glyph/label) while it is busy — either
  /// dimmed behind a progress spinner, or as the dim end of a twinkling glyph.
  final double busyContent;

  /// Brand tint alpha for a selected control's background fill.
  final double selectedSurface;

  /// Brand tint alpha for an accent surface's background fill.
  final double accentSurface;

  /// Alpha for a light (white) scrim fill painted behind compact elements that
  /// float over media (image/video), e.g. the on-media tag pill. A standard
  /// light-overlay step (5% grid), independent of theme.
  final double mediaScrim;

  /// MD3 state-layer opacity applied over the base color on hover.
  /// Fixed across light/dark themes (MD3 semantics), fed to [StarryStateLayer].
  final double stateHover;

  /// MD3 state-layer opacity applied over the base color on focus.
  final double stateFocus;

  /// MD3 state-layer opacity applied over the base color while pressed.
  final double statePressed;

  /// MD3 state-layer opacity applied over the base color while dragged.
  final double stateDragged;

  /// MD3 disabled-container alpha applied to a disabled control's fill.
  final double disabledContainer;

  static const StarryOpacity standard = StarryOpacity();

  static StarryOpacity lerp(StarryOpacity a, StarryOpacity b, double t) {
    return t < 0.5 ? a : b;
  }
}

/// Frosted-glass surface parameters for [StarryGlassPanel].
///
/// Bundles the three continuous visual quantities that define the glass
/// look — backdrop blur sigma and the surface / border alpha — so they live
/// in the theme alongside the already-tokenized radius, border width and
/// elevation. Defaults capture the panel's original hand-tuned look. Unlike
/// [StarryOpacity] (discrete design decisions), these are continuous, so
/// [lerp] truly interpolates for smooth theme / animation transitions.
@immutable
class StarryGlass {
  const StarryGlass({
    this.blurSigma = 22,
    this.surfaceOpacity = 0.82,
    this.borderOpacity = 0.58,
  });

  /// Gaussian blur sigma applied to the backdrop behind the panel.
  final double blurSigma;

  /// Alpha applied to the theme surface fill.
  final double surfaceOpacity;

  /// Alpha applied to the `onMedia` hairline border color.
  final double borderOpacity;

  static const StarryGlass standard = StarryGlass();

  static StarryGlass lerp(StarryGlass a, StarryGlass b, double t) {
    return StarryGlass(
      blurSigma: lerpDouble(a.blurSigma, b.blurSigma, t) ?? a.blurSigma,
      surfaceOpacity:
          lerpDouble(a.surfaceOpacity, b.surfaceOpacity, t) ?? a.surfaceOpacity,
      borderOpacity:
          lerpDouble(a.borderOpacity, b.borderOpacity, t) ?? a.borderOpacity,
    );
  }
}

/// Brand-custom colors that flip between light and dark themes.
@immutable
class StarryBrandColors {
  const StarryBrandColors({
    required this.gradientStart,
    required this.gradientEnd,
    required this.primaryPale,
    required this.primaryTint50,
    required this.accentGradientEnd,
    required this.brandGlow,
    required this.accentGlow,
    required this.accentPurple,
  });

  final Color gradientStart;
  final Color gradientEnd;

  /// Fixed brand accent purple (e.g. the search capsule / login gradient
  /// anchor). A brand-accent role, not a rung of the primary ramp.
  final Color accentPurple;

  /// Pale primary tint — the top-left anchor of the immersive gradient
  /// fallback / atmosphere overlay.
  final Color primaryPale;

  /// Faint primary tint — the mid stop of the immersive gradient.
  final Color primaryTint50;

  /// Accent gradient terminal — the bottom-right stop of the immersive
  /// gradient.
  final Color accentGradientEnd;

  /// Ambient brand glow-orb color (already carries its own alpha).
  final Color brandGlow;

  /// Ambient accent glow-orb color (already carries its own alpha).
  final Color accentGlow;

  static StarryBrandColors lerp(
    StarryBrandColors a,
    StarryBrandColors b,
    double t,
  ) {
    Color l(Color x, Color y) => Color.lerp(x, y, t)!;
    return StarryBrandColors(
      gradientStart: l(a.gradientStart, b.gradientStart),
      gradientEnd: l(a.gradientEnd, b.gradientEnd),
      primaryPale: l(a.primaryPale, b.primaryPale),
      primaryTint50: l(a.primaryTint50, b.primaryTint50),
      accentPurple: l(a.accentPurple, b.accentPurple),
      accentGradientEnd: l(a.accentGradientEnd, b.accentGradientEnd),
      brandGlow: l(a.brandGlow, b.brandGlow),
      accentGlow: l(a.accentGlow, b.accentGlow),
    );
  }
}

/// Focus-highlight glow metrics. Parameterizes the emphasis glow halo
/// (blur / spread / offset / alpha) painted by [StarryAiButton]; the halo color
/// is not stored here — it reuses `semantic.brand` at the use site.
@immutable
class StarryFocusMetrics {
  const StarryFocusMetrics();

  /// Blur radius of the emphasis glow halo.
  final double glowBlurRadius = 8;

  /// Spread radius of the emphasis glow halo.
  final double glowSpreadRadius = 1;

  /// Offset of the emphasis glow halo (centered by default).
  final Offset glowOffset = Offset.zero;

  /// Opacity applied to `semantic.brand` when painting the emphasis glow halo.
  final double glowAlpha = 0.5;

  /// Ordered (name, value) pairs for spec rendering.
  List<(String, double)> get steps => <(String, double)>[
    ('focus/glow/blur', glowBlurRadius),
    ('focus/glow/spread', glowSpreadRadius),
    ('focus/glow/alpha', glowAlpha),
  ];
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
    required this.controlMetrics,
    required this.breakpoints,
    required this.indicator,
    required this.motion,
    required this.brand,
    this.opacity = const StarryOpacity(),
    this.focus = const StarryFocusMetrics(),
    this.letterSpacing = const StarryLetterSpacing(),
    this.glass = const StarryGlass(),
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

  /// Control metrics (intrinsic control sizes: height, icon, stroke).
  final StarryControlMetrics controlMetrics;

  /// Responsive breakpoints (Material 3 window size class thresholds).
  final StarryBreakpoints breakpoints;

  /// Status-indicator / dot diameters (decorative, non-interactive).
  final StarryIndicator indicator;

  /// Motion durations and easing curves.
  final StarryMotion motion;

  /// Brand-custom colors (card/divider backgrounds and the brand gradient).
  final StarryBrandColors brand;

  /// Semantic opacity tokens (disabled / busy content, tinted surfaces).
  final StarryOpacity opacity;

  /// Focus-highlight metrics (reserved glow geometry; default style = ring).
  final StarryFocusMetrics focus;

  /// Letter-spacing (tracking) scale — logical pixels.
  final StarryLetterSpacing letterSpacing;

  /// Frosted-glass surface parameters (blur sigma, surface / border alpha).
  final StarryGlass glass;

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

  // Brand-custom colors. The brand gradient is tuned per brightness.
  static const StarryBrandColors _lightBrand = StarryBrandColors(
    gradientStart: Color(0xFFAB99FF),
    gradientEnd: Color(0xFF7A5CE8),
    primaryPale: Color(0xFFEDE4FF),
    primaryTint50: Color(0xFFF9F6FF),
    accentGradientEnd: Color(0xFFB567F1),
    brandGlow: Color(0x3D7F53EE),
    accentGlow: Color(0x47FFB7E8),
    accentPurple: Color(0xFF8D67F1),
  );

  static const StarryBrandColors _darkBrand = StarryBrandColors(
    gradientStart: Color(0xFFB7A9FF),
    gradientEnd: Color(0xFF7A5CE8),
    primaryPale: Color(0xFF4A2386),
    primaryTint50: Color(0xFFF9F6FF),
    accentGradientEnd: Color(0xFFB567F1),
    brandGlow: Color(0x3D7F53EE),
    accentGlow: Color(0x47FFB7E8),
    accentPurple: Color(0xFFB7A9FF),
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
    onError: Color(0xFFFFFFFF),
    onMedia: Color(0xFFFFFFFF),
    mediaOverlayEnd: Color(0x99000000),
    infoBg: Color(0xFFCFFAFE),
    info: Color(0xFF0891B2),
    infoStrong: Color(0xFF0E7490),
    scrim: Color(0x66000000),
    shadow: Color(0x1A000000),
    inverseSurface: Color(0xFF1E1E26),
    onInverseSurface: Color(0xFFCCCCCC),
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
    onError: Color(0xFFFFFFFF),
    onMedia: Color(0xFFFFFFFF),
    mediaOverlayEnd: Color(0xCC030014),
    infoBg: Color(0xFF08303A),
    info: Color(0xFF22D3EE),
    infoStrong: Color(0xFF67E8F9),
    scrim: Color(0x99000000),
    shadow: Color(0x40000000),
    inverseSurface: Color(0xFFFFFFFF),
    onInverseSurface: Color(0xFF333333),
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
    controlMetrics: StarryControlMetrics(),
    breakpoints: StarryBreakpoints(),
    indicator: StarryIndicator(),
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
    controlMetrics: StarryControlMetrics(),
    breakpoints: StarryBreakpoints(),
    indicator: StarryIndicator(),
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
    StarryControlMetrics? controlMetrics,
    StarryBreakpoints? breakpoints,
    StarryIndicator? indicator,
    StarryMotion? motion,
    StarryBrandColors? brand,
    StarryOpacity? opacity,
    StarryFocusMetrics? focus,
    StarryLetterSpacing? letterSpacing,
    StarryGlass? glass,
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
      controlMetrics: controlMetrics ?? this.controlMetrics,
      breakpoints: breakpoints ?? this.breakpoints,
      indicator: indicator ?? this.indicator,
      motion: motion ?? this.motion,
      brand: brand ?? this.brand,
      opacity: opacity ?? this.opacity,
      focus: focus ?? this.focus,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      glass: glass ?? this.glass,
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
      controlMetrics: t < 0.5 ? controlMetrics : other.controlMetrics,
      breakpoints: t < 0.5 ? breakpoints : other.breakpoints,
      indicator: t < 0.5 ? indicator : other.indicator,
      motion: StarryMotion.lerp(motion, other.motion, t),
      brand: StarryBrandColors.lerp(brand, other.brand, t),
      opacity: StarryOpacity.lerp(opacity, other.opacity, t),
      focus: t < 0.5 ? focus : other.focus,
      letterSpacing: t < 0.5 ? letterSpacing : other.letterSpacing,
      glass: StarryGlass.lerp(glass, other.glass, t),
    );
  }
}
