# 角色卡与世界书编辑器的基础组件

本批补全通用组件能力，页面迁移另行实施。公开入口统一为
`package:starry_ui/starry_ui.dart`，视觉只读取现有令牌。

| 组件 | 使用契约 |
| --- | --- |
| `StarryTabBar<T>` / `StarryTab<T>` | 页面持有稳定 `value`；标签、图标、计数不承担身份。窄宽换行；方向键与 Home/End 跳过禁用项。页面负责对应内容面板。 |
| `StarryNumberField` | 仅整数，支持 nullable、min/max、readOnly、enabled。每次编辑回传 `StarryNumberFieldResult`；无效输入不回退、不夹取、不伪装成旧值。应用提供错误文案。 |
| `StarryMediaSlot` | 应用传入单资源 `preview` 和添加／替换／移除回调、文案；应用负责媒体加载、文件选择、上传和删除确认。加载期间禁用操作，只读隐藏操作。 |
| `StarryExpandableCard` | `expanded` 非空时受控，只发出变更请求。`headerActions` 独立于折叠按钮与旋转图标；`maintainState` 决定隐藏后是否保留子树。折叠内容不接收焦点或无障碍访问。 |
| `StarryDropdown<T>` | 保留内联展开。非空 value 受控；受控空选择须显式设置 `valueIsControlled: true`。支持受控 expanded、focusNode、选项禁用、键盘选择和 Escape 关闭。长列表限制可见高度并懒构建。 |
| `StarryTextArea` | 普通多行与 composer 都支持只读和校验反馈；普通多行增加 maxLength、maxLengthEnforcement、showCounter。计数按字素而非 UTF-16 长度。 |
| `StarryAvatar` | 应用媒体 `media` 与 `imageProvider` 互斥；应用媒体自行处理加载／失败。提供 `semanticLabel` 标识身份；可点击的小头像保留 48 命中区。 |
| `StarryTag` | `leading` 继承状态墨色和图标尺寸，仍是非交互标签；筛选和删除用 Chip。 |
| `StarryCodeBlock` | 原文可选择、长行换行；可选限制代码视窗高度。语言仅作标签，不解析／重排 JSON。开启复制时由应用提供四种本地化反馈文案；默认使用平台剪贴板，也可注入异步 writer。成功才显示回执，失败可重试；代码变化使旧回执失效。 |
| `StarryDialog` / `StarryDialogAction` | 通用标题、消息／自定义内容、受控操作按钮；最多一个 primary。内容滚动、按钮换行；danger 与 loading 显式表达。`show<T>` 提供模态路由；业务保存、授权、选项查询和操作关闭由调用方处理。 |
| `StarryInputDialog` | 复用统一弹窗与 TextField，支持单／多行、长度、帮助与同步 validator。校验失败保持打开并聚焦字段；成功原样返回文本，允许空文本须由应用决定。 |

数字字段的编辑状态必须参与保存校验：应用保留最后一次 result，只有
`result.isValid` 才可更新业务值并允许保存。不要把无效 result 的 null 当作可选空值；
不要忽略回调后继续保存上一次有效值。无界整数也限制在 ±(2^53 − 1)，保证
原生与 Web 精确表示一致。

`StarryAssetCard` 仍是内部的封面导航卡片（整卡点击、标题叠在封面上），
与编辑字段 `StarryMediaSlot` 的独立操作契约不同；没有新增公开导出或兼容别名。

新组件及扩展组件均提供 All Variants / Playground；展示目录由 build_runner 生成。
后续页面迁移应先替换重复控件，再接入真实编辑状态、验证与保存链路。

第二批仍只补全组件，不改应用页面。迁移 `_ApiPanel` 时用 `StarryTabBar`
表达语言选项，用 `StarryCodeBlock` 展示原始代码，删除页面中的 copied 状态与延时
复位逻辑。不要把字符串格式化、API 生成或可写 JSON 编辑器搬进组件库。
宿主 ThemeData 装配 StarryTokens 与从它派生的 StarryApplicationTokens；
主应用已装配，Widgetbook 本批补齐这一装配，基础 token 和 AppTheme 不变。

未保存确认框通过 `StarryDialog.show<_UnsavedEditAction>` 保留
保存／草稿／放弃／继续编辑的四个返回值；从 builder 的 dialogContext 关闭正确
的 Navigator。`confirm` 的确认、取消、外部关闭分别返回 true、false、null。
`barrierDismissible: false` 禁止外部点击与 Escape，系统返回或程序化 pop 的保护由
调用方的 PopScope 决定。异步业务过程中按钮禁用与 loading 由页面状态驱动。

`StarryInputDialog` 不沿用旧 AppDialog.input 的隐式 trim／空值转 null；
迁移调用方需显式验证并决定规范化方式。选项弹窗使用 `StarryDialog.content`
组合现有列表／字段，搜索、异步请求和多选状态仍由应用管理。旧 AppDialog、
EditTextDialog 及原生 AlertDialog 的替换与退役登记在页面迁移阶段同步完成。
