import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';
import 'package:starry_ui/src/inputs/input_shell.dart';

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.light().copyWith(platform: TargetPlatform.android),
  home: Scaffold(
    body: Center(child: SizedBox(width: 320, child: child)),
  ),
);

Future<void> _tapPadding(WidgetTester tester) async {
  final rect = tester.getRect(find.byType(StarryInputShell));
  await tester.tapAt(
    Offset(rect.left + 8, rect.center.dy),
    kind: PointerDeviceKind.touch,
  );
  await tester.pump();
}

void main() {
  for (final (name, field) in [
    ('text', const StarryTextField(hint: 'Input')),
    ('search', const StarrySearchInput(hint: 'Search')),
    ('multiline', const StarryTextArea(hint: 'Text')),
  ]) {
    testWidgets('$name padding opens and reopens the keyboard on touch', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 800);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_host(field));
      await tester.pumpAndSettle();
      await _tapPadding(tester);
      expect(tester.testTextInput.isVisible, isTrue);

      final input = tester.widget<TextField>(find.byType(TextField));
      tester.testTextInput.hide();
      expect(input.focusNode!.hasFocus, isTrue);
      await _tapPadding(tester);
      expect(tester.testTextInput.isVisible, isTrue);

      tester.testTextInput.hide();
      await tester.tap(find.byType(TextField), kind: PointerDeviceKind.touch);
      await tester.pump();
      expect(tester.testTextInput.isVisible, isTrue);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('disabled inputs ignore padding touches', (tester) async {
    for (final field in [
      const StarryTextField(enabled: false),
      const StarrySearchInput(enabled: false),
      const StarryTextArea(enabled: false),
    ]) {
      await tester.pumpWidget(_host(field));
      await tester.pumpAndSettle();
      await _tapPadding(tester);
      expect(tester.testTextInput.isVisible, isFalse);
      final input = tester.widget<TextField>(find.byType(TextField));
      expect(input.focusNode!.hasFocus, isFalse);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('read-only padding focuses without opening the keyboard', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const StarryTextField(readOnly: true)));
    await tester.pumpAndSettle();
    await _tapPadding(tester);
    final input = tester.widget<TextField>(find.byType(TextField));
    expect(input.focusNode!.hasFocus, isTrue);
    expect(tester.testTextInput.isVisible, isFalse);
  });

  testWidgets('shell activation preserves selection and clear actions', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'alpha beta');
    addTearDown(controller.dispose);
    var clears = 0;
    await tester.pumpWidget(
      _host(
        StarryTextField(
          controller: controller,
          showClearButton: true,
          clearTooltip: 'Clear',
          onClear: () => clears++,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _tapPadding(tester);
    controller.selection = const TextSelection(baseOffset: 2, extentOffset: 5);
    tester.testTextInput.hide();
    await _tapPadding(tester);
    expect(
      controller.selection,
      const TextSelection(baseOffset: 2, extentOffset: 5),
    );
    await tester.tap(find.byTooltip('Clear'), kind: PointerDeviceKind.touch);
    await tester.pump();
    expect(controller.text, isEmpty);
    expect(clears, 1);
  });

  testWidgets('search button keeps its action without activating the editor', (
    tester,
  ) async {
    var searches = 0;
    await tester.pumpWidget(
      _host(
        StarrySearchInput(
          searchButtonText: 'Search',
          onSearch: () => searches++,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Search'), kind: PointerDeviceKind.touch);
    await tester.pump();
    expect(searches, 1);
    expect(tester.testTextInput.isVisible, isFalse);
  });
}
