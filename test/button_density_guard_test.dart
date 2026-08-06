// 按钮密度门禁(button density-compression gate)。
//
// 目的:框架默认 `VisualDensity.adaptivePlatformDensity` 在桌面/Web 会解析成
// `compact`,把 Material 按钮的填充压到低于目标高度(AGENTS.md §1.5.2「可视高
// ≠ 布局高」的密度子问题)。同心嵌套时这会让按钮矮于 `controlHeight − 2·gap`、
// 上下白缝比左右宽,破坏四周同心;独立使用时也会让按钮悄悄变矮、跨端不一致。
// `StarryButton` 与 `StarryTextButton` 都已显式钉 `VisualDensity.standard`
// 让 token 高度权威、密度不再隐式压缩。
//
// 本门禁保证这一不变量不退化:`lib/src/buttons/**` 里凡是自带 Material 可点击
// 控件(IconButton / TextButton / ElevatedButton / OutlinedButton /
// FilledButton)的按钮组件,其源码必须出现 `VisualDensity.standard`。
//
// 与 `no_padded_tap_target_in_inputs_test.dart` 的分工:
//   • inputs 门禁管「命中区高度膨胀」——高度受限外壳内的控件必须 `shrinkWrap`。
//   • 本门禁管「密度压缩」——按钮组件必须 `standard` 密度。
// 两者是同一 §1.5.2 bug 类的两个子问题,故意分开:独立按钮*正当*使用
// `padded` 命中区(§1.5.6 ≥48 人机工程),把 inputs 的 `shrinkWrap` 目录扫描
// 直接扩到 buttons/ 会误报,所以 buttons/ 只校验密度这一项。
//
// 转义阀门:在文件任意一行加 `// density-guard-allow: <理由>` 显式豁免。
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 受本门禁约束的目录。
const String _guardedDir = 'lib/src/buttons';

/// 自带 Material 可点击控件的构造器(命中即认定该文件是「按钮组件」,需钉密度)。
/// `.styleFrom` 是静态助手,不影响判定(有它必然也有控件调用)。
final RegExp _tappableCtor = RegExp(
  r'\b(?:IconButton|TextButton|ElevatedButton|OutlinedButton|FilledButton)'
  r'(?:\.\w+)?\s*\(',
);

/// 密度声明。
const String _densityToken = 'VisualDensity.standard';

/// 行级转义阀门标记。
const String _allowMarker = '// density-guard-allow';

void main() {
  test('lib/src/buttons 内按钮组件必须钉 VisualDensity.standard(防密度压缩)', () {
    final dir = Directory(_guardedDir);
    expect(dir.existsSync(), isTrue, reason: '未找到 $_guardedDir——请在包根目录运行测试。');

    final violations = <String>[];

    for (final entity in dir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final source = entity.readAsStringSync();

      // 不含 Material 可点击控件的文件不是按钮组件,跳过。
      if (!_tappableCtor.hasMatch(source)) continue;
      if (source.contains(_allowMarker)) continue; // 显式豁免
      if (source.contains(_densityToken)) continue; // 已钉密度

      violations.add(entity.path);
    }

    expect(
      violations,
      isEmpty,
      reason:
          '以下按钮组件位于 $_guardedDir,含 Material 可点击控件却未钉 '
          '`$_densityToken`——框架默认 `adaptivePlatformDensity` 在桌面/Web 会'
          '解析成 `compact`、把按钮压矮,破坏跨端一致与同心(AGENTS.md §1.5.2):\n'
          '${violations.join('\n')}\n\n'
          '修法:在按钮的 `ButtonStyle` / `styleFrom(...)` 里加 '
          '`visualDensity: $_densityToken`。若确有必要,在文件内加 '
          '`$_allowMarker: <理由>` 显式豁免。',
    );
  });
}
