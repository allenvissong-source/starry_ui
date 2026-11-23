## 1. 数据模型

- [x] 1.1 实现 lib/src/components/starry_action_item.dart：StarryActionItem 不可变模型（id、title、subtitle?、keywords、leadingBuilder、selected、disabled、group?、children?、onActivate?），不含任何业务语义；运行 flutter analyze 通过
- [x] 1.2 为模型写单测：按 title/subtitle/keywords 命中过滤、空分组识别，flutter test 单文件通过

## 2. 键盘可导航过滤分组列表

- [x] 2.1 实现 lib/src/components/starry_action_list.dart：过滤输入框（打开自动聚焦）、分组标题渲染且不可激活、焦点行可见描边（t.focus + t.controlMetrics.focusBorderWidth）、条目 button/option 语义暴露标题与选中态；flutter analyze 通过
- [x] 2.2 widget 测试：方向键下/上在可激活条目间循环且跳过分组标题、Enter 触发当前条目 onActivate、Esc 触发关闭回调、输入文本后列表只显示命中条目；flutter test 通过
- [x] 2.3 widget 测试：禁用条目不响应 Enter、选中条目 semantics 暴露 selected 状态；flutter test 通过

## 3. 统一表面与子页导航

- [x] 3.1 实现 lib/src/components/starry_action_surface.dart：compact（<600）走 showModalBottomSheet(isScrollControlled/enableDrag)，medium 及以上走 OverlayEntry 锚定浮层；同一数据模型两种形态渲染；flutter analyze 通过
- [x] 3.2 锚定定位 widget 测试：触发区下方空间充足时浮层位于下方、底部空间不足时翻转到上方、水平方向不越出视口安全边距；flutter test 通过
- [x] 3.3 焦点与关闭 widget 测试：打开后焦点进入列表、Esc 关闭后焦点归还触发控件、点击遮罩关闭且不触发任何条目；flutter test 通过
- [x] 3.4 子页 widget 测试：带 children 的条目在同一面板内打开二级列表并出现返回按钮、返回回到主列表、子页时 Esc 先出栈再按一次才关闭、两种形态行为一致；flutter test 通过

## 4. 导出、文档与全量验证

- [x] 4.1 lib/starry_ui.dart barrel 追加三个新文件 export，消费方可从 package:starry_ui/starry_ui.dart 直接引用
- [x] 4.2 为三个组件写 Widgetbook use-case（All Variants + Playground），运行 dart run build_runner build --delete-conflicting-outputs 并确认 main.directories.g.dart 重新生成
- [x] 4.3 starry_ui 全量 flutter analyze（No issues found）与 flutter test 全绿；只对新增文件执行 dart format，不跑全仓 format
- [x] 4.4 跨仓验证：主工程 D:\Starry-AI\starry 运行 flutter analyze --no-fatal-infos 通过，确认新公开 API 可被主工程解析
