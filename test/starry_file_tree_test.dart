import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

void main() {
  testWidgets('folders collapse without changing the controlled selection', (
    tester,
  ) async {
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [StarryTokens.light]),
        home: Scaffold(
          body: StarryFileTree(
            paths: const ['SKILL.md', 'references/core.md'],
            selectedPath: 'SKILL.md',
            label: 'Files',
            onSelected: (path) => selected = path,
          ),
        ),
      ),
    );
    await tester.tap(find.text('references'));
    await tester.pump();
    expect(find.text('core.md'), findsNothing);
    expect(selected, isNull);
    await tester.tap(find.text('references'));
    await tester.pump();
    await tester.tap(find.text('core.md'));
    expect(selected, 'references/core.md');
  });

  testWidgets('file buttons can be reached and activated by keyboard', (
    tester,
  ) async {
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [StarryTokens.light]),
        home: Scaffold(
          body: StarryFileTree(
            paths: const ['SKILL.md'],
            selectedPath: null,
            label: 'Files',
            onSelected: (path) => selected = path,
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(selected, 'SKILL.md');
    expect(tester.takeException(), isNull);
  });
}
