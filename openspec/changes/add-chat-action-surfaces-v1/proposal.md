## Why

Starry 的统一聊天入口需要跨桌面与移动端复用的菜单/选择面板和键盘可导航列表，但这些能力属于设计系统而非业务仓。将它们沉淀为 `starry_ui` 公共组件，可以避免主应用重复造轮子并确保响应式、无障碍和令牌契约一致。

## What Changes

- 新增桌面锚定浮层公共组件，支持相对触发器定位、焦点进入/退出、Esc 关闭和边界内重定位。
- 新增移动端底部面板公共组件，支持同一面板内的二级子页与可预测返回，不嵌套多层弹窗。
- 新增键盘可导航的过滤/分组选择列表，支持方向键、Enter、Esc、可见焦点和语义标签。
- 提供响应式入口，使消费方以相同数据模型在桌面呈现锚定浮层、在手机呈现底部面板。
- 通过 `lib/starry_ui.dart` 唯一公共 barrel 导出，不包含 Starry 业务数据、路由或操作。
- 使用现有 tokens，不新增色板、令牌维度、兼容别名或旧实现 fallback。

## Capabilities

### New Capabilities

- `chat-action-surfaces-v1`

### Modified Capabilities

- 无。

## Impact

- 影响 `lib/src/interactions/**`、`lib/src/navigation/**`、`lib/starry_ui.dart`、Widgetbook use-case、widget/无障碍测试。
- 主应用通过 `package:starry_ui/starry_ui.dart` 消费；`starry_ui` 不导入 `package:starry/`。
- 不包含 Plus 菜单条目、斜杠命令、Topic 状态或任何业务执行逻辑。