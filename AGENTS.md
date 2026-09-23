# AGENTS.md — starry_ui 组件库工作契约

> 本文件是任何 AI/人类贡献者在 `starry_ui` 包内写代码前 **必须先读** 的唯一权威规范。
> 它综合三处来源:(1) ui-ux-design 设计智能技能的十大规则族与三层令牌架构;
> (2) 本仓库真实存在的 `StarryTokens` API;(3) 迁移前三个组件
> (StarryChip / StarryBadge / StarryMessageList) 时踩坑总结出的可执行范式。
>
> 冲突裁决顺序:用户明确要求 > 正确性/无障碍/契约 > 本文件 > 个人风格偏好。

---

## 0. 环境与工具铁律(先看这条,能省一半时间)

- **本包物理路径:`D:\Starry-1.07\starry_ui`**,与主工程
  `D:\Starry-1.07\Starry-Flutter-Frontend` 是**同级兄弟目录**。主工程用
  `path: ../starry_ui` 依赖本包,两者相对位置不能改(CI 也依赖这个布局:它把
  五个兄弟仓 checkout 到主仓的上一级再 `pub get`)。
- **验证命令直接在 PowerShell 里跑**,工作目录设为本包根:
  - `flutter test` —— 全量(当前 27 个测试文件)
  - `flutter test test/xxx_test.dart` —— 单文件
  - `flutter analyze` / `dart format .`

  改完组件后**至少跑一次全量 `flutter test`**:本包有多道源码门禁以测试形式
  存在(§1.5.2 的 `no_padded_tap_target_in_inputs_test`、
  `button_density_guard_test`,§7.1 的 `no_hardcoded_colors_test`),
  它们只在测试里生效,`analyze` 发现不了。
- **golden 基线不在本机生成。** 唯一真源是主工程
  `.github/workflows/golden-baselines.yml` 的 ubuntu 渲染器。Windows 与 Linux
  的 Skia 对文字/图标光栅化不同(实测文字类 golden 差异约 4.4%),所以本地
  `--update-goldens` 只用来确认"差异是否符合预期",**生成的图不要提交**。
- **PowerShell 的两个实测坑**:
  1. `git` 把进度写进 stderr,PowerShell 会判为错误——命令末尾加 `exit 0`
     或 `| Out-Null`,不要据此认为 git 失败。
  2. .NET 的 `[IO.File]::ReadAllLines()` 等 API **不跟随 `Set-Location`**,
     用的是进程工作目录。一律传绝对路径。
- **改动影响主工程时,回主工程验证。** 本包测试全绿不代表主工程能编译:
  新增或重命名公开 API 后,到主工程跑 `flutter analyze`;涉及 Web 的改动跑
  `flutter build web --release`——它能抓出 `dart:io` 误用这类只在 Web 炸的问题
  (主工程 persona 编辑器曾因 `Platform.isX` 在 Web 崩溃)。
- **不要在工作区根目录 `D:\Starry-1.07` 下创建任何文件**(日志、截图、临时
  脚本)。根目录是多仓工作区、不属于任何仓库;临时产物规则见根目录 `AGENTS.md`。

---

## 1. 设计令牌:唯一真源,禁止硬编码

**任何颜色、圆角、间距、字号、阴影、动效时长都必须来自令牌,禁止字面量 hex / 魔法数字。**
运行时统一入口:

```dart
final t = Theme.of(context).extension<StarryTokens>()!;
```

`StarryTokens` 是基础设计值的唯一真源,提供 `StarryTokens.light` / `StarryTokens.dark`
两个静态实例,`lerp`/`copyWith` 已实现。`StarryApplicationTokens` 是同包内从
`StarryTokens` 派生的组件角色图(surface/text/interaction/chrome/feed/media/code/
metric/status),不得拥有另一套独立色板;应用只负责把这两个根扩展装配进
`ThemeData`,不得在应用仓重新定义通用视觉 token。运行时入口:

```dart
final t = context.starryTokens;
final app = context.starryApplicationTokens;
```

### 1.1 三层令牌架构(与 ui-ux-design 技能一致)

```
Primitive(原始色阶) → Semantic(语义角色) → Component(组件私有常量)
```

- **Primitive**:`t.purple / t.blue / t.gray / t.mint / t.coral`,每个是
  `StarryColorScale`,字段 `s50 s100 s200 … s900`(另有 `.stops` 返回浅→深列表)。
  **组件里不要直接引用 primitive**,除非在实现语义色的那一层。
- **Semantic**:`t.semantic`(`StarrySemanticColors`),这是组件应该用的层。
- **Component**:组件内部的私有 const(如 swipe 行宽 72、卡片圆角复用
  `t.radius`),只服务当前组件,不要伪装成通用抽象。

### 1.2 `t.semantic`(StarrySemanticColors)—— 组件配色只用这层

| 角色 | 字段 | light 参考值 |
|---|---|---|
| 品牌 | `brand` / `brandStrong` / `onBrand` | `#AA99FF` / — / `#241B45` |
| 背景 | `background` / `backgroundSecondary` / `backgroundTertiary` | — |
| 表面 | `surface` / `surfaceVariant` | — / `#F3F0FF` |
| 描边 | `border` / `borderStrong` | `#E4E4EB` |
| 文本 | `textPrimary` / `textSecondary` / `textTertiary` / `textDisabled` | `#17171D` / `#565670` |
| 成功 | `successBg` / `success` / `successStrong` | — |
| 警告 | `warningBg` / `warning` / `warningStrong` | — |
| 错误 | `errorBg` / `error` / `errorStrong` | `error`=`#EF4444`(dark `#F87171`) |
| 信息 | `infoBg` / `info` / `infoStrong` | `info`=`#0891B2` |

### 1.3 其余令牌族

- **`t.radius`**(StarryRadius):`none=0, xs=4, sm=8, md=12, lg=16, xl=20,
  xxl=28, full=999`(胶囊/圆用 `full` 或直接 `height/2`)。字段名不带数字后缀。
- **`t.spacing`**(StarrySpacing):`s0=0, s1=4, s2=8, s3=12, s4=16, s5=20,
  s6=24, s8=32, s10=40, s12=48, s16=64`。**所有 padding/gap 走这里**,对齐
  ui-ux 的 4pt/8dp 间距系统。**仅限"元素之间的空"(padding/gap/margin)**;
  控件本体固有尺寸(图标字号、控件高度、描边宽)不属于此族,走 `t.controlMetrics`,
  不要用 `spacing.s5` 之类去表达图标尺寸。
