<p align="center">
  <img src=".github/assets/starry-logo.png" alt="Starry logo" width="120" height="120">
</p>
<h1 align="center">Starry UI</h1>
<p align="center"><strong>English</strong> · <a href="README.zh-CN.md">简体中文</a></p>

Flutter widgets and design tokens for building interfaces with Starry’s visual style. The library includes buttons, forms, tables, empty states, and media pickers.

## Quick start

Add the package to your Flutter app’s `pubspec.yaml`:

```yaml
dependencies:
  starry_ui:
    git: https://github.com/allenvissong-source/starry_ui.git
```

Run `flutter pub get`, then use the widgets from the public library:

```dart
import 'package:flutter/widgets.dart';
import 'package:starry_ui/starry_ui.dart';

Widget saveButton(VoidCallback onSave) =>
    StarryButton(label: 'Save', onPressed: onSave);
```

## License

The Starry UI code is licensed under [Apache 2.0](LICENSE). Bundled fonts follow the terms in [`fonts/`](fonts/).
