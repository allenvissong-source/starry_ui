import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

const _labels = StarryWindowControlLabels(
  minimize: 'Minimize',
  maximize: 'Maximize',
  restore: 'Restore',
  close: 'Close window',
);

Widget _host({
  required StarryDesktopPlatform platform,
  StarryWindowVisualState visualState = StarryWindowVisualState.normal,
  bool isFocused = true,
  bool disableAnimations = false,
  VoidCallback? onMinimize,
  VoidCallback? onToggleMaximize,
  VoidCallback? onClose,
}) {
  final Widget body = StarryDesktopWindowFrame(
    platform: platform,
    visualState: visualState,
    isFocused: isFocused,
    labels: _labels,
    onMinimize: onMinimize ?? () {},
    onToggleMaximize: onToggleMaximize ?? () {},
    onClose: onClose ?? () {},
    dragAreaBuilder: (context, child) => child,
    title: const Text('Starry'),
    child: const SizedBox.expand(key: ValueKey<String>('content')),
  );
  final Widget frame;
  if (disableAnimations) {
    frame = Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: body,
      ),
    );
  } else {
    frame = body;
  }
  return MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: frame),
  );
}

/// Mirrors production wiring: the frame is installed through
/// `MaterialApp.builder`, which mounts it *above* the navigator, so the frame
/// cannot borrow the navigator's overlay.
Widget _appLevelHost({required StarryDesktopPlatform platform, Widget? body}) {
  return MaterialApp(
    theme: AppTheme.light(),
    builder: (context, child) => StarryDesktopWindowFrame(
      platform: platform,
      visualState: StarryWindowVisualState.normal,
      isFocused: true,
      labels: _labels,
      onMinimize: () {},
      onToggleMaximize: () {},
      onClose: () {},
      dragAreaBuilder: (context, child) => child,
      title: const Text('Starry'),
      child: child ?? const SizedBox.shrink(),
    ),
    home: Scaffold(body: body ?? const SizedBox.shrink()),
  );
}