- **`t.controlMetrics`**(StarryControlMetrics):交互控件本体固有尺寸,与
  `spacing`(空)`radius`(圆角)正交。高度 `heightXs=32, heightSm=36,
  heightMd=44, heightLg=48, heightXl=56`(`heightXs=32` 锚定系统内最小的
  真实紧凑控件 = chip 高度,4pt 节奏);图标字号 `iconXs=14, iconSm=16,
  iconMd=18, iconLg=20, iconXl=24`;描边宽 `borderThin=1, borderThick=2`。
  语义 getter(组件层优先读这些):`controlHeight=heightLg(48)`、
  `focusBorderWidth=borderThick(2)`、`restBorderWidth=borderThin(1)`、
  `innerRadiusDelta=borderThick(2)`(内圆角 = `radius.lg - innerRadiusDelta`)、
  `minTouchTarget=heightLg(48)`。**控件图标/高度/描边只从这里取。**
  当前消费方:`StarryChip.visualHeight → heightXs(32)`、`StarryTextField`
  InputDecoration `constraints.minHeight → controlHeight(48)`。新控件的
  高度一律从此族取档,**严禁**再用 `spacing.s8` 之类"借间距当高度"。
- **`t.indicator`**(StarryIndicator):状态点/指示点直径(装饰性、非交互),与
  `controlMetrics`(交互控件尺寸)正交——状态点不承载触控/4pt 控件节奏承诺,故独立成族。
  两档:`dotSm=8`(徽标状态点)、`dotMd=12`(消息列表未读点)。当前消费方:
  `StarryBadge.dotSize`(默认 `dotSm`)、`StarryMessageList` 未读点(`dotMd`)。
- **`t.typography`**(StarryTypography.standard):字号阶梯
  `displayLarge … labelSmall`,每个是 `StarryTextStyleToken(size, lineHeight)`,
  取 `.textStyle` 得到 `TextStyle`(含相对行高)。常用:`bodySmall=(12,16)`、
  `bodyMedium=(14,20)`、`labelSmall=(11,16)`。
- **`t.elevation`**(StarryElevation,light/dark 各一套):`level1 … level4`,
  已是可直接用的 `List<BoxShadow>`。
- **`t.motion`**(StarryMotion.standard):`durationShort=150ms`、
  `durationMedium=300ms`、`durationLong=500ms`、`durationSlow=800ms`、
  `durationSlower=1200ms`;两条曲线**不相等**——`easingStandard = Cubic(0.2,0,0,1)`,
  `easingEmphasized = Cubic(0.05,0.7,0.1,1.0)`(减速尾更陡)。另有 `pressedScale=0.95`。
  **动画时长/曲线只从这里取。**
- **`t.brand`**(StarryBrandColors):`gradientStart, gradientEnd, primaryPale,
  primaryTint50, accentGradientEnd, brandGlow, accentGlow` —— 沉浸式渐变与
  光晕的品牌资产。
- 另有 `t.opacity`、`t.focus`、`t.glass`、`t.letterSpacing`、`t.breakpoints`
  五族,用法以 `starry_tokens.dart` 为准,本文不重复列举。

### 1.4 AppTheme 颜色装配:唯一字面量 = seed,其余派生自 token

`app_theme.dart` 里**唯一允许的颜色字面量是 `AppTheme.seed`**
(`Color(0xFFAB99FF)`),只用于喂 `ColorScheme.fromSeed` 生成 M3 色板。
`ColorScheme` 上被 `copyWith` 覆盖的其它颜色(`onPrimary` / `secondary` 等)
必须从 `StarryTokens.semantic.*` 派生,**不得在 app_theme 里重新声明颜色 const**
——否则与 `starry_tokens.dart` 形成双真源,主题迭代必然漂移。

```dart
final tokens = isLight ? StarryTokens.light : StarryTokens.dark;
final colorScheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness)
  .copyWith(
    primary: seed,
    onPrimary: tokens.semantic.onBrand,      // 不再是独立 const
    secondary: tokens.semantic.brandStrong,  // 明暗各取值,随主题自适应
  );
```

- **`secondary` 现解析为主题自适应紫 `brandStrong`**(light `#9179F5` /
  dark `#AA99FF`);旧蓝色 `secondary`(`0xFF4F8CF7`)已移除。
- **`seed`(`0xFFAB99FF`)与 `semantic.brand`(`0xFFAA99FF`)刻意一字之差、
  并不相等**:seed 只派生 M3 色板,brand 是设计语义品牌色,定位不同。这是有意
  为之,**后续维护者不要把它们"修正"成相等**。

> 违反本节 = 直接打回。看到 `Color(0xFF...)`、`EdgeInsets.all(16)`、
> `Duration(milliseconds: 200)` 这类字面量,先问"对应哪个令牌"。

---

### 1.5 视觉几何原则(iOS 血统:同心圆角与光学修正)

圆角/嵌套/居中/描边这类"看着对不对"的判断不能靠手感,背后是一组由 iOS 开创、
可用公式落地的几何法则。本节把它们沉淀为契约:凡涉及"一个圆角控件套在另一个圆角
控件里"、"图标在圆/胶囊里居中"、"发丝级描边"的场景,按此执行,**不得靠像素级
挪动或裁剪去凑**。所有半径/尺寸取值仍走 §1.3 令牌族,本节只定几何关系。

#### 1.5.1 同心圆角:`内半径 = 外半径 − 间隙`(核心法则)

两个圆角矩形嵌套时,内外圆弧必须**共圆心**,否则拐角处会出现"月牙缝"或
"鼓包"。共圆心的充要条件是四周间隙 `g` 处处相等,且:

```
innerRadius = outerRadius − g      (g = 内外元素之间的均匀间隙)
```

- **同半径嵌套是错的**:内外用同一个 `radius` 值,拐角处内圆弧会明显鼓出去,
  视觉上"内框拐角比外框还方"。这是最常见的圆角 bug。
- **间隙必须四周一致**:上/下/左/右的 `g` 不等,就没有统一圆心,拐角必留缝。
  Starry 里"月牙缝""描边被填色顶穿"几乎都是这个根因——不是圆角值错,是间隙不均。
- **不用裁剪**:`Clip.antiAlias` 把内元素切一刀能盖住溢出,但切完内元素的圆端
  就不再是标准圆弧了。同心法则下内外都保持完整正圆弧,**禁止用裁剪替代算半径**。
