// 全局硬编码颜色门禁(design-system color gate)。
//
// 目的:令牌是唯一真源(见 AGENTS.md §1)。任何组件 / 用例 / 页面里出现
// `Color(0x...)` 或 `Colors.*` 字面量都是污染——组件配色必须走
// `Theme.of(context).extension<StarryTokens>()!.semantic.*`。本测试随
// `run_tests` 一起执行,是提交前的强制门禁:新增硬编码颜色会直接让测试挂掉。
//
// 豁免(全部显式、可审计):
//   1. 整文件豁免 `_wholeFileAllowlist`:
//        - starry_tokens.dart —— 调色板本体,令牌的唯一真源;
//        - foundations.dart   —— Widgetbook 文档/画廊页,内容本身就是"展示各种
//          颜色"(如 WCAG 对比度示例徽标),不是被消费的组件配色。
//   2. 行级 `Colors.transparent` —— 平台"无填充"哨兵,无设计语义,全局允许。
//   3. 尾注 `// hardcode-allow: <理由>` —— 显式转义阀门,给确有必要的单点
//      字面量(如 app_theme.dart 的 seed)。新增时必须写清理由,便于审计。
//
// 豁免的判定单位是**逻辑语句**,不是物理行。这一点是被实测推翻过的:门禁原先
// 只看单行,于是 `dart format` 把一条语句折成多行、把尾注推到了下一行,两个早已
// 存在且写明理由的豁免(starry_asset_card.usecase.dart 的占位色块、
// starry_tag.usecase.dart 的 onMedia 背板)突然被判违规——源码一个字符没改,
// 门禁却红了。改成按语句判定,是因为格式化工具本就有权重排行边界:任何以物理行
// 为单位的豁免,都会在下一次 reflow 时随机失效。
//
// 想扩展到间距/圆角/时长等其它魔法数字时,复用同一遍历骨架另加规则即可。
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 整文件豁免(仅文件名,匹配 lib/src 下任意路径)。
const Set<String> _wholeFileAllowlist = <String>{
  'starry_tokens.dart',
  'foundations.dart',
};

/// 颜色字面量:`Color(0x...)` 或 `Colors.<name>`。
final RegExp _colorLiteral = RegExp(r'Color\(0x|Colors\.[A-Za-z]');

/// 允许的平台哨兵:`Colors.transparent`(无设计语义的"无填充")。
final RegExp _allowedTransparent = RegExp(r'Colors\.transparent\b');

/// 转义阀门标记。
const String _allowMarker = '// hardcode-allow';

/// 各条逻辑语句覆盖的物理行区间(闭区间,0-based)。
///
/// 终止符是 `;` 或 `,`,且**只在括号深度回到 0 时**才算终止——深度跨行累计。
/// 光看 `;` 不够:Flutter 里绝大多数颜色字面量是命名实参,以 `,` 结尾而非 `;`,
/// 于是相邻两条实参会被并进同一区间,前一条的标记泄漏给后一条(这一点由下面
/// "相邻语句的标记不会泄漏"一例钉住,它确实先失败过)。反过来,见 `,` 就切也是
/// 错的:`ColoredBox(` 换行后内层实参的 `,` 会把语句切断,把尾注甩出区间——正是
/// 要修的那个 bug。所以必须按深度判断。
///
/// 切分刻意保持朴素:门禁要判断的是"这个字面量和那句尾注是否属于同一条语句",
/// 而不是完整解析 Dart。字符串里的括号/逗号会让区间偏大,方向是更宽容,不会把
/// 合规代码判成违规。
List<({int start, int end})> _statementRanges(List<String> lines) {
  final ranges = <({int start, int end})>[];
  var start = 0;
  var depth = 0;
  for (var i = 0; i < lines.length; i++) {
    final code = lines[i].split('//').first;
    var terminates = false;
    for (final char in code.split('')) {
      if (char == '(' || char == '[' || char == '{') {
        depth++;
      } else if (char == ')' || char == ']' || char == '}') {
        if (depth > 0) depth--;
      } else if (char == ';' || char == ',') {
        if (depth == 0) terminates = true;
      }
    }
    // 一行以「未闭合的开括号」结尾时不终止:后续行仍属同一条语句。
    if (depth > 0) terminates = false;
    if (terminates) {
      ranges.add((start: start, end: i));
      start = i + 1;
    }
  }
  if (start < lines.length) {
    ranges.add((start: start, end: lines.length - 1));
  }
  return ranges;
}