void main() {
  testWidgets('Windows controls are right aligned and ordered', (tester) async {
    await tester.pumpWidget(_host(platform: StarryDesktopPlatform.windows));

    final minimize = tester.getCenter(
      find.byKey(StarryDesktopWindowFrame.minimizeKey),
    );
    final maximize = tester.getCenter(
      find.byKey(StarryDesktopWindowFrame.maximizeKey),
    );
    final close = tester.getCenter(
      find.byKey(StarryDesktopWindowFrame.closeKey),
    );

    expect(minimize.dx, lessThan(maximize.dx));
    expect(maximize.dx, lessThan(close.dx));
    expect(close.dx, greaterThan(700));
  });

  testWidgets('macOS controls are left aligned and ordered', (tester) async {
    await tester.pumpWidget(_host(platform: StarryDesktopPlatform.macOS));

    final close = tester.getCenter(
      find.byKey(StarryDesktopWindowFrame.closeKey),
    );
    final minimize = tester.getCenter(
      find.byKey(StarryDesktopWindowFrame.minimizeKey),
    );
    final maximize = tester.getCenter(
      find.byKey(StarryDesktopWindowFrame.maximizeKey),
    );

    expect(close.dx, lessThan(minimize.dx));
    expect(minimize.dx, lessThan(maximize.dx));
    expect(close.dx, lessThan(100));
  });

  testWidgets('normal frame sits flush to the window with a visible border', (
    tester,
  ) async {
    await tester.pumpWidget(_host(platform: StarryDesktopPlatform.windows));

    final frame = tester.widget<Container>(
      find.byKey(StarryDesktopWindowFrame.frameKey),
    );
    final decoration = frame.decoration! as BoxDecoration;
    final foreground = frame.foregroundDecoration! as BoxDecoration;

    expect(decoration.borderRadius, isNotNull);
    // The border must live in the foreground decoration. In the background it
    // is painted over by the frame's own clipped `ColoredBox` fill and never
    // reaches the screen.
    expect(decoration.border, isNull);
    expect(foreground.border, isNotNull);
    expect(foreground.borderRadius, decoration.borderRadius);

    // A shadow cannot render against a transparent window background once the
    // frame is flush with the window bounds, so it must not be requested.
    expect(decoration.boxShadow, isNull);

    // No outer gutter: any padding here would expose the transparent window
    // background as a ring of desktop around the app.
    expect(
      find.ancestor(
        of: find.byKey(StarryDesktopWindowFrame.frameKey),
        matching: find.byType(Padding),
      ),
      findsNothing,
    );
  });

  testWidgets('normal frame fills the whole window surface', (tester) async {
    await tester.pumpWidget(_host(platform: StarryDesktopPlatform.windows));

    final frameRect = tester.getRect(
      find.byKey(StarryDesktopWindowFrame.frameKey),
    );

    expect(frameRect.topLeft, Offset.zero);
    expect(
      frameRect.size,
      tester.view.physicalSize / tester.view.devicePixelRatio,
    );
  });

  testWidgets('frame corner radius never exceeds the OS corner rounding', (
    tester,
  ) async {
    await tester.pumpWidget(_host(platform: StarryDesktopPlatform.windows));

    final frame = tester.widget<Container>(
      find.byKey(StarryDesktopWindowFrame.frameKey),
    );
    final radius =
        (frame.decoration! as BoxDecoration).borderRadius! as BorderRadius;

    // Windows 11 rounds window corners at roughly 8dp. A larger radius would
    // cut a tighter arc inside the compositor's own, exposing the transparent
    // window background as a nick at each corner.
    expect(radius.topLeft.x, lessThanOrEqualTo(8));
    expect(radius.topLeft.x, greaterThan(0));
  });

  testWidgets('content area is inset on all four sides by the surround', (
    tester,
  ) async {
    await tester.pumpWidget(_host(platform: StarryDesktopPlatform.windows));

    final frameRect = tester.getRect(
      find.byKey(StarryDesktopWindowFrame.frameKey),
    );
    final contentRect = tester.getRect(
      find.byKey(StarryDesktopWindowFrame.contentKey),
    );

    // Left / right / bottom share one inset; the top is deeper because the
    // control strip belongs to the surround, above the content.
    expect(contentRect.left - frameRect.left, 8);
    expect(frameRect.right - contentRect.right, 8);
    expect(frameRect.bottom - contentRect.bottom, 8);
    expect(contentRect.top - frameRect.top, greaterThan(8));
  });

  testWidgets('content sits below the window controls, never beside them', (
    tester,
  ) async {
    await tester.pumpWidget(_host(platform: StarryDesktopPlatform.windows));

    final contentTop = tester
        .getRect(find.byKey(StarryDesktopWindowFrame.contentKey))
        .top;

    for (final key in <Key>[
      StarryDesktopWindowFrame.minimizeKey,
      StarryDesktopWindowFrame.maximizeKey,
      StarryDesktopWindowFrame.closeKey,
    ]) {
      expect(
        tester.getRect(find.byKey(key)).bottom,
        lessThanOrEqualTo(contentTop),
      );
    }
  });

  testWidgets('content area carries its own smaller corner radius', (
    tester,
  ) async {
    await tester.pumpWidget(_host(platform: StarryDesktopPlatform.windows));

    final content = tester.widget<DecoratedBox>(
      find.byKey(StarryDesktopWindowFrame.contentKey),
    );
    final frame = tester.widget<Container>(
      find.byKey(StarryDesktopWindowFrame.frameKey),
    );
    final contentRadius =
        (content.decoration as BoxDecoration).borderRadius! as BorderRadius;
    final frameRadius =
        (frame.decoration! as BoxDecoration).borderRadius! as BorderRadius;

    expect(contentRadius.topLeft.x, greaterThan(0));
    expect(contentRadius.topLeft.x, lessThan(frameRadius.topLeft.x));
  });

  testWidgets('title strip paints no fill or divider over the surround', (
    tester,
  ) async {
    await tester.pumpWidget(_host(platform: StarryDesktopPlatform.windows));

    // A filled strip or a bottom rule would visually split the continuous
    // surround, which is exactly what this frame must avoid.
    expect(
      find.descendant(
        of: find.byKey(StarryDesktopWindowFrame.titleBarKey),
        matching: find.byType(ColoredBox),
      ),
      findsNothing,
    );
  });

  testWidgets('maximized frame removes outer chrome but keeps title bar', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        platform: StarryDesktopPlatform.windows,
        visualState: StarryWindowVisualState.maximized,
      ),
    );

    final frame = tester.widget<Container>(
      find.byKey(StarryDesktopWindowFrame.frameKey),
    );
    final decoration = frame.decoration! as BoxDecoration;

    expect(decoration.border, isNull);
    expect(frame.foregroundDecoration, isNull);
    expect(decoration.boxShadow, isNull);
    expect(decoration.borderRadius, BorderRadius.zero);
    expect(
      find.ancestor(
        of: find.byKey(StarryDesktopWindowFrame.frameKey),
        matching: find.byType(Padding),
      ),
      findsNothing,
    );
    expect(find.byKey(StarryDesktopWindowFrame.titleBarKey), findsOneWidget);
  });

  testWidgets('fullscreen exposes content without frame or title bar', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        platform: StarryDesktopPlatform.windows,
        visualState: StarryWindowVisualState.fullscreen,
      ),
    );

    expect(find.byKey(const ValueKey<String>('content')), findsOneWidget);
    expect(find.byKey(StarryDesktopWindowFrame.frameKey), findsNothing);
    expect(find.byKey(StarryDesktopWindowFrame.titleBarKey), findsNothing);
  });

  testWidgets('controls provide 48dp targets and invoke callbacks once', (
    tester,
  ) async {
    var minimized = 0;
    var toggled = 0;
    var closed = 0;
    await tester.pumpWidget(
      _host(
        platform: StarryDesktopPlatform.windows,
        onMinimize: () => minimized++,
        onToggleMaximize: () => toggled++,
        onClose: () => closed++,
      ),
    );

    for (final key in <Key>[
      StarryDesktopWindowFrame.minimizeKey,
      StarryDesktopWindowFrame.maximizeKey,
      StarryDesktopWindowFrame.closeKey,
    ]) {
      expect(tester.getSize(find.byKey(key)), const Size.square(48));
      await tester.tap(find.byKey(key));
      await tester.pump();
    }

    expect(minimized, 1);
    expect(toggled, 1);
    expect(closed, 1);
  });

  testWidgets('maximized control announces restore', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(
        platform: StarryDesktopPlatform.macOS,
        visualState: StarryWindowVisualState.maximized,
      ),
    );

    expect(find.bySemanticsLabel('Restore'), findsOneWidget);
    expect(find.bySemanticsLabel('Maximize'), findsNothing);
    expect(find.bySemanticsLabel('Minimize'), findsOneWidget);
    expect(find.bySemanticsLabel('Close window'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('control tooltips work when mounted above the app navigator', (
    tester,
  ) async {
    await tester.pumpWidget(
      _appLevelHost(platform: StarryDesktopPlatform.windows),
    );
    expect(tester.takeException(), isNull);

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(gesture.removePointer);
    await gesture.addPointer(location: Offset.zero);
    await gesture.moveTo(
      tester.getCenter(find.byKey(StarryDesktopWindowFrame.closeKey)),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Close window'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('app-level frame preserves text input inherited widgets', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _appLevelHost(
        platform: StarryDesktopPlatform.windows,
        body: TextField(
          key: const ValueKey<String>('frame-text-field'),
          controller: controller,
        ),
      ),
    );

    final field = find.byKey(const ValueKey<String>('frame-text-field'));
    await tester.tap(field);
    await tester.pump();

    expect(tester.takeException(), isNull);
    await tester.enterText(field, 'starry');
    expect(controller.text, 'starry');
  });

  testWidgets('frame overlay stays hidden from the application subtree', (
    tester,
  ) async {
    late OverlayState appRootOverlay;
    late OverlayState frameOverlay;

    await tester.pumpWidget(
      _appLevelHost(
        platform: StarryDesktopPlatform.windows,
        body: Builder(
          builder: (context) {
            appRootOverlay = Overlay.of(context, rootOverlay: true);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    frameOverlay = tester.state<OverlayState>(
      find
          .ancestor(
            of: find.byKey(StarryDesktopWindowFrame.closeKey),
            matching: find.byType(Overlay),
          )
          .first,
    );

    // The app keeps resolving its own root overlay, so toasts and dialogs are
    // unaffected by the frame's private overlay.
    expect(appRootOverlay, isNot(same(frameOverlay)));
    expect(
      find.descendant(
        of: find.byWidget(appRootOverlay.widget),
        matching: find.byKey(StarryDesktopWindowFrame.closeKey),
      ),
      findsNothing,
    );
  });

  testWidgets('pressed windows control paints a token-driven feedback layer', (
    tester,
  ) async {
    await tester.pumpWidget(_host(platform: StarryDesktopPlatform.windows));
    final finder = find.byKey(StarryDesktopWindowFrame.closeKey);
    final inkWell = tester.widget<InkWell>(
      find.descendant(of: finder, matching: find.byType(InkWell)),
    );
    final tokens = Theme.of(tester.element(finder)).extension<StarryTokens>()!;

    // At rest the InkWell paints nothing of its own.
    expect(
      inkWell.overlayColor!.resolve(const <WidgetState>{}),
      Colors.transparent,
    );
    // Pressed stacks the MD3 pressed step over the semantic foreground.
    expect(
      inkWell.overlayColor!.resolve(const <WidgetState>{WidgetState.pressed}),
      tokens.semantic.textPrimary.withValues(
        alpha: tokens.opacity.statePressed,
      ),
    );
    // Hover/focus stay owned by the manual opaque fill, so they must not gain
    // an InkWell overlay of their own.
    expect(
      inkWell.overlayColor!.resolve(const <WidgetState>{WidgetState.hovered}),
      Colors.transparent,
    );

    // A real press must not throw while the feedback layer paints.
    final gesture = await tester.press(finder);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('pressed macOS control paints the same feedback layer', (
    tester,
  ) async {
    await tester.pumpWidget(_host(platform: StarryDesktopPlatform.macOS));
    final finder = find.byKey(StarryDesktopWindowFrame.closeKey);
    final inkWell = tester.widget<InkWell>(
      find.descendant(of: finder, matching: find.byType(InkWell)),
    );
    final tokens = Theme.of(tester.element(finder)).extension<StarryTokens>()!;

    expect(
      inkWell.overlayColor!.resolve(const <WidgetState>{WidgetState.pressed}),
      tokens.semantic.textPrimary.withValues(
        alpha: tokens.opacity.statePressed,
      ),
    );

    final gesture = await tester.press(finder);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'macOS control reveals its glyph immediately under reduced motion',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 160));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        _host(platform: StarryDesktopPlatform.macOS, disableAnimations: true),
      );

      final button = find.byKey(StarryDesktopWindowFrame.closeKey);
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(gesture.removePointer);
      // Start outside the control so hover flips on, not off.
      await gesture.addPointer(
        location: tester.getTopLeft(button) - const Offset(24, 24),
      );
      await gesture.moveTo(tester.getCenter(button));
      // A single frame must already be at the resting opacity: with animations
      // disabled the 150ms fade must not interpolate at all.
      await tester.pump();

      final opacity = tester.widget<AnimatedOpacity>(
        find.descendant(of: button, matching: find.byType(AnimatedOpacity)),
      );
      expect(opacity.opacity, 1.0);
    },
  );
}
