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
//   3. 行级尾注 `// hardcode-allow: <理由>` —— 显式转义阀门,给确有必要的单点
//      字面量(如 app_theme.dart 的 seed)。新增时必须写清理由,便于审计。
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

/// 行级转义阀门标记。
const String _allowMarker = '// hardcode-allow';

void main() {
  test('lib/src 内无硬编码颜色字面量(令牌是唯一真源)', () {
    final libSrc = Directory('lib/src');
    expect(
      libSrc.existsSync(),
      isTrue,
      reason: '未找到 lib/src——请在包根目录运行测试。',
    );

    final violations = <String>[];

    for (final entity in libSrc.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final fileName = entity.uri.pathSegments.last;
      if (_wholeFileAllowlist.contains(fileName)) continue;

      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (!_colorLiteral.hasMatch(line)) continue;
        if (line.contains(_allowMarker)) continue;

        // 去掉允许的 transparent 后,若还残留颜色字面量才算违规。
        final stripped = line.replaceAll(_allowedTransparent, '');
        if (!_colorLiteral.hasMatch(stripped)) continue;

        violations.add('${entity.path}:${i + 1}: ${line.trim()}');
      }
    }

    expect(
      violations,
      isEmpty,
      reason: '发现硬编码颜色字面量,必须改用 StarryTokens 语义色:\n'
          '${violations.join('\n')}\n\n'
          '若确有单点必要(如平台契约常量),在该行尾加 '
          '`$_allowMarker: <理由>` 显式豁免;整文件示例/文档页可加入 '
          '_wholeFileAllowlist,并在 AGENTS.md §7.3 记录。',
    );
  });
}
