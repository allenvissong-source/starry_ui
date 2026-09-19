# Barrel export audit — why the zero-consumption exports stay

Measured 2026-09-20 on this workspace. Every number here is counted by
`_agent_logs/g3p3_twin_census.py` (census) and
`_agent_logs/g3p3_barrel_filter.py` (in-file filter), both re-runnable.

This file exists because "22 barrel exports have zero consumers" reads as a
deletion list and is not one. The per-component reason lives here rather than in
a commit message, so a future audit finds it (task 4.3).

## Method, so the numbers can be re-derived

`lib/starry_ui.dart` carries **61 export directives**, through which **120
public names** are reachable.

A *consumer* is a reference to the name that is not in the declaring file, not
an `import` / `export` / `part` directive, and not a line comment. Self-reference
is not consumption.

The count is taken **three** times, and keeping them apart is the whole point:

| Scope | What it answers |
| --- | --- |
| main repo `lib/` | does the app use it? |
| `starry_ui/lib/` excluding the declaring file | does the package use it elsewhere? |
| `starry_ui/lib/` declaring file only | is it load-bearing where it is declared? |

Windows note: ripgrep output is parsed with an anchored regex, because paths
start with a drive letter and splitting on `:` silently misfiles every hit.

## Result

| Bucket | Count |
| --- | --- |
| public names reachable via the barrel | 120 |
| zero consumers in the main repo | 52 |
| — of which still instantiated inside `starry_ui/lib` | 36 |
| — of which zero outside their own declaring file | 16 |
| — of those 16, load-bearing inside their declaring file | 15 |
| — of those 16, referenced nowhere in `lib/` at all | **1** |

**Deletable: none.** The single name with no reference anywhere under `lib/`,
`StarryBreathingDot`, has a dedicated test group
(`test/tier1_capability_additions_test.dart:269-311`, 2 tests over 11 lines of
assertions). Deleting the class means deleting those tests, and deleting tests is
not on the table. It is a *published capability with proven behaviour and no
current caller* — which is a deliberate export, not residue.

The audit figure of 22 is not reproducible under any of the three scopes
(52 / 16 / 1). Stated as a divergence rather than reconciled by picking whichever
scope lands on 22.

## Per-component reasons

### The 36 with zero main-repo consumers but live in-package use

Deleting any of these breaks `starry_ui` itself. They fall into three groups:

- **Composed by another Starry component.** `StarryAvatarSize` /
  `StarryIdentityDensity` (used by `StarryIdentityRow`), `StarryStateLayer`
  (used by `StarryDockBar`), `StarrySwipeable` (used by `StarryMessageList` and
  `StarrySlidableDrawer`), `StarrySwitch` (used by `StarrySettingsTile`),
  `StarryBrandColors` (used by `StarryImmersiveBackground`), `StarryTypography`
  (used by `StarryEmojiText` and `AppTheme`), `StarrySemanticColors` (31 uses).
  These are the design system working as intended: the app consumes the
  composite, the package consumes the part.
- **Enum / data types of a live component.** `StarryAvatarShape`,
  `StarryBadgePosition`, `StarryChipVariant`, `StarryIconButtonVariant`,
  `StarryMessageListAction`, `StarryMessageListItemData`, `StarryTextFieldState`,
  `StarryTopBarActionStyle`. A parameter type with no direct app reference is
  still the only way to pass that parameter.
- **Exercised by the Widgetbook catalogue.** `StarryAiButton`, `StarryAssetCard`,
  `StarryBadge`, `StarryChip`, `StarryEmojiText`, `StarryErrorWidget`,
  `StarryIconButton`, `StarryIdentityRow`, `StarryMessageList`,
  `StarryPageWrapper`, `StarryPulsingWidget`, `StarryRotatingWidget`,
  `StarryScalingWidget`, `StarrySearchInput`, `StarrySegmentedControl`,
  `StarrySkeletonOrContent`, `StarrySliverSkeletonOrContent`. Each has a
  `*.usecase.dart` and an entry in `main.directories.g.dart`. The catalogue is
  the package's shop window; an unconsumed-by-the-app component is exactly what
  a catalogue is for.

### The 15 with no external reference that are still load-bearing

All 15 are referenced only inside their own declaring file, which the census
excludes by design (a class is not its own consumer). That exclusion is right for
"does anything else use this" and wrong for "can this be deleted":

| Name | Why deleting it breaks the build |
| --- | --- |
| `StarrySpacing` | `starry_tokens.dart:1108` — `final StarrySpacing spacing;` on `StarryTokens` |
| `StarryRadius` | `:1098` — `final StarryRadius radius;` |
| `StarryMotion` | `:1120` — `final StarryMotion motion;` |
| `StarryOpacity` | `:1126` — `final StarryOpacity opacity;` |
| `StarryElevation` | field of `StarryTokens`, plus `foundations.dart` |
| `StarryGlass` | `:1089` — constructor default `const StarryGlass()` |
| `StarryIndicator` | `:1117` — `final StarryIndicator indicator;` |
| `StarryLetterSpacing` | `:1132` — `final StarryLetterSpacing letterSpacing;` |
| `StarryFocusMetrics` | `:1129` — `final StarryFocusMetrics focus;` |
| `StarryControlMetrics` | `:1111` — `final StarryControlMetrics controlMetrics;` |
| `StarryControlMetricsTokens` | 16 uses — the primitive layer `StarrySemanticControlMetrics` maps onto |
| `StarrySwitchSize` | `starry_switch.dart:33,42,96,98` — the `size` parameter, exhaustively switched |
| `StarryMasterDetailMode` | `starry_master_detail_layout.dart:82-85` — the mode it switches on |
| `StarryExpandableCard` | its own `State` class references it (`:94,97`) |
| `StarryResponsiveWidgetBuilder` | `starry_responsive.dart:53` — the `builder` field's type |
| `StarryWindowDragAreaBuilder` | `starry_desktop_window_frame.dart:77,220` |

These are token classes and parameter types. They are exported because a consumer
that reads `tokens.spacing.s4` needs `StarrySpacing` to be a nameable type. Their
"zero consumers" figure is an artefact of the measurement, not a property of the
code — which is precisely why the three scopes are reported separately instead of
collapsed into one number.

## Decision (task 4.1)

For all 52: **recorded as deliberately exported.** None gains a consumer in this
change and none is withdrawn from the barrel.

Withdrawing the 36 would break the package. Withdrawing the 15 token types would
make `StarryTokens`' own public fields unnameable by consumers. Withdrawing
`StarryBreathingDot` would orphan a passing test suite. The honest outcome of
this audit is that the zero-consumption figure was measuring the wrong thing,
and the list it produced contains nothing that should go.
