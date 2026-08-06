import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// Shared helpers ------------------------------------------------------------

/// AA contrast ratio of black (#000) text on [c] — matches the spec's
/// per-swatch "AA xx.xx" annotation (dark-text legibility on the swatch).
double _aaVsBlack(Color c) => (_relLuminance(c) + 0.05) / 0.05;

/// A spec-faithful primitive swatch: color chip + token name (+ optional
/// badge) + hex + "AA" contrast-vs-black value. Badge-bearing swatches get a
/// 2px brand border to read as "selected", exactly like the poster.
class _SpecSwatch extends StatelessWidget {
  const _SpecSwatch({required this.color, required this.name, this.badge});

  final Color color;
  final String name;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).extension<StarryTokens>()!.semantic;
    final hex = _hex(color);
    final aa = _aaVsBlack(color);
    final highlighted = badge != null;
    return SizedBox(
      width: 104,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: highlighted ? s.brand : s.border,
                width: highlighted ? 2 : 1,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: s.textPrimary,
                  ),
                ),
                if (badge != null)
                  TextSpan(
                    text: '  $badge',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: s.brandStrong,
                    ),
                  ),
              ],
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 2),
          Text(
            hex,
            style: TextStyle(
              fontSize: 11,
              fontFeatures: [FontFeature.tabularFigures()],
              color: s.textTertiary,
            ),
          ),
          Text(
            'AA ${aa.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 10.5,
              fontFeatures: [FontFeature.tabularFigures()],
              color: s.textDisabled,
            ),
          ),
        ],
      ),
    );
  }
}

/// One primitive ramp row: bilingual role heading + optional note, then the
/// full 10-stop scale rendered as spec swatches.
class _SpecScaleRow extends StatelessWidget {
  const _SpecScaleRow({
    required this.zh,
    required this.en,
    required this.names,
    required this.scale,
    this.note,
    this.badges = const {},
  });

  final String zh;
  final String en;
  final String? note;
  final List<String> names;
  final StarryColorScale scale;
  final Map<int, String> badges;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).extension<StarryTokens>()!.semantic;
    final stops = scale.stops;
    final ls = Theme.of(context).extension<StarryTokens>()!.letterSpacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$zh · ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: s.textPrimary,
                ),
              ),
              TextSpan(
                text: en,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: ls.wider,
                  color: s.textTertiary,
                ),
              ),
              if (note != null)
                TextSpan(
                  text: '  $note',
                  style: TextStyle(fontSize: 11, color: s.textDisabled),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 16,
          children: [
            for (var i = 0; i < stops.length; i++)
              _SpecSwatch(color: stops[i], name: names[i], badge: badges[i]),
          ],
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}

/// A numbered white section card matching the spec poster chrome. Reused by
/// every foundation page so the whole gallery reads as one design document.
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String index;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).extension<StarryTokens>()!.semantic;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
      decoration: BoxDecoration(
        color: s.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: s.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A17171D),
            blurRadius: 24,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                if (index.isNotEmpty)
                  TextSpan(
                    text: '$index · ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: s.brand,
                    ),
                  ),
                TextSpan(
                  text: title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: s.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.6,
              color: s.textTertiary,
            ),
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }
}

/// A small labelled divider used between sub-groups inside a section.
class _SubDivider extends StatelessWidget {
  const _SubDivider(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<StarryTokens>()!;
    final s = tokens.semantic;
    final ls = tokens.letterSpacing;
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 18),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: ls.wider,
              color: s.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Divider(color: s.border)),
        ],
      ),
    );
  }
}


