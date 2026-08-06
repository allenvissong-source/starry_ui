import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

Widget _host(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: Center(child: child)),
  );
}

/// Returns the bordered surface [BoxDecoration] painted by the shared
/// StarrySurface primitive inside [root].
BoxDecoration _cardSurfaceDecoration(WidgetTester tester, Finder root) {
  final container = tester
      .widgetList<Container>(
        find.descendant(of: root, matching: find.byType(Container)),
      )
      .firstWhere(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration! as BoxDecoration).border != null,
      );
  return container.decoration! as BoxDecoration;
}

void main() {
  testWidgets('StarryMessageList renders items, title and badge', (tester) async {
    await tester.pumpWidget(
      _host(
        StarryMessageList(
          title: '消息',
          badgeLabel: '2 未读',
          emptyLabel: '暂无消息',
          items: <StarryMessageListItemData>[
            StarryMessageListItemData(
              id: 1,
              title: 'Nova',
              subtitle: 'hello',
              timeLabel: '09:24',
              avatarText: 'N',
              unread: true,
              actions: <StarryMessageListAction>[
                StarryMessageListAction(
                  label: '删除',
                  icon: Icons.delete_outline,
                  backgroundColor: const Color(0xFFF53D61),
                  foregroundColor: Colors.white,
                  onTap: () {},
                ),
              ],
            ),
            const StarryMessageListItemData(
              id: 2,
              title: 'Team',
              subtitle: 'update',
              timeLabel: '昨天',
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('消息'), findsOneWidget);
    expect(find.text('2 未读'), findsOneWidget);
    expect(find.text('Nova'), findsOneWidget);
    expect(find.text('Team'), findsOneWidget);
  });

  testWidgets('StarryMessageList shows empty label when no items', (tester) async {
    await tester.pumpWidget(
      _host(
        const StarryMessageList(
          emptyLabel: '暂无消息',
          items: <StarryMessageListItemData>[],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('暂无消息'), findsOneWidget);
    expect(find.byIcon(Icons.inbox), findsOneWidget);
  });

  testWidgets('StarryMessageList reuses the shared surface primitive',
      (tester) async {
    final tokens = StarryTokens.light;
    await tester.pumpWidget(
      _host(
        const StarryMessageList(
          emptyLabel: '暂无消息',
          items: <StarryMessageListItemData>[],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final deco = _cardSurfaceDecoration(tester, find.byType(StarryMessageList));
    expect(deco.color, tokens.semantic.surface);
    expect(deco.borderRadius, BorderRadius.circular(tokens.radius.lg));
    expect(deco.boxShadow, tokens.elevation.level2);
    // MessageList keeps its softer surfaceVariant border via the primitive's
    // borderColor override rather than hand-rolling the surface.
    expect((deco.border! as Border).top.color, tokens.semantic.surfaceVariant);
  });

  testWidgets('StarryBadge renders count and caps at maxCount', (tester) async {
    await tester.pumpWidget(
      _host(
        const StarryBadge(
          count: 128,
          maxCount: 99,
          child: Icon(Icons.notifications_outlined),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('99+'), findsOneWidget);
  });

  testWidgets('StarryBadge hides when count is zero and not a dot', (tester) async {
    await tester.pumpWidget(
      _host(
        const StarryBadge(
          count: 0,
          child: Icon(Icons.mail_outline),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('0'), findsNothing);
  });

  testWidgets('StarryChip renders label and delete button', (tester) async {
    var deleted = false;
    await tester.pumpWidget(
      _host(
        StarryChip(
          label: 'Tag',
          onDelete: () => deleted = true,
          deleteTooltip: '删除',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tag'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    expect(deleted, isTrue);
  });

  testWidgets('StarryChip variants build without error', (tester) async {
    await tester.pumpWidget(
      _host(
        const Wrap(
          children: <Widget>[
            StarryChip(label: 'Outlined'),
            StarryChip(label: 'Filled', variant: StarryChipVariant.filled),
            StarryChip(label: 'Tonal', variant: StarryChipVariant.tonal),
            StarryChip(label: 'Selected', selected: true),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Outlined'), findsOneWidget);
    expect(find.text('Filled'), findsOneWidget);
    expect(find.text('Tonal'), findsOneWidget);
    expect(find.text('Selected'), findsOneWidget);
  });

  testWidgets('StarryButton fires onPressed and exposes button semantics',
      (tester) async {
    var tapped = 0;
    await tester.pumpWidget(
      _host(
        StarryButton(label: '提交', onPressed: () => tapped++),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('提交'), findsOneWidget);
    await tester.tap(find.text('提交'));
    expect(tapped, 1);
  });

  testWidgets('StarryButton is disabled when onPressed is null', (tester) async {
    await tester.pumpWidget(
      _host(
        const StarryButton(label: '禁用', onPressed: null),
      ),
    );
    await tester.pumpAndSettle();

    final button = tester.widget<TextButton>(find.byType(TextButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('StarryButton in loading state blocks the tap', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(
      _host(
        StarryButton(label: '加载', loading: true, onPressed: () => tapped++),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final button = tester.widget<TextButton>(find.byType(TextButton));
    expect(button.onPressed, isNull);
    expect(tapped, 0);
  });

  testWidgets('StarryButton renders every variant without error',
      (tester) async {
    await tester.pumpWidget(
      _host(
        Wrap(
          children: <Widget>[
            StarryButton(label: 'Filled', onPressed: () {}),
            StarryButton(
              label: 'Secondary',
              variant: StarryButtonVariant.secondary,
              onPressed: () {},
            ),
            StarryButton(
              label: 'Tonal',
              variant: StarryButtonVariant.tonal,
              onPressed: () {},
            ),
            StarryButton(
              label: 'Text',
              variant: StarryButtonVariant.text,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Filled'), findsOneWidget);
    expect(find.text('Secondary'), findsOneWidget);
    expect(find.text('Tonal'), findsOneWidget);
    expect(find.text('Text'), findsOneWidget);
  });

  testWidgets('StarrySwitch toggles via onChanged', (tester) async {
    var value = false;
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) => StarrySwitch(
            value: value,
            label: '通知',
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('通知'), findsOneWidget);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(value, isTrue);
  });

  testWidgets('StarrySwitch is non-interactive when onChanged is null',
      (tester) async {
    await tester.pumpWidget(
      _host(
        const StarrySwitch(value: true, onChanged: null),
      ),
    );
    await tester.pumpAndSettle();

    final control = tester.widget<Switch>(find.byType(Switch));
    expect(control.onChanged, isNull);
  });

  testWidgets('StarryTag renders label for every status', (tester) async {
    await tester.pumpWidget(
      _host(
        const Wrap(
          children: <Widget>[
            StarryTag(label: '默认'),
            StarryTag(label: '成功', status: StarryTagStatus.success),
            StarryTag(label: '警告', status: StarryTagStatus.warning),
            StarryTag(label: '错误', status: StarryTagStatus.error),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('默认'), findsOneWidget);
    expect(find.text('成功'), findsOneWidget);
    expect(find.text('警告'), findsOneWidget);
    expect(find.text('错误'), findsOneWidget);
  });

  testWidgets('StarryTextArea renders label and accepts input', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(
      _host(
        StarryTextArea(label: '备注', controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '一些描述');
    expect(controller.text, '一些描述');
  });

  testWidgets('StarryEmptyState renders title, message and default icon',
      (tester) async {
    await tester.pumpWidget(
      _host(
        const StarryEmptyState(title: '暂无数据', message: '这里空空如也'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('暂无数据'), findsOneWidget);
    expect(find.text('这里空空如也'), findsOneWidget);
    expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
  });

  testWidgets('StarryEmptyState uses custom icon and action when provided',
      (tester) async {
    await tester.pumpWidget(
      _host(
        StarryEmptyState(
          icon: const Icon(Icons.search_off_outlined),
          title: '无结果',
          action: StarryButton(label: '重试', onPressed: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.search_off_outlined), findsOneWidget);
    expect(find.byIcon(Icons.inbox_outlined), findsNothing);
    expect(find.text('重试'), findsOneWidget);
  });

  testWidgets('StarryLoadingIndicator renders a spinner', (tester) async {
    await tester.pumpWidget(
      _host(const StarryLoadingIndicator()),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('StarryFullScreenLoadingIndicator renders message', (tester) async {
    await tester.pumpWidget(
      _host(const StarryFullScreenLoadingIndicator(message: '加载中')),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('加载中'), findsOneWidget);
  });

  testWidgets('StarryPageWrapper wraps child in SafeArea with padding',
      (tester) async {
    await tester.pumpWidget(
      _host(
        const StarryPageWrapper(child: Text('内容')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('内容'), findsOneWidget);
    expect(find.byType(SafeArea), findsOneWidget);
  });

  testWidgets('StarryPageWrapper omits SafeArea when disabled', (tester) async {
    await tester.pumpWidget(
      _host(
        const StarryPageWrapper(safeArea: false, child: Text('内容')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('内容'), findsOneWidget);
    // MaterialApp itself introduces no SafeArea; disabling ours removes it.
    expect(find.byType(SafeArea), findsNothing);
  });

  testWidgets('Starry looping animations build (enabled and disabled)',
      (tester) async {
    await tester.pumpWidget(
      _host(
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            StarryPulsingWidget(child: Text('pulse')),
            StarryRotatingWidget(child: Icon(Icons.refresh)),
            StarryScalingWidget(child: Icon(Icons.favorite)),
            StarryPulsingWidget(enabled: false, child: Text('static-pulse')),
            StarryRotatingWidget(enabled: false, child: Icon(Icons.sync)),
            StarryScalingWidget(enabled: false, child: Icon(Icons.star)),
          ],
        ),
      ),
    );
    await tester.pump();

    expect(find.text('pulse'), findsOneWidget);
    expect(find.text('static-pulse'), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  testWidgets('StarryExpandableCard toggles children on header tap',
      (tester) async {
    var expanded = false;
    await tester.pumpWidget(
      _host(
        StarryExpandableCard(
          header: const Text('高级选项'),
          onExpansionChanged: (v) => expanded = v,
          children: const <Widget>[Text('隐藏内容')],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('高级选项'), findsOneWidget);

    await tester.tap(find.text('高级选项'));
    await tester.pumpAndSettle();
    expect(expanded, isTrue);
    expect(find.text('隐藏内容'), findsOneWidget);

    await tester.tap(find.text('高级选项'));
    await tester.pumpAndSettle();
    expect(expanded, isFalse);
  });

  testWidgets('StarryExpandableCard honors initiallyExpanded', (tester) async {
    await tester.pumpWidget(
      _host(
        const StarryExpandableCard(
          header: Text('详情'),
          initiallyExpanded: true,
          children: <Widget>[Text('展开内容')],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('展开内容'), findsOneWidget);
  });

  testWidgets('StarryCard renders the shared radius.lg + level2 surface',
      (tester) async {
    await tester.pumpWidget(
      _host(const StarryCard(child: Text('卡片'))),
    );
    await tester.pumpAndSettle();

    final deco = _cardSurfaceDecoration(tester, find.byType(StarryCard));
    final tokens = StarryTokens.light;
    expect(deco.borderRadius, BorderRadius.circular(tokens.radius.lg));
    expect((deco.border! as Border).top.color, tokens.semantic.border);
    expect(deco.boxShadow, tokens.elevation.level2);
  });

  testWidgets(
      'StarryExpandableCard header is a split 48-tall / 28-radius pill surface',
      (tester) async {
    await tester.pumpWidget(
      _host(
        const StarryExpandableCard(
          header: Text('分区'),
          children: <Widget>[Text('内容')],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final tokens = StarryTokens.light;
    // The header pill is the first bordered surface. Its corner uses the same
    // textfield invariant max(radius.xxl, controlHeight / 2) = 28, and it is
    // pinned to controlHeight (48) tall — reading exactly like a single-line
    // StarryTextField.
    final headerDeco =
        _cardSurfaceDecoration(tester, find.byType(StarryExpandableCard));
    final expectedRadius = math.max(
      tokens.radius.xxl,
      tokens.controlMetrics.controlHeight / 2,
    );
    expect(headerDeco.borderRadius, BorderRadius.circular(expectedRadius));
    expect((headerDeco.border! as Border).top.color, tokens.semantic.border);
    expect(headerDeco.boxShadow, tokens.elevation.level2);

    // Header is pinned to the single-line control height (48).
    final headerBox = tester.widget<SizedBox>(
      find
          .descendant(
            of: find.byType(StarryExpandableCard),
            matching: find.byType(SizedBox),
          )
          .first,
    );
    expect(headerBox.height, tokens.controlMetrics.controlHeight);
  });

  testWidgets(
      'StarryExpandableCard detaches a separate radius.xxl content panel when '
      'expanded', (tester) async {
    await tester.pumpWidget(
      _host(
        const StarryExpandableCard(
          header: Text('分区'),
          initiallyExpanded: true,
          children: <Widget>[Text('内容')],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final tokens = StarryTokens.light;
    // The expanded state exposes two distinct bordered surfaces: the header
    // pill (28) and a detached content panel (radius.xxl = 28).
    final decorations = tester
        .widgetList<Container>(
          find.descendant(
            of: find.byType(StarryExpandableCard),
            matching: find.byType(Container),
          ),
        )
        .map((c) => c.decoration)
        .whereType<BoxDecoration>()
        .where((d) => d.border != null)
        .toList();
    final radii = decorations
        .map((d) => d.borderRadius)
        .whereType<BorderRadius>()
        .toList();
    final headerRadius = math.max(
      tokens.radius.xxl,
      tokens.controlMetrics.controlHeight / 2,
    );
    expect(radii, contains(BorderRadius.circular(headerRadius)));
    expect(radii, contains(BorderRadius.circular(tokens.radius.xxl)));
  });

  testWidgets(
      'StarryDropdown trigger is a 48-tall / 28-radius pill surface showing the '
      'hint', (tester) async {
    await tester.pumpWidget(
      _host(
        StarryDropdown<String>(
          hint: '请选择',
          items: const <StarryDropdownItem<String>>[
            StarryDropdownItem<String>(value: 'a', label: '选项 A'),
            StarryDropdownItem<String>(value: 'b', label: '选项 B'),
          ],
          onSelected: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final tokens = StarryTokens.light;
    // Collapsed: the hint shows and options are not laid out.
    expect(find.text('请选择'), findsOneWidget);
    expect(find.text('选项 A'), findsNothing);

    // The trigger pill uses the same textfield invariant as the ExpandableCard
    // header: max(radius.xxl, controlHeight / 2) = 28, pinned to controlHeight.
    final triggerDeco =
        _cardSurfaceDecoration(tester, find.byType(StarryDropdown<String>));
    final expectedRadius = math.max(
      tokens.radius.xxl,
      tokens.controlMetrics.controlHeight / 2,
    );
    expect(triggerDeco.borderRadius, BorderRadius.circular(expectedRadius));
    expect(triggerDeco.boxShadow, tokens.elevation.level2);

    final triggerBox = tester.widget<SizedBox>(
      find
          .descendant(
            of: find.byType(StarryDropdown<String>),
            matching: find.byType(SizedBox),
          )
          .first,
    );
    expect(triggerBox.height, tokens.controlMetrics.controlHeight);
  });

  testWidgets(
      'StarryDropdown expands an inline detached radius.xxl option panel',
      (tester) async {
    await tester.pumpWidget(
      _host(
        StarryDropdown<String>(
          hint: '请选择',
          initiallyExpanded: true,
          items: const <StarryDropdownItem<String>>[
            StarryDropdownItem<String>(value: 'a', label: '选项 A'),
            StarryDropdownItem<String>(value: 'b', label: '选项 B'),
          ],
          onSelected: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final tokens = StarryTokens.light;
    // Both option rows are laid out inline (not in a floating overlay).
    expect(find.text('选项 A'), findsOneWidget);
    expect(find.text('选项 B'), findsOneWidget);

    // The expanded state exposes two distinct bordered surfaces: the trigger
    // pill (28) and a detached option panel (radius.xxl = 28).
    final radii = tester
        .widgetList<Container>(
          find.descendant(
            of: find.byType(StarryDropdown<String>),
            matching: find.byType(Container),
          ),
        )
        .map((c) => c.decoration)
        .whereType<BoxDecoration>()
        .where((d) => d.border != null)
        .map((d) => d.borderRadius)
        .whereType<BorderRadius>()
        .toList();
    final triggerRadius = math.max(
      tokens.radius.xxl,
      tokens.controlMetrics.controlHeight / 2,
    );
    expect(radii, contains(BorderRadius.circular(triggerRadius)));
    expect(radii, contains(BorderRadius.circular(tokens.radius.xxl)));
  });

  testWidgets(
      'StarryDropdown fills the trigger and collapses on select', (tester) async {
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        // Disable the ink splash so the tap doesn't load the ink_sparkle
        // fragment shader (unavailable in the unit-test engine); the selection
        // logic under test is independent of the splash visual.
        theme: AppTheme.light().copyWith(splashFactory: NoSplash.splashFactory),
        home: Scaffold(
          body: Center(
            child: StatefulBuilder(
          builder: (context, setState) {
            return StarryDropdown<String>(
              hint: '请选择',
              value: selected,
              initiallyExpanded: true,
              items: const <StarryDropdownItem<String>>[
                StarryDropdownItem<String>(value: 'a', label: '选项 A'),
                StarryDropdownItem<String>(value: 'b', label: '选项 B'),
              ],
              onSelected: (v) => setState(() => selected = v),
            );
          },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('选项 B'));
    await tester.pumpAndSettle();

    // Callback fired, trigger reflects the chosen label, panel collapsed
    // (option rows no longer laid out), hint is gone.
    expect(selected, 'b');
    expect(find.text('选项 B'), findsOneWidget); // now shown in the trigger
    expect(find.text('选项 A'), findsNothing);
    expect(find.text('请选择'), findsNothing);
  });

  group('AppTheme 品牌色收敛：secondary = 紫色 brandStrong（非旧蓝）', () {
    const oldBlue = Color(0xFF4F8CF7); // 收敛前的字面蓝，必须已消失

    test('light：secondary 等于 semantic.brandStrong，且不再是旧蓝', () {
      final scheme = AppTheme.light().colorScheme;
      final tokens = StarryTokens.light;
      expect(scheme.secondary, tokens.semantic.brandStrong);
      expect(scheme.secondary, const Color(0xFF9179F5));
      expect(scheme.secondary, isNot(oldBlue));
      expect(scheme.onPrimary, tokens.semantic.onBrand);
      expect(scheme.primary, AppTheme.seed);
    });

    test('dark：secondary 等于 semantic.brandStrong，且不再是旧蓝', () {
      final scheme = AppTheme.dark().colorScheme;
      final tokens = StarryTokens.dark;
      expect(scheme.secondary, tokens.semantic.brandStrong);
      expect(scheme.secondary, const Color(0xFFAA99FF));
      expect(scheme.secondary, isNot(oldBlue));
      expect(scheme.onPrimary, tokens.semantic.onBrand);
      expect(scheme.primary, AppTheme.seed);
    });

    test('种子色保持字面未变（0xFFAB99FF），与 semantic.brand 刻意不完全相等', () {
      expect(AppTheme.seed, const Color(0xFFAB99FF));
      expect(StarryTokens.light.semantic.brand, isNot(AppTheme.seed));
    });
  });

  group('StarryEmojiText', () {
    testWidgets('splits emoji and text runs into separate styled spans',
        (tester) async {
      await tester.pumpWidget(_host(const StarryEmojiText('AB👋CD')));

      final richText = tester.widget<RichText>(
        find.descendant(
          of: find.byType(StarryEmojiText),
          matching: find.byType(RichText),
        ),
      );
      // Text.rich wraps our span in an effective-style root span; our span is
      // its single child, and the emoji/text runs live one level deeper.
      final wrapper = richText.text as TextSpan;
      final our = wrapper.children!.first as TextSpan;
      final children = our.children!.cast<TextSpan>();
      expect(children.length, 3);
      expect(children[0].text, 'AB');
      expect(children[1].text, '👋');
      expect(children[2].text, 'CD');
      expect(children[0].style!.fontFamily, StarryTypography.fontFamilyBody);
      expect(children[1].style!.fontFamily, StarryTypography.fontFamilyEmoji);
      expect(children[2].style!.fontFamily, StarryTypography.fontFamilyBody);
    });

    testWidgets('honors custom text/emoji font families', (tester) async {
      await tester.pumpWidget(
        _host(
          const StarryEmojiText(
            'x😀',
            textFontFamily: 'CustomText',
            emojiFontFamily: 'CustomEmoji',
          ),
        ),
      );

      final richText = tester.widget<RichText>(
        find.descendant(
          of: find.byType(StarryEmojiText),
          matching: find.byType(RichText),
        ),
      );
      final wrapper = richText.text as TextSpan;
      final our = wrapper.children!.first as TextSpan;
      final children = our.children!.cast<TextSpan>();
      expect(children[0].style!.fontFamily, 'CustomText');
      expect(children[1].style!.fontFamily, 'CustomEmoji');
    });
  });

  group('StarryTypography font tokens', () {
    test('display/title styles resolve to Outfit', () {
      const t = StarryTypography.standard;
      expect(t.displayLarge.fontFamily, 'Outfit');
      expect(t.titleLarge.fontFamily, 'Outfit');
      expect(t.titleMedium.fontFamily, 'Outfit');
      expect(StarryTypography.fontFamilyDisplay, 'Outfit');
    });

    test('body/label styles resolve to Inter', () {
      const t = StarryTypography.standard;
      expect(t.bodyMedium.fontFamily, 'Inter');
      expect(t.bodySmall.fontFamily, 'Inter');
      expect(StarryTypography.fontFamilyBody, 'Inter');
    });

    test('textStyle carries CJK + emoji fallback in order', () {
      const t = StarryTypography.standard;
      final titleFallback = t.titleLarge.textStyle.fontFamilyFallback;
      final bodyFallback = t.bodyMedium.textStyle.fontFamilyFallback;
      expect(titleFallback, containsAllInOrder(<String>['MiSans', 'Twemoji']));
      expect(bodyFallback, containsAllInOrder(<String>['MiSans', 'Twemoji']));
      expect(StarryTypography.fontFamilyCjk, 'MiSans');
      expect(StarryTypography.fontFamilyEmoji, 'Twemoji');
    });

    test('titleLarge textStyle applies Outfit family with fallback', () {
      final style = StarryTypography.standard.titleLarge.textStyle;
      expect(style.fontFamily, 'Outfit');
      expect(style.fontFamilyFallback, contains('MiSans'));
      expect(style.fontFamilyFallback, contains('Twemoji'));
    });
  });
}
