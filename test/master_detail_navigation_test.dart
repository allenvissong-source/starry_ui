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

const _detailKey = Key('detail-region');

Widget _layout({
  required bool paneVisible,
  required ValueChanged<bool> onChanged,
  double? paneWidth,
}) {
  return StarryMasterDetailLayout(
    paneVisible: paneVisible,
    onPaneVisibleChanged: onChanged,
    paneWidth: paneWidth,
    pane: StarryNavigationPane(
      sections: _sections,
      selectedId: 'profile',
      onItemSelected: (_) {},
    ),
    detail: const SizedBox.expand(
      key: _detailKey,
      child: Center(child: Text('detail-body')),
    ),
  );
}

void main() {
  group('StarryMasterDetailLayout', () {
    testWidgets('renders side by side at the expanded entry point', (
      tester,
    ) async {
      await _pumpAt(
        tester,
        const Size(840, 800),
        child: _layout(paneVisible: true, onChanged: (_) {}),
      );

      expect(find.text('detail-body'), findsOneWidget);
      expect(find.byType(StarryNavigationPane), findsOneWidget);
      expect(
        tester.getSize(find.byType(StarryNavigationPane)).width,
        StarryMasterDetailLayout.defaultPaneWidth,
      );
      expect(tester.getTopLeft(find.byType(StarryNavigationPane)).dx, 0);
      // Detail starts after the pane + separator: the pane takes layout space.
      expect(
        tester.getTopLeft(find.byKey(_detailKey)).dx,
        greaterThanOrEqualTo(StarryMasterDetailLayout.defaultPaneWidth),
      );
    });

    testWidgets('falls back to overlay just below the breakpoint', (
      tester,
    ) async {
      await _pumpAt(
        tester,
        const Size(839, 800),
        child: _layout(paneVisible: true, onChanged: (_) {}),
      );

      // The pane floats above the detail instead of pushing it aside.
      expect(tester.getTopLeft(find.byType(StarryNavigationPane)).dx, 0);
      expect(tester.getTopLeft(find.byKey(_detailKey)).dx, 0);
      expect(find.byType(StarryNavigationPane), findsOneWidget);
    });

    testWidgets('side-by-side hides the pane entirely when collapsed', (
      tester,
    ) async {
      await _pumpAt(
        tester,
        const Size(1000, 800),
        child: _layout(paneVisible: false, onChanged: (_) {}),
      );

      expect(find.byType(StarryNavigationPane), findsNothing);
      // Detail reclaims the leading edge once the pane is gone.
      expect(tester.getTopLeft(find.byKey(_detailKey)).dx, 0);
      expect(find.text('detail-body'), findsOneWidget);
    });

    testWidgets('overlay scrim tap reports a visibility change', (
      tester,
    ) async {
      bool? reported;
      await _pumpAt(
        tester,
        const Size(700, 800),
        child: _layout(
          paneVisible: true,
          onChanged: (value) => reported = value,
        ),
      );

      await tester.tapAt(const Offset(650, 400));
      await tester.pumpAndSettle();

      expect(reported, isFalse);
    });

    testWidgets('overlay is not mounted while collapsed', (tester) async {
      await _pumpAt(
        tester,
        const Size(700, 800),
        child: _layout(paneVisible: false, onChanged: (_) {}),
      );

      expect(find.byType(StarryNavigationPane), findsNothing);
    });

    testWidgets('Escape closes the open overlay pane', (tester) async {
      bool? reported;
      await _pumpAt(
        tester,
        const Size(700, 800),
        child: _layout(
          paneVisible: true,
          onChanged: (value) => reported = value,
        ),
      );
      expect(find.byType(StarryNavigationPane), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(reported, isFalse);
      // The layout does not own visibility: the host rebuilds with
      // paneVisible=false, which this controlled test does not do.
    });

    testWidgets('overlay close button takes focus on open and closes on tap', (
      tester,
    ) async {
      bool? reported;
      await _pumpAt(
        tester,
        const Size(700, 800),
        child: _layout(
          paneVisible: true,
          onChanged: (value) => reported = value,
        ),
      );

      // The sheet must grab keyboard focus when it mounts.
      final closeFocus = Focus.of(
        tester.element(find.byKey(StarryMasterDetailLayout.closeKey)),
      );
      expect(closeFocus.hasPrimaryFocus, isTrue);

      await tester.tap(find.byKey(StarryMasterDetailLayout.closeKey));
      await tester.pumpAndSettle();

      expect(reported, isFalse);
    });

    testWidgets('open overlay excludes the backing detail from semantics', (
      tester,
    ) async {
      await _pumpAt(
        tester,
        const Size(700, 800),
        child: _layout(paneVisible: true, onChanged: (_) {}),
      );

      final excluded = tester.widget<ExcludeSemantics>(
        find
            .ancestor(
              of: find.text('detail-body'),
              matching: find.byType(ExcludeSemantics),
            )
            .first,
      );
      expect(excluded.excluding, isTrue);
    });

    testWidgets('collapsed overlay leaves the backing detail semantics live', (
      tester,
    ) async {
      await _pumpAt(
        tester,
        const Size(700, 800),
        child: _layout(paneVisible: false, onChanged: (_) {}),
      );

      final excluded = tester.widget<ExcludeSemantics>(
        find
            .ancestor(
              of: find.text('detail-body'),
              matching: find.byType(ExcludeSemantics),
            )
            .first,
      );
      expect(excluded.excluding, isFalse);
    });

    testWidgets('honours reduced motion by settling immediately', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(700, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        _host(
          size: const Size(700, 800),
          disableAnimations: true,
          child: _layout(paneVisible: true, onChanged: (_) {}),
        ),
      );
      await tester.pump();

      // With animations disabled the pane is already at its resting offset
      // after a single frame.
      expect(tester.getTopLeft(find.byType(StarryNavigationPane)).dx, 0);
    });

    test('exposes defaultPaneWidth as the 256pt navigation spec', () {
      expect(StarryMasterDetailLayout.defaultPaneWidth, 256);
    });

    testWidgets('honours a custom paneWidth in side-by-side', (tester) async {
      await _pumpAt(
        tester,
        const Size(840, 800),
        child: _layout(paneVisible: true, onChanged: (_) {}, paneWidth: 320),
      );

      expect(tester.getSize(find.byType(StarryNavigationPane)).width, 320);
      // Detail starts after the custom-width pane + separator.
      expect(
        tester.getTopLeft(find.byKey(_detailKey)).dx,
        greaterThanOrEqualTo(320),
      );
    });

    testWidgets('honours a custom paneWidth in overlay', (tester) async {
      await _pumpAt(
        tester,
        const Size(700, 800),
        child: _layout(paneVisible: true, onChanged: (_) {}, paneWidth: 300),
      );

      // The floating sheet that hosts the pane is the nearest SizedBox
      // ancestor of the pane and takes the custom width.
      final sheetBox = tester.widget<SizedBox>(
        find
            .ancestor(
              of: find.byType(StarryNavigationPane),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(sheetBox.width, 300);
    });
  });

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
        const Size(StarryMasterDetailLayout.defaultPaneWidth, 900),
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
        const Size(StarryMasterDetailLayout.defaultPaneWidth, 900),
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
