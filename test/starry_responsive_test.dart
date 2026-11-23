import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

void main() {
  Widget host({required Size size, required Widget child}) {
    return MaterialApp(
      theme: ThemeData(extensions: const [StarryTokens.light]),
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: child,
      ),
    );
  }

  group('StarryResponsiveContext', () {
    testWidgets('starryWindowSizeClass resolves page width at boundaries', (
      tester,
    ) async {
      final cases = <double, StarryWindowSizeClass>{
        599: StarryWindowSizeClass.compact,
        600: StarryWindowSizeClass.medium,
        839: StarryWindowSizeClass.medium,
        840: StarryWindowSizeClass.expanded,
        1199: StarryWindowSizeClass.expanded,
        1200: StarryWindowSizeClass.large,
        1599: StarryWindowSizeClass.large,
        1600: StarryWindowSizeClass.extraLarge,
      };
      for (final entry in cases.entries) {
        late StarryWindowSizeClass seen;
        await tester.pumpWidget(
          host(
            size: Size(entry.key, 800),
            child: Builder(
              builder: (context) {
                seen = context.starryWindowSizeClass;
                return const SizedBox.shrink();
              },
            ),
          ),
        );
        expect(seen, entry.value, reason: 'width=${entry.key}');
      }
    });

    testWidgets('starryBreakpoints falls back without StarryTokens', (
      tester,
    ) async {
      late StarryBreakpoints bp;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              bp = context.starryBreakpoints;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(bp.compact, 600);
      expect(bp.large, 1600);
    });
  });

  group('StarryResponsiveBuilder', () {
    testWidgets('keys off the constraint width, not the page width', (
      tester,
    ) async {
      late StarryWindowSizeClass seen;
      await tester.pumpWidget(
        host(
          size: const Size(1400, 800),
          child: Center(
            child: SizedBox(
              width: 500,
              child: StarryResponsiveBuilder(
                builder: (context, sizeClass, constraints) {
                  seen = sizeClass;
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );
      // Page is 1400 (large), but the box is 500 wide → compact.
      expect(seen, StarryWindowSizeClass.compact);
    });
  });
}
