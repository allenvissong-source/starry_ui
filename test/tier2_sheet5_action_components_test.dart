import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/main.directories.g.dart' as widgetbook_directories;
import 'package:starry_ui/starry_ui.dart';
import 'package:widgetbook/widgetbook.dart';

// Internal-only primitive, tested via its implementation library.
import 'package:starry_ui/src/feedback/starry_error_widget.dart';

// Positive-evidence coverage for the Sheet5 action/feedback sedimentation:
//   • StarryErrorWidget        — full-surface error state with token retry CTA
//   • StarryPrimaryActionButton — thin full-width filled CTA wrapper
// All assertions are pump-only + widget/style inspection.

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  home: Scaffold(body: child),
);

StarryTokens _tokens(WidgetTester tester, Finder anchor) {
  final ctx = tester.element(anchor);
  return Theme.of(ctx).extension<StarryTokens>()!;
}

// Fixed pixel travel of the sliver between collapsed and expanded in these
// tests: expandedHeight 200 - collapsedHeight 72 = 128, with a zero top safe
// inset (the default flutter_test surface has no MediaQuery padding).
const double _kCollapseTravel = 128;

// Key on the injected expanded backdrop so coverage geometry can be read off
// its render rect.
const ValueKey<String> _kBackdropKey = ValueKey<String>('expanded-backdrop');

// Nearest enclosing DefaultTextStyle colour for a rendered text widget.
Color _defaultTextStyleColor(WidgetTester tester, Finder of) {
  final DefaultTextStyle dt = tester.widget<DefaultTextStyle>(
    find.ancestor(of: of, matching: find.byType(DefaultTextStyle)).first,
  );
  return dt.style.color!;
}

// Nearest enclosing IconTheme colour for a rendered standard action glyph.
Color _iconThemeColor(WidgetTester tester, Finder of) {
  final IconTheme it = tester.widget<IconTheme>(
    find.ancestor(of: of, matching: find.byType(IconTheme)).first,
  );
  return it.data.color!;
}

// The Icon widget's own explicit colour - used for custom child actions that
// set their own colour and therefore must NOT pick up the foreground override.
Color _iconOwnColor(WidgetTester tester, Finder of) {
  final Icon icon = tester.widget<Icon>(of);
  return icon.color!;
}

// --- Real WCAG contrast math (independent of the component's colour formula) ---

double _channelLinear(double v) {
  final double s = v / 255.0;
  return s <= 0.03928
      ? s / 12.92
      : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
}

double _luminance(Color c) {
  final r = c.r * 255.0, g = c.g * 255.0, b = c.b * 255.0;
  return 0.2126 * _channelLinear(r) +
      0.7152 * _channelLinear(g) +
      0.0722 * _channelLinear(b);
}

