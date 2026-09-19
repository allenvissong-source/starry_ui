import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/main.directories.g.dart' as widgetbook_directories;
import 'package:starry_ui/starry_ui.dart';
import 'package:widgetbook/widgetbook.dart';

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
