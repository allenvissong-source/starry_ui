# Starry UI 规约与验收标准（conventions）

> **Phase 1 权威规约**。定义命名规约、成熟度状态机、单组件验收清单、双提交纪律、依赖方向。所有 Phase 2+ 迁移动作以本文件为准。**零代码改动**。

## 1. 命名规约

- **包公共前缀**：对外组件统一 `Starry` 前缀（如 `StarryButton`），与主项目遗留 `App*`/`Ailore*` 命名区分；迁移即改名，主项目侧替换 import。
- **文件布局**：`lib/src/<layer>/<component>.dart`，layer ∈ `components` / `foundations` / `theme`；迁移中组件先置 `lib/src/_migrating/`。
- **barrel**：`lib/starry_ui.dart` 只导出 public stable 符号；`src/` 与 `_migrating/` 为私有实现，调用方**禁止**直接 import。
- **Widgetbook 用例**：`<component>.usecase.dart`，与组件同名对应；`main.directories.g.dart` 由 build_runner 生成，不手改。
- **token 引用**：组件内一律 `Theme.of(context).extension<StarryTokens>()`，禁止裸 `Color(0x…)` / 裸数值 padding / radius / fontSize。

## 2. 成熟度状态机

```
_migrating  ──验收通过──▶  internal stable  ──设计确认为公共 API──▶  public stable
```

| 状态 | 位置 | 进 barrel | 晋升条件 |
|---|---|---|---|
| `_migrating` | `lib/src/_migrating/` | 否 | 刚迁入，未验收 |
| internal stable | `lib/src/components/…` | 否 | 通过第 3 节全部验收项，但设计价值判为 pattern/business-specific，仅库内/主项目内部用 |
| public stable | `lib/src/…` + 导出 | 是 | 通过验收 **且** 设计价值为 foundation/通用 pattern，确认对外稳定 |

> 晋升到 public stable = 加入 `starry_ui.dart` barrel export；一旦公开，接口视为对外契约，破坏性变更需版本升级说明。

## 3. 单组件验收清单（逐项，缺一不可）

每个迁移组件在晋升前必须全部满足并留证据：

1. **视觉与规格对齐**：与主项目原组件像素级对齐（或按设计规格修正），明暗主题均验证。
2. **无裸魔法值**：颜色/间距/圆角/字号/阴影全部走 `StarryTokens`；缺口值已按 `token-map.md` §6 决策处理，不留内联硬编码（特例需注释说明）。
3. **Widgetbook 用例覆盖**：至少一个 `.usecase.dart`，覆盖主要变体/状态（default/disabled/loading 等）。
4. **`flutter analyze` 洁净**：`D:\flutter\bin\dart.bat analyze` 或 dart MCP `analyze_files` 返回 No issues。
5. **Web 真机核对**：经 chrome-devtools MCP 打开 Widgetbook web 预览，截图/快照核对渲染，**不得标为“未验证”**。
6. **单向依赖检查**：组件不 import 主项目符号、不引入 state/nav/business/io 依赖（若为 B 级需显式确认最小化）。

## 4. 双提交纪律

每次组件迁移拆成两个独立、各自验证的提交：

1. **库侧提交（starry_ui 仓库）**：新增/规范化组件 + usecase + token 化，库侧 `pub get` / `analyze` / Widgetbook 构建通过后提交。
2. **主项目提交（Starry-Flutter-Frontend）**：替换原组件为 `starry_ui` 导入 + 删除主项目旧实现，主项目 `analyze` / 相关测试通过后提交。

> 两提交**不得混合**；主项目提交依赖库侧提交已落地（path 依赖可解析）。回滚时可独立回退主项目侧而不影响库。

## 5. 依赖方向（不可违反）

- **主项目 → starry_ui 单向依赖**，永不反向。
- starry_ui 不得 import 主项目任何包/符号；如发现组件依赖主项目的 model/service，说明它不是纯展示，应留主项目或先剥离依赖再迁。
- token 是 starry_ui 的内部资产，主项目通过 barrel 消费，不复制粘贴 token 定义。

## 6. 验收失败处理

- 任一验收项不过 → 组件留在 `_migrating/`，不进 barrel，不做主项目替换提交。
- 发现组件实际耦合业务（清单误判为 A/B）→ 改判去向为 keep-in-main 或 internal-stable，更新 `component-inventory.md`。

---
_规约为 Phase 2+ 执行约束；本 Phase 仅确立标准，未改动任何组件代码。_