// WCAG contrast ratio (1..21).
double _contrast(Color a, Color b) {
  final double la = _luminance(a);
  final double lb = _luminance(b);
  final double hi = la > lb ? la : lb;
  final double lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

// Source-over-destination with an explicit source alpha (0..1); result is opaque.
Color _compositeWithAlpha(Color src, double a, Color dst) {
  return Color.from(
    alpha: 1.0,
    red: a * src.r + (1 - a) * dst.r,
    green: a * src.g + (1 - a) * dst.g,
    blue: a * src.b + (1 - a) * dst.b,
  );
}

// Source-over-destination using the source colour's own alpha channel.
Color _compositeOver(Color src, Color dst) =>
    _compositeWithAlpha(src, src.a, dst);

// Pumps an expanded sliver top bar inside a CustomScrollView and returns the
// attached controller so callers can pin progress exactly
// (offset = progress * [_kCollapseTravel]). When [poppable] is true the bar
// sits on a second route so `Navigator.canPop()` is true and
// [StarrySliverPageTopBar.showDefaultBack] actually renders the back arrow.
Future<ScrollController> _pumpExpandedSliver(
  WidgetTester tester, {
  required ThemeData theme,
  Color? backdrop,
  Color? expandedFg,
  bool poppable = false,
  bool showDefaultBack = false,
  double topSafeInset = 0,
  Widget? leading,
  List<StarryTopBarActionItem> leftActions = const <StarryTopBarActionItem>[],
  List<StarryTopBarActionItem> rightActions = const <StarryTopBarActionItem>[],
}) async {
  final ScrollController controller = ScrollController();

  Widget buildBar() {
    return StarrySliverPageTopBar(
      titleText: 'STARRY',
      subtitleText: 'header',
      expandedHeight: 200,
      collapsedHeight: 72,
      expandedBackground: backdrop == null
          ? null
          : ColoredBox(key: _kBackdropKey, color: backdrop),
      expandedForegroundColor: expandedFg,
      showDefaultBack: showDefaultBack,
      leading: leading,
      leftActions: leftActions,
      rightActions: rightActions,
    );
  }

  Widget wrapSafeInset(Widget child) {
    if (topSafeInset == 0) return child;
    return MediaQuery(
      data: MediaQueryData(padding: EdgeInsets.only(top: topSafeInset)),
      child: child,
    );
  }

  Widget buildBody() {
    return wrapSafeInset(
      Scaffold(
        body: CustomScrollView(
          controller: controller,
          slivers: <Widget>[
            buildBar(),
            SliverList.builder(
              itemCount: 40,
              itemBuilder: (BuildContext context, int i) =>
                  ListTile(title: Text('row $i')),
            ),
          ],
        ),
      ),
    );
  }

  if (poppable) {
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        initialRoute: '/bar',
        routes: <String, WidgetBuilder>{
          '/': (_) => const Scaffold(body: Center(child: Text('root'))),
          '/bar': (_) => buildBody(),
        },
      ),
    );
  } else {
    await tester.pumpWidget(MaterialApp(theme: theme, home: buildBody()));
  }
  await tester.pump();
  return controller;
}