/// Shared page scaffold: paints the poster canvas edge-to-edge (no seam),
/// then centers the section column within a comfortable max width so every
/// foundation page reads as one centered poster instead of a left-stretched
/// debug grid.
class _FoundationScaffold extends StatelessWidget {
  const _FoundationScaffold({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).extension<StarryTokens>()!.semantic;
    return ColoredBox(
      color: s.backgroundSecondary,
      child: SizedBox.expand(
        child: LayoutBuilder(
          builder: (context, constraints) {
            const padding = EdgeInsets.symmetric(horizontal: 28, vertical: 36);
            return SingleChildScrollView(
              padding: padding,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - padding.vertical,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1080),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: children,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Colors foundation --------------------------------------------------------

class ColorsFoundation extends StatelessWidget {
  const ColorsFoundation({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    const purpleNames = [
      'purple/50',
      'purple/100',
      'purple/200',
      'purple/300',
      'purple/400',
      'purple/500',
      'purple/600',
      'purple/700',
      'purple/800',
      'purple/900',
    ];
    const blueNames = [
      'blue50',
      'blue100',
      'blue200',
      'blue300',
      'blue400',
      'blue500',
      'blue600',
      'blue700',
      'blue800',
      'blue900',
    ];
    const grayNames = [
      'gray/50',
      'gray/100',
      'gray/200',
      'gray/300',
      'gray/400',
      'gray/500',
      'gray/600',
      'gray/700',
      'gray/800',
      'gray/900',
    ];
    const secondaryNames = [
      'secondary50',
      'secondary100',
      'secondary200',
      'secondary300',
      'secondary400',
      'secondary500',
      'secondary600',
      'secondary700',
      'secondary800',
      'secondary900',
    ];
    const ctaNames = [
      'cta50',
      'cta100',
      'cta200',
      'cta300',
      'cta400',
      'cta500',
      'cta600',
      'cta700',
      'cta800',
      'cta900',
    ];
    return _FoundationScaffold(
      children: [
        const _PosterHeader(),
        const SizedBox(height: 28),
        _SectionCard(
          index: '01',
          title: '颜色 Color',
          subtitle:
              '品牌色板与中性色板为原色层 Primitives；语义主题变量引用原色并提供 '
              'Light / Dark 双值，切换模式即全局换肤。',
          children: [
            _SpecScaleRow(
              zh: '品牌色',
              en: 'BRAND PURPLE',
              names: purpleNames,
              scale: t.purple,
              badges: const {4: ' · 主色'},
            ),
            _SpecScaleRow(
              zh: '晴空蓝',
              en: 'BRAND BLUE',
              note: '（第二品牌色 · 候选）',
              names: blueNames,
              scale: t.blue,
              badges: const {4: ' ★ 候选主色'},
            ),
            _SpecScaleRow(
              zh: '中性色',
              en: 'NEUTRAL GRAY',
              names: grayNames,
              scale: t.gray,
            ),
            const _SubDivider('核心角色 · CORE ROLES'),
            _SpecScaleRow(
              zh: '薄荷辅色',
              en: 'SECONDARY',
              note: 'AA = 深色文字在其上的对比度',
              names: secondaryNames,
              scale: t.mint,
              badges: const {3: ' ★'},
            ),
            _SpecScaleRow(
              zh: '珊瑚',
              en: 'CTA · CORAL',
              note: '（行动召唤专用 ★ hover / ★ 语义主）',
              names: ctaNames,
              scale: t.coral,
              badges: const {4: ' ★ hover', 5: ' ★ 语义主'},
            ),
            const _SubDivider('语义主题变量 · THEME TOKENS  Light / Dark'),
            const _SemanticDualTable(),
          ],
        ),
      ],
    );
  }
}

/// The poster masthead shown at the top of the Colors foundation page,
/// matching the spec header (eyebrow chip + bilingual title + subtitle).
class _PosterHeader extends StatelessWidget {
  const _PosterHeader();

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<StarryTokens>()!;
    final s = tokens.semantic;
    final ls = tokens.letterSpacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: s.surfaceVariant,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'DESIGN SYSTEM · MOBILE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: ls.wider,
                    color: s.brandStrong,
                  ),
                ),
                TextSpan(
                  text: '   v1.0 · 2026-07',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: s.brand,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '移动端 ',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: s.textPrimary,
                ),
              ),
              TextSpan(
                text: 'App Design Tokens',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: s.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '以 #AA99FF 为主色的明暗双主题变量体系 — 颜色 / 圆角 / 阴影完整变量表，绑定变量即可一键换肤。',
          style: TextStyle(fontSize: 13, height: 1.6, color: s.textSecondary),
        ),
      ],
    );
  }
}

/// Role accessor tuple for the dual-column semantic table.
typedef _RoleGetter = Color Function(StarrySemanticColors s);

const List<(String, _RoleGetter)> _semanticRoles = [
  ('brand/primary', _rBrand),
  ('brand/primary-strong', _rBrandStrong),
  ('brand/on-primary', _rOnBrand),
  ('bg/primary', _rBackground),
  ('bg/secondary', _rBackgroundSecondary),
  ('bg/tertiary', _rBackgroundTertiary),
  ('surface/card', _rSurface),
  ('surface/variant', _rSurfaceVariant),
  ('text/primary', _rTextPrimary),
  ('text/secondary', _rTextSecondary),
  ('text/tertiary', _rTextTertiary),
  ('text/disabled', _rTextDisabled),
  ('border/default', _rBorder),
  ('border/strong', _rBorderStrong),
  ('success/bg', _rSuccessBg),
  ('success/main', _rSuccess),
  ('success/text', _rSuccessStrong),
  ('warning/bg', _rWarningBg),
  ('warning/main', _rWarning),
  ('warning/text', _rWarningStrong),
  ('error/bg', _rErrorBg),
  ('error/main', _rError),
  ('error/text', _rErrorStrong),
  ('info/bg', _rInfoBg),
  ('info/main', _rInfo),
  ('info/text', _rInfoStrong),
];

Color _rBrand(StarrySemanticColors s) => s.brand;
Color _rBrandStrong(StarrySemanticColors s) => s.brandStrong;
Color _rOnBrand(StarrySemanticColors s) => s.onBrand;
Color _rBackground(StarrySemanticColors s) => s.background;
Color _rBackgroundSecondary(StarrySemanticColors s) => s.backgroundSecondary;
Color _rBackgroundTertiary(StarrySemanticColors s) => s.backgroundTertiary;
Color _rSurface(StarrySemanticColors s) => s.surface;
Color _rSurfaceVariant(StarrySemanticColors s) => s.surfaceVariant;
Color _rTextPrimary(StarrySemanticColors s) => s.textPrimary;
Color _rTextSecondary(StarrySemanticColors s) => s.textSecondary;
Color _rTextTertiary(StarrySemanticColors s) => s.textTertiary;
Color _rTextDisabled(StarrySemanticColors s) => s.textDisabled;
Color _rBorder(StarrySemanticColors s) => s.border;
Color _rBorderStrong(StarrySemanticColors s) => s.borderStrong;
Color _rSuccessBg(StarrySemanticColors s) => s.successBg;
Color _rSuccess(StarrySemanticColors s) => s.success;
Color _rSuccessStrong(StarrySemanticColors s) => s.successStrong;
Color _rWarningBg(StarrySemanticColors s) => s.warningBg;
Color _rWarning(StarrySemanticColors s) => s.warning;
Color _rWarningStrong(StarrySemanticColors s) => s.warningStrong;
Color _rErrorBg(StarrySemanticColors s) => s.errorBg;
Color _rError(StarrySemanticColors s) => s.error;
Color _rErrorStrong(StarrySemanticColors s) => s.errorStrong;
Color _rInfoBg(StarrySemanticColors s) => s.infoBg;
Color _rInfo(StarrySemanticColors s) => s.info;
Color _rInfoStrong(StarrySemanticColors s) => s.infoStrong;

String _hex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

/// One chip (color square + hex) rendered on a mode-appropriate backdrop.
class _ModeChip extends StatelessWidget {
  const _ModeChip({required this.color, required this.dark});
  final Color color;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final bg = dark ? const Color(0xFF121217) : const Color(0xFFFFFFFF);
    final fg = dark ? const Color(0xFFF5F5F8) : const Color(0xFF17171D);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x22808080)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0x33808080)),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _hex(color),
            style: TextStyle(
              fontSize: 12,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dual-column (Light | Dark) semantic token table, spec section 01.
class _SemanticDualTable extends StatelessWidget {
  const _SemanticDualTable();

  @override
  Widget build(BuildContext context) {
    final role = Theme.of(context).extension<StarryTokens>()!.semantic;
    final light = StarryTokens.light.semantic;
    final dark = StarryTokens.dark.semantic;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 200,
              child: Text(
                '变量 Token',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: role.textPrimary,
                ),
              ),
            ),
            SizedBox(
              width: 180,
              child: Text(
                'Light 浅色模式',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: role.textPrimary,
                ),
              ),
            ),
            SizedBox(
              width: 180,
              child: Text(
                'Dark 深色模式',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: role.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final role in _semanticRoles)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 200,
                  child: Text(
                    role.$1,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(
                        context,
                      ).extension<StarryTokens>()!.semantic.textSecondary,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: _ModeChip(color: role.$2(light), dark: false),
                ),
                SizedBox(
                  width: 180,
                  child: _ModeChip(color: role.$2(dark), dark: true),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Radius foundation --------------------------------------------------------

class RadiusFoundation extends StatelessWidget {
  const RadiusFoundation({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<StarryTokens>()!;
    final r = tokens.radius;
    final s = tokens.semantic;
    final items = <(String, double)>[
      ('radius/none', r.none),
      ('radius/xs', r.xs),
      ('radius/sm', r.sm),
      ('radius/md', r.md),
      ('radius/lg', r.lg),
      ('radius/xl', r.xl),
      ('radius/2xl', r.xxl),
      ('radius/full', r.full),
    ];
    return _FoundationScaffold(
      children: [
        _SectionCard(
          index: '02',
          title: '圆角 Radius',
          subtitle:
              '8 级圆角刻度，从直角到全圆。组件按层级取值：小控件 xs–sm，卡片 md–lg，浮层 xl–2xl，胶囊/头像用 full。',
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final e in items)
                  Container(
                    width: 150,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: s.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: s.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1EDFF),
                            borderRadius: BorderRadius.circular(
                              e.$2 > 28 ? 28 : e.$2,
                            ),
                            border: Border.all(color: const Color(0xFFC9BBFF)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          e.$1,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: s.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${e.$2.toStringAsFixed(0)} px',
                          style: TextStyle(fontSize: 11, color: s.textTertiary),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// Elevation foundation -----------------------------------------------------

class ElevationFoundation extends StatelessWidget {
  const ElevationFoundation({super.key});

  @override
  Widget build(BuildContext context) {
    const names = ['shadow/sm', 'shadow/md', 'shadow/lg', 'shadow/xl'];
    const lightCaptions = [
      '0 1 2 · 5%    0 1 1 · 3%',
      '0 4 16 -4 · 10%    0 2 4 -2 · 6%',
      '0 8 24 -6 · 12%    0 4 8 -4 · 8%',
      '0 24 64 -16 · 25%    0 12 28 -12 · 15%',
    ];
    const darkCaptions = [
      '0 1 2 · 50%',
      '0 4 16 -4 · 55%    0 2 4 -2 · 45%',
      '0 8 24 -6 · 60%    0 4 8 -4 · 50%',
      '0 24 64 -16 · 65%  +  品牌环境光 10%',
    ];
    final lightLevels = StarryElevation.light.levels;
    final darkLevels = StarryElevation.dark.levels;

    Widget panels(bool wide) {
      final light = _ShadowPanel(
        title: 'LIGHT 浅色模式',
        dark: false,
        names: names,
        captions: lightCaptions,
        shadows: lightLevels,
      );
      final darkPanel = _ShadowPanel(
        title: 'DARK 深色模式',
        dark: true,
        names: names,
        captions: darkCaptions,
        shadows: darkLevels,
      );
      if (wide) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: light),
            const SizedBox(width: 24),
            Expanded(child: darkPanel),
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [light, const SizedBox(height: 24), darkPanel],
      );
    }

    return _FoundationScaffold(
      children: [
        _SectionCard(
          index: '03',
          title: '阴影 Shadow / Elevation',
          subtitle:
              '4 级海拔阴影 sm 用于标签徽标 md 用于卡片 lg 用于弹窗浮层 xl 用于模态/大浮层。深色模式提高不透明度 xl 额外叠加品牌色环境光。',
          children: [
            LayoutBuilder(builder: (context, c) => panels(c.maxWidth >= 780)),
          ],
        ),
      ],
    );
  }
}

/// One themed panel (light or dark) holding the four shadow specimens.
class _ShadowPanel extends StatelessWidget {
  const _ShadowPanel({
    required this.title,
    required this.dark,
    required this.names,
    required this.captions,
    required this.shadows,
  });

  final String title;
  final bool dark;
  final List<String> names;
  final List<String> captions;
  final List<List<BoxShadow>> shadows;

  @override
  Widget build(BuildContext context) {
    final panelBg = dark ? const Color(0xFF17171C) : const Color(0xFFF0F0F2);
    final ls = Theme.of(context).extension<StarryTokens>()!.letterSpacing;
    final panelBorder = dark
        ? const Color(0x1FFFFFFF)
        : const Color(0xFFE4E4E9);
    final cardBg = dark ? const Color(0xFF1F1F26) : Colors.white;
    final titleColor = dark ? const Color(0xFFB4B4C0) : const Color(0xFF6B6B78);
    final nameColor = dark ? const Color(0xFFF5F5F7) : const Color(0xFF17171C);
    final capColor = dark ? const Color(0xFF8A8A99) : const Color(0xFF9A9AA5);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      decoration: BoxDecoration(
        color: panelBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: panelBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: ls.wider,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < names.length; i++) ...[
            if (i > 0) const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                boxShadow: shadows[i],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    names[i],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: nameColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    captions[i],
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.4,
                      fontFamily: 'monospace',
                      color: capColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Charts foundation --------------------------------------------------------

class ChartsFoundation extends StatelessWidget {
  const ChartsFoundation({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<StarryTokens>()!;
    final chart = tokens.chart;
    final s = tokens.semantic;
    const barHeights = <double>[70, 92, 128, 84, 108, 96];
    return _FoundationScaffold(
      children: [
        _SectionCard(
          index: '06',
          title: '数据可视化色板 Chart Palette',
          subtitle:
              '8 色分类色板，与品牌紫协调且相互可区分。按序号取色，超过 8 类从 chart/1 循环；同一数据系列在明暗模式下使用同一色。',
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (var i = 0; i < chart.length; i++)
                  _SpecSwatch(color: chart[i], name: 'chart/${i + 1}'),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              '应用示例 · BAR CHART',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: tokens.letterSpacing.wider,
                color: s.textTertiary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              decoration: BoxDecoration(
                color: s.backgroundSecondary,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: s.border),
              ),
              child: SizedBox(
                height: 150,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < barHeights.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          width: 38,
                          height: barHeights[i],
                          decoration: BoxDecoration(
                            color: chart[i],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Typography foundation ----------------------------------------------------

class TypographyFoundation extends StatelessWidget {
  const TypographyFoundation({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<StarryTokens>()!;
    final t = tokens.typography;
    final s = tokens.semantic;
    final ls = tokens.letterSpacing;
    return _FoundationScaffold(
      children: [
        _SectionCard(
          index: '',
          title: '字阶 Typography',
          subtitle:
              '统一字阶，size/line-height 成对定义。展示文本用 display/headline，标题用 title，正文用 body，辅助信息用 label。',
          children: [
            for (final entry in t.ramp)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.$1,
                      style: entry.$2.textStyle.copyWith(color: s.textPrimary),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${entry.$1}  ·  ${entry.$2.size.toStringAsFixed(0)}/'
                      '${entry.$2.lineHeight.toStringAsFixed(0)}  ·  '
                      'height ${entry.$2.heightFactor.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 11, color: s.textTertiary),
                    ),
                  ],
                ),
              ),
          ],
        ),
        _SectionCard(
          index: '',
          title: '字间距 Letter Spacing',
          subtitle:
              '字间距（tracking）以逻辑像素定义，直接赋给 TextStyle.letterSpacing。'
              'normal(0) 为正文默认，wide/wider 用于副标题与眉标签，widest 用于'
              '强调 / 全大写导航标题，tight 预留给大字号标题收紧。',
          children: [
            for (final entry in ls.steps)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: Text(
                        entry.$1,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                          color: s.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      'ABC 示例',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: entry.$2,
                        color: s.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${entry.$2.toStringAsFixed(1)} px',
                      style: TextStyle(fontSize: 11.5, color: s.textTertiary),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Spacing foundation -------------------------------------------------------

class SpacingFoundation extends StatelessWidget {
  const SpacingFoundation({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<StarryTokens>()!;
    final sp = tokens.spacing;
    final s = tokens.semantic;
    return _FoundationScaffold(
      children: [
        _SectionCard(
          index: '05',
          title: '间距 Spacing',
          subtitle:
              '4px 基间，11 级刻度。组件内部用 1–4 级，卡片与列表间距用 4–6 级，页面分区用 8 级以上。色条为实际像素宽度。',
          children: [
            for (final entry in sp.steps)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    SizedBox(
                      width: 84,
                      child: Text(
                        entry.$1,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                          color: s.textPrimary,
                        ),
                      ),
                    ),
                    if (entry.$2 > 0)
                      Container(
                        width: entry.$2,
                        height: 18,
                        decoration: BoxDecoration(
                          color: s.brand,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    const SizedBox(width: 12),
                    Text(
                      entry.$2 > 0
                          ? '${entry.$2.toStringAsFixed(0)} px'
                          : '0 px（无间距）',
                      style: TextStyle(fontSize: 11.5, color: s.textTertiary),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Motion foundation --------------------------------------------------------

/// Breakpoints foundation ---------------------------------------------------

class BreakpointsFoundation extends StatelessWidget {
  const BreakpointsFoundation({super.key});

  static const _ranges = <String, String>{
    'breakpoint/compact': 'compact < 600',
    'breakpoint/medium': 'medium 600–840',
    'breakpoint/expanded': 'expanded 840–1200',
    'breakpoint/large': 'large 1200–1600（≥1600 为 extraLarge）',
  };

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<StarryTokens>()!;
    final bp = tokens.breakpoints;
    final s = tokens.semantic;
    return _FoundationScaffold(
      children: [
        _SectionCard(
          index: '09',
          title: '断点 Breakpoints',
          subtitle:
              'Material 3 Window Size Class 阈值（逻辑像素）。按可用布局宽度（MediaQuery / LayoutBuilder）而非物理设备宽度判定；下边界含、上边界不含。',
          children: [
            for (final entry in bp.steps)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: Text(
                        entry.$1,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                          color: s.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 72,
                      child: Text(
                        '${entry.$2.toStringAsFixed(0)} px',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: s.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _ranges[entry.$1] ?? '',
                        style: TextStyle(fontSize: 11.5, color: s.textTertiary),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Control metrics foundation ----------------------------------------------

class ControlMetricsFoundation extends StatelessWidget {
  const ControlMetricsFoundation({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<StarryTokens>()!;
    final cm = tokens.controlMetrics;
    final ind = tokens.indicator;
    final s = tokens.semantic;
    final r = tokens.radius;

    final heights = <(String, double)>[
      ('height/xs', cm.heightXs),
      ('height/sm', cm.heightSm),
      ('height/md', cm.heightMd),
      ('height/lg', cm.heightLg),
      ('height/xl', cm.heightXl),
    ];
    final icons = <(String, double)>[
      ('icon/xs', cm.iconXs),
      ('icon/sm', cm.iconSm),
      ('icon/md', cm.iconMd),
      ('icon/lg', cm.iconLg),
      ('icon/xl', cm.iconXl),
    ];
    final borders = <(String, double)>[
      ('border/thin', cm.borderThin),
      ('border/thick', cm.borderThick),
    ];
    final dots = <(String, double)>[
      ('dot/sm', ind.dotSm),
      ('dot/md', ind.dotMd),
    ];

    return _FoundationScaffold(
      children: [
        _SectionCard(
          index: '08',
          title: '控件度量 Control Metrics',
          subtitle: '交互控件本体的固有尺寸(高度 / 图标 / 描边),与「间距」「圆角」正交。色块为实际像素尺寸。',
          children: [
            const _SubDivider('控件高度 · HEIGHT'),
            for (final entry in heights)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 96,
                      child: Text(
                        entry.$1,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                          color: s.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      width: 120,
                      height: entry.$2,
                      decoration: BoxDecoration(
                        color: s.brand,
                        borderRadius: BorderRadius.circular(r.sm),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${entry.$2.toStringAsFixed(0)} px',
                      style: TextStyle(fontSize: 11.5, color: s.textTertiary),
                    ),
                  ],
                ),
              ),
            const _SubDivider('图标字号 · ICON'),
            for (final entry in icons)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 96,
                      child: Text(
                        entry.$1,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                          color: s.textPrimary,
                        ),
                      ),
                    ),
                    Icon(Icons.star_rounded, size: entry.$2, color: s.brand),
                    const SizedBox(width: 12),
                    Text(
                      '${entry.$2.toStringAsFixed(0)} px',
                      style: TextStyle(fontSize: 11.5, color: s.textTertiary),
                    ),
                  ],
                ),
              ),
            const _SubDivider('描边宽度 · BORDER'),
            for (final entry in borders)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 96,
                      child: Text(
                        entry.$1,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                          color: s.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      width: 120,
                      height: 32,
                      decoration: BoxDecoration(
                        color: s.surface,
                        border: Border.all(
                          color: s.borderStrong,
                          width: entry.$2,
                        ),
                        borderRadius: BorderRadius.circular(r.sm),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${entry.$2.toStringAsFixed(0)} px',
                      style: TextStyle(fontSize: 11.5, color: s.textTertiary),
                    ),
                  ],
                ),
              ),
            const _SubDivider('派生关系 · DERIVED'),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '内圆角 = radius.lg − borderThick = '
                '${r.lg.toStringAsFixed(0)} − '
                '${cm.innerRadiusDelta.toStringAsFixed(0)} = '
                '${(r.lg - cm.innerRadiusDelta).toStringAsFixed(0)} px',
                style: TextStyle(fontSize: 12, color: s.textSecondary),
              ),
            ),
            Text(
              'controlHeight = ${cm.controlHeight.toStringAsFixed(0)} px · '
              'minTouchTarget = ${cm.minTouchTarget.toStringAsFixed(0)} px · '
              'focus/rest border = ${cm.focusBorderWidth.toStringAsFixed(0)}/'
              '${cm.restBorderWidth.toStringAsFixed(0)} px',
              style: TextStyle(fontSize: 12, color: s.textSecondary),
            ),
            const _SubDivider('指示器 · INDICATOR'),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '状态点直径(装饰性、非交互;独立于控件高度)。',
                style: TextStyle(fontSize: 12, color: s.textSecondary),
              ),
            ),
            for (final entry in dots)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 96,
                      child: Text(
                        entry.$1,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                          color: s.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      width: entry.$2,
                      height: entry.$2,
                      decoration: BoxDecoration(
                        color: s.info,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${entry.$2.toStringAsFixed(0)} px',
                      style: TextStyle(fontSize: 11.5, color: s.textTertiary),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class MotionFoundation extends StatelessWidget {
  const MotionFoundation({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<StarryTokens>()!;
    final m = tokens.motion;
    final s = tokens.semantic;
    final durations = <(String, String)>[
      ('durationShort', '${m.durationShort.inMilliseconds} ms'),
      ('durationMedium', '${m.durationMedium.inMilliseconds} ms'),
      ('durationLong', '${m.durationLong.inMilliseconds} ms'),
    ];
    final easings = <(String, String)>[
      ('easingStandard', m.easingStandard.toString()),
      ('easingEmphasized', m.easingEmphasized.toString()),
    ];
    final interactions = <(String, String)>[
      ('pressedScale', m.pressedScale.toString()),
    ];
    return _FoundationScaffold(
      children: [
        _SectionCard(
          index: '07',
          title: '动效 Motion',
          subtitle:
              '3 档时长 + 2 条缓动曲线。短时长用于点按反馈，中时长用于常规过渡，长时长用于页面级转场；标准曲线用于大多数场景，强调曲线用于需要突出的关键动作。',
          children: [
            const _SubDivider('时长 DURATION'),
            for (final r in durations)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 168,
                      child: Text(
                        r.$1,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                          color: s.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      r.$2,
                      style: TextStyle(fontSize: 12.5, color: s.textSecondary),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            const _SubDivider('缓动 EASING'),
            for (final r in easings)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 168,
                      child: Text(
                        r.$1,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                          color: s.textPrimary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        r.$2,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: s.textSecondary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            const _SubDivider('交互 INTERACTION'),
            for (final r in interactions)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 168,
                      child: Text(
                        r.$1,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                          color: s.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      r.$2,
                      style: TextStyle(fontSize: 12.5, color: s.textSecondary),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            const _SubDivider('实时预览 LIVE PREVIEW'),
            Text(
              'durationMedium · easingStandard',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: s.textTertiary,
              ),
            ),
            const SizedBox(height: 14),
            const _MotionDemo(),
          ],
        ),
      ],
    );
  }
}

class _MotionDemo extends StatefulWidget {
  const _MotionDemo();

  @override
  State<_MotionDemo> createState() => _MotionDemoState();
}

class _MotionDemoState extends State<_MotionDemo> {
  bool _on = false;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<StarryTokens>()!;
    final m = tokens.motion;
    final s = tokens.semantic;
    return Row(
      children: [
        AnimatedContainer(
          duration: m.durationMedium,
          curve: m.easingStandard,
          width: _on ? 200 : 80,
          height: 48,
          decoration: BoxDecoration(
            color: s.brand,
            borderRadius: BorderRadius.circular(_on ? 24 : 8),
          ),
        ),
        const SizedBox(width: 16),
        FilledButton(
          onPressed: () => setState(() => _on = !_on),
          child: const Text('Toggle'),
        ),
      ],
    );
  }
}

/// Contrast matrix foundation (spec 04 · 对比度矩阵) --------------------------
///
/// Computes live WCAG 2.1 contrast ratios between text roles and background
/// roles, for both Light and Dark themes. Ratings: ≥7 AAA, ≥4.5 AA,
/// ≥3 AA大 (large text / graphics only), <3 不足 (fail for body text).

double _relLuminance(Color c) {
  double ch(double v) {
    v = v / 255.0;
    return v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = ch(((c.toARGB32() >> 16) & 0xFF).toDouble());
  final g = ch(((c.toARGB32() >> 8) & 0xFF).toDouble());
  final b = ch((c.toARGB32() & 0xFF).toDouble());
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

double _contrast(Color a, Color b) {
  final la = _relLuminance(a);
  final lb = _relLuminance(b);
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

({String label, Color bg, Color fg}) _rating(double ratio) {
  if (ratio >= 7) {
    return (
      label: 'AAA',
      bg: const Color(0xFFDCFCE7),
      fg: const Color(0xFF15803D),
    );
  } else if (ratio >= 4.5) {
    return (
      label: 'AA',
      bg: const Color(0xFFFEF3C7),
      fg: const Color(0xFFB45309),
    );
  } else if (ratio >= 3) {
    return (
      label: 'AA大',
      bg: const Color(0xFFE0F0FF),
      fg: const Color(0xFF245CC7),
    );
  }
  return (
    label: '不足',
    bg: const Color(0xFFFEE2E2),
    fg: const Color(0xFFDC2626),
  );
}

class _ContrastCell extends StatelessWidget {
  const _ContrastCell({required this.fg, required this.bg});
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    final ratio = _contrast(fg, bg);
    final r = _rating(ratio);
    return Container(
      width: 96,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: r.bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            '${ratio.toStringAsFixed(1)} · ${r.label}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: r.fg,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                'Aa',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContrastGrid extends StatelessWidget {
  const _ContrastGrid({required this.s});
  final StarrySemanticColors s;

  @override
  Widget build(BuildContext context) {
    // Columns: background roles. Rows: text/foreground roles.
    final cols = <(String, Color)>[
      ('bg/primary', s.background),
      ('bg/secondary', s.backgroundSecondary),
      ('brand/subtle', s.surfaceVariant),
      ('brand/primary', s.brand),
    ];
    final rows = <(String, Color)>[
      ('text/primary', s.textPrimary),
      ('text/secondary', s.textSecondary),
      ('text/tertiary', s.textTertiary),
      ('brand/on-primary', s.onBrand),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(width: 120),
            for (final c in cols)
              SizedBox(
                width: 100,
                child: Text(
                  c.$1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    row.$1,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                for (final c in cols) _ContrastCell(fg: row.$2, bg: c.$2),
              ],
            ),
          ),
      ],
    );
  }
}

class ContrastMatrixFoundation extends StatelessWidget {
  const ContrastMatrixFoundation({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<StarryTokens>()!;
    final s = tokens.semantic;
    final ls = tokens.letterSpacing;
    return _FoundationScaffold(
      children: [
        _SectionCard(
          index: '04',
          title: '对比度矩阵 Contrast Matrix',
          subtitle:
              '关键前景 / 背景组合的 WCAG 对比实测。绿底 ≥7 AAA，黄底 ≥4.5 AA，AA大 ＝ 仅大文本与图形（≥3），红底 <3 禁止用于正文。',
          children: [
            Text(
              'LIGHT 浅色模式',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: ls.wide,
                color: s.textTertiary,
              ),
            ),
            const SizedBox(height: 12),
            _ContrastGrid(s: StarryTokens.light.semantic),
            const SizedBox(height: 28),
            Text(
              'DARK 深色模式',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: ls.wide,
                color: s.textTertiary,
              ),
            ),
            const SizedBox(height: 12),
            _ContrastGrid(s: StarryTokens.dark.semantic),
            const SizedBox(height: 18),
            Text(
              '注：浅色模式 text/tertiary 仅用于占位 / 禁用文本，不用于正文；深色模式 text/tertiary 仅限大文本与图标。品牌色上的文字一律使用 brand/on-primary（深紫），不使用白色。',
              style: TextStyle(
                fontSize: 11.5,
                height: 1.6,
                color: s.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
