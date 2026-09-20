import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

Widget _host(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(
      body: Center(child: SizedBox(width: 360, child: child)),
    ),
  );
}

/// Behavior contracts migrated from the main Flutter app's dedicated component
/// tests (app_text_field_test, ailore_switch_test, app_chip_test). These assert
/// the user-facing semantics the call sites rely on, now owned by starry_ui.
void main() {
  group('StarrySwitch', () {
    testWidgets('toggles via onChanged on tap', (tester) async {
      var value = false;
      await tester.pumpWidget(
        _host(StarrySwitch(value: value, onChanged: (next) => value = next)),
      );
      await tester.tap(find.byType(StarrySwitch));
      expect(value, isTrue);
    });

    testWidgets('toggles on space key when focused', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      var value = false;
      await tester.pumpWidget(
        _host(
          StarrySwitch(
            value: value,
            focusNode: node,
            onChanged: (next) => value = next,
          ),
        ),
      );
      node.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      expect(value, isTrue);
    });

    testWidgets('is non-interactive when onChanged is null', (tester) async {
      await tester.pumpWidget(_host(const StarrySwitch(value: true)));
      expect(tester.takeException(), isNull);
      expect(find.byType(StarrySwitch), findsOneWidget);
    });
  });

  group('StarryTextField', () {
    testWidgets('error hides helperText while counter persists', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'abc');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 140,
            child: StarryTextField(
              controller: controller,
              label: 'Username',
              helperText: 'Helper',
              validationState: StarryTextFieldState.error,
              errorText: 'Error',
              showCounter: true,
              maxLength: 10,
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Helper'), findsNothing);
      expect(find.text('3/10'), findsOneWidget);
    });

    testWidgets('clear button has tooltip and clears text', (tester) async {
      final controller = TextEditingController(text: 'abc');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _host(
          StarryTextField(
            controller: controller,
            showClearButton: true,
            clearTooltip: 'Clear',
          ),
        ),
      );

      expect(find.byTooltip('Clear'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();
      expect(controller.text, isEmpty);
    });

    testWidgets('clear button is hidden when readOnly', (tester) async {
      final controller = TextEditingController(text: 'abc');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _host(
          StarryTextField(
            controller: controller,
            readOnly: true,
            showClearButton: true,
            clearTooltip: 'Clear',
          ),
        ),
      );

      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('no clear affordance when field is empty', (tester) async {
      final controller = TextEditingController(text: '');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _host(
          StarryTextField(
            controller: controller,
            showClearButton: true,
            clearTooltip: 'Clear',
          ),
        ),
      );

      expect(find.byIcon(Icons.clear), findsNothing);
    });
  });

  group('StarryChip', () {
    testWidgets('delete action exposes its tooltip', (tester) async {
      await tester.pumpWidget(
        _host(const StarryChip(label: 'Tag', onDelete: _noop, deleteTooltip: 'Remove')),
      );

      expect(find.byTooltip('Remove'), findsOneWidget);
    });
  });
}

void _noop() {}
