import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

Widget _host(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  testWidgets('StarrySettingsTile.navigation renders and fires onTap', (
    tester,
  ) async {
    var tapped = 0;
    await tester.pumpWidget(
      _host(
        StarrySettingsTile.navigation(
          title: '账号管理',
          subtitle: '管理你的账号',
          onTap: () => tapped++,
        ),
      ),
    );
    expect(find.text('账号管理'), findsOneWidget);
    expect(find.text('管理你的账号'), findsOneWidget);
    await tester.tap(find.text('账号管理'));
    await tester.pumpAndSettle();
    expect(tapped, 1);
  });

  testWidgets('StarrySettingsTile.toggle drives the switch', (tester) async {
    var value = false;
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) => StarrySettingsTile.toggle(
            title: '深色模式',
            value: value,
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      ),
    );
    expect(find.byType(StarrySwitch), findsOneWidget);
    expect(value, isFalse);
    // The switch sits under IgnorePointer; the row handles the toggle.
    await tester.tap(find.text('深色模式'));
    await tester.pumpAndSettle();
    expect(value, isTrue);
  });

  testWidgets('StarryGroupCard renders children with dividers', (tester) async {
    await tester.pumpWidget(
      _host(
        StarryGroupCard(
          elevated: true,
          children: const [
            StarrySettingsTile(title: 'A'),
            StarrySettingsTile(title: 'B'),
          ],
        ),
      ),
    );
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('StarryGroupAction fires onTap', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(
      _host(
        StarryGroupCard(
          children: [
            StarryGroupAction(label: '退出登录', onPressed: () => tapped++),
          ],
        ),
      ),
    );
    expect(find.text('退出登录'), findsOneWidget);
    await tester.tap(find.text('退出登录'));
    await tester.pumpAndSettle();
    expect(tapped, 1);
  });

  testWidgets('StarrySectionHeader renders title, description and child', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const StarrySectionHeader(
          title: '通用',
          description: '常用设置项',
          child: Text('slot'),
        ),
      ),
    );
    expect(find.text('通用'), findsOneWidget);
    expect(find.text('常用设置项'), findsOneWidget);
    expect(find.text('slot'), findsOneWidget);
  });

  testWidgets('StarrySectionHeader muted tone renders title', (tester) async {
    await tester.pumpWidget(
      _host(
        const StarrySectionHeader(
          title: '高级',
          tone: StarrySectionHeaderTone.muted,
        ),
      ),
    );
    expect(find.text('高级'), findsOneWidget);
  });

  testWidgets('StarryAssetCard empty state renders icon and title, taps', (
    tester,
  ) async {
    var tapped = 0;
    await tester.pumpWidget(
      _host(
        SizedBox(
          width: 160,
          height: 160,
          child: StarryAssetCard(
            title: '我的角色',
            emptyIcon: Icons.image_outlined,
            onTap: () => tapped++,
          ),
        ),
      ),
    );
    expect(find.text('我的角色'), findsOneWidget);
    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    await tester.tap(find.byType(StarryAssetCard));
    await tester.pumpAndSettle();
    expect(tapped, 1);
  });

  testWidgets('StarryReferenceCard renders title, typeLabel and remove', (
    tester,
  ) async {
    var removed = 0;
    await tester.pumpWidget(
      _host(
        SizedBox(
          width: 280,
          child: StarryReferenceCard(
            title: '参考文档',
            description: '引用描述',
            typeLabel: 'PDF',
            onRemove: () => removed++,
          ),
        ),
      ),
    );
    expect(find.text('参考文档'), findsOneWidget);
    expect(find.text('引用描述'), findsOneWidget);
    expect(find.text('PDF'), findsOneWidget);
    expect(find.byType(StarryTag), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(removed, 1);
  });

  testWidgets('StarrySegmentedControl switches segments (N=4)', (tester) async {
    var index = 0;
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) => StarrySegmentedControl(
            labels: const ['全部', '图片', '文本', '音频'],
            selectedIndex: index,
            onChanged: (i) => setState(() => index = i),
          ),
        ),
      ),
    );
    expect(find.text('全部'), findsOneWidget);
    expect(find.text('音频'), findsOneWidget);
    await tester.tap(find.text('文本'));
    await tester.pumpAndSettle();
    expect(index, 2);
  });
}
