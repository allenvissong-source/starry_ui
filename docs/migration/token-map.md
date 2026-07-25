# Starry UI 全维度 Token 映射表（token-map）

> **Phase 1 权威 token 映射**。左侧为主项目 `lib/` 中的裸魔法值（静态扫描证据，761 个 dart 文件），右侧为 starry_ui `StarryTokens` 体系对应项。**零代码改动**；库组件内**禁止裸魔法值**，主项目在迁移时逐一替换为 token。

## 0. Token 体系总览（来源：`lib/src/theme/starry_tokens.dart`）

| 维度 | Token 类 | 取值 |
|---|---|---|
| 颜色·色阶 | `StarryColorScale` | purple/blue/gray/mint/coral，各 s50–s900（10 档） |
| 颜色·语义 | `StarrySemanticColors` | brand/surface/background/border/text*/success/warning/error/info（明暗翻转） |
| 颜色·品牌 | `StarryBrandColors` | brandGold/characterCardBg/feedCardBg/feedDivider/gradientStart/End |
| 圆角 | `StarryRadius` | none=0, xs=4, sm=8, md=12, lg=16, xl=20, xxl=28, full=999 |
| 阴影 | `StarryElevation` | level1–level4（BoxShadow 列表，明暗各一套） |
| 间距 | `StarrySpacing` | s0=0, s1=4, s2=8, s3=12, s4=16, s5=20, s6=24, s8=32, s10=40, s12=48, s16=64（4px 节律） |
| 字号/行高 | `StarryTypography` / `StarryTextStyleToken(size,lineHeight)` | display/headline/title/body/label 各 L/M/S |
| 动效 | `StarryMotion` | short=150ms / medium=300ms / long=500ms，Cubic(0.2,0,0,1) |

## 1. 颜色映射

扫描到 **226** 处 `Color(0x…)` 字面量，去重 **50** 个。其中可直接映射到语义/色阶 token 的高频值：

| 主项目字面量 | 出现 | 透明度 | → Token |
|---|---:|:--:|---|
| `0xFFFFFFFF` | 12 | 不透明 | `semantic.background / surface (light)` |
| `0x33AA99FF` | 9 | 0x33 叠加 | `semantic.brand (light) / purple.s400 (0xFFAB99FF≈)` |
| `0x24FFFFFF` | 6 | 0x24 叠加 | `semantic.background / surface (light)` |
| `0x22AA99FF` | 6 | 0x22 叠加 | `semantic.brand (light) / purple.s400 (0xFFAB99FF≈)` |
| `0xD1FFFFFF` | 6 | 0xD1 叠加 | `semantic.background / surface (light)` |
| `0x66AA99FF` | 4 | 0x66 叠加 | `semantic.brand (light) / purple.s400 (0xFFAB99FF≈)` |
| `0x1AAA99FF` | 4 | 0x1A 叠加 | `semantic.brand (light) / purple.s400 (0xFFAB99FF≈)` |
| `0xFFAA99FF` | 3 | 不透明 | `semantic.brand (light) / purple.s400 (0xFFAB99FF≈)` |
| `0x33FFFFFF` | 3 | 0x33 叠加 | `semantic.background / surface (light)` |
| `0x2AAA99FF` | 3 | 0x2A 叠加 | `semantic.brand (light) / purple.s400 (0xFFAB99FF≈)` |

> `AA99FF` 及其 alpha 变体（`33/22/66/1A/2A/19/02AD…` 前缀）是全项目最密集的品牌紫复用点，统一映射到 `semantic.brand`（叠加态用 `.withOpacity()` 或色阶邻档）。

## 2. 圆角映射

| 主项目值 | 出现 | → Token |
|---|---:|---|
| `16` | 15 | `radius.lg` |
| `20` | 3 | `radius.xl` |
| `24` | 2 | **缺口**（见 §6） |
| `32` | 2 | **缺口**（见 §6） |
| `1` | 1 | **缺口**（见 §6） |
| `6` | 1 | **缺口**（见 §6） |
| `10` | 1 | **缺口**（见 §6） |

## 3. 间距映射（EdgeInsets + SizedBox 合并）

| 主项目值 | 出现 | → Token |
|---|---:|---|
| `6` | 52 | **缺口**（见 §6） |
| `2` | 49 | **缺口**（见 §6） |
| `20` | 39 | `spacing.s5` |
| `8` | 28 | `spacing.s2` |
| `16` | 27 | `spacing.s4` |
| `12` | 26 | `spacing.s3` |
| `10` | 23 | **缺口**（见 §6） |
| `14` | 17 | **缺口**（见 §6） |
| `24` | 14 | `spacing.s6` |
| `32` | 11 | `spacing.s8` |
| `4` | 10 | `spacing.s1` |
| `1` | 7 | **缺口**（见 §6） |
| `18` | 7 | **缺口**（见 §6） |
| `40` | 7 | `spacing.s10` |
| `28` | 6 | **缺口**（见 §6） |
| `3` | 6 | **缺口**（见 §6） |
| `36` | 4 | **缺口**（见 §6） |
| `48` | 4 | `spacing.s12` |
| `9` | 3 | **缺口**（见 §6） |
| `72` | 3 | **缺口**（见 §6） |

## 4. 字号映射

