// 高度安全门禁(concentric height-safety gate)。
//
// 目的:高度受限的控件外壳(`lib/src/inputs/**`,内腔按 §1.5.2 锁死在
// `controlHeight` = 48)里,任何 Material 可点击控件默认命中区都是
// `MaterialTapTargetSize.padded`——它在可视盒*之外*补 48×48 命中区,会绕过
// 外壳的高度约束把整行顶高(实测把 48 控件顶到 52),破坏四周同心白缝(见
// AGENTS.md §1.5.2「可视高 ≠ 布局高」)。规避方式是把这些控件显式改成
// `MaterialTapTargetSize.shrinkWrap`(让布局盒贴合可视盒),再用 constraints
// 把高度约束进内腔。
//
// 本测试随 `run_tests` 一起跑,是提交前强制门禁:在 `lib/src/inputs/**` 里
// 新增一个未声明 `shrinkWrap` 的裸 Material 可点击控件会直接让测试挂掉。
//
// 覆盖控件(默认 `padded` 命中区的 Material 可点击件):
//   IconButton(含 .filled/.filledTonal/.outlined 变体)、TextButton、
//   ElevatedButton、OutlinedButton、FilledButton(含 .tonal)。
//   —— `StarryButton` 不在此列:它的缩减高度只能经 `StarryButton.concentric`
//   传入,而该工厂内部已绑定 `shrinkWrap`(§1.5.2),类型层面即安全;默认
//   构造器不收 height,不会缩高,也就不会顶穿外壳。
//
// 判定:从控件构造器的 `(` 起做括号配平切片(跨行、跳过字符串/字符字面量),
// 若切片内出现 `MaterialTapTargetSize.shrinkWrap` 即视为安全。裸 `IconButton`
// 常把 `shrinkWrap` 写在嵌套的 `IconButton.styleFrom(...)` 里,仍落在同一切片内。
//
// 转义阀门(显式、可审计):在控件构造器所在行,或其配平切片内任意一行,
// 加尾注 `// height-safe-allow: <理由>`。新增时必须写清理由,便于审计。
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 受门禁约束的目录:高度受限控件外壳都在这里。
const String _guardedDir = 'lib/src/inputs';

/// 默认 `padded` 命中区的 Material 可点击控件构造器。`(?:\.\w+)?` 覆盖
/// `.filled` / `.outlined` / `.tonal` 等命名构造器;`styleFrom` 是静态样式
/// 助手不是控件,已在下方 [_styleHelper] 里排除。
final RegExp _tappableCtor = RegExp(
  r'\b(?:IconButton|TextButton|ElevatedButton|OutlinedButton|FilledButton)'
  r'(?:\.\w+)?\s*\(',
);

/// 静态样式助手(不是控件),命中后跳过。
final RegExp _styleHelper = RegExp(
  r'\b(?:IconButton|TextButton|ElevatedButton|OutlinedButton|FilledButton)'
  r'\.styleFrom\s*\(',
);

/// 高度安全声明。
const String _safeToken = 'MaterialTapTargetSize.shrinkWrap';

/// 行级转义阀门标记。
const String _allowMarker = '// height-safe-allow';

/// 从 [source] 中 `(` 所在下标 [openParen] 起,返回其配平右括号的下标(含)。
/// 跳过单/双引号字符串内的括号。找不到配平时返回字符串末尾。
int _matchingParen(String source, int openParen) {
  var depth = 0;
  String? quote;
  for (var i = openParen; i < source.length; i++) {
    final ch = source[i];
    if (quote != null) {
      if (ch == r'\') {
        i++; // 跳过转义字符
      } else if (ch == quote) {
        quote = null;
      }
      continue;
    }
    if (ch == "'" || ch == '"') {
      quote = ch;
    } else if (ch == '(') {
      depth++;
    } else if (ch == ')') {
      depth--;
      if (depth == 0) return i;
    }
  }
  return source.length - 1;
}

/// 把 [source] 里 [start,end] 下标区间换算成 1 基起始行号(用于报告)。
int _lineOf(String source, int index) =>
    '\n'.allMatches(source.substring(0, index)).length + 1;

void main() {
  test('lib/src/inputs 内可点击控件必须声明 shrinkWrap(同心高度安全)', () {
    final dir = Directory(_guardedDir);
    expect(dir.existsSync(), isTrue, reason: '未找到 $_guardedDir——请在包根目录运行测试。');

    final violations = <String>[];

    for (final entity in dir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final source = entity.readAsStringSync();

      for (final m in _tappableCtor.allMatches(source)) {
        // 排除 `.styleFrom(` 静态助手。
        if (_styleHelper.matchAsPrefix(source, m.start) != null) continue;

        final openParen = m.end - 1; // 匹配以 `(` 结尾
        final closeParen = _matchingParen(source, openParen);
        final slice = source.substring(m.start, closeParen + 1);

        if (slice.contains(_safeToken)) continue; // 已声明 shrinkWrap
        if (slice.contains(_allowMarker)) continue; // 显式豁免

        final ctor = source.substring(m.start, openParen).trim();
        violations.add(
          '${entity.path}:${_lineOf(source, m.start)}: $ctor(...)',
        );
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          '以下 Material 可点击控件位于高度受限外壳目录($_guardedDir),'
          '却未声明 `$_safeToken`——默认的 `padded` 命中区会顶穿外壳内腔、'
          '破坏同心(AGENTS.md §1.5.2「可视高 ≠ 布局高」):\n'
          '${violations.join('\n')}\n\n'
          '修法:给控件加 `tapTargetSize: MaterialTapTargetSize.shrinkWrap`'
          '(IconButton 走 `IconButton.styleFrom(tapTargetSize: '
          'MaterialTapTargetSize.shrinkWrap)`),并用 constraints 把高度约束进'
          '内腔(`StarryInputShell.interiorHeight`)。若确有单点必要,在该控件'
          '构造器行或其参数块内加 `$_allowMarker: <理由>` 显式豁免。',
    );
  });
}
