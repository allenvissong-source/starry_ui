import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

const _sections = [
  StarryNavigationSection(
    title: '个人',
    items: [
      StarryNavigationItem(
        id: 'profile',
        label: '个人资料',
        icon: Icons.badge_outlined,
      ),
      StarryNavigationItem(
        id: 'memory',
        label: '记忆',
        icon: Icons.history_rounded,
        enabled: false,
      ),
    ],
  ),
  StarryNavigationSection(
    title: '模型',
    items: [
      StarryNavigationItem(
        id: 'model',
        label: '模型服务',
        icon: Icons.cloud_outlined,
      ),
    ],
  ),
];

Widget _host({
  required Widget child,
  required Size size,
  bool disableAnimations = false,
}) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: MediaQuery(
      data: MediaQueryData(size: size, disableAnimations: disableAnimations),
      child: Scaffold(body: child),
    ),
  );
}

/// Sizes the test surface itself; the widget under test then fills it without
/// an extra `SizedBox` re-clamping the constraint.
Future<void> _pumpAt(
  WidgetTester tester,
  Size size, {
  required Widget child,
  bool disableAnimations = false,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    _host(size: size, child: child, disableAnimations: disableAnimations),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('StarryNavigationPane', () {
    testWidgets('renders section titles and every item', (tester) async {
      await _pumpAt(
        tester,
        const Size(400, 800),
        child: StarryNavigationPane(
          sections: _sections,
          selectedId: 'profile',
          onItemSelected: (_) {},
        ),
      );

      expect(find.text('个人'), findsOneWidget);
      expect(find.text('模型'), findsOneWidget);
      expect(find.text('个人资料'), findsOneWidget);
      expect(find.text('记忆'), findsOneWidget);
      expect(find.text('模型服务'), findsOneWidget);
    });

    testWidgets('marks the selected item and never renders a chevron', (
      tester,
    ) async {
      await _pumpAt(
        tester,
        const Size(400, 800),
        child: StarryNavigationPane(
          sections: _sections,
          selectedId: 'model',
          onItemSelected: (_) {},
        ),
      );

      final selected = tester.widget<StarrySettingsTile>(
        find.ancestor(
          of: find.text('模型服务'),
          matching: find.byType(StarrySettingsTile),
        ),
      );
      expect(selected.selected, isTrue);
      expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
    });

    testWidgets('disabled items are inert and exposed as disabled', (
      tester,
    ) async {
      final taps = <String>[];
      await _pumpAt(
        tester,
        const Size(400, 800),
        child: StarryNavigationPane(
          sections: _sections,
          selectedId: 'profile',
          onItemSelected: taps.add,
        ),
      );

      await tester.tap(find.text('记忆'));
      await tester.pumpAndSettle();
      expect(taps, isEmpty);

      final disabled = tester.widget<StarrySettingsTile>(
        find.ancestor(
          of: find.text('记忆'),
          matching: find.byType(StarrySettingsTile),
        ),
      );
      expect(disabled.enabled, isFalse);

      await tester.tap(find.text('模型服务'));
      await tester.pumpAndSettle();
      expect(taps, ['model']);
    });

    testWidgets('group labels stay quieter and shorter than their items', (
      tester,
    ) async {
      await _pumpAt(
        tester,
        const Size(256, 900),
        child: StarryNavigationPane(
          sections: _sections,
          selectedId: 'profile',
          onItemSelected: (_) {},
        ),
      );

      // A group label must not compete with the entries it introduces. A
      // page-level section header renders at the same size as the item labels,
      // which flattens the hierarchy and costs a full row per group in a
      // narrow rail.
      final labelSize = tester.widget<Text>(find.text('个人')).style!.fontSize!;
      final itemSize = tester.widget<Text>(find.text('个人资料')).style!.fontSize!;
      expect(labelSize, lessThan(itemSize));

      // Density comes from the labels and gaps, never from clipping the row
      // below its control-height token. 44 is `control/height/md`: this pane
      // is desktop-only, so the 48pt finger-touch floor does not apply, but
      // the row must not shrink below a real token step.
      final tile = find.byType(StarrySettingsTile).first;
      expect(tester.getSize(tile).height, 44);

      // Rows must tile without gaps so the pointer never lands on dead space
      // between two entries.
      final first = tester.getRect(find.byType(StarrySettingsTile).at(0));
      final second = tester.getRect(find.byType(StarrySettingsTile).at(1));
      expect(second.top, first.bottom);
    });

    testWidgets('labels sit a weight lighter, selection still steps up', (
      tester,
    ) async {
      await _pumpAt(
        tester,
        const Size(256, 900),
        child: StarryNavigationPane(
          sections: _sections,
          selectedId: 'profile',
          onItemSelected: (_) {},
        ),
      );

      final resting = tester.widget<Text>(find.text('模型服务')).style!.fontWeight;
      final selected = tester.widget<Text>(find.text('个人资料')).style!.fontWeight;

      // A dozen medium-weight labels in a narrow rail read as noise, so the
      // pane rests lighter than a settings list…
      expect(resting, FontWeight.w400);
      // …but the active row must still be the heaviest thing in the column.
      expect(selected!.value, greaterThan(resting!.value));
    });

    testWidgets('settings lists keep their original weights', (tester) async {
      await _pumpAt(
        tester,
        const Size(400, 300),
        child: Column(
          children: [
            StarrySettingsTile(title: '静息', onTap: () {}),
            StarrySettingsTile(title: '选中', selected: true, onTap: () {}),
          ],
        ),
      );

      // Guard: the pane's lighter weight is opt-in and must not leak into the
      // nine settings pages that share this tile.
      expect(
        tester.widget<Text>(find.text('静息')).style!.fontWeight,
        FontWeight.w500,
      );
      expect(
        tester.widget<Text>(find.text('选中')).style!.fontWeight,
        FontWeight.w600,
      );
    });
  });

  testWidgets('StarrySettingsTile.navigation still shows a chevron', (
    tester,
  ) async {
    await _pumpAt(
      tester,
      const Size(400, 200),
      child: StarrySettingsTile.navigation(title: '账号', onTap: () {}),
    );

    expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
  });
}