| 主项目 fontSize | 出现 | → Token |
|---|---:|---|
| `13` | 15 | **缺口**（见 §6） |
| `11` | 4 | `typography.labelSmall` |
| `10` | 2 | **缺口**（见 §6） |
| `14` | 2 | `typography.titleSmall` |
| `12` | 2 | `typography.bodySmall` |
| `18` | 2 | **缺口**（见 §6） |
| `22` | 1 | `typography.titleLarge` |
| `20` | 1 | **缺口**（见 §6） |
| `15` | 1 | **缺口**（见 §6） |
| `28` | 1 | `typography.headlineMedium` |

## 5. 阴影 / 字重

- **阴影**：主项目多用内联 `BoxShadow(...)`，统一收敛到 `elevation.level1–4`；迁移时按视觉层级选级，不再内联硬编码 shadow。
- **字重**：`FontWeight.w400/w500/w600/w700` 由 `StarryTypography` 的 TextStyle 承载（各语义样式已内置 weight），组件不再单独指定裸 FontWeight。

## 6. Token 缺口清单（Phase 2 前需补充，本 Phase 仅记录）

> 以下主项目在用、但现有 token 体系**无对应档位**的值。Phase 2 消费前需决策：①补进对应 token 类；②就近归并到最接近档位；③判定为一次性特例保留内联。

### 6.1 圆角缺口

| 缺口值 | 出现 | 建议 |
|---|---:|---|
| `24` | 2 | 就近 `radius.xl`(20) 或新增档 |
| `32` | 2 | 就近 `radius.xxl`(28) 或新增档 |
| `1` | 1 | 就近 `radius.none`(0) 或新增档 |
| `6` | 1 | 就近 `radius.xs`(4) 或新增档 |
| `10` | 1 | 就近 `radius.sm`(8) 或新增档 |

### 6.2 间距缺口（非 4px 节律）

| 缺口值 | 出现 | 建议 |
|---|---:|---|
| `6` | 52 | 就近 `spacing.s1`(4) 或特例 |
| `2` | 49 | 就近 `spacing.s0`(0) 或特例 |
| `10` | 23 | 就近 `spacing.s2`(8) 或特例 |
| `14` | 17 | 就近 `spacing.s3`(12) 或特例 |
| `1` | 7 | 就近 `spacing.s0`(0) 或特例 |
| `18` | 7 | 就近 `spacing.s4`(16) 或特例 |
| `28` | 6 | 就近 `spacing.s6`(24) 或特例 |
| `3` | 6 | 就近 `spacing.s1`(4) 或特例 |
| `36` | 4 | 就近 `spacing.s8`(32) 或特例 |
| `9` | 3 | 就近 `spacing.s2`(8) 或特例 |
| `72` | 3 | 就近 `spacing.s16`(64) 或特例 |
| `120` | 3 | 就近 `spacing.s16`(64) 或特例 |
| `13` | 2 | 就近 `spacing.s3`(12) 或特例 |
| `22` | 2 | 就近 `spacing.s5`(20) 或特例 |
| `280` | 2 | 就近 `spacing.s16`(64) 或特例 |
| `420` | 2 | 就近 `spacing.s16`(64) 或特例 |

### 6.3 字号缺口

| 缺口值 | 出现 | 建议 |
|---|---:|---|
| `13` | 15 | 就近 `typography.bodySmall`(12) 或新增 |
| `10` | 2 | 就近 `typography.labelSmall`(11) 或新增 |
| `18` | 2 | 就近 `typography.titleMedium`(16) 或新增 |
| `20` | 1 | 就近 `typography.titleLarge`(22) 或新增 |
| `15` | 1 | 就近 `typography.titleSmall`(14) 或新增 |

### 6.4 颜色缺口（无 token 对应的高频字面量）

共 40 个去重字面量无直接 token 映射，高频前 20：

| 字面量 | 出现 | 备注 |
|---|---:|---|
| `0xFFF3F4F6` | 11 | 中性灰系，考虑并入 `gray` 色阶 |
| `0xFF999999` | 10 | 中性灰系，考虑并入 `gray` 色阶 |
| `0xFF9CA3AF` | 10 | 中性灰系，考虑并入 `gray` 色阶 |
| `0x14000000` | 8 | 黑/白叠加，改用 `.withOpacity()` |
| `0xFF030014` | 7 | 特例，逐一评估 |
| `0xFFEDEEF1` | 6 | 特例，逐一评估 |
| `0xFF1F1F1F` | 6 | 特例，逐一评估 |
| `0xFF0B071A` | 5 | 特例，逐一评估 |
| `0xFFD1D5DB` | 5 | 中性灰系，考虑并入 `gray` 色阶 |
| `0xFF4B5563` | 5 | 中性灰系，考虑并入 `gray` 色阶 |
| `0xFF7B61FF` | 4 | 特例，逐一评估 |
| `0xFFEDE4FF` | 4 | 特例，逐一评估 |
| `0xFFE5E7EB` | 4 | 中性灰系，考虑并入 `gray` 色阶 |
| `0x40000000` | 4 | 黑/白叠加，改用 `.withOpacity()` |
| `0xFF100A24` | 4 | 特例，逐一评估 |
| `0xFF17102D` | 4 | 特例，逐一评估 |
| `0xFF74717D` | 4 | 特例，逐一评估 |
| `0xFFCCCCCC` | 4 | 中性灰系，考虑并入 `gray` 色阶 |
| `0xFF333333` | 4 | 中性灰系，考虑并入 `gray` 色阶 |
| `0xFFF5F5F5` | 4 | 中性灰系，考虑并入 `gray` 色阶 |

---
_映射表由静态扫描 + token 源码提取生成；主项目与 token 源码均未改动。_
