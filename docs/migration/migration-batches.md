# Starry UI 迁移批次与顺序（migration-batches）

> **Phase 1 权威批次编排**。批次划分基于组件清单（`component-inventory.md`）的静态扫描证据：169 个候选组件（A/B 耦合、public 命名），按 feature 归属分批。**零代码改动**；本文件只定义顺序、前置依赖与首步接线决策点。

## 0. 候选分布（来源：静态扫描 detail.txt）

| Feature | 候选数 | 迁移阶段 |
|---|---:|---|
| core | 95 | Phase 2 |
| chat | 37 | Phase 3 |
| cluster | 14 | Phase 3 |
| auth | 7 | Phase 3 |
| assets / creator / profile / settings / square / splash / starry_ai / dev / regex | 10 | Phase 4 |
| **合计** | **≈163+** | — |

> 数量以静态扫描为准，随实际消费逐组件确认；`typography.dart` 等误归类项在批次执行时剔除。设计价值/去向三属性见 `component-inventory.md`，PURE(A) 不等于必进公共 API。

## 1. Phase 2 — core（≈95，基础层，最高优先）

core 是所有其它 feature 的依赖底座，**必须最先落地**。内部再分三波，波内可并行、波间有序：

**Wave 2.0 — token 落地（前置，阻塞一切组件迁移）**
- `StarryTokens` 全体系（color/radius/spacing/typography/elevation/motion）已在库内，Phase 2 首步需补齐 `token-map.md` §6 的缺口决策（补档 / 就近归并 / 特例保留），组件迁移不得引入裸魔法值。

**Wave 2.1 — 原子基础组件（无组件间依赖，可并行）**
- 按钮族：`AppButton` / `AppIconButton` / `AppTextButton` / `PrimaryButton` / `PrimaryActionButton` / `SecondaryButton`
- 输入族：`AppTextField` / `SearchInput` / `SearchCapsule`
- 展示原子：`AppBadge` / `AppChip` / `BaseCard` / `CachedAvatar` / `MaterialSymbol` / `EmojiText`
- 反馈原子：`LoadingIndicator` / `FullScreenLoadingIndicator` / `EmptyState` / 循环动画（Pulsing/Rotating/Scaling）

**Wave 2.2 — 组合/布局组件（依赖 2.1 原子）**
- 布局：`PageTopBar` / `PageWrapper` / `SectionHeader(WithDivider)` / `KeyboardStableScaffold`
- 卡片组合：`ExpandableCard` / feed 原语（FeedBookmarkButton/FeedMetricBar/FeedTypePill/…）
- 弹层/底栏：`BottomSheetHandle` / `BottomSheetWrapper` / `AppDockBar` / `AppHubHeader` 族
- settings 展示壳：`AiloreControlShell` / `AiloreSwitch` / `AiloreSlider` / `SegmentedThree` 等（B 级需确认无 state/nav 泄漏）

## 2. Phase 3 — chat / cluster / auth（≈58）

**前置：Phase 2 core 全部落地**（chat/cluster/auth 大量复用 core 原子）。

- **chat（37）**：消息气泡、输入工具条、附件网格等展示层；剥离 controller/notifier 依赖后迁移，业务态留主项目。
- **cluster（14）**：群组/集群展示卡片与列表项。
- **auth（7）**：登录/注册表单展示壳，表单校验与提交逻辑留主项目。

波内顺序：先各 feature 的共享子组件，再页面级组合件。

## 3. Phase 4 — 长尾 + 收尾（≈10）

- assets / creator / profile / settings / square / splash / starry_ai 各 1–2 个候选，逐一评估去向（多为 business-specific，倾向 keep-in-main 或 internal-stable）。
- 收尾：清理主项目残留重复组件、统一 import 到 barrel、回归验证。

## 4. Phase 2 首步 —— path 依赖接线（承接 Phase 0 延后决策）

Phase 2 的**第一个原子提交** = 引入 `starry_ui` path 依赖到主项目 pubspec + 替换首个组件（建议 `AppButton` 或 `BaseCard`，依赖最少）。此刻必须定两个待定项：

| 待定项 | 选项 | 默认建议 |
|---|---|---|
| (a) 依赖形态 | 相对 path / 绝对 path | 相对 path（跨机器/CI 可移植）→ 需 (b) |
| (b) 是否搬迁 starry_ui | 挪到主项目同级 / 原地不动 | 若选相对 path，则搬到主项目同级仓库目录，得到干净相对 path；否则保持绝对 path 原地引用 |

> 两项联动：**选相对 path ⇒ 建议搬迁**（主项目同级），**选绝对 path ⇒ 可原地**（`D:\Starry-1.07\starry_ui`）。跨 Windows/WSL 时注意 UNC/`/mnt/d` 路径一致性。此决策在 Phase 2 首步做，不在 Phase 0/1。

## 5. 每批前置依赖总则

1. **token 先行**：任何组件迁移前，其所用 token 缺口必须已决策（补档/归并/特例）。
2. **共享基础组件先行**：被多处复用的原子（按钮/输入/卡片/头像）必须先达 public stable，再迁依赖它的组合件。
3. **单向依赖**：主项目 → starry_ui，永不反向；starry_ui 不得 import 主项目任何符号。
4. **成熟度晋升**：新迁入组件先入 `_migrating/`，验收通过后晋升 internal/public stable 并进 barrel（见 `conventions.md`）。

---
_批次编排由静态扫描 feature 归属生成；主项目与库代码均未改动。_
