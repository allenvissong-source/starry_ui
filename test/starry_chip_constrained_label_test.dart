import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

void main() {
  for (final deletable in [false, true]) {
    testWidgets(
      'long scaled chip label stays within width, delete=$deletable',
      (tester) async {
        var taps = 0;
        var deletes = 0;
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(),
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2)),
              child: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 200,
                    child: StarryChip(
                      label: 'A very long resource purpose label',
                      leading: const Icon(Icons.label_outline),
                      trailing: const Icon(Icons.expand_more),
                      onTap: () => taps++,
                      onDelete: deletable ? () => deletes++ : null,
                      deleteTooltip: deletable ? 'Delete tag' : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        expect(tester.getSize(find.byType(StarryChip)).width, 200);
        await tester.tap(find.text('A very long resource purpose label'));
        expect(taps, 1);
        if (deletable) {
          await tester.tap(find.byIcon(Icons.close));
          expect(deletes, 1);
        }
      },
    );
  }
}
