import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

Widget _host(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: Center(child: child)),
  );
}

/// Empirically verifies StarryChip's delete affordance honours the ≥44×44
/// minimum hit target (AGENTS.md §1.5.6) while the visible pill stays at the
/// compact `heightXs` — the hit region is decoupled from the visible icon via
/// a taller transparent hit host, not by enlarging the pill.
void main() {
  testWidgets('deletable chip: hit region ≥44 while pill stays heightXs', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(StarryChip(label: '标签', onDelete: () {}, deleteTooltip: '删除')),
    );
    await tester.pumpAndSettle();

    final BuildContext ctx = tester.element(find.byType(StarryChip));
    final StarryTokens t = Theme.of(ctx).extension<StarryTokens>()!;

    // The delete InkResponse's real box must be ≥44 (repo standard = 48).
    final Rect hit = tester.getRect(find.byType(InkResponse));
    // ignore: avoid_print
    print(
      'CHIP-DELETE-HIT ${hit.width}x${hit.height} (min 44, '
      'target ${t.controlMetrics.minTouchTarget})',
    );
    expect(hit.width, greaterThanOrEqualTo(44.0));
    expect(hit.height, greaterThanOrEqualTo(44.0));
    expect(
      hit.height,
      moreOrLessEquals(t.controlMetrics.minTouchTarget, epsilon: 0.6),
    );

    // The visible close icon stays at the compact glyph size (not enlarged to
    // fill the hit box).
    final Icon icon = tester.widget<Icon>(find.byIcon(Icons.close));
    expect(icon.size, moreOrLessEquals(t.controlMetrics.iconSm, epsilon: 0.01));
  });

  testWidgets('non-deletable chip stays compact (heightXs, no hit host)', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const StarryChip(label: '标签')));
    await tester.pumpAndSettle();

    final BuildContext ctx = tester.element(find.byType(StarryChip));
    final StarryTokens t = Theme.of(ctx).extension<StarryTokens>()!;

    expect(find.byType(InkResponse), findsNothing);
    final Rect chip = tester.getRect(find.byType(StarryChip));
    // ignore: avoid_print
    print(
      'CHIP-PLAIN-HEIGHT ${chip.height} (expect '
      '${t.controlMetrics.heightXs})',
    );
    expect(
      chip.height,
      moreOrLessEquals(t.controlMetrics.heightXs, epsilon: 0.6),
    );
  });
}
