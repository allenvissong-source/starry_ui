import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

void main() {
  testWidgets('a tall invalid field keeps its error message in view', (
    tester,
  ) async {
    final key = GlobalKey<StarryFormState>();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: StarryForm(
              key: key,
              child: StarryFormField<bool>(
                label: 'Permissions',
                validator: (_) => 'Choose a signing identity',
                builder: (_) => const SizedBox(height: 900),
              ),
            ),
          ),
        ),
      ),
    );
    expect(key.currentState!.validate(), isFalse);
    await tester.pumpAndSettle();
    expect(
      find.text('Choose a signing identity').hitTestable(),
      findsOneWidget,
    );
  });

  testWidgets(
    'validation reveals first invalid field and saves corrected data',
    (tester) async {
      final key = GlobalKey<StarryFormState>();
      final focus = FocusNode();
      final controller = TextEditingController();
      addTearDown(focus.dispose);
      addTearDown(controller.dispose);
      String? saved;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: StarryForm(
                key: key,
                child: StarryFormSection(
                  title: 'Identity',
                  children: [
                    const SizedBox(height: 700),
                    StarryFormField<String>(
                      label: 'Name',
                      helperText: 'A public name',
                      focusNode: focus,
                      onSaved: (value) => saved = value,
                      validator: (value) =>
                          value?.isNotEmpty == true ? null : 'Name is required',
                      builder: (field) => StarryTextField(
                        controller: controller,
                        focusNode: focus,
                        onChanged: field.didChange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      expect(key.currentState!.validate(), isFalse);
      await tester.pumpAndSettle();
      expect(focus.hasFocus, isTrue);
      expect(find.text('Name is required').hitTestable(), findsOneWidget);
      await tester.enterText(find.byType(StarryTextField), 'Starry');
      await tester.pumpAndSettle();
      expect(find.text('Name is required'), findsNothing);
      expect(key.currentState!.validate(), isTrue);
      key.currentState!.save();
      expect(saved, 'Starry');
      key.currentState!.reset();
      await tester.pump();
      expect(find.text('Name is required'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