/// 第 [index] 行的颜色字面量是否被同一条语句内的标记豁免。
bool _statementExempts(
  List<String> lines,
  List<({int start, int end})> ranges,
  int index,
) {
  final range = ranges.firstWhere(
    (r) => index >= r.start && index <= r.end,
    orElse: () => (start: index, end: index),
  );
  for (var j = range.start; j <= range.end; j++) {
    if (lines[j].contains(_allowMarker)) return true;
  }
  return false;
}

/// 扫描一段源码,返回未被豁免的颜色字面量行(已 trim)。
///
/// 与下面的目录遍历共用同一判定,所以针对它写的断言就是针对门禁本身的断言。
List<String> scanForHardcodedColors(String source) {
  final lines = source.split('\n');
  final ranges = _statementRanges(lines);
  final hits = <String>[];
  for (var i = 0; i < lines.length; i++) {
    if (!_colorLiteral.hasMatch(lines[i])) continue;
    final stripped = lines[i].replaceAll(_allowedTransparent, '');
    if (!_colorLiteral.hasMatch(stripped)) continue;
    if (_statementExempts(lines, ranges, i)) continue;
    hits.add(lines[i].trim());
  }
  return hits;
}

void main() {
  test('lib/src 内无硬编码颜色字面量(令牌是唯一真源)', () {
    final libSrc = Directory('lib/src');
    expect(libSrc.existsSync(), isTrue, reason: '未找到 lib/src——请在包根目录运行测试。');

    final violations = <String>[];

    for (final entity in libSrc.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final fileName = entity.uri.pathSegments.last;
      if (_wholeFileAllowlist.contains(fileName)) continue;

      final lines = entity.readAsLinesSync();
      final ranges = _statementRanges(lines);

      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (!_colorLiteral.hasMatch(line)) continue;

        // 去掉允许的 transparent 后,若还残留颜色字面量才算违规。
        final stripped = line.replaceAll(_allowedTransparent, '');
        if (!_colorLiteral.hasMatch(stripped)) continue;

        // 豁免按逻辑语句判定:标记可以落在该语句的任意一行(通常是最后一行的
        // 尾注),因为格式化有权重排行边界。
        if (_statementExempts(lines, ranges, i)) continue;

        violations.add('${entity.path}:${i + 1}: ${line.trim()}');
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          '发现硬编码颜色字面量,必须改用 StarryTokens 语义色:\n'
          '${violations.join('\n')}\n\n'
          '若确有单点必要(如平台契约常量),在该**语句**内加 '
          '`$_allowMarker: <理由>` 显式豁免;整文件示例/文档页可加入 '
          '_wholeFileAllowlist,并在 AGENTS.md §7.3 记录。',
    );
  });

  // 把上面那段注释钉成可执行断言:同一条语句排成一行还是多行,门禁结论必须一致;
  // 同时证明豁免没有被顺手放宽成人人可用。
  group('豁免以逻辑语句为单位,不受格式化换行影响', () {
    test('单行豁免仍然成立', () {
      expect(
        scanForHardcodedColors(
          'media: const ColoredBox(color: Color(0xFF6B8CB0)), '
          '// hardcode-allow: 占位色块\n',
        ),
        isEmpty,
      );
    });

    test('同一语句被折成多行后豁免依然成立', () {
      expect(
        scanForHardcodedColors(
          'media: const ColoredBox(\n'
          '  color: Color(0xFF6B8CB0),\n'
          '), // hardcode-allow: 占位色块\n',
        ),
        isEmpty,
        reason:
            '这正是 dart format 产生的形状。若这里变红,说明门禁又退回按物理行'
            '判定,下一次格式化会再次误报。',
      );
    });

    test('三元表达式跨行后豁免依然成立', () {
      expect(
        scanForHardcodedColors(
          'color: onMedia\n'
          '    ? const Color(0xFF334155)\n'
          '    : null, // hardcode-allow: onMedia 背板\n',
        ),
        isEmpty,
      );
    });

    test('没有标记的字面量照样违规', () {
      final hits = scanForHardcodedColors('color: const Color(0xFF334155),\n');
      expect(hits, hasLength(1));
      expect(hits.single, contains('0xFF334155'));
    });

    test('相邻语句的标记不会泄漏到下一条语句', () {
      final hits = scanForHardcodedColors(
        'a: const Color(0xFF111111), // hardcode-allow: 有理由\n'
        'b: const Color(0xFF222222),\n',
      );
      expect(hits, hasLength(1), reason: '第二条语句没有自己的标记,必须仍然违规。');
      expect(hits.single, contains('0xFF222222'));
    });

    test('Colors.transparent 仍然全局免检', () {
      expect(scanForHardcodedColors('color: Colors.transparent,\n'), isEmpty);
    });
  });
}
