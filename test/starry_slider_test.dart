import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

Widget _host(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  final tokens = StarryTokens.light;

  group('StarrySlider', () {
    testWidgets('bare slider (no header) wires token track colors',
        (tester) async {
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 360,
            child: StarrySlider(value: 40, onChanged: (_) {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Slider), findsOneWidget);
      // No header column when title/valueText/headerTrailing are all null.
      expect(find.byType(Text), findsNothing);

      final sliderTheme = tester.widget<SliderTheme>(
        find.ancestor(
          of: find.byType(Slider),
          matching: find.byType(SliderTheme),
        ).first,
      );
      expect(sliderTheme.data.activeTrackColor, tokens.semantic.brand);
      expect(sliderTheme.data.inactiveTrackColor, tokens.semantic.surfaceVariant);
      expect(sliderTheme.data.thumbColor, tokens.semantic.surface);
      expect(sliderTheme.data.trackHeight, StarrySlider.trackHeight);
    });

    testWidgets('header row renders title and value pill', (tester) async {
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 360,
            child: StarrySlider(
              value: 40,
              onChanged: (_) {},
              title: 'Temperature',
              valueText: '40%',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Temperature'), findsOneWidget);
      expect(find.text('40%'), findsOneWidget);
    });

    testWidgets('showThumb=false hides thumb and overlay', (tester) async {
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 360,
            child: StarrySlider(
              value: 40,
              onChanged: (_) {},
              showThumb: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final sliderTheme = tester.widget<SliderTheme>(
        find.ancestor(
          of: find.byType(Slider),
          matching: find.byType(SliderTheme),
        ).first,
      );
      expect(sliderTheme.data.thumbColor, Colors.transparent);
      expect(sliderTheme.data.overlayColor, Colors.transparent);
    });

    testWidgets('reports value changes via onChanged', (tester) async {
      double? changed;
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 360,
            child: StarrySlider(
              value: 40,
              onChanged: (v) => changed = v,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Slider));
      await tester.pumpAndSettle();
      expect(changed, isNotNull);
    });

    testWidgets('color overrides win over tokens', (tester) async {
      const custom = Color(0xFF123456);
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 360,
            child: StarrySlider(
              value: 40,
              onChanged: (_) {},
              activeTrackColor: custom,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final sliderTheme = tester.widget<SliderTheme>(
        find.ancestor(
          of: find.byType(Slider),
          matching: find.byType(SliderTheme),
        ).first,
      );
      expect(sliderTheme.data.activeTrackColor, custom);
    });
  });
}