// Sends the scrollable to [offset] and pumps one frame so the sliver delegate
// rebuilds with the new shrinkOffset (and therefore progress).
Future<void> _seek(
  WidgetTester tester,
  ScrollController controller,
  double offset,
) async {
  controller.jumpTo(offset);
  await tester.pump();
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
  group('StarryErrorWidget', () {
    testWidgets('renders title, message and the default error icon', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const StarryErrorWidget(title: 'Oops', message: 'It broke.')),
      );
      expect(find.text('Oops'), findsOneWidget);
      expect(find.text('It broke.'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('default error icon is tinted with the semantic error token', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const StarryErrorWidget(title: 'Oops')));
      final t = _tokens(tester, find.text('Oops'));
      final icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
      expect(icon.color, t.semantic.error);
    });

    testWidgets('retry CTA is a StarryButton and fires onRetry', (
      tester,
    ) async {
      var tapped = 0;
      await tester.pumpWidget(
        _host(
          StarryErrorWidget(
            title: 'Oops',
            retryLabel: 'Try again',
            onRetry: () => tapped++,
          ),
        ),
      );
      expect(find.byType(StarryButton), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      await tester.tap(find.byType(StarryButton));
      await tester.pump();
      expect(tapped, 1);
    });

    testWidgets('omits the retry button when onRetry is null', (tester) async {
      await tester.pumpWidget(_host(const StarryErrorWidget(title: 'Oops')));
      expect(find.byType(StarryButton), findsNothing);
    });

    testWidgets('shows the details block only when showDetails is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const StarryErrorWidget(title: 'Oops', details: 'HTTP 500')),
      );
      expect(find.text('HTTP 500'), findsNothing);

      await tester.pumpWidget(
        _host(
          const StarryErrorWidget(
            title: 'Oops',
            details: 'HTTP 500',
            showDetails: true,
          ),
        ),
      );
      expect(find.text('HTTP 500'), findsOneWidget);
    });

    testWidgets('Widgetbook directories expose StarryErrorWidget', (
      tester,
    ) async {
      final root = widgetbook_directories.directories;
      expect(
        root.any(
          (node) => _widgetbookTreeContainsName(node, 'StarryErrorWidget'),
        ),
        isTrue,
      );
    });
  });

  group('StarryPrimaryActionButton', () {
    testWidgets('wraps a filled StarryButton and fires onPressed', (
      tester,
    ) async {
      var tapped = 0;
      await tester.pumpWidget(
        _host(
          StarryPrimaryActionButton(label: 'Go', onPressed: () => tapped++),
        ),
      );
      final button = tester.widget<StarryButton>(find.byType(StarryButton));
      expect(button.variant, StarryButtonVariant.filled);
      expect(button.fullWidth, isTrue);
      expect(button.pressScale, isTrue);
      expect(find.text('Go'), findsOneWidget);
      await tester.tap(find.byType(StarryButton));
      await tester.pump();
      expect(tapped, 1);
    });

    testWidgets('folds height to the token controlHeight (48, not 52)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(StarryPrimaryActionButton(label: 'Go', onPressed: () {})),
      );
      final t = _tokens(tester, find.text('Go'));
      expect(t.controlMetrics.controlHeight, 48);
      // The wrapper must not hard-tune a 52px SizedBox.
      final sizedBoxes = tester
          .widgetList<SizedBox>(find.byType(SizedBox))
          .where((b) => b.height == 52);
      expect(sizedBoxes, isEmpty);
    });

    testWidgets('is disabled when enabled is false', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(
        _host(
          StarryPrimaryActionButton(
            label: 'Go',
            enabled: false,
            onPressed: () => tapped++,
          ),
        ),
      );
      final button = tester.widget<StarryButton>(find.byType(StarryButton));
      expect(button.onPressed, isNull);
      await tester.tap(find.byType(StarryButton));
      await tester.pump();
      expect(tapped, 0);
    });

    testWidgets('Widgetbook directories expose StarryPrimaryActionButton', (
      tester,
    ) async {
      final root = widgetbook_directories.directories;
      expect(
        root.any(
          (node) =>
              _widgetbookTreeContainsName(node, 'StarryPrimaryActionButton'),
        ),
        isTrue,
      );
    });
  });

  group('StarryPageTopBar', () {
    testWidgets('renders the title text and centers it', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: const StarryPageTopBar(titleText: 'STARRY'),
        ),
      );
      expect(find.text('STARRY'), findsOneWidget);
      expect(find.byType(NavigationToolbar), findsOneWidget);
    });

    testWidgets(
      'elevated action reuses StarryRoundIconShell and fires onPressed',
      (tester) async {
        var tapped = 0;
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(),
            home: StarryPageTopBar(
              titleText: 'Home',
              rightActions: <StarryTopBarActionItem>[
                StarryTopBarActionItem(
                  icon: const Icon(Icons.add),
                  tooltip: 'Add',
                  onPressed: () => tapped++,
                ),
              ],
            ),
          ),
        );
        expect(find.byType(StarryRoundIconShell), findsOneWidget);
        expect(find.byIcon(Icons.add), findsOneWidget);
        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();
        expect(tapped, 1);
      },
    );

    testWidgets('flat action dims and does not tap when disabled', (
      tester,
    ) async {
      var tapped = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: StarryPageTopBar(
            titleText: 'Home',
            rightActions: const <StarryTopBarActionItem>[
              StarryTopBarActionItem(
                icon: Icon(Icons.more_horiz),
                tooltip: 'More',
                style: StarryTopBarActionStyle.flat,
              ),
            ],
          ),
        ),
      );
      // Disabled (onPressed == null): no round shell, and tapping is a no-op.
      expect(find.byType(StarryRoundIconShell), findsNothing);
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pump();
      expect(tapped, 0);
    });

    testWidgets('custom action widget is rendered as-is', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: StarryPageTopBar(
            titleText: 'Home',
            rightActions: <StarryTopBarActionItem>[
              StarryTopBarActionItem.custom(
                tooltip: 'Profile',
                child: const CircleAvatar(child: Text('A')),
              ),
            ],
          ),
        ),
      );
      expect(find.text('A'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('preferredSize is content height plus bottom padding', (
      tester,
    ) async {
      const bar = StarryPageTopBar(titleText: 'X');
      expect(
        bar.preferredSize.height,
        StarryPageTopBar.defaultHeight + StarryPageTopBar.defaultBottomPadding,
      );
    });

    testWidgets('Widgetbook directories expose StarryPageTopBar', (
      tester,
    ) async {
      final root = widgetbook_directories.directories;
      expect(
        root.any(
          (node) => _widgetbookTreeContainsName(node, 'StarryPageTopBar'),
        ),
        isTrue,
      );
    });
  });

  group('StarrySliverPageTopBar', () {
    Widget sliverHost(StarrySliverPageTopBar bar) => MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: CustomScrollView(
          slivers: <Widget>[
            bar,
            SliverList.builder(
              itemCount: 20,
              itemBuilder: (context, index) =>
                  ListTile(title: Text('row $index')),
            ),
          ],
        ),
      ),
    );

    testWidgets('renders as a SliverPersistentHeader with its title', (
      tester,
    ) async {
      await tester.pumpWidget(
        sliverHost(const StarrySliverPageTopBar(titleText: '收藏夹')),
      );
      expect(find.byType(SliverPersistentHeader), findsOneWidget);
      expect(find.text('收藏夹'), findsOneWidget);
    });

    testWidgets('collapsed toolbar reuses StarryPageTopBar chrome', (
      tester,
    ) async {
      await tester.pumpWidget(
        sliverHost(const StarrySliverPageTopBar(titleText: 'Home')),
      );
      expect(find.byType(StarryPageTopBar), findsOneWidget);
    });

    testWidgets('left action fires onPressed', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(
        sliverHost(
          StarrySliverPageTopBar(
            titleText: 'Home',
            leftActions: <StarryTopBarActionItem>[
              StarryTopBarActionItem(
                icon: const Icon(Icons.arrow_back_ios_new),
                tooltip: 'Back',
                onPressed: () => tapped++,
              ),
            ],
          ),
        ),
      );
      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pump();
      expect(tapped, 1);
    });

    testWidgets('expandedBackground grows the header extent', (tester) async {
      await tester.pumpWidget(
        sliverHost(
          const StarrySliverPageTopBar(
            titleText: 'STARRY',
            expandedHeight: 220,
            expandedBackground: ColoredBox(color: Colors.transparent),
          ),
        ),
      );
      final header = tester.widget<SliverPersistentHeader>(
        find.byType(SliverPersistentHeader),
      );
      expect(header.delegate.maxExtent, greaterThan(header.delegate.minExtent));
      expect(find.byType(ColoredBox), findsWidgets);
    });

    testWidgets(
      'expanded backdrop paints behind default back, leading strip and actions',
      (tester) async {
        // A real OPAQUE backdrop (not a transparent ColoredBox).
        const backdrop = Color(0xFF0F0F16);
        const fg = Color(0xFFFFFFFF);
        await _pumpExpandedSliver(
          tester,
          theme: AppTheme.light(),
          backdrop: backdrop,
          expandedFg: fg,
          poppable: true,
          showDefaultBack: true,
          leftActions: const <StarryTopBarActionItem>[
            StarryTopBarActionItem(icon: Icon(Icons.add), tooltip: 'Add'),
          ],
          rightActions: const <StarryTopBarActionItem>[
            StarryTopBarActionItem(
              icon: Icon(Icons.favorite),
              tooltip: 'Fav',
              style: StarryTopBarActionStyle.flat,
            ),
          ],
        );

        final Rect bg = tester.getRect(find.byKey(_kBackdropKey));
        final Rect back = tester.getRect(find.byIcon(Icons.arrow_back_ios_new));
        final Rect add = tester.getRect(find.byIcon(Icons.add));
        final Rect fav = tester.getRect(find.byIcon(Icons.favorite));
        final Rect title = tester.getRect(find.text('STARRY'));

        // The backdrop starts at the very top of the viewport - behind the
        // status-bar / back-affordance area, not below the toolbar.
        expect(bg.top, 0.0);
        // Every chrome element sits ON the backdrop, i.e. within its rect.
        for (final Rect r in <Rect>[back, add, fav, title]) {
          expect(r.left, greaterThanOrEqualTo(bg.left));
          expect(r.right, lessThanOrEqualTo(bg.right));
          expect(r.top, greaterThanOrEqualTo(bg.top));
          expect(r.bottom, lessThanOrEqualTo(bg.bottom));
        }
      },
    );

    // Real accessibility acceptance (NOT formula-locking). With an expanded
    // media backdrop present and NO caller override, the flat chrome foreground
    // resolves to the semantic `onMedia` token and floats over a constant media
    // scrim. We read the ACTUAL foreground colours off the rendered tree,
    // compute the ACTUAL composited backing (backdrop at opacity (1-p) over
    // surface, then the scrim over that), and assert WCAG contrast at five
    // scroll points on both themes. Thresholds are explicit by use (text 4.5,
    // icons/glyphs 3.0) and are NOT lowered to make a failure pass.
    for (final (String label, ThemeData theme, Color backdrop)
        in <(String, ThemeData, Color)>[
          (
            'light theme / dark backdrop',
            AppTheme.light(),
            const Color(0xFF0F0F16),
          ),
          (
            'dark theme / light backdrop',
            AppTheme.dark(),
            const Color(0xFFF3ECDC),
          ),
        ]) {
      testWidgets(
        'flat chrome holds real contrast across the whole scroll interval ($label)',
        (tester) async {
          final controller = await _pumpExpandedSliver(
            tester,
            theme: theme,
            backdrop: backdrop,
            expandedFg: null,
            poppable: true,
            showDefaultBack: true,
            leftActions: const <StarryTopBarActionItem>[
              StarryTopBarActionItem(
                icon: Icon(Icons.favorite),
                tooltip: 'Flat',
                style: StarryTopBarActionStyle.flat,
              ),
            ],
            rightActions: const <StarryTopBarActionItem>[
              StarryTopBarActionItem(
                icon: Icon(Icons.add),
                tooltip: 'Elevated',
              ),
              StarryTopBarActionItem(
                icon: Icon(Icons.star),
                tooltip: 'Flat',
                style: StarryTopBarActionStyle.flat,
              ),
            ],
          );
          final t = _tokens(tester, find.text('STARRY'));
          final Color surface = t.semantic.surface;
          final Color scrim = t.semantic.mediaOverlayEnd;

          for (final double p in <double>[0, 0.25, 0.5, 0.75, 1]) {
            await _seek(tester, controller, _kCollapseTravel * p);

            // Actual composited backing behind the flat chrome strip.
            final Color backdropLayer = _compositeWithAlpha(
              backdrop,
              1 - p,
              surface,
            );
            final Color backing = _compositeOver(scrim, backdropLayer);

            // Foregrounds read off the rendered tree (not hardcoded).
            final Color titleFg = _defaultTextStyleColor(
              tester,
              find.text('STARRY'),
            );
            final Color subFg = _defaultTextStyleColor(
              tester,
              find.text('header'),
            );
            final Color flatLeftFg = _iconThemeColor(
              tester,
              find.byIcon(Icons.favorite),
            );
            final Color flatRightFg = _iconThemeColor(
              tester,
              find.byIcon(Icons.star),
            );
            // Elevated glyphs read off the tree; their backing is the opaque
            // surface shell (which paints over the scrim locally).
            final Color elevatedBackGlyph = _iconThemeColor(
              tester,
              find.byIcon(Icons.arrow_back_ios_new),
            );
            final Color elevatedAddGlyph = _iconThemeColor(
              tester,
              find.byIcon(Icons.add),
            );

            // Text: WCAG AA 4.5:1. Icons / UI glyphs: 3:1.
            expect(
              _contrast(titleFg, backing),
              greaterThanOrEqualTo(4.5),
              reason: 'title p=$p ($label)',
            );
            expect(
              _contrast(subFg, backing),
              greaterThanOrEqualTo(4.5),
              reason: 'subtitle p=$p ($label)',
            );
            expect(
              _contrast(flatLeftFg, backing),
              greaterThanOrEqualTo(3.0),
              reason: 'flat-left p=$p ($label)',
            );
            expect(
              _contrast(flatRightFg, backing),
              greaterThanOrEqualTo(3.0),
              reason: 'flat-right p=$p ($label)',
            );
            expect(
              _contrast(elevatedBackGlyph, surface),
              greaterThanOrEqualTo(3.0),
              reason: 'elevated-back p=$p ($label)',
            );
            expect(
              _contrast(elevatedAddGlyph, surface),
              greaterThanOrEqualTo(3.0),
              reason: 'elevated-add p=$p ($label)',
            );
          }
        },
      );
    }

    // Non-zero safe-area inset must not break the contrast guarantee either.
    testWidgets(
      'flat chrome holds contrast with a non-zero top safe-area inset',
      (tester) async {
        final controller = await _pumpExpandedSliver(
          tester,
          theme: AppTheme.light(),
          backdrop: const Color(0xFF0F0F16),
          expandedFg: null,
          topSafeInset: 24,
          rightActions: const <StarryTopBarActionItem>[
            StarryTopBarActionItem(icon: Icon(Icons.add), tooltip: 'Elevated'),
          ],
        );
        final t = _tokens(tester, find.text('STARRY'));
        final Color surface = t.semantic.surface;
        final Color scrim = t.semantic.mediaOverlayEnd;

        for (final double p in <double>[0, 0.5, 1]) {
          await _seek(tester, controller, _kCollapseTravel * p);
          final Color backdropLayer = _compositeWithAlpha(
            const Color(0xFF0F0F16),
            1 - p,
            surface,
          );
          final Color backing = _compositeOver(scrim, backdropLayer);
          final Color titleFg = _defaultTextStyleColor(
            tester,
            find.text('STARRY'),
          );
          expect(
            _contrast(titleFg, backing),
            greaterThanOrEqualTo(4.5),
            reason: 'title p=$p',
          );
          final Color addGlyph = _iconThemeColor(
            tester,
            find.byIcon(Icons.add),
          );
          expect(
            _contrast(addGlyph, surface),
            greaterThanOrEqualTo(3.0),
            reason: 'elevated-add p=$p',
          );
        }
      },
    );

    // A caller-supplied raw foreground is HELD CONSTANT across the scroll
    // interval (no lockstep lerp through the mid-grey midpoint). The component
    // guarantees contrast only for the semantic `onMedia` path; an arbitrary raw
    // colour is the caller's responsibility.
    testWidgets('raw expandedForegroundColor is held constant, not lerped', (
      tester,
    ) async {
      const rawFg = Color(0xFFFFFFFF);
      final controller = await _pumpExpandedSliver(
        tester,
        theme: AppTheme.light(),
        backdrop: const Color(0xFF0F0F16),
        expandedFg: rawFg,
      );

      Future<Color> titleAt(double p) async {
        await _seek(tester, controller, _kCollapseTravel * p);
        return _defaultTextStyleColor(tester, find.text('STARRY'));
      }

      expect(await titleAt(0), rawFg);
      expect(await titleAt(0.25), rawFg);
      expect(await titleAt(0.5), rawFg);
      expect(await titleAt(0.75), rawFg);
      expect(await titleAt(1), rawFg);
    });

    // Elevated actions own an opaque surface shell: their glyph must pair with
    // that shell (token textPrimary), NOT adopt the overlay foreground. The old
    // code rendered a white glyph on a white surface shell (1:1).
    testWidgets(
      'elevated glyph pairs with its surface shell, never the overlay foreground',
      (tester) async {
        const customColor = Color(0xFF00FF00);
        const rawFg = Color(0xFF3355AA);
        await _pumpExpandedSliver(
          tester,
          theme: AppTheme.light(),
          backdrop: const Color(0xFF0F0F16),
          expandedFg: rawFg,
          rightActions: const <StarryTopBarActionItem>[
            StarryTopBarActionItem(icon: Icon(Icons.add), tooltip: 'Add'),
            StarryTopBarActionItem.custom(
              child: Icon(Icons.favorite, color: customColor),
            ),
          ],
        );
        final t = _tokens(tester, find.text('STARRY'));

        // Elevated glyph = token textPrimary (pairs with the surface shell),
        // NOT the overlay raw colour.
        expect(
          _iconThemeColor(tester, find.byIcon(Icons.add)),
          t.semantic.textPrimary,
        );
        expect(
          _iconThemeColor(tester, find.byIcon(Icons.add)),
          isNot(equals(rawFg)),
        );
        // Custom child keeps its own explicit colour.
        expect(_iconOwnColor(tester, find.byIcon(Icons.favorite)), customColor);

        // The elevated action's own surface shell fill is the token surface.
        final AnimatedContainer shell = tester.widget<AnimatedContainer>(
          find.descendant(
            of: find.byType(StarryRoundIconShell).first,
            matching: find.byType(AnimatedContainer),
          ),
        );
        final ShapeDecoration deco = shell.decoration! as ShapeDecoration;
        expect(deco.color, t.semantic.surface);
        expect(deco.color, isNot(equals(rawFg)));

        // And the elevated glyph actually contrasts with its shell.
        expect(
          _contrast(
            _iconThemeColor(tester, find.byIcon(Icons.add)),
            deco.color!,
          ),
          greaterThanOrEqualTo(3.0),
        );
      },
    );

    // Default-regression: with NO expandedBackground at all (the plain pinned
    // bar hosts actually use), the chrome stays on token colours regardless of
    // scroll.
    for (final (String label, ThemeData theme) in <(String, ThemeData)>[
      ('light', AppTheme.light()),
      ('dark', AppTheme.dark()),
    ]) {
      testWidgets(
        'plain pinned bar keeps token chrome with no expanded backdrop ($label)',
        (tester) async {
          final controller = await _pumpExpandedSliver(
            tester,
            theme: theme,
            backdrop: null,
            expandedFg: null,
            rightActions: const <StarryTopBarActionItem>[
              StarryTopBarActionItem(icon: Icon(Icons.add), tooltip: 'Add'),
            ],
          );
          final t = _tokens(tester, find.text('STARRY'));
          expect(
            _defaultTextStyleColor(tester, find.text('STARRY')),
            t.semantic.textSecondary,
          );
          expect(
            _iconThemeColor(tester, find.byIcon(Icons.add)),
            t.semantic.textPrimary,
          );
          await _seek(tester, controller, _kCollapseTravel * 0.5);
          expect(
            _defaultTextStyleColor(tester, find.text('STARRY')),
            t.semantic.textSecondary,
          );
          expect(
            _iconThemeColor(tester, find.byIcon(Icons.add)),
            t.semantic.textPrimary,
          );
          await _seek(tester, controller, _kCollapseTravel);
          expect(
            _defaultTextStyleColor(tester, find.text('STARRY')),
            t.semantic.textSecondary,
          );
          expect(
            _iconThemeColor(tester, find.byIcon(Icons.add)),
            t.semantic.textPrimary,
          );
        },
      );
    }
    testWidgets('subtitle text is rendered when supplied', (tester) async {
      await tester.pumpWidget(
        sliverHost(
          const StarrySliverPageTopBar(
            titleText: '收藏夹',
            subtitleText: '128 个项目',
          ),
        ),
      );
      expect(find.text('128 个项目'), findsOneWidget);
    });

    // Pushes the sliver page onto a second route so `Navigator.canPop()` is
    // true — the precondition for the built-in back affordance to appear.
    Future<void> pumpPoppableSliver(
      WidgetTester tester,
      StarrySliverPageTopBar bar,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => Scaffold(
                        body: CustomScrollView(
                          slivers: <Widget>[
                            bar,
                            SliverList.builder(
                              itemCount: 20,
                              itemBuilder: (context, index) =>
                                  ListTile(title: Text('row $index')),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('showDefaultBack injects the back arrow when canPop', (
      tester,
    ) async {
      await pumpPoppableSliver(
        tester,
        const StarrySliverPageTopBar(
          titleText: 'Detail',
          showDefaultBack: true,
        ),
      );
      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
    });

    testWidgets('showDefaultBack injects nothing at a non-poppable root', (
      tester,
    ) async {
      await tester.pumpWidget(
        sliverHost(
          const StarrySliverPageTopBar(
            titleText: 'Home',
            showDefaultBack: true,
          ),
        ),
      );
      expect(find.byIcon(Icons.arrow_back_ios_new), findsNothing);
    });

    testWidgets('explicit leading overrides showDefaultBack', (tester) async {
      await pumpPoppableSliver(
        tester,
        const StarrySliverPageTopBar(
          titleText: 'Detail',
          showDefaultBack: true,
          leading: Icon(Icons.close),
        ),
      );
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new), findsNothing);
    });

    testWidgets('Widgetbook directories expose StarrySliverPageTopBar', (
      tester,
    ) async {
      final root = widgetbook_directories.directories;
      expect(
        root.any(
          (node) => _widgetbookTreeContainsName(node, 'StarrySliverPageTopBar'),
        ),
        isTrue,
      );
    });
  });
}
