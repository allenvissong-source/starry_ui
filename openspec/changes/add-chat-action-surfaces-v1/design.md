## Context

主应用聊天入口目前有两套不可复用的表面：桌面端手写的 AiActionPopupLayer（锚定浮层 + 自管 OverlayEntry）与设置页里一批 showModalBottomSheet 选择器。统一聊天入口要求 Plus 菜单与 slash 面板共用同一表面：宽屏锚定浮层、紧凑布局底部面板、二级选择在同面板内子页完成。本设计把表面壳与可导航列表收敛进 starry_ui，业务条目、命令解析与路由留在主应用 change（见 proposal.md 动机）。断点直接复用现有 StarryWindowSizeClass：compact（<600）走底部面板，medium 及以上走锚定浮层。

## Goals / Non-Goals

### Goals
- 一份不可变条目数据模型同时驱动锚定浮层与底部面板两种形态。
- 列表键盘可导航（上/下循环、Enter 激活、Esc 关闭）、可输入过滤、可分组，焦点行有可见描边，条目带 button/option 语义。
- 二级列表在同一面板内以子页呈现，头部返回，不再弹新层。
- 仅通过 lib/starry_ui.dart 导出；不引入业务类型、不新增令牌。

### Non-Goals
- 不提供相机/相册/文件/模型/技能/联网等具体业务条目与其行为（主应用 change 负责）。
- 不做 slash 命令解析、过滤匹配规则以外的命令引擎、Plan/Goal 执行。
- 不改主应用现有聊天装配，不迁移主应用既有弹窗（主应用 change 的任务）。

## Decisions

### Decision 1: 单一不可变条目模型 StarryActionItem
模型字段：id、title、subtitle?、keywords（过滤用字符串）、leadingBuilder（消费方提供图标 Widget，包内不锁图标字体）、selected、disabled、group?（分组标题串）、children?（非空表示该条目是二级入口，其内容为另一组 StarryActionItem）、onActivate?。
- 为什么：两种渲染器、过滤、分组、子页全部读同一模型；消费方不感知形态切换。
- 备选：让消费方分别提供浮层与底部面板两套数据 → 拒绝，必然漂移，直接违反统一入口目标。

### Decision 2: 形态由窗口尺寸类决定，复用平台表面
- compact：showModalBottomSheet(isScrollControlled: true, enableDrag: true)。
- medium 及以上：OverlayEntry 挂到应用 OverlayState，不新增 Navigator 路由。
- 为什么：底部面板与锚定浮层都是平台既有惯例；自绘窗口管理器会重复造轮子且焦点/手势语义不一致。
- 备选：统一用 overlay 自绘面板 → 拒绝，破坏手机端底部抽屉的平台手势与安全区约定。

### Decision 3: 锚定浮层定位策略
打开时由消费方传入触发矩形（按钮全局 Rect）。内部步骤：先以内容自然高度在触发区下方摆放；若下方剩余高度不足则翻转到上方；水平方向按视口 padding 钳制；仍超高则内容区内部滚动而非越界。关闭由遮罩点击、Esc、选择完成触发，焦点关闭前归还触发控件。
- 为什么：位置计算只依赖触发矩形与视口，不依赖主应用布局上下文，可独立 widget 测试。

### Decision 4: 共享列表 StarryActionList
带 FocusNode 与 CallbackShortcuts：上/下在拍平后的可激活条目序列上循环移动焦点；Enter 激活当前条目；Esc 触发关闭回调。内部一个过滤输入框，打开时自动聚焦；过滤实时按 title + subtitle + keywords 匹配；分组标题不可激活、方向键跳过；空分组整体隐藏。焦点行用 t.focus 描边 + t.controlMetrics.focusBorderWidth。
- 为什么：键盘、过滤、分组、语义只实现一次，两种形态复用。

### Decision 5: 子页 = 面板内面包屑栈
面板持有一个条目组栈（首帧为主组）。点击带 children 的条目入栈，头部左侧出现返回按钮出栈；整个过程底部面板/浮层保持挂载，内容区用交叉淡入切换。当前位于子页时，下滑/Esc/遮罩先回主组，再按一次才关闭。
- 为什么：满足“二级选择为同面板子页并可返回，不套多层弹窗”。

### Decision 6: 视觉全部取自现有令牌
表面色 t.semantic.surface、描边 border、主文本 textPrimary、次文本 textSecondary、禁用降透明度 t.opacity、圆角 t.radius.lg（浮层）与 t.radius.xl（面板顶部）、间距 t.spacing、动效 t.motion.durationShort/easingStandard、高度档位 t.controlMetrics。不新增 token、不新增色板。

### Decision 7: 文件落点与导出
实现文件放 lib/src/components/（沿用“Containers / surfaces”分组）：starry_action_item.dart（模型）、starry_action_list.dart（可导航列表）、starry_action_surface.dart（统一入口：形态选择 + 锚定浮层 + 底部面板 + 子页栈）。barrel 追加三行 export。配套 widget 测试与 Widgetbook use-case 同目录惯例。

## Risks / Trade-offs

- OverlayEntry 焦点泄漏：浮层关闭时若未归还焦点，键盘焦点悬空 → 浮层内部在 dispose 统一还焦，widget 测试覆盖“打开→关闭后焦点回到触发控件”。
- 子页状态下面板手势与返回顺序矛盾：用户在子页下滑时会直接关掉面板 → 面板拦截下滑/遮罩/Esc：深度>0 时先出栈，深度=0 才关闭；测试覆盖“子页 Esc 先回主组，再次 Esc 关闭”。
- 过滤框抢焦点导致桌面打开即输入：这是刻意行为（slash 面板打开即可敲命令），触发控件焦点在关闭时归还，测试断言。
- 锚定高度估算偏差：未渲染时内容高度未知 → 打开后先用最大约束（视口 70%）定位，布局完成按自然高度钳制；不做像素级对齐承诺。

## Migration Plan

纯增量：不改任何既有公开组件，主应用在自己的 change 里完成从 AiActionPopupLayer 到新表面的迁移。回滚 = 移除 barrel 三行 export 与新增文件，主应用侧无残留。

## Open Questions

无。业务条目内容、命令集合与是否禁用由主应用 change 决定，本能力只提供表面与模型。
