import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/main.directories.g.dart' as widgetbook_directories;
import 'package:starry_ui/starry_ui.dart';
import 'package:starry_ui/src/feedback/starry_looping_animations.dart';
import 'package:widgetbook/widgetbook.dart';

// Internal-only primitives no longer surfaced on the public barrel; tested here
// via their implementation libraries (same-package access).
import 'package:starry_ui/src/buttons/starry_ai_button.dart';
import 'package:starry_ui/src/media/starry_identity_row.dart';
import 'package:starry_ui/src/buttons/starry_ai_button.usecase.dart'
    as starry_ai_button_usecase;

// Positive-evidence coverage for the Sheet5 "二档" component sedimentation:
//   • StarryCountFormatter — compact 万/w grouping
//   • StarryAvatar         — fallback chain, border, shape, tap
//   • StarryIdentityRow    — density sizing, subtitle, badges, trailing
//   • StarryToggleIconButton — glyph + tonal swap on select, disabled, a11y
//   • StarryMetricButton   — formatting, active glyph, disabled, loading, tone
//   • StarryAiButton       — default sparkle, glow halo, busy twinkle, gradient
// All assertions are pump-only + widget/style inspection; none tap an InkWell,
// so they are unaffected by the environmental `shaders/ink_sparkle.frag`
// shader-asset version mismatch that breaks tap-based InkWell tests.

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  home: Scaffold(body: Center(child: child)),
);

StarryTokens _tokens(WidgetTester tester, Finder anchor) {
  final ctx = tester.element(anchor);
  return Theme.of(ctx).extension<StarryTokens>()!;
}

double _verticalCenter(WidgetTester tester, Finder finder) {
  final rect = tester.getRect(finder);
  return rect.top + rect.height / 2;
}

bool _widgetbookTreeContainsName(WidgetbookNode node, String name) {
  if (node.name == name) return true;
  if (node is WidgetbookFolder) {
    return (node.children ?? const <WidgetbookNode>[]).any(
      (child) => _widgetbookTreeContainsName(child, name),
    );
  }
  return false;
}

