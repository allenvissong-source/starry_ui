import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

Widget _host(Widget child, {bool dark = false, double scale = 1}) =>
    MaterialApp(
      theme: dark ? AppTheme.dark() : AppTheme.light(),
      home: MediaQuery(
        data: MediaQueryData(
          textScaler: TextScaler.linear(scale),
          disableAnimations: true,
        ),
        child: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(width: 320, child: child),
          ),
        ),
      ),
    );

double _contrast(Color foreground, Color background) {
  final a = foreground.computeLuminance();
  final b = background.computeLuminance();
  return a > b ? (a + .05) / (b + .05) : (b + .05) / (a + .05);
}

void main() {
  test(
    'background image veil preserves themed text contrast and interpolates',
    () {
      for (final t in [StarryTokens.light, StarryTokens.dark]) {
        for (final photo in [
          const Color(0xFF000000),
          const Color(0xFFFFFFFF),
          const Color(0xFFFF0000),
          const Color(0xFF00FF00),
          const Color(0xFF0000FF),
        ]) {
          final backdrop = Color.alphaBlend(
            t.semantic.backgroundImageOverlay,
            photo,
          );
          for (final text in [
            t.semantic.textPrimary,
            t.semantic.textSecondary,
          ]) {
            expect(_contrast(text, backdrop), greaterThanOrEqualTo(4.5));
            final glass = Color.alphaBlend(
              t.semantic.surface.withValues(
                alpha: t.glass.contentSurfaceOpacity,
              ),
              backdrop,
            );
            expect(_contrast(text, glass), greaterThanOrEqualTo(4.5));
          }
        }
        expect(t.semantic.backgroundImageOverlay, isNot(t.semantic.scrim));
        expect(
          t.semantic.backgroundImageOverlay,
          isNot(t.semantic.mediaOverlayEnd),
        );
      }
      expect(
        StarryTokens.light
            .lerp(StarryTokens.dark, .5)
            .semantic
            .backgroundImageOverlay,
        Color.lerp(
          StarryTokens.light.semantic.backgroundImageOverlay,
          StarryTokens.dark.semantic.backgroundImageOverlay,
          .5,
        ),
      );
    },
  );

  testWidgets(
    'section material scope updates without changing geometry or text',
    (tester) async {
      const section = StarryContentSection(
        title: 'Heading',
        child: Text('Body'),
      );
      Future<void> mount(StarryContentSectionVariant variant) =>
          tester.pumpWidget(
            _host(StarryContentSectionTheme(variant: variant, child: section)),
          );
      await mount(StarryContentSectionVariant.solid);
      final size = tester.getSize(find.byWidget(section));
      final bodyPosition = tester.getTopLeft(find.text('Body'));
      await mount(StarryContentSectionVariant.frosted);
      expect(find.byType(StarrySurface), findsNothing);
      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(tester.getSize(find.byWidget(section)), size);
      expect(tester.getTopLeft(find.text('Body')), bodyPosition);
      final glass = tester.widget<StarryGlassPanel>(
        find.byType(StarryGlassPanel),
      );
      final t = StarryTokens.light;
      expect(glass.boxShadow, isEmpty);
      final decoration =
          tester
                  .widget<DecoratedBox>(
                    find
                        .descendant(
                          of: find.byType(StarryGlassPanel),
                          matching: find.byType(DecoratedBox),
                        )
                        .last,
                  )
                  .decoration
              as BoxDecoration;
      expect(
        decoration.color,
        t.semantic.surface.withValues(alpha: t.glass.contentSurfaceOpacity),
      );
      expect(
        decoration.boxShadow,
        isEmpty,
        reason: 'frosted sections float on the page photo without elevation',
      );
      expect(
        DefaultTextStyle.of(tester.element(find.text('Body'))).style.color!.a,
        1,
      );
      await tester.pumpWidget(
        _host(
          const StarryContentSectionTheme(
            variant: StarryContentSectionVariant.frosted,
            child: StarryContentSection(
              variant: StarryContentSectionVariant.solid,
              child: Text('Override'),
            ),
          ),
        ),
      );
      expect(find.byType(StarrySurface), findsOneWidget);
      expect(find.byType(BackdropFilter), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  for (final dark in [false, true]) {
    testWidgets('content section contrast and heading semantics dark=$dark', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          const StarryContentSection(
            title: '角色 Skill',
            subtitle: 'SKILLS',
            icon: Icons.description_outlined,
            child: Text('阅读正文'),
          ),
          dark: dark,
          scale: 2,
        ),
      );
      final t = dark ? StarryTokens.dark : StarryTokens.light;
      final panel = tester.widget<StarrySurface>(find.byType(StarrySurface));
      expect(panel.elevated, isTrue);
      expect(panel.clipBehavior, Clip.none);
      final box = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(StarrySurface),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      final decoration = box.decoration as BoxDecoration;
      final background = decoration.color!;
      expect(background, t.semantic.surface);
      expect(background.a, 1);
      expect((decoration.border! as Border).top.color, t.semantic.border);
      expect(decoration.boxShadow, t.elevation.level2);
      expect(decoration.borderRadius, BorderRadius.circular(t.radius.md));
      for (final label in ['角色 Skill', 'SKILLS']) {
        final text = tester.widget<Text>(find.text(label));
        expect(
          _contrast(text.style!.color!, background),
          greaterThanOrEqualTo(4.5),
        );
      }
      expect(
        tester.getSemantics(find.text('角色 Skill')).flagsCollection.isHeader,
        isTrue,
      );
      expect(
        tester.widget<Text>(find.text('角色 Skill')).style!.fontWeight,
        FontWeight.w500,
      );
      expect(
        DefaultTextStyle.of(tester.element(find.text('阅读正文'))).style.fontWeight,
        FontWeight.w400,
      );
      final bodyStyle = DefaultTextStyle.of(
        tester.element(find.text('阅读正文')),
      ).style;
      expect(bodyStyle.fontSize, t.typography.bodyMedium.size);
      expect(bodyStyle.color, t.semantic.textSecondary);
      expect(tester.takeException(), isNull);
      semantics.dispose();
    });
  }

  testWidgets('embedded disclosure keeps keyboard access without surfaces', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      _host(
        StarryContentSection(
          title: 'Skill',
          child: StarryExpandableCard(
            embedded: true,
            focusNode: focus,
            header: const Text(
              'A long binding title that wraps on a narrow screen',
            ),
            children: const [Text('Body')],
          ),
        ),
        scale: 2,
      ),
    );
    expect(find.byType(StarrySurface), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(StarryExpandableCard),
        matching: find.byType(StarrySurface),
      ),
      findsNothing,
    );
    final trigger = find.byType(InkWell);
    expect(tester.getSize(trigger).height, greaterThanOrEqualTo(48));
    expect(
      tester
              .getTopLeft(
                find.text('A long binding title that wraps on a narrow screen'),
              )
              .dx -
          tester.getTopLeft(trigger).dx,
      greaterThanOrEqualTo(StarryTokens.light.spacing.s3),
      reason: 'embedded header text must not sit on the hover fill edge',
    );
    expect(find.text('Body'), findsNothing);
    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Body'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Body')).dx - tester.getTopLeft(trigger).dx,
      greaterThanOrEqualTo(StarryTokens.light.spacing.s3),
      reason: 'embedded body must align with the header inset',
    );
    expect(find.byType(StarrySurface), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
}
