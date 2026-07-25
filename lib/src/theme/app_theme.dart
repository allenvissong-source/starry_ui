import 'package:flutter/material.dart';

import 'starry_tokens.dart';

/// Starry UI 的 Material 3 主题。
///
/// 单一品牌种子色，`ColorScheme.fromSeed` 自动推导整套配色，明暗两套都从
/// 同一颗种子生成，保证色相一致。组件库里所有组件都只吃 [ThemeData] 里的
/// token（colorScheme / textTheme），不写死颜色。
class AppTheme {
  const AppTheme._();

  /// 品牌种子色。改这一个值即可换肤。
  static const Color seed = Color(0xFFAB99FF);

  /// 品牌色上的前景文字：品牌色块一律用深紫，绝不用纯白。
  static const Color onBrand = Color(0xFF241B45);

  /// 次要品牌色（晴空蓝 blue500）。
  static const Color secondary = Color(0xFF4F8CF7);

  static ThemeData light() => _base(Brightness.light);

  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    ).copyWith(
      primary: seed,
      onPrimary: onBrand,
      secondary: secondary,
    );
    final tokens = isLight ? StarryTokens.light : StarryTokens.dark;
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      // 页面画布吃语义 background token（明 #FFFFFF / 暗 #121217），
      // 而不是 Material 推导的 surface —— 保证换肤时画布随 token 走。
      scaffoldBackgroundColor: tokens.semantic.background,
      textTheme: _textTheme(tokens.typography, colorScheme.onSurface),
      extensions: <ThemeExtension<dynamic>>[
        tokens,
      ],
    );
  }

  /// Build a Material [TextTheme] from the spec type ramp so every text style
  /// used by Material widgets carries the spec-exact size / line height.
  static TextTheme _textTheme(StarryTypography t, Color color) {
    TextStyle s(StarryTextStyleToken tok) =>
        tok.textStyle.copyWith(color: color);
    return TextTheme(
      displayLarge: s(t.displayLarge),
      displayMedium: s(t.displayMedium),
      displaySmall: s(t.displaySmall),
      headlineLarge: s(t.headlineLarge),
      headlineMedium: s(t.headlineMedium),
      headlineSmall: s(t.headlineSmall),
      titleLarge: s(t.titleLarge),
      titleMedium: s(t.titleMedium),
      titleSmall: s(t.titleSmall),
      bodyLarge: s(t.bodyLarge),
      bodyMedium: s(t.bodyMedium),
      bodySmall: s(t.bodySmall),
      labelLarge: s(t.labelLarge),
      labelMedium: s(t.labelMedium),
      labelSmall: s(t.labelSmall),
    );
  }
}