void main() {
  group('StarryCountFormatter.compact', () {
    test('below 10k renders the plain decimal string', () {
      expect(StarryCountFormatter.compact(0), '0');
      expect(StarryCountFormatter.compact(999), '999');
      expect(StarryCountFormatter.compact(9999), '9999');
    });

    test('at/above 10k collapses to a 万/w form', () {
      expect(StarryCountFormatter.compact(10000), '1.0w');
      expect(StarryCountFormatter.compact(12345), '1.2w');
      // 99999 / 10000 = 9.9999 (< 10) → 1-decimal form, which rounds to 10.0w.
      expect(StarryCountFormatter.compact(99999), '10.0w');
      // 100000 / 10000 = 10.0 (>= 10) → integer form.
      expect(StarryCountFormatter.compact(100000), '10w');
      expect(StarryCountFormatter.compact(120000), '12w');
    });

    test('negative counts clamp to 0 (no stray minus)', () {
      expect(StarryCountFormatter.compact(-5), '0');
    });

    test('Widgetbook directories expose StarryCountFormatter by name', () {
      expect(
        widgetbook_directories.directories.any(
          (node) => _widgetbookTreeContainsName(node, 'StarryCountFormatter'),
        ),
        isTrue,
      );
    });
  });

  group('StarryCountFormatter.grouped', () {
    test('small counts render as the plain decimal string', () {
      expect(StarryCountFormatter.grouped(0), '0');
      expect(StarryCountFormatter.grouped(999), '999');
      expect(StarryCountFormatter.grouped(1234), '1,234');
    });

    test('inserts a comma every three digits from the right', () {
      expect(StarryCountFormatter.grouped(1234567), '1,234,567');
      expect(StarryCountFormatter.grouped(100000), '100,000');
      expect(StarryCountFormatter.grouped(100000000), '100,000,000');
    });

    test('negative counts clamp to 0 (no stray minus)', () {
      expect(StarryCountFormatter.grouped(-5), '0');
    });
  });
  group('StarryAvatar', () {
    testWidgets('size enum carries the shipped diameter tiers', (tester) async {
      expect(StarryAvatarSize.values.map((s) => s.diameter).toList(), <double>[
        24,
        32,
        40,
        48,
        64,
        80,
      ]);
    });

    testWidgets('no image + fallbackText paints initials (first two letters)', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const StarryAvatar(fallbackText: 'Alice')));
      expect(find.text('AL'), findsOneWidget);
    });

    testWidgets('two-token fallbackText yields each initial', (tester) async {
      await tester.pumpWidget(
        _host(const StarryAvatar(fallbackText: 'John Doe')),
      );
      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('no image + no text falls through to the person glyph', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const StarryAvatar()));
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('fallbackIcon wins over the default person glyph', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const StarryAvatar(fallbackIcon: Icons.pets)),
      );
      expect(find.byIcon(Icons.pets), findsOneWidget);
      expect(find.byIcon(Icons.person), findsNothing);
    });

    testWidgets(
      'bordered=false draws no ring; bordered=true draws brand ring',
      (tester) async {
        await tester.pumpWidget(_host(const StarryAvatar(fallbackText: 'A')));
        final noBorder = tester
            .widgetList<DecoratedBox>(
              find.descendant(
                of: find.byType(StarryAvatar),
                matching: find.byType(DecoratedBox),
              ),
            )
            .map((d) => d.decoration as BoxDecoration)
            .firstWhere(
              (d) => d.border == null || d.border != null,
              orElse: () => const BoxDecoration(),
            );
        expect(noBorder.border, isNull);

        await tester.pumpWidget(
          _host(const StarryAvatar(fallbackText: 'A', bordered: true)),
        );
        final t = _tokens(tester, find.byType(StarryAvatar));
        final withBorder = tester
            .widgetList<DecoratedBox>(
              find.descendant(
                of: find.byType(StarryAvatar),
                matching: find.byType(DecoratedBox),
              ),
            )
            .map((d) => d.decoration as BoxDecoration)
            .firstWhere((d) => d.border != null);
        expect((withBorder.border! as Border).top.color, t.semantic.brand);
      },
    );

    testWidgets('explicit borderColor overrides the default brand ring', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const StarryAvatar(
            fallbackText: 'A',
            bordered: true,
            borderColor: Colors.red,
          ),
        ),
      );
      final withBorder = tester
          .widgetList<DecoratedBox>(
            find.descendant(
              of: find.byType(StarryAvatar),
              matching: find.byType(DecoratedBox),
            ),
          )
          .map((d) => d.decoration as BoxDecoration)
          .firstWhere((d) => d.border != null);
      expect((withBorder.border! as Border).top.color, Colors.red);
    });

    testWidgets('customSize overrides the preset diameter', (tester) async {
      await tester.pumpWidget(
        _host(const StarryAvatar(fallbackText: 'A', customSize: 56)),
      );
      final box = tester.widget<SizedBox>(
        find
            .descendant(
              of: find.byType(StarryAvatar),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(box.width, 56);
      expect(box.height, 56);
    });

    testWidgets('onTap makes the avatar an accessible button', (tester) async {
      await tester.pumpWidget(
        _host(StarryAvatar(fallbackText: 'A', onTap: () {})),
      );
      expect(find.byType(InkWell), findsOneWidget);
    });
  });

  group('StarryIdentityRow', () {
    testWidgets('density maps to avatar diameter 24 / 32 / 40', (tester) async {
      for (final entry in <StarryIdentityDensity, double>{
        StarryIdentityDensity.feed: StarryAvatarSize.xs.diameter,
        StarryIdentityDensity.compact: StarryAvatarSize.small.diameter,
        StarryIdentityDensity.regular: StarryAvatarSize.medium.diameter,
      }.entries) {
        await tester.pumpWidget(
          _host(StarryIdentityRow(name: 'A', density: entry.key)),
        );
        final avatar = tester.widget<StarryAvatar>(find.byType(StarryAvatar));
        expect(avatar.customSize, entry.value);
      }
    });

    testWidgets('subtitle=null → single line (name only)', (tester) async {
      await tester.pumpWidget(_host(const StarryIdentityRow(name: 'Alice')));
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('@alice'), findsNothing);
    });

    testWidgets('subtitle → second line rendered', (tester) async {
      await tester.pumpWidget(
        _host(const StarryIdentityRow(name: 'Alice', subtitle: '@alice')),
      );
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('@alice'), findsOneWidget);
    });

    testWidgets('badges render inline after the name', (tester) async {
      await tester.pumpWidget(
        _host(
          const StarryIdentityRow(
            name: 'Alice',
            badges: <Widget>[Icon(Icons.verified)],
          ),
        ),
      );
      expect(
        find.descendant(
          of: find.byType(StarryIdentityRow),
          matching: find.byIcon(Icons.verified),
        ),
        findsOneWidget,
      );
    });

    testWidgets('trailing slot renders after the identity region', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const StarryIdentityRow(
            name: 'Alice',
            trailing: Icon(Icons.chevron_right),
          ),
        ),
      );
      expect(
        find.descendant(
          of: find.byType(StarryIdentityRow),
          matching: find.byIcon(Icons.chevron_right),
        ),
        findsOneWidget,
      );
    });

    testWidgets(
      'single-line name is centered against the avatar in every density',
      (tester) async {
        for (final density in StarryIdentityDensity.values) {
          await tester.pumpWidget(
            _host(StarryIdentityRow(name: 'Alice', density: density)),
          );
          expect(
            _verticalCenter(tester, find.text('Alice')),
            moreOrLessEquals(
              _verticalCenter(tester, find.byType(StarryAvatar)),
              epsilon: 1,
            ),
          );
        }
      },
    );

    testWidgets(
      'two-line text group is centered against the avatar in every density',
      (tester) async {
        for (final density in StarryIdentityDensity.values) {
          await tester.pumpWidget(
            _host(
              StarryIdentityRow(
                name: 'Alice',
                subtitle: '@alice',
                density: density,
              ),
            ),
          );
          final nameRect = tester.getRect(find.text('Alice'));
          final subtitleRect = tester.getRect(find.text('@alice'));
          final textGroupCenter = (nameRect.top + subtitleRect.bottom) / 2;
          expect(
            textGroupCenter,
            moreOrLessEquals(
              _verticalCenter(tester, find.byType(StarryAvatar)),
              epsilon: 1,
            ),
          );
        }
      },
    );
  });

  group('StarryToggleIconButton', () {
    testWidgets('unselected shows base glyph on the neutral surface', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          StarryToggleIconButton(
            icon: Icons.bookmark_border,
            selectedIcon: Icons.bookmark,
            selected: false,
            tooltip: 'Bookmark',
            onChanged: (_) {},
          ),
        ),
      );
      final t = _tokens(tester, find.byType(StarryToggleIconButton));
      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
      final icon = tester.widget<Icon>(find.byIcon(Icons.bookmark_border));
      expect(icon.color, t.semantic.textTertiary);
      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      expect(
        (container.decoration! as BoxDecoration).color,
        t.semantic.surfaceVariant,
      );
    });

    testWidgets('selected swaps glyph AND tints the background brand', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          StarryToggleIconButton(
            icon: Icons.bookmark_border,
            selectedIcon: Icons.bookmark,
            selected: true,
            tooltip: 'Bookmark',
            onChanged: (_) {},
          ),
        ),
      );
      final t = _tokens(tester, find.byType(StarryToggleIconButton));
      expect(find.byIcon(Icons.bookmark), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_border), findsNothing);
      final icon = tester.widget<Icon>(find.byIcon(Icons.bookmark));
      expect(icon.color, t.semantic.brand);
      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      expect(
        (container.decoration! as BoxDecoration).color,
        t.semantic.brand.withValues(alpha: 0.10),
      );
    });

    testWidgets('disabled uses the disabled ink and no gesture callback', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const StarryToggleIconButton(
            icon: Icons.bookmark_border,
            selectedIcon: Icons.bookmark,
            selected: false,
            tooltip: 'Bookmark',
          ),
        ),
      );
      final t = _tokens(tester, find.byType(StarryToggleIconButton));
      final icon = tester.widget<Icon>(find.byIcon(Icons.bookmark_border));
      expect(icon.color, t.semantic.textDisabled);
      final gesture = tester.widget<GestureDetector>(
        find.descendant(
          of: find.byType(StarryToggleIconButton),
          matching: find.byType(GestureDetector),
        ),
      );
      expect(gesture.onTap, isNull);
    });

    testWidgets('selected state is surfaced to assistive tech', (tester) async {
      await tester.pumpWidget(
        _host(
          StarryToggleIconButton(
            icon: Icons.bookmark_border,
            selectedIcon: Icons.bookmark,
            selected: true,
            tooltip: 'Bookmark',
            onChanged: (_) {},
          ),
        ),
      );
      final semantics = tester
          .widgetList<Semantics>(
            find.descendant(
              of: find.byType(StarryToggleIconButton),
              matching: find.byType(Semantics),
            ),
          )
          .firstWhere((s) => s.properties.selected != null);
      expect(semantics.properties.selected, isTrue);
    });
  });

  group('StarryMetricButton', () {
    testWidgets('count runs through the compact formatter by default', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          StarryMetricButton(
            icon: Icons.favorite_border,
            count: 12345,
            semanticLabel: 'Likes',
            onTap: () {},
          ),
        ),
      );
      expect(find.text('1.2w'), findsOneWidget);
    });

    testWidgets('countFormatter override wins over the default', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          StarryMetricButton(
            icon: Icons.favorite_border,
            count: 12345,
            semanticLabel: 'Likes',
            countFormatter: (c) => '$c',
            onTap: () {},
          ),
        ),
      );
      expect(find.text('12345'), findsOneWidget);
    });

    testWidgets(
      'active swaps to activeIcon and tints ink brand (surface tone)',
      (tester) async {
        await tester.pumpWidget(
          _host(
            StarryMetricButton(
              icon: Icons.favorite_border,
              activeIcon: Icons.favorite,
              count: 3,
              active: true,
              semanticLabel: 'Likes',
              onTap: () {},
            ),
          ),
        );
        final t = _tokens(tester, find.byType(StarryMetricButton));
        expect(find.byIcon(Icons.favorite), findsOneWidget);
        final icon = tester.widget<Icon>(find.byIcon(Icons.favorite));
        expect(icon.color, t.semantic.brand);
      },
    );

    testWidgets('disabled dims to disabledContent opacity and blocks taps', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          StarryMetricButton(
            icon: Icons.favorite_border,
            count: 3,
            disabled: true,
            semanticLabel: 'Likes',
            onTap: () {},
          ),
        ),
      );
      final t = _tokens(tester, find.byType(StarryMetricButton));
      final opacity = tester.widget<Opacity>(
        find.descendant(
          of: find.byType(StarryMetricButton),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacity.opacity, t.opacity.disabledContent);
      final gesture = tester.widget<GestureDetector>(
        find.descendant(
          of: find.byType(StarryMetricButton),
          matching: find.byType(GestureDetector),
        ),
      );
      expect(gesture.onTap, isNull);
    });

    testWidgets('allowDisabledTap keeps the tap live while disabled', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          StarryMetricButton(
            icon: Icons.favorite_border,
            count: 3,
            disabled: true,
            allowDisabledTap: true,
            semanticLabel: 'Likes',
            onTap: () {},
          ),
        ),
      );
      final gesture = tester.widget<GestureDetector>(
        find.descendant(
          of: find.byType(StarryMetricButton),
          matching: find.byType(GestureDetector),
        ),
      );
      expect(gesture.onTap, isNotNull);
    });

    testWidgets('loading replaces the glyph with a spinner', (tester) async {
      await tester.pumpWidget(
        _host(
          StarryMetricButton(
            icon: Icons.favorite_border,
            count: 3,
            loading: true,
            semanticLabel: 'Likes',
            onTap: () {},
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });

    testWidgets('onMedia tone paints white ink regardless of active', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          StarryMetricButton(
            icon: Icons.favorite_border,
            count: 3,
            tone: StarryMetricTone.onMedia,
            semanticLabel: 'Likes',
            onTap: () {},
          ),
        ),
      );
      final icon = tester.widget<Icon>(find.byIcon(Icons.favorite_border));
      expect(icon.color, Colors.white);
    });
  });

  group('StarryAiButton', () {
    testWidgets('defaults: built-in sparkle glyph, size 48, not busy', (
      tester,
    ) async {
      await tester.pumpWidget(_host(StarryAiButton(onTap: () {})));
      final b = tester.widget<StarryAiButton>(find.byType(StarryAiButton));
      expect(b.icon, Icons.auto_awesome);
      // `size` is null by default and resolves to controlMetrics.controlHeight
      // (48) at build time; assert the rendered diameter, not the field.
      expect(tester.getSize(find.byType(StarryAiButton)), const Size(48, 48));
      expect(b.busy, isFalse);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });

    testWidgets('rests with a brand gradient fill + reserved glow halo', (
      tester,
    ) async {
      await tester.pumpWidget(_host(StarryAiButton(onTap: () {})));
      final t = _tokens(tester, find.byType(StarryAiButton));
      final container = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(StarryAiButton),
              matching: find.byType(Container),
            ),
          )
          .firstWhere((c) => c.decoration is BoxDecoration);
      final deco = container.decoration! as BoxDecoration;
      // Brand gradient.
      final gradient = deco.gradient! as LinearGradient;
      expect(gradient.colors, <Color>[
        t.brand.gradientStart,
        t.brand.gradientEnd,
      ]);
      // Reserved glow halo geometry from the token layer.
      final shadow = deco.boxShadow!.single;
      expect(shadow.blurRadius, t.focus.glowBlurRadius);
      expect(shadow.spreadRadius, t.focus.glowSpreadRadius);
      expect(
        shadow.color,
        t.semantic.brand.withValues(alpha: t.focus.glowAlpha),
      );
    });

    testWidgets('busy twinkles the glyph instead of overlaying a spinner', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const StarryAiButton(busy: true)));
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
      // The twinkle is the shared looping primitive, breathing from the
      // busy-content opacity token up to full ink.
      final t = _tokens(tester, find.byType(StarryAiButton));
      final pulse = tester.widget<StarryPulsingWidget>(
        find.descendant(
          of: find.byType(StarryAiButton),
          matching: find.byType(StarryPulsingWidget),
        ),
      );
      expect(pulse.minOpacity, t.opacity.busyContent);
      expect(pulse.maxOpacity, 1.0);
      // Cycle speed comes from the motion token, not a local literal: the
      // primitive resolves a null duration to `motion.durationSlower`.
      expect(pulse.duration, isNull);
      expect(t.motion.durationSlower, const Duration(milliseconds: 1200));
    });

    testWidgets('busy twinkle animates the glyph opacity over the cycle', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const StarryAiButton(busy: true)));
      final t = _tokens(tester, find.byType(StarryAiButton));
      double glyphOpacity() => tester
          .widgetList<Opacity>(
            find.descendant(
              of: find.byType(StarryPulsingWidget),
              matching: find.byType(Opacity),
            ),
          )
          .first
          .opacity;
      // Start of the cycle sits at the dimmed end...
      expect(glyphOpacity(), closeTo(t.opacity.busyContent, 0.01));
      // ...and half a cycle later it has brightened towards full ink.
      await tester.pump(t.motion.durationSlower ~/ 2);
      expect(glyphOpacity(), greaterThan(t.opacity.busyContent + 0.1));
    });

    testWidgets('reduce motion rests the busy glyph instead of twinkling', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(body: Center(child: StarryAiButton(busy: true))),
          ),
        ),
      );
      expect(find.byType(StarryPulsingWidget), findsNothing);
      final t = _tokens(tester, find.byType(StarryAiButton));
      final opacity = tester
          .widgetList<Opacity>(
            find.descendant(
              of: find.byType(StarryAiButton),
              matching: find.byType(Opacity),
            ),
          )
          .first;
      expect(opacity.opacity, t.opacity.busyContent);
    });

    testWidgets('glyph uses white foreground ink in both states', (
      tester,
    ) async {
      await tester.pumpWidget(_host(StarryAiButton(onTap: () {})));
      final icon = tester.widget<Icon>(find.byIcon(Icons.auto_awesome));
      expect(icon.color, Colors.white);

      await tester.pumpWidget(_host(const StarryAiButton(busy: true)));
      final busyIcon = tester.widget<Icon>(find.byIcon(Icons.auto_awesome));
      expect(busyIcon.color, Colors.white);
    });

    testWidgets('icon override replaces the default sparkle', (tester) async {
      await tester.pumpWidget(
        _host(StarryAiButton(icon: Icons.smart_toy, onTap: () {})),
      );
      expect(find.byIcon(Icons.smart_toy), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsNothing);
    });

    testWidgets('backgroundColor override drops the gradient for a flat fill', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          StarryAiButton(
            backgroundColor: const Color(0xFF123456),
            onTap: () {},
          ),
        ),
      );
      final container = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(StarryAiButton),
              matching: find.byType(Container),
            ),
          )
          .firstWhere((c) => c.decoration is BoxDecoration);
      final deco = container.decoration! as BoxDecoration;
      expect(deco.gradient, isNull);
      expect(deco.color, const Color(0xFF123456));
    });

    testWidgets('All States usecase keeps state examples at one size', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          Builder(builder: starry_ai_button_usecase.allStatesStarryAiButton),
        ),
      );
      final buttons = tester.widgetList<StarryAiButton>(
        find.byType(StarryAiButton),
      );
      expect(buttons, hasLength(3));
      // Default size resolves from controlMetrics.controlHeight (48) at build
      // time, so the field is null; assert the rendered diameter is uniform.
      final sizes = <Size>[
        for (var i = 0; i < buttons.length; i++)
          tester.getSize(find.byType(StarryAiButton).at(i)),
      ];
      expect(sizes, everyElement(const Size(48, 48)));
    });
  });

  group('StarryTag — accent', () {
    testWidgets('accent is a distinct enum value', (tester) async {
      expect(StarryTagStatus.values, contains(StarryTagStatus.accent));
    });

    testWidgets('accent paints a brand-tinted surface with brandStrong ink', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const StarryTag(label: 'AI', status: StarryTagStatus.accent)),
      );
      final t = _tokens(tester, find.byType(StarryTag));
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(StarryTag),
          matching: find.byType(Container),
        ),
      );
      final deco = container.decoration! as BoxDecoration;
      expect(deco.color, t.semantic.brand.withValues(alpha: 0.12));
      final text = tester.widget<Text>(
        find.descendant(
          of: find.byType(StarryTag),
          matching: find.byType(Text),
        ),
      );
      expect(text.style!.color, t.semantic.brandStrong);
      expect(text.style!.fontWeight, FontWeight.w700);
      expect(text.style!.fontSize, t.typography.labelSmall.size);
    });
  });

  group('StarrySkeletonOrContent', () {
    testWidgets('not loading + not empty renders content', (tester) async {
      await tester.pumpWidget(
        _host(
          StarrySkeletonOrContent(
            isLoading: false,
            isEmpty: false,
            skeletonBuilder: (_) => const Text('SKELETON'),
            contentBuilder: (_) => const Text('CONTENT'),
          ),
        ),
      );
      expect(find.text('CONTENT'), findsOneWidget);
      expect(find.text('SKELETON'), findsNothing);
    });

    testWidgets('empty renders emptyBuilder over content', (tester) async {
      await tester.pumpWidget(
        _host(
          StarrySkeletonOrContent(
            isLoading: false,
            isEmpty: true,
            skeletonBuilder: (_) => const Text('SKELETON'),
            contentBuilder: (_) => const Text('CONTENT'),
            emptyBuilder: (_) => const Text('EMPTY'),
          ),
        ),
      );
      expect(find.text('EMPTY'), findsOneWidget);
      expect(find.text('CONTENT'), findsNothing);
    });

    testWidgets('error branch wins over every other state', (tester) async {
      await tester.pumpWidget(
        _host(
          StarrySkeletonOrContent(
            isLoading: true,
            isEmpty: true,
            error: 'boom',
            skeletonBuilder: (_) => const Text('SKELETON'),
            contentBuilder: (_) => const Text('CONTENT'),
            emptyBuilder: (_) => const Text('EMPTY'),
            errorBuilder: (_, e) => Text('ERROR:$e'),
          ),
        ),
      );
      expect(find.text('ERROR:boom'), findsOneWidget);
      expect(find.text('SKELETON'), findsNothing);
      expect(find.text('EMPTY'), findsNothing);
    });

    testWidgets('skeleton appears after appearDelay while loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          StarrySkeletonOrContent(
            isLoading: true,
            isEmpty: false,
            appearDelay: const Duration(milliseconds: 50),
            skeletonBuilder: (_) => const Text('SKELETON'),
            contentBuilder: (_) => const Text('CONTENT'),
          ),
        ),
      );
      // Before the delay elapses the skeleton is withheld (anti-flicker).
      expect(find.text('SKELETON'), findsNothing);
      await tester.pump(const Duration(milliseconds: 60));
      expect(find.text('SKELETON'), findsOneWidget);
      // Settle the min-show timer so the test tears down cleanly.
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('Widgetbook directories expose StarrySkeletonOrContent', (
      tester,
    ) async {
      expect(
        widgetbook_directories.directories.any(
          (node) =>
              _widgetbookTreeContainsName(node, 'StarrySkeletonOrContent'),
        ),
        isTrue,
      );
    });
  });

  group('StarrySliverSkeletonOrContent', () {
    Widget sliverHost(Widget sliver) => MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(body: CustomScrollView(slivers: <Widget>[sliver])),
    );

    testWidgets('not loading + not empty renders content sliver', (
      tester,
    ) async {
      await tester.pumpWidget(
        sliverHost(
          StarrySliverSkeletonOrContent(
            isLoading: false,
            isEmpty: false,
            skeletonSliverBuilder: (_) =>
                const SliverToBoxAdapter(child: Text('SKELETON')),
            contentSliverBuilder: (_) =>
                const SliverToBoxAdapter(child: Text('CONTENT')),
          ),
        ),
      );
      expect(find.text('CONTENT'), findsOneWidget);
      expect(find.text('SKELETON'), findsNothing);
    });

    testWidgets('empty renders empty sliver over content', (tester) async {
      await tester.pumpWidget(
        sliverHost(
          StarrySliverSkeletonOrContent(
            isLoading: false,
            isEmpty: true,
            skeletonSliverBuilder: (_) =>
                const SliverToBoxAdapter(child: Text('SKELETON')),
            contentSliverBuilder: (_) =>
                const SliverToBoxAdapter(child: Text('CONTENT')),
            emptySliverBuilder: (_) =>
                const SliverToBoxAdapter(child: Text('EMPTY')),
          ),
        ),
      );
      expect(find.text('EMPTY'), findsOneWidget);
      expect(find.text('CONTENT'), findsNothing);
    });

    testWidgets('Widgetbook directories expose StarrySliverSkeletonOrContent', (
      tester,
    ) async {
      expect(
        widgetbook_directories.directories.any(
          (node) => _widgetbookTreeContainsName(
            node,
            'StarrySliverSkeletonOrContent',
          ),
        ),
        isTrue,
      );
    });
  });
}
