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
  ///
  /// 这是唯一保留的颜色字面量：它是 `ColorScheme.fromSeed` 的锚点。语义
  /// token 的品牌色（`semantic.brand` = 0xFFAA99FF）在此基础上做过微调，
  /// 故种子色与语义品牌色刻意不完全相等。`onPrimary` / `secondary` 则直接
  /// 派生自 [StarryTokens]，不再各写一份，避免手动同步的双源。
  static const Color seed = Color(
    0xFFAB99FF,
  ); // hardcode-allow: seed 是唯一色字面量,喂 ColorScheme.fromSeed(见 AGENTS §1.4)

  static ThemeData light() => _base(Brightness.light);

  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final tokens = isLight ? StarryTokens.light : StarryTokens.dark;
    final colorScheme =
        ColorScheme.fromSeed(seedColor: seed, brightness: brightness).copyWith(
          primary: seed,
          // 品牌色前景与次要品牌色直接吃 token，明暗各自取值、随主题自适应。
          onPrimary: tokens.semantic.onBrand,
          secondary: tokens.semantic.brandStrong,
        );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      // 页面画布吃语义 background token（明 #FFFFFF / 暗 #121217），
      // 而不是 Material 推导的 surface —— 保证换肤时画布随 token 走。
      scaffoldBackgroundColor: tokens.semantic.background,
      textTheme: _textTheme(tokens.typography, colorScheme.onSurface),
      extensions: <ThemeExtension<dynamic>>[tokens],
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