- Apple 在 iOS 26「Liquid Glass」把这条正式化为 SwiftUI `ConcentricRectangle` /
  `.rect(corners: .concentric)` / `.containerShape`,由容器自动下发同心半径
  [[ConcentricRectangle | Apple Developer]](https://developer.apple.com/documentation/swiftui/concentricrectangle)[[The math behind nesting rounded corners | Cloud Four]](https://cloudfour.com/thinks/the-math-behind-nesting-rounded-corners/)。

Starry 落地:内圆角控件用 `t.radius.lg - t.controlMetrics.innerRadiusDelta`
(见 §1.3 `innerRadiusDelta=borderThick(2)`)即"外半径 − 描边宽"这一常见特例。

#### 1.5.2 胶囊套胶囊:均匀内缩必然自动同心(推论)

外层是胶囊(高 `H`、半径 `H/2` 的 `StadiumBorder`),四周均匀内缩 `g`。
**关键:`H` 必须取"外壳内腔高",不是控件外框高。** 外壳恒绘一条
`focusBorderWidth`(=2)的聚焦描边,`ShapeBorder.dimensions` 会把 child 四周各内推
一个 border,所以 child 真正的排布高是 `内腔高 = controlHeight − 2·border`(48 − 4 =
**44**),不是 `controlHeight`。而水平方向的 `trailingPadding(= g)` 也是绘在描边**以内**
的,故上下的同心内缩必须在同一个"内腔坐标系"里算,四边可视白缝才会等宽:

```
内腔高 Hi = controlHeight − 2·border          (= 48 − 2·2 = 44)
内层高   = Hi − 2g                            (= 44 − 2·4 = 36)
内层半径 = Hi/2 − g = (Hi − 2g)/2 = 内层高 / 2  →  内层也是完美胶囊,且天然同心
```

代码真源:`StarryInputShell.interiorHeight`(= `controlHeight − 2·border`)与
`StarryInputShell.concentricInnerHeight`(= `interiorHeight − 2·gap`)。搜索框尾插的
"搜索"按钮把 `height` 取后者,四边可视白缝实测均为 `gap`(见
`test/search_input_concentric_test.dart`,`RenderBox` 实测 gapTop=gapBottom=gapRight=4)。

- 结论:**胶囊里放胶囊,只要保证四周内缩相等,内层用 `StadiumBorder` 即可**,
  半径不用手算,几何上自动落在同心位置。
- 反面:内层若用固定 `RoundedRectangleBorder(radius)` 而 `radius ≠ (H−2g)/2`,
  就破坏同心。胶囊场景一律 `StadiumBorder`,不写死半径。
- `StadiumBorder` 是真正与高度无关的胶囊;`RoundedRectangleBorder(r)` 的实际
  圆角会被 `min(r, height/2, width/2)` 夹取,细高/矮宽时不等于你写的 `r`。
- **反例(本仓踩过的坑)**:给"有真实宽度的按钮"套用"点状图标"的
  `Transform.translate` 外移量,会把按钮实心边推到/顶穿外壳描边;`Transform.translate`
  只做视觉位移、不参与布局也不裁剪,故会溢出。正解是走本节同心内缩,而非平移。
- **可视高 ≠ 布局高:命中区回填会顶穿同心(本仓踩过的坑,已有回归测试)。** 光把内层
  可视胶囊压到 36 还不够——若它的**布局盒**仍是 48,就会成为宿主 `Row` 里最高的孩子,
  把外壳内腔顶回 48(控件整体 48→52),上下白缝随之从 `g` 胀到 `(Hi_padded − 36)/2`,
  而水平缝仍是 `g`,又变回上下≈右侧 1.5 倍的不对称。两个具体来源都要堵:
    1. **内层按钮自身**:`StarryButton` 在传入显式 `height`(即同心场景)时用
       `MaterialTapTargetSize.shrinkWrap`,让布局盒贴合可视胶囊;仅在 `height == null`
       的独立按钮才用 `padded` 把命中区补到 ≥48(§1.5.6)。同一个 48 控件内,"同心 36 高"
       与"命中 ≥48 高"不可兼得,同心场景下显式高度优先。**这个"缩减高度 + shrinkWrap"
       的组合被固化成一等 API `StarryButton.concentric(...)`(唯一能给按钮传 `height` 的
       入口):默认构造器根本不收 `height`,所以"缩减高度却仍是 padded"这种不对称陷阱在
       类型层面不可表达,调用方无法误踩。**
    2. **同排的其它控件**:如"叉掉按钮",默认 `IconButton` 是 `padded` 命中区(48×48),
       会绕过 `constraints` 把 `Row` 顶到 52。必须显式
       `IconButton.styleFrom(tapTargetSize: shrinkWrap)` 且把高度约束到 `interiorHeight`,
       让每个孩子都落进 44 内腔,控件才稳定在 48、内层四缝才均匀。

> **两道源码门禁(随 `flutter test` 强制跑,不达标直接挂)守住本节两个子问题**:
> ① `no_padded_tap_target_in_inputs_test.dart` —— 扫 `lib/src/inputs/**`,高度受限
> 外壳内的 Material 可点击控件必须声明 `MaterialTapTargetSize.shrinkWrap`(堵"命中区
> 膨胀顶穿");② `button_density_guard_test.dart` —— 扫 `lib/src/buttons/**`,凡含
> Material 按钮的组件必须钉 `VisualDensity.standard`(堵"密度压缩变矮")。两者故意分开:
> 独立按钮*正当*用 `padded` 命中区(§1.5.6),所以 `shrinkWrap` 只在 inputs 强制、
> buttons 只校验密度。各留行级豁免注释(`// height-safe-allow` / `// density-guard-allow`)。

**特例:胶囊套圆(圆 = 宽高相等的胶囊)。** 圆就是 `width == height` 时的
`StadiumBorder`(半径退化为 `直径/2`),所以"圆嵌在胶囊里"是本节令内层宽=高的特例,
同样满足 §1.5.1 `内半径 = 外半径 − g`:

```
外层胶囊内腔高 Hi = controlHeight − 2·border、内缘半径 Hi/2,四周均匀内缩 g
→ 圆直径 = Hi − 2g,圆半径 = Hi/2 − g = 内缘半径 − g   ✅ 同心
```

- **与胶囊套胶囊的差别**:圆只在**垂直方向**自动占满 `H−2g` 并上下同心;水平方向它
  不铺满,必须**自己把左右也留成 `g`** 才四周同心。胶囊套胶囊是"内缩即同心",
  圆套胶囊是"内缩管上下、左右要另外摆位"。
- **本仓已在用(仅搜索框)**:`StarrySearchInput` 的"叉掉按钮"是这个特例——
  `minTouchTarget(48)` 见方的圆形命中区扣在 `controlHeight(48)` 高的胶囊右端,
  图标中心落在 `controlHeight/2` 处(=胶囊半圆心),共用圆心。定位量见
  `StarryInputShell.endCapNudge`(§1.5.6)。**"图标顶到药丸圆角"是搜索框专属观感**,
  不是通用输入框规则:`StarryTextField` 的尾部控件(清除键 / suffixIcon / trailing)
  一律走**统一内缩** `endPadding(20)`,与 `suffixIcon`、leading 同一口径,左右视觉对称。
  清除键保留 `minTouchTarget(48)` 宽的命中区,但**图标在框内居中**——这样
  `IconButton` 的 hover/splash 圆环始终扣在"×"上(用 `alignment` 只挪字形、不挪墨圈,
  会让圆环偏心)。居中的字形比裸 `suffixIcon` 多缩进半个命中余量
  `(minTouchTarget − iconMd)/2`;仅当清除键是**最右**控件时,用
  `Transform.translate` 把**整颗按钮**(字形 + 墨圈一起)外移这一段,落到统一内缩上——
  与搜索框 `clearIsLast` 同思路,只是这里落到 `endPadding` 而非药丸圆角。回归见
  `test/search_input_concentric_test.dart` 的
  "trailing affordances share one end inset" 与
  "clear button ink circle stays centered on the glyph"。
- **落地**:圆钮/圆头像用 `CircleBorder()` 或宽高相等的 `StadiumBorder`,**不要**用
  `RoundedRectangleBorder(radius: H/2)` 硬凑——它受 `min(r, w/2, h/2)` 夹取,宽≠高
  时不再是正圆。
  尾插一个同心圆(圆钮/圆头像)时,直径取几何真源
  `StarryInputShell.concentricCircleDiameter(t)`(= `concentricInnerHeight`,因圆是
  宽=高的胶囊),并让左右各留 `concentricGap` 保持四周同心。

#### 1.5.3 连续圆角 / 超椭圆(squircle)

iOS 图标与卡片用的不是正圆角,而是**连续曲率**的超椭圆(squircle),四阶超椭圆:

```
x⁴ + y⁴ = r⁴            (n=4 超椭圆;圆是 n=2 的特例)
App 图标圆角 ≈ 22.37% × 边长
```

- 连续圆角在拐角处曲率平滑过渡(无突变),**视觉上比同数值的正圆角"更圆、更大"**,
  所以从正圆角迁到连续圆角时半径观感会变大,需要重新校准。
- SwiftUI 用 `RoundedRectangle(cornerRadius:style: .continuous)` 表达
  [[RoundedCornerStyle.continuous | Apple Developer]](https://developer.apple.com/documentation/swiftui/roundedcornerstyle/continuous)。
  Flutter 的 `ContinuousRectangleBorder` **只是近似**(Apple 官方 squircle 约 60%
  平滑度,Flutter 的实现更"方"),半径 ≳16pt 的大表面才值得上,小控件用普通圆角即可。
- Starry 现状:统一用 `RoundedRectangleBorder` / `StadiumBorder`;引入连续圆角
  需专门评估并作为受控扩充(§7.1),不得零散散布。

#### 1.5.4 光学居中:按重心而非包围盒

非对称图形(三角形、播放键)在圆/方里"居中"要按**视觉重心**摆,不是几何包围盒中心。

```
等边三角形重心 = 从底边起 1/3 高处(而非 1/2)
→ 播放三角放进圆里要整体右移一点,肉眼才居中
```

- 判据:纯图标按钮里的三角/箭头等非对称字形,居中后仍"偏"就按重心补偿
  [[Optical adjustments | Bjango]](https://bjango.com/articles/opticaladjustments/)。
- 与 §2 规则 1(纯图标按钮必须 `Semantics`)配合:补偿的是**图标绘制位置**,
  命中区(§1.5.6)不跟着偏。

#### 1.5.5 光学过冲:等"面积"而非等"外接尺寸"

圆形/三角形要和方形看起来一样大,得比方形的外接尺寸更大——补的是面积差:

```
等面积时圆直径 = √(4/π) × 方边长 ≈ 1.1284 × 方边长   (即放大约 12.84%)
字体/图标的光学过冲通常 1–3%
```

- 圆点、圆形头像、圆形按钮与同格方形元素并置时,直接用同一数值会显小,按面积
  匹配后再吸附到像素网格 [[Optical adjustments | Bjango]](https://bjango.com/articles/opticaladjustments/)。
- Starry 里 `t.indicator`(状态点直径)与相邻方形控件并置时,先按面积核对再定档,
  不要机械等边长。

#### 1.5.6 最小命中区:44×44pt(硬约束)

可点元素的命中区 **≥44×44pt**(Apple HIG 原文;visionOS 抬到 60×60pt),命中区
**可以大于**可见图标——用 hit-slop 扩,不必把图标画大
[[Buttons | Apple HIG]](https://developer.apple.com/design/human-interface-guidelines/buttons)。

- 已由 §1.3 `controlMetrics.minTouchTarget=heightLg(48)` 与 §2 规则 2(命中区
  ≥44×44)承载,本节只补"命中区与视觉尺寸解耦"这一点:清除键等点状图标,
  图标 `iconMd(18)` 但命中盒撑到 48,靠透明外扩而非放大图标。
- **本仓落地**:`StarryChip` 的"叉掉"件即此解耦——可见胶囊仍是 `heightXs(32)`,
  但删除 `InkResponse` 自身盒撑到 `minTouchTarget(48)`(≥44),胶囊背景以
  `Positioned` 垂直内缩 `(48−32)/2` 画在 48 高的命中宿主之后,图标保持 `iconSm`。
  回归测试 `chip_delete_hit_target_test.dart` 实测命中盒 48×48、可见胶囊仍 32。
- **机制陷阱(本仓踩过的坑):命中盒被每层祖先 RenderBox 尺寸裁剪,hit-slop 必须是
  真实布局高度,不能靠 `radius` 凑。** Flutter 命中测试自外向内逐层做,任一祖先的
  `hitTest` 先判点是否落在自己盒内,越界直接拒——所以"命中区 ≥44"要求那条交互链上
  **每一层的布局盒都 ≥44**。给 `InkResponse`/`InkWell` 设大 `radius` 只放大 ripple
  涟漪、**不放大命中盒**;把图标塞进一个 32 高的父盒里,命中区就被裁到 32。正解是像
  上面那样让可点件**自身**占一个 ≥44 的盒(`SizedBox.square`/`constraints`),可见图标
  用 `Center` 居中、尺寸不变——视觉与命中就此解耦。

#### 1.5.7 发丝描边与像素网格对齐

1px 描边在 @2x/@3x 屏上要画成真正的物理发丝,并对齐像素网格才锐利:

```
发丝宽 = 1.0 / devicePixelRatio        → @2x 为 0.5pt,@3x 为 0.33pt
居中描边的线要按半个线宽做偏移,才落在像素边界上(否则发虚)
```

- 逻辑描边走 `t.controlMetrics.borderThin(1)`;需要"物理一像素"的分隔线才按
  `1/devicePixelRatio` 处理,并注意居中 stroke 的半宽偏移
  [[UIScreen nativeScale | Stack Overflow]](https://stackoverflow.com/questions/2734097/how-to-draw-a-1px-line-using-core-graphics)。
- Flutter 里用 `MediaQuery.of(context).devicePixelRatio` 换算;分隔线优先
  `Divider`/`BorderSide` 交给框架吸附,避免手绘错位。

#### 1.5.8 图标外壳必须锁死图标尺寸(本仓踩过多次的坑)

把 `Icon` 放进任何"图标外壳"(圆形/方形/胶囊按钮壳、`StarryRoundIconShell`
一类)时,**外壳必须显式约束图标的字号**——传 `size:` 或套 `IconTheme`——
绝不能只用一个 `SizedBox` 框住、让无尺寸 `Icon` 自己回退。原因:无尺寸 `Icon`
回退到 Material 环境默认的 **24**,被外壳的小盒(如 `iconMd(18)+2 = 20`)约束后
**非对称溢出**,MaterialIcons 的 em-box 度量下就读成"图标不在圆心、偏右下"。
这不是 §1.5.4 的光学重心问题,而是**尺寸失配**,加位移补偿只会越修越歪。

```
错(偏):  SizedBox(20, child: Center(child: Icon(Icons.add)))        // 回退 24 → 溢出
对(正):  IconTheme.merge(data: IconThemeData(size: iconSize(t)),   // 锁 18,显式 size 仍可覆盖
           child: Center(child: widget.child))
```

- 判据:全库图标消费方(`StarryButton`/`StarryTextField`/`StarrySearchInput`/
  `StarryIconButton`/`StarryChip`)都显式传 `t.controlMetrics.iconMd`;任何新增
  图标外壳若既不传 `size` 也不套 `IconTheme`,一律视为缺陷。
- **本仓落地**:`StarryRoundIconShell` 内层 `Center` 外包
  `IconTheme.merge(size: StarryControlShell.iconSize(t))`,让无尺寸 `Icon` 按控件
  语言的 18 渲染,显式 `Icon(size:)` 仍可覆盖。
- **实测方法(定"偏没偏"只认像素,不认源码推断)**:CanvasKit 的 WebGL 画布不保留
  drawing buffer、`toImage` 读不回,截图落盘又被桥接工作区守卫挡;可靠路径是
  **widget 测试里加载真实 `materialicons-regular.otf`(而非 flutter_test 的 Ahem
  占位字体)** 经真实控件 `RepaintBoundary.toImage(pixelRatio:4)` 光栅化,量墨迹
  包围盒中心相对几何中心的 dx/dy。`toImage`/`toByteData` 必须包在
  `tester.runAsync()` 里,否则 fake-async 不驱动真异步会挂死。本次修复实测:无尺寸
  变体 bboxDx/Dy 从 +7.5/+8.5 归零到 −0.5/0.0,与显式 18px 对照逐像素一致。

> 违反本节 = 直接打回。看到"内外圆角同值嵌套"、"用 `Clip` 盖溢出而不算同心半径"、
> "`Transform.translate` 把实心控件推出描边"、"图标在圆里按包围盒居中却肉眼偏"、
> "图标外壳只用 `SizedBox` 框住、不锁图标 `size`/`IconTheme`(§1.5.8)",
> 先回到本节的公式重算,而不是继续像素级挪。

---

## 2. 十大规则族(ui-ux-design 技能,按优先级)

组件交付前逐条自检。前两族是 **CRITICAL,不达标不许合入**。

1. **无障碍 (CRITICAL)** — 文本对比 ≥4.5:1(大字 3:1);可见焦点环;纯图标按钮
   必须 `Semantics(button:true, label:...)`;键盘可达;不靠颜色单独传达信息;
   尊重 `MediaQuery.disableAnimations` / reduced-motion。
2. **触控交互 (CRITICAL)** — 命中区 ≥44×44;目标间距 ≥8;主交互用 tap 不靠 hover;
   异步操作给 loading 反馈;按压有视觉反馈(InkWell/InkResponse ripple)。
3. **性能 (HIGH)** — 图片声明尺寸/占位防 CLS,`loadingBuilder`+`errorBuilder`;
   50+ 列表虚拟化(`ListView.builder`);只动画 transform/opacity。
4. **风格选择 (HIGH)** — 风格与产品一致;**禁止 emoji 当图标**,用矢量
   `Icons.*`;状态(hover/pressed/disabled)视觉清晰;每屏一个主 CTA。
5. **布局响应 (HIGH)** — 移动优先;断点 375/768/1024/1440;无横向滚动;
   正文移动端 ≥16;固定元素给底层内容留安全 padding。
6. **字体配色 (MEDIUM)** — 行高 1.5+;语义色 token;暗色用降饱和变体而非反色;
   数字列/价格/计时用 tabular figures 防抖动。
7. **动画 (MEDIUM)** — 微交互 150–300ms;进入 ease-out / 退出 ease-in;
   退出比进入短;每个动画都要表达因果,**禁止空转/装饰动画**;动画可中断。
8. **表单反馈 (MEDIUM)** — 可见 label(不只 placeholder);错误靠近字段并说明
   如何修复;破坏性操作确认 + 危险色;失败后聚焦首个无效字段。
9. **导航模式 (HIGH)** — 返回可预测并保留状态;底部导航 ≤5;弹窗/表单有明确
   关闭方式;当前位置高亮。
10. **图表数据 (LOW)** — 图表类型匹配数据;图例可见;tooltip 给精确值;
    颜色之外补图案/直标;提供无障碍摘要。

---

## 3. 组件编写范式(前 3 个组件迁移直接沉淀,照抄即可)

### 3.1 可点击/可删除元素:InkResponse + Material 祖先 + Semantics + Tooltip

`InkWell` / `InkResponse` 需要 **Material 祖先** 才有涟漪、焦点、hover 光标。
一个元素若"可删除但本身不可点",也必须补 Material。范式(取自 StarryChip):

```dart
// 删除按钮:命中区放大到 28×28(视觉图标仍 16),键盘可达 + 语义标签 + 提示。
if (onDelete != null) ...<Widget>[
  SizedBox(width: t.spacing.s1),
  Tooltip(
    message: deleteTooltip!,               // assert(onDelete==null || deleteTooltip!=null)
    child: Semantics(
      button: true,
      label: deleteTooltip,
      child: InkResponse(
        onTap: enabled ? onDelete : null,
        radius: 20,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 28, height: 28,
          child: Center(child: Icon(Icons.close, size: 16,
              color: fgColor.withValues(alpha: 0.7))),
        ),
      ),
    ),
  ),
],

// Material 祖先:tap 或 delete 任一存在就必须包一层。
Widget content = visualChip;
if (onTap != null && enabled) {
  content = InkWell(
    borderRadius: BorderRadius.circular(visualHeight / 2),
    onTap: onTap, child: content);
}
if ((onTap != null && enabled) || onDelete != null) {
  content = Material(color: Colors.transparent, child: content);
}
if (!enabled) content = Opacity(opacity: 0.5, child: content);
return content;
```

要点:命中区 ≥44 用"外扩 hitArea + 视觉小图标"实现,不是把图标画大;禁用态统一
`Opacity(0.5)`;用 `withValues(alpha:)` 而非弃用的 `withOpacity`。

### 3.2 徽标/计数:真 Semantics + 真入场动画 + tabular figures(取自 StarryBadge)

- **禁止空转动画**(如 `AnimatedScale` 恒定 scale=1,违反 §7 motion-meaning)。
  用真正 0→1 的入场:
  ```dart
  if (animate) {
    badge = TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 150),   // 对齐 durationShort
      curve: Curves.easeOut,
      child: badge,
      builder: (context, value, child) => Transform.scale(scale: value, child: child),
    );
  }
  ```
- **数字用等宽字形**防跳动:`fontFeatures: const [FontFeature.tabularFigures()]`。
- **语义标签**代替纯颜色/纯数字视觉:
  ```dart
  final semanticsLabel = showDot
      ? 'New notification'
      : (count! > maxCount ? 'More than $maxCount' : '$count');
  badge = Semantics(container: true, label: semanticsLabel, child: badge);
  ```

### 3.3 列表/滑动项:手势必须有可见替代 + 虚拟化开关 + 未读语义(取自 StarryMessageList)

- **手势替代 (HIGH, gesture-alternative)**:侧滑操作必须再给一个键盘/可点的
  溢出菜单,不能让滑动成为唯一入口:
  ```dart
  if (widget.item.actions.isNotEmpty) _buildOverflowMenu(), // 放在标题列之后
  // PopupMenuButton<int>(icon: more_vert, tooltip: 'Actions', splashRadius: 20, ...)
  ```
- **虚拟化开关**:新增可选 `double? maxHeight`。为 null → 沿用 `Column` 全量构建
  (贴合内容,向后兼容);非 null → `ConstrainedBox(maxHeight)` + `ListView.separated`
  懒构建,应对大数据集(§3 virtualize-lists)。**保持默认行为不破坏既有调用方。**
- **未读不能只靠颜色**:未读圆点包 `Semantics(label: 'Unread', child: ...)`。
- **头像图片**必须给 `loadingBuilder` 和 `errorBuilder`,都回退到
  `_buildAvatarFallback()`,防裂图/空白。

---

## 4. 成熟度阶梯与 barrel 导出策略

状态机:`_migrating → internal stable → public stable`。

- 迁移中的组件先放 `lib/src/_migrating/`,视为私有,**不得**出现在
  `lib/starry_ui.dart` 且**不得**被消费方直接 import。
- 只有到达 **public stable** 才在 `lib/starry_ui.dart` 加一行 `export`。
- 当前已 public-stable 并导出:icon_button / text_button / button / card /
  text_field / textarea / switch / message_list / badge / chip / tag,以及
  theme(tokens + app_theme)。
- 目录约定(按角色收敛):`buttons/`(按钮族:icon_button / text_button / button)、
  `inputs/`(表单输入控件:text_field / textarea / switch，附 `input_border.dart` 共用 helper)、
  `tags/`(标签徽标:badge / chip / tag)、`feedback/`(反馈类:message_list)、
  `components/`(容器/表面类通用组件,当前仅 card)、`overlays/`(浮层背景)、
  `foundations/`(基础演示页)、`theme/`(令牌与主题)。
  `components/` 已从「半迁移暂存区」收敛为「容器/表面类组件区」,其余组件按角色归入
  上述专属目录,不再作为过渡堆放地。

---

## 5. Widgetbook use-case 约定

每个组件配一个 `xxx.usecase.dart`,**至少两个 use-case**:

- `@UseCase(name: 'All Variants', type: StarryXxx)` — 一屏 `Wrap` 平铺所有变体/
  状态(含 selected / disabled / deletable / leading 等),用于总览与验收。
  **当横向排列会拥挤、换行或降低逐项对比效率时,改用单列 `Column` 纵向排列**;
  行间距必须来自 `t.spacing`,不得为展示页另写数字。验收时从 Web 语义树确认各项
  `transform` 的 x 基本一致、y 依次递增,不能只看截图猜布局。
- `@UseCase(name: 'Playground', type: StarryXxx)` — 用 `context.knobs.*`
  (string/boolean/object.dropdown)暴露关键参数,供交互调参。

改完 use-case 或注解后需重新生成:

```powershell
dart run build_runner build --delete-conflicting-outputs
```

`main.directories.g.dart` 是生成物,不要手改。

### 5.1 生成文件策略(硬性)

| 文件 | 生成器 | 生成命令 | 是否跟踪 | 理由 |
|---|---|---|---|---|
| `lib/main.directories.g.dart` | `widgetbook_generator` | `dart run build_runner build --delete-conflicting-outputs` | **是,已跟踪** | Widgetbook 目录文件必须跨 clone 稳定;消费方和 CI 不跑 build_runner;提交的文件是可审查的产物 |

- **不要手改 `main.directories.g.dart`**——它是 `// GENERATED CODE - DO NOT MODIFY BY HAND`。
- **不要在 `.gitignore` 中排除 `*.g.dart`**——本仓刻意跟踪 `main.directories.g.dart`。
- **CI 可复现门禁**:`.github/workflows/generated-files-check.yml` 在每次 push / PR 时
  跑 `dart run build_runner build --delete-conflicting-outputs` 后接 `git diff --exit-code`。
  如果生成物与提交的版本不一致(即有人改了 `@UseCase` 注解但忘了重新生成),CI 会 fail。
- 改完任何 `*.usecase.dart` 的注解后,**必须**本地跑一次生成命令并提交 diff。

---

## 6. 代码风格与 lint

- lint 基线:`analysis_options.yaml` = `package:flutter_lints/flutter.yaml`
  (flutter_lints ^6)。
- **通配符参数用单下划线**:`(_, _)` 而非 `(_, __)` —— 本仓库
  `unnecessary_underscores` 会报后者(迁移时真实踩过)。
- 用 `withValues(alpha:)`,不用已弃用的 `withOpacity`。
- 不留墓碑注释("这里删了 X / 待清理");版本历史可追溯。
- 不引入新依赖/新工具链,除非用户明确同意。

---

## 7. 收敛与变更半径

- 向单一、面向当前设计目标的实现收敛;不加不必要的 fallback、兼容层、临时开关、
  双轨逻辑、静默降级;不为假想未来预埋复杂度。
- 最小必要改动完成目标;新增 API 优先做成"可选且默认保持旧行为"(如
  MessageList 的 `maxHeight`),避免破坏既有调用方签名。
- 兼容措施只有"维持外部契约 / 降低真实迁移风险 / 数据兼容 / 明确调用方依赖"时才留,
  并注明为什么留、依赖谁、移除前提。

### 7.1 迁移纯净性门禁(每个组件必须逐项通过)

迁移的目标是把能力重写为 `starry_ui` 的单一实现,**不是把旧项目的实现、令牌或兼容包袱
复制进来**。每完成一个组件,必须执行以下门禁:

1. **Token 冻结**
   - 组件只读取现有 `StarryTokens`:`semantic / brand / spacing / radius /
     typography / elevation / motion / controlMetrics / indicator`;不得把旧项目的 token、颜色表、
     主题扩展或常量类带入。
   - 迁移普通组件时,`lib/src/theme/starry_tokens.dart` 与 `app_theme.dart` 应保持零差异。
     不得为了适配单个组件新增 token、别名、旧字段映射或同义字段。
   - **冻结 + 受控扩充(须获批)**:token 默认冻结;确有跨组件、可复用且设计已批准的新语义
     角色或新维度时,必须单独提案并获得用户确认,不能夹带在组件迁移中。经批准的扩充属受控例外,
     其对 `starry_tokens.dart` 的非零差异不视为污染,但须在本文件记录。
   - **已批准的受控扩充记录**:2026-07 经用户批准新增第 8 个 token 组 `controlMetrics`
     (`StarryControlMetrics`)——「交互控件本体固有尺寸」独立原子维度,与 `spacing`(间距)
     `radius`(圆角)正交。该维度经授权一次性做满成套刻度(高度 5 档 / 图标 5 档 / 描边 2 档
     + 语义 getter),即使部分档位当前无组件消费,属该维度内的设计决策,凌驾于反预埋条款。
     跨到其他维度(如 `elevation` / `motion`)仍适用「能不加就不加」:品牌壳阴影复用
     `elevation.level1`、按压复用 `motion.durationShort` / `easingStandard`,不得为单个
     控件新增 elevation 级或 motion 项。
   - **已批准的受控扩充记录**:2026-07 经用户批准在 `StarrySemanticColors` 新增 `onError`
     语义色(浅/深主题均为纯白 `#FFFFFF`,即 error 底上的前景色)。此前 `StarryBadge` 计数
     文字缺少对应语义角色,只能裸写 `Colors.white`;补 `onError` 后 badge 前景改为
    `t.semantic.onError`,消除该处硬编码。属语义色族内补全,不新增维度。
   - **已批准的受控扩充记录**:2026-07 经用户批准新增第 9 个 token 组 `indicator`
     (`StarryIndicator`)——「状态点/指示点直径」独立原子维度,与 `controlMetrics`
     (交互控件尺寸)正交:状态点是装饰性、非交互标记,不承载触控/4pt 控件节奏承诺,
     故不并入 controlMetrics 而单独成族。两档 `dotSm=8` / `dotMd=12`,统一此前
     `StarryBadge`(硬编码 8)与 `StarryMessageList` 未读点(硬编码 12)两处不一致的裸值。
     属新维度,受控例外;Foundations 因仅 2 档且语义邻近,并入 `ControlMetricsFoundation`
     的 `指示器 · INDICATOR` 子分区,不单开页。
   - **已批准的受控扩充记录**:2026-07 经用户批准对 `app_theme.dart` 做主题级
     颜色收敛——移除独立声明的 `onBrand`(`0xFF241B45`)与蓝色 `secondary`
     (`0xFF4F8CF7`)两个颜色 const,改为从 `StarryTokens.semantic`(`onBrand` /
     `brandStrong`)派生,消除 app_theme 与令牌的双真源;`seed`(`0xFFAB99FF`)
     字面量保持不变。属主题装配收敛(非组件迁移),对 `app_theme.dart` 的非零差异
     为受控例外,规则见 §1.4。**上文"迁移普通组件时 app_theme.dart 应保持零差异"
     仍成立**:组件迁移中不得夹带 app_theme 改动,主题级颜色收敛须像本次一样单独获批。
2. **禁止硬编码与魔法数字**
   - 颜色、间距、尺寸、圆角、阴影、字号、透明度、动画时长/曲线全部取现有 token。
   - 禁止 `Color(0x...)`、`Colors.*`、裸 `withValues(alpha: 数字)`、裸尺寸/间距/
     圆角/时长。仅 Flutter 平台契约常量(如 `kMinInteractiveDimension`)和纯算法常量
     (如比例除数)可直接使用,且含义必须清晰。
   - 禁止把魔法数字换成组件私有常量来规避审计;若现有 token 无法表达,先停下确认设计。
3. **禁止双写与重复真源**
   - 同一组件类/枚举/视觉规则只能有一个实现;迁移前后必须全仓搜索类名和目标符号。
   - 不得同时保留旧/新颜色解析、两套布局、双主题分支、重复 barrel export 或复制出的
     gradient/token 常量。
   - Widgetbook 只调用正式组件,不得在 use-case 内复制组件视觉实现。
4. **禁止无依据的兼容层**
   - 不为旧组件照搬 `color / backgroundColor / borderRadius / padding / brightness`
     等可绕过设计系统的覆盖参数;API 应直接表达当前 Starry 设计目标。
   - 禁止 fallback、legacy alias、旧枚举映射、临时开关、双轨逻辑、静默降级。
   - 唯一例外是已确认的真实外部调用契约;保留时必须写清依赖方、理由和删除条件。
5. **污染扫描与证据**
   - 用 `git diff -- lib/src/theme/starry_tokens.dart lib/src/theme/app_theme.dart` 证明
     token 未被改动;普通迁移预期为空。
   - 对迁移文件搜索 `Color(0x`、`Colors.`、`withValues`、`Duration(`、
     `Opacity(opacity:`、裸 `alpha/stops/radius`、`fallback/compat/legacy/deprecated`。
   - 全仓统计目标 `class/enum` 定义次数,每个正式符号必须为 1;同时复核 public barrel
     只有一个导出路径。
   - 搜索结果不为零时逐条解释并消除;没有证据不得声称“未污染 / 无硬编码 / 无双写”。
   - **已自动化(硬编码颜色 · 全局门禁)**:`test/no_hardcoded_colors_test.dart`
     遍历 **整个 `lib/src`**,命中 `Color(0x...)` 或具名 `Colors.<name>` 即 fail
     并打印 `file:line`。豁免全部显式、可审计:
     (a) 整文件白名单 `_wholeFileAllowlist` = `starry_tokens.dart`(调色板唯一真源)
     + `foundations.dart`(Widgetbook 文档页,内容即"展示各种颜色");
     (b) 行级放行 `Colors.transparent`(平台"无填充"哨兵,无设计语义);
     (c) 行级尾注 `// hardcode-allow: <理由>` 转义阀门(如 `app_theme.dart` 的
     `seed`),新增时必须写清理由。采用"全量扫描 + 白名单"而非目录清单,
     新增组件目录自动纳入,无需改门禁。此门禁随 `flutter test` 自动执行,
     组件颜色硬编码复查以它为准;其余维度(尺寸/间距/时长/双写等)仍按上述手工扫描。

### 7.2 完成状态与跟踪表

- 迁移、设计走查收敛、Web 验证是独立里程碑;每完成一个就立即更新 Sheet5 对应行 I 列,
  **做一个标一个,禁止攒批**。
- 状态文本必须准确反映已有证据;静态分析、Web 或像素验证缺失时不得写“全部通过”。
- 组件 API 发生收敛(删除旧覆盖参数/兼容入口)时,状态中标注“设计走查收敛(Token 审计)”;
  若移除兼容分支,明确标注“无兼容分支”。

---

## 8. 验证与交付契约(硬性)

每次改动完成后,按顺序做且给出证据:

1. **静态分析**:`flutter analyze` → 必须 `No issues found`。
2. **测试**:`flutter test` 跑全量(改动面小可先跑单文件,但提交前至少全量一次)。
   已有测试失败不得跳过,也不得用"界面看起来对"替代。
3. **格式**:只格式化你改过的文件 —— `dart format lib/src/<你改的文件>.dart`。
   **不要跑 `dart format .`**:本仓代码由更早版本的 dart 格式化,Dart 3.12.2 的
   tall-style 会重排 **79/149 个文件**(实测),把无关改动混进 diff;而主仓 CI
   没有 format 步骤,拦不住。全量重排需要单独立项并 pin SDK 版本,不要顺手做。
4. **视觉回归**:涉及渲染的改动,以 `test/` 下的 widget 测试与 golden 为准。
   golden 基线由主工程 `golden-baselines.yml` 的 ubuntu 渲染器生成(见 §0),
   本地跑出的差异先判断是否符合预期,不要直接提交本地生成的图。
   - **CanvasKit 无法做像素回读**:`canvas.getContext('webgl')` 返回 null
     (未开 `preserveDrawingBuffer`),所以不能靠浏览器画布取色验证颜色。
     颜色契约(如 `secondary` 是否等于某 token)一律用 Dart 层测试断言
     `ColorScheme` / token 值,比像素采样更强也更稳。
   - **需要量"图标偏没偏"这类像素问题**时,走 widget 测试:加载真实
     `materialicons-regular.otf`(而非 flutter_test 默认的 Ahem 占位字体),
     用 `RepaintBoundary.toImage(pixelRatio: 4)` 光栅化后量墨迹包围盒。
     `toImage`/`toByteData` 必须包在 `tester.runAsync()` 里,否则 fake-async
     不驱动真异步会挂死(§1.5.8 实测方法)。
5. **跨仓影响**:改动涉及公开 API 或 Web 行为时,按 §0 最后一条回主工程验证。
6. **污染门禁复核**:执行 §7.1 的 token diff、硬编码扫描、重复符号统计和 barrel 检查。
7. **收尾用语**:逐项验证全过 → 结尾写 `✅ 已全部完成`;有未过项 →
   `⚠️ 未全部完成`;被环境阻塞 → `⛔ 阻塞`。**绝不在未逐项验证时声称完成。**

> 已验证范例(留作基线):Chip 删除键 `role=button, tappable, 28×28`;
> MessageList 行含 `Unread` 标签 + 40×40 溢出菜单按钮 + 72×74 侧滑操作;
> Badge 呈现 `New notification` / `More than 99` / 数字语义标签。

---

## 9. 交付说明格式

代码落地类任务,最终消息覆盖:**做了什么**(改了什么/为什么/关键文件)、
**契约影响**(是否动接口/参数/默认行为,调用方注意点)、**清理与收敛**
(删了哪些冗余、保留哪些兼容项及原因)、**验证**(analyze/reload/Web 无障碍树
结果,哪些因环境未验证)、**遗留事项**(超边界问题、已知风险、后续建议)。
