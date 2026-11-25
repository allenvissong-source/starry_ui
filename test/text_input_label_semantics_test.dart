import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

void main() {
  const label = 'Find pattern';
  for (final field in <Widget>[
    const StarryTextField(label: label),
    const StarryTextArea(label: label),
    const StarryTextArea.composer(label: label),
  ]) {
    testWidgets('${field.runtimeType} attaches its label to the editor', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(extensions: [StarryTokens.light]),
            home: Scaffold(body: SizedBox(height: 350, child: field)),
          ),
        );

        final editor = find.byType(EditableText);
        expect(find.text(label), findsOneWidget);
        expect(find.bySemanticsLabel(label), findsOneWidget);
        final data = tester.getSemantics(editor).getSemanticsData();
        expect(data.label, label);
        expect(data.flagsCollection.isTextField, isTrue);

        await tester.enterText(editor, 'example');
        await tester.pump();
        final edited = tester.getSemantics(editor).getSemanticsData();
        expect(edited.label, label);
        expect(edited.value, 'example');
        expect(edited.hasAction(SemanticsAction.setText), isTrue);
        expect(find.bySemanticsLabel(label), findsOneWidget);
      } finally {
        semantics.dispose();
      }
    });
  }
}
