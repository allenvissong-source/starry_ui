import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';
import 'package:starry_ui/src/inputs/input_shell.dart';

Widget _host(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(
      body: Center(child: SizedBox(width: 360, child: child)),
    ),
  );
}

/// Empirically verifies the concentric capsule-in-capsule gap of the trailing
/// Search button (AGENTS.md §1.5.2): with an empty field (hint showing, so no
/// clear button), the visible white channel between the button's painted
/// Material capsule and the shell's inner border edge must be a uniform
/// [StarryInputShell.concentricGap] on all four sides.
void main() {
  testWidgets('trailing Search button nests concentrically (empty field)', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        StarrySearchInput(
          hint: '输入关键词',
          searchButtonText: '搜索',
          onSearch: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final BuildContext ctx = tester.element(find.byType(StarrySearchInput));
    final StarryTokens t = Theme.of(ctx).extension<StarryTokens>()!;
    final double gap = StarryInputShell.concentricGap(t); // 4
    final double border = t.controlMetrics.focusBorderWidth; // 2

    // Outer shell box (includes the 2px border on every side).
    final Rect shell = tester.getRect(find.byType(AnimatedContainer));
    // The Search button's painted Material capsule.
    final Rect button = tester.getRect(
      find.descendant(
        of: find.byType(StarryButton),
        matching: find.byType(Material),
      ),
    );

    // Shell interior = inside the always-painted focus border.
    final double interiorTop = shell.top + border;
    final double interiorBottom = shell.bottom - border;
    final double interiorRight = shell.right - border;

    final double gapTop = button.top - interiorTop;
    final double gapBottom = interiorBottom - button.bottom;
    final double gapRight = interiorRight - button.right;

    // ignore: avoid_print
    print(
      'CONCENTRIC shell=$shell button=$button '
      'gapTop=$gapTop gapBottom=$gapBottom gapRight=$gapRight '
      'expectedGap=$gap',
    );

    expect(
      gapTop,
      moreOrLessEquals(gap, epsilon: 0.6),
      reason: 'top gap must equal concentricGap',
    );
    expect(
      gapBottom,
      moreOrLessEquals(gap, epsilon: 0.6),
      reason: 'bottom gap must equal concentricGap',
    );
    expect(
      gapRight,
      moreOrLessEquals(gap, epsilon: 0.6),
      reason: 'right gap must equal concentricGap',
    );
    // All four visible gaps uniform ⇒ top≈bottom≈right.
    expect((gapTop - gapBottom).abs(), lessThan(0.6));
    expect((gapTop - gapRight).abs(), lessThan(0.6));
  });

  testWidgets(
    'trailing Search button stays concentric with clear button shown',
    (tester) async {
      final controller = TextEditingController(text: 'hello');
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _host(
          StarrySearchInput(
            controller: controller,
            hint: '输入关键词',
            searchButtonText: '搜索',
            onSearch: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final BuildContext ctx = tester.element(find.byType(StarrySearchInput));
      final StarryTokens t = Theme.of(ctx).extension<StarryTokens>()!;
      final double gap = StarryInputShell.concentricGap(t);
      final double border = t.controlMetrics.focusBorderWidth;

      final Rect shell = tester.getRect(find.byType(AnimatedContainer));
      final Rect button = tester.getRect(
        find.descendant(
          of: find.byType(StarryButton),
          matching: find.byType(Material),
        ),
      );

      final double gapTop = button.top - (shell.top + border);
      final double gapBottom = (shell.bottom - border) - button.bottom;
      final double gapRight = (shell.right - border) - button.right;

      // ignore: avoid_print
      print(
        'CONCENTRIC(clear) shell=$shell button=$button '
        'gapTop=$gapTop gapBottom=$gapBottom gapRight=$gapRight '
        'shellHeight=${shell.height}',
      );

      expect(gapTop, moreOrLessEquals(gap, epsilon: 0.6));
      expect(gapBottom, moreOrLessEquals(gap, epsilon: 0.6));
      expect(gapRight, moreOrLessEquals(gap, epsilon: 0.6));
    },
  );

  // Class-level guard for the "visible height ≠ layout height" trap: a child
  // whose *layout* box exceeds the interior (e.g. a `padded` 48 tap target)
  // silently inflates the height-pinned pill past `controlHeight`, which is the
  // root cause behind every concentric-gap asymmetry here. Rather than only
  // checking the two gap scenarios above, assert the invariant directly: the
  // shell must measure exactly `controlHeight` across every content
  // permutation. If a future affordance reintroduces a 48-tall child, this
  // fails regardless of whether anyone remembered to add a gap test for it.
  testWidgets('shell height stays controlHeight across content permutations', (
    tester,
  ) async {
    Future<void> expectPinned(Widget child) async {
      await tester.pumpWidget(_host(child));
      await tester.pumpAndSettle();
      final BuildContext ctx = tester.element(find.byType(StarrySearchInput));
      final StarryTokens t = Theme.of(ctx).extension<StarryTokens>()!;
      final Rect shell = tester.getRect(find.byType(AnimatedContainer));
      // ignore: avoid_print
      print(
        'SHELL-HEIGHT ${shell.height} (expect '
        '${t.controlMetrics.controlHeight})',
      );
      expect(
        shell.height,
        moreOrLessEquals(t.controlMetrics.controlHeight, epsilon: 0.6),
      );
    }

    // plain field, no affordances
    await expectPinned(const StarrySearchInput(hint: '输入关键词'));
    // trailing search button only
    await expectPinned(
      StarrySearchInput(hint: '输入关键词', searchButtonText: '搜索', onSearch: () {}),
    );
    // clear button shown (text present), no search button
    final c1 = TextEditingController(text: 'hello');
    addTearDown(c1.dispose);
    await expectPinned(StarrySearchInput(controller: c1, hint: '输入关键词'));
    // clear + search button together (the worst case)
    final c2 = TextEditingController(text: 'hello');
    addTearDown(c2.dispose);
    await expectPinned(
      StarrySearchInput(
        controller: c2,
        hint: '输入关键词',
        searchButtonText: '搜索',
        onSearch: () {},
      ),
    );
  });

  // Same "visible height ≠ layout height" trap, guarding StarryTextField's own
  // clear button. Its trailing clear IconButton defaults to a `padded` 48×48
  // tap target that sits *outside* its constraints and would inflate the
  // height-pinned shell past `controlHeight` (AGENTS.md §1.5.2). The
  // source-scanning gate (no_padded_tap_target_in_inputs_test.dart) forbids the
  // raw pattern; this asserts the resulting geometry stays pinned.
  testWidgets('StarryTextField shell stays controlHeight with clear button', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'hello');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _host(
        StarryTextField(
          controller: controller,
          hint: '输入关键词',
          showClearButton: true,
          clearTooltip: '清除',
        ),
      ),
    );
    await tester.pumpAndSettle();

    final BuildContext ctx = tester.element(find.byType(StarryTextField));
    final StarryTokens t = Theme.of(ctx).extension<StarryTokens>()!;
    // The clear button must be present (otherwise the guard is vacuous).
    expect(find.byIcon(Icons.clear), findsOneWidget);
    final Rect shell = tester.getRect(find.byType(AnimatedContainer));
    // ignore: avoid_print
    print(
      'TEXTFIELD-SHELL-HEIGHT ${shell.height} (expect '
      '${t.controlMetrics.controlHeight})',
    );
    expect(
      shell.height,
      moreOrLessEquals(t.controlMetrics.controlHeight, epsilon: 0.6),
    );
  });

  // 方案1: the general text field uses ONE trailing inset for every affordance
  // (clear button, suffixIcon, custom trailing) — no end-cap nudge. This asserts
  // the clear icon and a following suffixIcon end at the same distance from the
  // shell's inner edge, i.e. the trailing edge is symmetric with the leading
  // edge's inset rule instead of the clear icon floating a half tap-target in.
  testWidgets('StarryTextField trailing affordances share one end inset', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'hello');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _host(
        StarryTextField(
          controller: controller,
          hint: '输入关键词',
          showClearButton: true,
          clearTooltip: '清除',
          suffixIcon: Icons.info_outline,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final BuildContext ctx = tester.element(find.byType(StarryTextField));
    final StarryTokens t = Theme.of(ctx).extension<StarryTokens>()!;
    final double border = t.controlMetrics.focusBorderWidth;
    final double endPadding = StarryInputShell.endPadding(t); // 20

    final Rect shell = tester.getRect(find.byType(AnimatedContainer));
    final double innerRight = shell.right - border;

    // The clear icon (glyph) and the suffix icon glyph.
    final Rect clearIcon = tester.getRect(find.byIcon(Icons.clear));
    final Rect suffixIcon = tester.getRect(find.byIcon(Icons.info_outline));

    // suffixIcon is the rightmost affordance: its right edge sits `endPadding`
    // inside the shell's inner edge.
    final double suffixGap = innerRight - suffixIcon.right;
    // ignore: avoid_print
    print(
      'TEXTFIELD-END-INSET suffixGap=$suffixGap '
      'clearRight=${clearIcon.right} suffixRight=${suffixIcon.right}',
    );
    expect(
      suffixGap,
      moreOrLessEquals(endPadding, epsilon: 0.6),
      reason: 'rightmost trailing icon must sit endPadding inside the shell',
    );

    // The clear icon precedes the suffix by exactly one `s3` text-gap + the icon
    // width — the key invariant is that neither is pushed to the pill corner by
    // a nudge, so both stay left of innerRight by a normal inset.
    expect(
      clearIcon.right,
      lessThan(suffixIcon.left + 0.6),
      reason: 'clear icon is inset (not nudged onto the round end)',
    );

    // Height stays pinned regardless of the affordance combo.
    expect(
      shell.height,
      moreOrLessEquals(t.controlMetrics.controlHeight, epsilon: 0.6),
    );
  });

  testWidgets(
    'StarryTextField clear button ink circle stays centered on the glyph',
    (tester) async {
      final controller = TextEditingController(text: 'hello');
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _host(
          StarryTextField(
            controller: controller,
            hint: '输入关键词',
            showClearButton: true,
            clearTooltip: '清除',
          ),
        ),
      );
      await tester.pumpAndSettle();

      final BuildContext ctx = tester.element(find.byType(StarryTextField));
      final StarryTokens t = Theme.of(ctx).extension<StarryTokens>()!;
      final double border = t.controlMetrics.focusBorderWidth;
      final double endPadding = StarryInputShell.endPadding(t); // 20

      final Rect shell = tester.getRect(find.byType(AnimatedContainer));
      final double innerRight = shell.right - border;

      // The IconButton box carries the ink hover/splash circle; the Icon is the
      // glyph. The regression fixed here: the circle must stay centered on the
      // "×" (an in-box `alignment` decoupled them), so both centers must match.
      final Rect box = tester.getRect(find.byType(IconButton));
      final Rect glyph = tester.getRect(find.byIcon(Icons.clear));
      // ignore: avoid_print
      print(
        'TEXTFIELD-CLEAR-CENTER boxCenter=${box.center.dx} '
        'glyphCenter=${glyph.center.dx} glyphRight=${glyph.right} '
        'innerRight=$innerRight',
      );
      expect(
        box.center.dx,
        moreOrLessEquals(glyph.center.dx, epsilon: 0.6),
        reason: 'ink ripple box must stay centered on the clear glyph',
      );

      // And, being the only trailing affordance, the glyph still lands on the
      // shared end inset (nudged out by exactly the centered tap slop).
      expect(
        innerRight - glyph.right,
        moreOrLessEquals(endPadding, epsilon: 0.6),
        reason: 'lone clear glyph sits endPadding inside the shell',
      );
    },
  );
}
