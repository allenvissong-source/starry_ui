import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'theme/app_theme.dart';

// 由 build_runner 根据组件里的 @UseCase 注解生成。
// 首次生成前该文件不存在，运行 `dart run build_runner build` 后出现。
import 'main.directories.g.dart';

void main() {
  runApp(const StarryWidgetbook());
}

@widgetbook.App()
class StarryWidgetbook extends StatelessWidget {
  const StarryWidgetbook({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: directories,
      addons: [
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(name: 'Light', data: AppTheme.light()),
            WidgetbookTheme(name: 'Dark', data: AppTheme.dark()),
          ],
        ),
        TextScaleAddon(),
        ViewportAddon([
          Viewports.none,
          IosViewports.iPhone13,
          AndroidViewports.samsungGalaxyS20,
        ]),
        InspectorAddon(),
      ],
    );
  }
}
