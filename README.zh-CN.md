<p align="center">
  <img src=".github/assets/starry-logo.png" alt="Starry 标志" width="120" height="120">
</p>
<h1 align="center">Starry UI</h1>
<p align="center"><a href="README.md">English</a> · <strong>简体中文</strong></p>

Starry 的 Flutter 组件与设计令牌，用于构建风格一致的界面。组件库包含按钮、表单、表格、空状态和媒体选择器。

## 快速开始

在 Flutter 应用的 `pubspec.yaml` 中加入依赖：

```yaml
dependencies:
  starry_ui:
    git: https://github.com/allenvissong-source/starry_ui.git
```

运行 `flutter pub get`，然后从公共入口导入组件：

```dart
import 'package:flutter/widgets.dart';
import 'package:starry_ui/starry_ui.dart';

Widget saveButton(VoidCallback onSave) =>
    StarryButton(label: 'Save', onPressed: onSave);
```

## 许可证

Starry UI 的代码使用 [Apache 2.0](LICENSE)。随包提供的字体遵循 [`fonts/`](fonts/) 中各自的许可条款。
