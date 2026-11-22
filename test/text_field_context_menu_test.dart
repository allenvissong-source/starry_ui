import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.light().copyWith(platform: TargetPlatform.android),
  home: Scaffold(
    body: Center(child: SizedBox(width: 320, child: child)),
  ),
);

Future<void> _openMenu(WidgetTester tester) async {
  await tester.longPress(find.byType(TextField));
  await tester.pumpAndSettle();
}

void main() {
  String? copied;
  setUp(() {
    copied = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.hasStrings') return {'value': true};
          if (call.method == 'Clipboard.getData') return {'text': 'clipboard'};
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        });
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('native text field control retains copy and paste menu', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'original text');
    addTearDown(controller.dispose);
    await tester.pumpWidget(_host(TextField(controller: controller)));
    await _openMenu(tester);
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Paste'), findsOneWidget);
  });

  testWidgets('ordinary Starry text field retains copy and paste menu', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'original text');
    addTearDown(controller.dispose);
    await tester.pumpWidget(_host(StarryTextField(controller: controller)));
    await _openMenu(tester);
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Paste'), findsOneWidget);
    final selected = controller.selection.textInside(controller.text);
    await tester.tap(find.text('Copy'));
    await tester.pumpAndSettle();
    expect(copied, selected);
    await _openMenu(tester);
    await tester.tap(find.text('Paste'));
    await tester.pumpAndSettle();
    expect(controller.text, contains('clipboard'));
  });

  testWidgets('read-only Starry field permits copying but not pasting', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'read only text');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _host(StarryTextField(controller: controller, readOnly: true)),
    );
    await _openMenu(tester);
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Paste'), findsNothing);
    expect(find.text('Cut'), findsNothing);
  });

  testWidgets(
    'custom paste replaces only paste and preserves exact field text',
    (tester) async {
      var pastes = 0;
      final controller = TextEditingController(text: 'original text');
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _host(StarryTextField(controller: controller, onPaste: () => pastes++)),
      );
      await _openMenu(tester);
      expect(find.text('Copy'), findsOneWidget);
      await tester.tap(find.text('Paste'));
      await tester.pumpAndSettle();
      expect(pastes, 1);
      expect(controller.text, 'original text');
      expect(find.text('Paste'), findsNothing);
    },
  );
}
