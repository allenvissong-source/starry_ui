import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

StarryActionItem _leaf(String id) =>
    StarryActionItem(id: id, title: 'Item $id', onActivate: () {});

Widget _host(Widget trigger) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: Builder(builder: (context) => trigger)),
  );
}

Future<Rect> _openSurface(
  WidgetTester tester, {
  required List<StarryActionItem> items,
  required ValueChanged<StarryActionItem> onSelected,
  FocusNode? triggerNode,
  String? initialSectionId,
}) async {
  Rect? triggerRect;
  await tester.pumpWidget(
    _host(
      Stack(
        children: [
          Positioned(
            left: 100,
            top: 100,
            child: Focus(
              focusNode: triggerNode,
              child: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      final box = context.findRenderObject()! as RenderBox;
                      triggerRect = box.localToGlobal(Offset.zero) & box.size;
                      StarryActionSurface.show(
                        context: context,
                        items: items,
                        anchorRect: triggerRect!,
                        onItemSelected: onSelected,
                        title: 'Actions',
                        initialSectionId: initialSectionId,
                      );
                    },
                    child: const Text('trigger'),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    ),
  );
  await tester.pumpAndSettle();
  if (triggerNode != null) {
    triggerNode.requestFocus();
    await tester.pump();
  }
  await tester.tap(find.text('trigger'));
  await tester.pumpAndSettle();
  return triggerRect!;
}

void main() {
  group('anchored overlay positioning', () {
    testWidgets('places the panel below the trigger when lower space fits', (
      tester,
    ) async {
      final rect = await _openSurface(
        tester,
        items: [_leaf('a'), _leaf('b')],
        onSelected: (_) {},
      );

      final panelTop = tester.getTopLeft(find.byType(StarryActionList));
      expect(panelTop.dy, greaterThanOrEqualTo(rect.bottom + 7));
    });

    testWidgets('flips the panel above the trigger near the viewport bottom', (
      tester,
    ) async {
      // Move the trigger to y=520 by overriding the host layout.
      Rect? triggerRect;
      await tester.pumpWidget(
        _host(
          Stack(
            children: [
              Positioned(
                top: 520,
                left: 100,
                child: Builder(
                  builder: (context) {
                    return ElevatedButton(
                      onPressed: () {
                        final box = context.findRenderObject()! as RenderBox;
                        triggerRect = box.localToGlobal(Offset.zero) & box.size;
                        StarryActionSurface.show(
                          context: context,
                          items: [_leaf('a'), _leaf('b'), _leaf('c')],
                          anchorRect: triggerRect!,
                          onItemSelected: (_) {},
                        );
                      },
                      child: const Text('trigger'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('trigger'));
      await tester.pumpAndSettle();

      final panelBottom = tester.getBottomRight(find.byType(StarryActionList));
      expect(panelBottom.dy, lessThanOrEqualTo(triggerRect!.top + 1));
    });

    testWidgets('clamps the panel horizontally inside the viewport', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          Stack(
            children: [
              Positioned(
                left: 0,
                top: 100,
                child: Builder(
                  builder: (context) {
                    return ElevatedButton(
                      onPressed: () => StarryActionSurface.show(
                        context: context,
                        items: [_leaf('a')],
                        anchorRect: const Rect.fromLTRB(0, 100, 48, 148),
                        onItemSelected: (_) {},
                      ),
                      child: const Text('trigger'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('trigger'));
      await tester.pumpAndSettle();

      final panelTop = tester.getTopLeft(find.byType(StarryActionList));
      expect(panelTop.dx, greaterThanOrEqualTo(7));
    });
  });

  group('focus and close', () {
    testWidgets(
      'focus enters the list; Esc closes and returns focus to the trigger',
      (tester) async {
        final triggerNode = FocusNode();
        addTearDown(triggerNode.dispose);
        await _openSurface(
          tester,
          items: [_leaf('a')],
          onSelected: (_) {},
          triggerNode: triggerNode,
        );

        // Focus moved off the trigger into the surface.
        expect(FocusManager.instance.primaryFocus, isNot(triggerNode));
        expect(find.byType(StarryActionList), findsOneWidget);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();

        expect(find.byType(StarryActionList), findsNothing);
        expect(FocusManager.instance.primaryFocus, triggerNode);
      },
    );

    testWidgets('tapping the scrim closes without selecting an item', (
      tester,
    ) async {
      var selected = 0;
      await _openSurface(
        tester,
        items: [_leaf('a'), _leaf('b')],
        onSelected: (_) => selected++,
      );

      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();

      expect(find.byType(StarryActionList), findsNothing);
      expect(selected, 0);
    });
  });

  group('sub-pages within the same surface', () {
    testWidgets('children open in-panel; back and Esc navigate; leaf closes', (
      tester,
    ) async {
      final selected = <String>[];
      final items = [
        StarryActionItem(
          id: 'runtime',
          title: 'Runtime',
          onActivate: () {},
          children: [
            StarryActionItem(
              id: 'model-a',
              title: 'Model A',
              onActivate: () {},
            ),
          ],
        ),
      ];
      await _openSurface(
        tester,
        items: items,
        onSelected: (item) => selected.add(item.id),
      );

      await tester.tap(find.text('Runtime'));
      await tester.pumpAndSettle();
      expect(find.text('Model A'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // Esc pops the sub-page instead of closing the surface.
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Model A'), findsNothing);
      expect(find.text('Runtime'), findsOneWidget);
      expect(find.byType(StarryActionList), findsOneWidget);

      // Second Esc closes the surface.
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(StarryActionList), findsNothing);
      expect(selected, isEmpty);

      // Reopen and activate a leaf through the sub-page.
      await tester.tap(find.text('trigger'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Runtime'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Model A'));
      await tester.pumpAndSettle();
      expect(selected, ['model-a']);
      expect(find.byType(StarryActionList), findsNothing);
    });

    testWidgets('initialSectionId opens directly at the child sub-page', (
      tester,
    ) async {
      final items = [
        StarryActionItem(
          id: 'runtime',
          title: 'Runtime',
          children: [
            StarryActionItem(
              id: 'model-a',
              title: 'Model A',
              onActivate: () {},
            ),
          ],
        ),
        StarryActionItem(id: 'other', title: 'Other'),
      ];
      await _openSurface(
        tester,
        items: items,
        onSelected: (_) {},
        initialSectionId: 'runtime',
      );

      // Already on the child page: leaf visible, sibling root row hidden,
      // back shown. The header repeats the parent title, so only the sibling
      // proves the root list is not showing.
      expect(find.text('Model A'), findsOneWidget);
      expect(find.text('Other'), findsNothing);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // Back returns to the root list.
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('Model A'), findsNothing);
      expect(find.text('Other'), findsOneWidget);
    });

    testWidgets('unknown initialSectionId falls back to the root list', (
      tester,
    ) async {
      final items = [
        StarryActionItem(
          id: 'runtime',
          title: 'Runtime',
          children: [StarryActionItem(id: 'model-a', title: 'Model A')],
        ),
      ];
      await _openSurface(
        tester,
        items: items,
        onSelected: (_) {},
        initialSectionId: 'missing',
      );
      expect(find.text('Model A'), findsNothing);
      expect(find.text('Runtime'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets('compact layout renders the same flow as a bottom sheet', (
      tester,
    ) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      final selected = <String>[];
      final items = [
        StarryActionItem(
          id: 'runtime',
          title: 'Runtime',
          onActivate: () {},
          children: [
            StarryActionItem(
              id: 'model-a',
              title: 'Model A',
              onActivate: () {},
            ),
          ],
        ),
      ];
      await _openSurface(
        tester,
        items: items,
        onSelected: (item) => selected.add(item.id),
      );

      // Bottom sheet is mounted; sub-page opens inside it.
      expect(find.text('Runtime'), findsOneWidget);
      await tester.tap(find.text('Runtime'));
      await tester.pumpAndSettle();
      expect(find.text('Model A'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // Esc pops sub-page; Esc again closes the sheet.
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Model A'), findsNothing);
      expect(find.text('Runtime'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(StarryActionList), findsNothing);
    });

    testWidgets('bottom sheet uses top-rounded corners from the radius token', (
      tester,
    ) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await _openSurface(tester, items: [_leaf('a')], onSelected: (_) {});

      // The bottom sheet Material carries the shape; find it by walking up
      // from the panel.
      final panelContext = tester.element(find.byType(StarryActionList));
      Material? sheetMaterial;
      panelContext.visitAncestorElements((el) {
        if (el.widget is Material &&
            (el.widget as Material).shape is RoundedRectangleBorder) {
          sheetMaterial = el.widget as Material;
          return false;
        }
        return true;
      });
      expect(sheetMaterial, isNotNull);
      final shape = sheetMaterial!.shape as RoundedRectangleBorder;
      final radius = (shape.borderRadius as BorderRadius).topLeft.x;
      // t.radius.lg == 16.
      expect(radius, 16);
    });
  });

  group('primaryActions', () {
    testWidgets(
      'renders horizontal primary actions above the list and fires on tap',
      (tester) async {
        final selected = <String>[];
        await tester.pumpWidget(
          _host(
            Stack(
              children: [
                Positioned(
                  left: 100,
                  top: 100,
                  child: Builder(
                    builder: (context) {
                      return ElevatedButton(
                        onPressed: () {
                          final box = context.findRenderObject()! as RenderBox;
                          StarryActionSurface.show(
                            context: context,
                            anchorRect:
                                box.localToGlobal(Offset.zero) & box.size,
                            items: [_leaf('a')],
                            primaryActions: [
                              StarryActionItem(
                                id: 'camera',
                                title: 'Camera',
                                leadingBuilder: (_) =>
                                    const Icon(Icons.camera_alt),
                              ),
                              StarryActionItem(
                                id: 'album',
                                title: 'Album',
                                leadingBuilder: (_) => const Icon(Icons.photo),
                              ),
                              StarryActionItem(
                                id: 'file',
                                title: 'File',
                                leadingBuilder: (_) =>
                                    const Icon(Icons.attach_file),
                              ),
                            ],
                            onItemSelected: (item) => selected.add(item.id),
                          );
                        },
                        child: const Text('trigger'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('trigger'));
        await tester.pumpAndSettle();

        expect(find.text('Camera'), findsOneWidget);
        expect(find.text('Album'), findsOneWidget);
        expect(find.text('File'), findsOneWidget);

        await tester.tap(find.text('Camera'));
        await tester.pumpAndSettle();
        expect(selected, ['camera']);
        // Surface closes after a primary action tap.
        expect(find.byType(StarryActionList), findsNothing);
      },
    );

    testWidgets('primary actions render in compact (bottom sheet) layout', (
      tester,
    ) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        _host(
          Stack(
            children: [
              Positioned(
                left: 100,
                top: 100,
                child: Builder(
                  builder: (context) {
                    return ElevatedButton(
                      onPressed: () {
                        final box = context.findRenderObject()! as RenderBox;
                        StarryActionSurface.show(
                          context: context,
                          anchorRect: box.localToGlobal(Offset.zero) & box.size,
                          items: [_leaf('a')],
                          primaryActions: [
                            StarryActionItem(
                              id: 'camera',
                              title: 'Camera',
                              leadingBuilder: (_) =>
                                  const Icon(Icons.camera_alt),
                            ),
                            StarryActionItem(
                              id: 'album',
                              title: 'Album',
                              leadingBuilder: (_) => const Icon(Icons.photo),
                            ),
                          ],
                          onItemSelected: (_) {},
                        );
                      },
                      child: const Text('trigger'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('trigger'));
      await tester.pumpAndSettle();

      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('Album'), findsOneWidget);
    });
  });

  group('showFilter', () {
    testWidgets('showFilter:false hides the root filter field', (tester) async {
      await tester.pumpWidget(
        _host(
          Stack(
            children: [
              Positioned(
                left: 100,
                top: 100,
                child: Builder(
                  builder: (context) {
                    return ElevatedButton(
                      onPressed: () {
                        final box = context.findRenderObject()! as RenderBox;
                        StarryActionSurface.show(
                          context: context,
                          anchorRect: box.localToGlobal(Offset.zero) & box.size,
                          items: [_leaf('a')],
                          showFilter: false,
                          onItemSelected: (_) {},
                        );
                      },
                      child: const Text('trigger'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('trigger'));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);
    });
  });

  group('anchor height limit', () {
    testWidgets(
      'panel height is clamped to the available space beside the trigger',
      (tester) async {
        // Put trigger near bottom so availableBelow is tiny; panel flips up.
        // Verify the panel does not extend below the trigger's bottom edge.
        Rect? triggerRect;
        await tester.pumpWidget(
          _host(
            Stack(
              children: [
                Positioned(
                  top: 560,
                  left: 100,
                  child: Builder(
                    builder: (context) {
                      return ElevatedButton(
                        onPressed: () {
                          final box = context.findRenderObject()! as RenderBox;
                          triggerRect =
                              box.localToGlobal(Offset.zero) & box.size;
                          StarryActionSurface.show(
                            context: context,
                            anchorRect: triggerRect!,
                            items: List.generate(30, (i) => _leaf('row-$i')),
                            onItemSelected: (_) {},
                          );
                        },
                        child: const Text('trigger'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('trigger'));
        await tester.pumpAndSettle();

        // Panel should be above the trigger (availableBelow too small).
        // Its bottom edge should be at or above the trigger's top edge.
        final panelBottom = tester.getBottomRight(
          find.byType(StarryActionList),
        );
        expect(panelBottom.dy, lessThanOrEqualTo(triggerRect!.top + 1));
      },
    );
  });

  group('externalFilterQuery', () {
    testWidgets('composer-driven query filters root list live without reopen', (
      tester,
    ) async {
      final query = ValueNotifier<String>('');
      addTearDown(query.dispose);
      final selected = <String>[];

      await tester.pumpWidget(
        _host(
          Stack(
            children: [
              Positioned(
                left: 100,
                top: 100,
                child: Builder(
                  builder: (context) {
                    return ElevatedButton(
                      onPressed: () {
                        final box = context.findRenderObject()! as RenderBox;
                        StarryActionSurface.show(
                          context: context,
                          anchorRect: box.localToGlobal(Offset.zero) & box.size,
                          items: [
                            StarryActionItem(
                              id: '/model',
                              title: 'Model',
                              onActivate: () => selected.add('/model'),
                            ),
                            StarryActionItem(
                              id: '/effort',
                              title: 'Effort',
                              onActivate: () => selected.add('/effort'),
                            ),
                            StarryActionItem(
                              id: '/new',
                              title: 'New chat',
                              onActivate: () => selected.add('/new'),
                            ),
                          ],
                          externalFilterQuery: query,
                          onItemSelected: (item) => selected.add(item.id),
                        );
                      },
                      child: const Text('trigger'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('trigger'));
      await tester.pumpAndSettle();

      // All three visible initially.
      expect(find.text('Model'), findsOneWidget);
      expect(find.text('Effort'), findsOneWidget);
      expect(find.text('New chat'), findsOneWidget);

      // Type '/mo' — should filter to only Model.
      query.value = '/mo';
      await tester.pumpAndSettle();
      expect(find.text('Model'), findsOneWidget);
      expect(find.text('Effort'), findsNothing);
      expect(find.text('New chat'), findsNothing);

      // Type '/ne' — filters to New chat.
      query.value = '/ne';
      await tester.pumpAndSettle();
      expect(find.text('Model'), findsNothing);
      expect(find.text('New chat'), findsOneWidget);

      // Empty query — shows all again.
      query.value = '/';
      await tester.pumpAndSettle();
      expect(find.text('Model'), findsOneWidget);
      expect(find.text('Effort'), findsOneWidget);
      expect(find.text('New chat'), findsOneWidget);
    });

    testWidgets(
      'external filter matches subtitle and keywords, not just id/title',
      (tester) async {
        final query = ValueNotifier<String>('');
        addTearDown(query.dispose);

        await tester.pumpWidget(
          _host(
            Stack(
              children: [
                Positioned(
                  left: 100,
                  top: 100,
                  child: Builder(
                    builder: (context) {
                      return ElevatedButton(
                        onPressed: () {
                          final box = context.findRenderObject()! as RenderBox;
                          StarryActionSurface.show(
                            context: context,
                            anchorRect:
                                box.localToGlobal(Offset.zero) & box.size,
                            items: const [
                              StarryActionItem(
                                id: '/skills',
                                title: 'Skills',
                                subtitle: 'Authorize and manage skills',
                                keywords: ['capability', 'plugin'],
                              ),
                              StarryActionItem(id: '/model', title: 'Model'),
                            ],
                            externalFilterQuery: query,
                            onItemSelected: (_) {},
                          );
                        },
                        child: const Text('trigger'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('trigger'));
        await tester.pumpAndSettle();

        // Subtitle term matches the skills row.
        query.value = '/authorize';
        await tester.pumpAndSettle();
        expect(find.text('Skills'), findsOneWidget);
        expect(find.text('Model'), findsNothing);

        // Keyword term matches too.
        query.value = 'plugin';
        await tester.pumpAndSettle();
        expect(find.text('Skills'), findsOneWidget);
        expect(find.text('Model'), findsNothing);
      },
    );
  });

  group('busy gating and per-open isolation', () {
    testWidgets(
      'a disabled (busy) row ignores tap and Enter; an enabled row still fires',
      (tester) async {
        final selected = <String>[];
        await _openSurface(
          tester,
          items: [
            StarryActionItem(
              id: '/compact',
              title: 'Compact',
              disabled: true,
              onActivate: () => selected.add('/compact'),
            ),
            StarryActionItem(
              id: '/new',
              title: 'New chat',
              onActivate: () => selected.add('/new'),
            ),
          ],
          onSelected: (item) => selected.add(item.id),
        );

        // Tapping the disabled busy row must not select it.
        await tester.tap(find.text('Compact'));
        await tester.pumpAndSettle();
        expect(selected, isEmpty);
        expect(find.byType(StarryActionList), findsOneWidget);

        // The enabled sibling remains active and closes on selection.
        await tester.tap(find.text('New chat'));
        await tester.pumpAndSettle();
        expect(selected, ['/new']);
        expect(find.byType(StarryActionList), findsNothing);
      },
    );

    testWidgets(
      'reopening the surface starts independent state; a prior callback never '
      'receives the later selection',
      (tester) async {
        final first = <String>[];
        final second = <String>[];

        // First open and select, surface closes.
        await _openSurface(
          tester,
          items: [_leaf('a')],
          onSelected: (item) => first.add(item.id),
        );
        await tester.tap(find.text('Item a'));
        await tester.pumpAndSettle();
        expect(first, ['a']);
        expect(find.byType(StarryActionList), findsNothing);

        // Second open with a separate callback: the first must not fire.
        await _openSurface(
          tester,
          items: [_leaf('b')],
          onSelected: (item) => second.add(item.id),
        );
        await tester.tap(find.text('Item b'));
        await tester.pumpAndSettle();
        expect(first, ['a'], reason: 'prior open keeps its own record');
        expect(second, ['b']);
      },
    );
  });

  group('anchor alignment and content shrinkwrap', () {
    testWidgets(
      'left-aligns the panel to the trigger and clamps it inside the right edge',
      (tester) async {
        // Default test viewport is 800x600; anchor near the right edge.
        await tester.pumpWidget(
          _host(
            Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 100,
                  child: Builder(
                    builder: (context) {
                      return ElevatedButton(
                        onPressed: () => StarryActionSurface.show(
                          context: context,
                          anchorRect: const Rect.fromLTRB(700, 100, 748, 148),
                          items: [_leaf('a'), _leaf('b')],
                          onItemSelected: (_) {},
                        ),
                        child: const Text('trigger'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('trigger'));
        await tester.pumpAndSettle();

        final panelTopLeft = tester.getTopLeft(find.byType(StarryActionList));
        final panelBottomRight = tester.getBottomRight(
          find.byType(StarryActionList),
        );
        final tokens = Theme.of(
          tester.element(find.byType(StarryActionList)),
        ).extension<StarryTokens>()!;
        // A ~320px panel cannot left-align to an x=700 trigger inside an 800px
        // viewport; production clamps the left edge so the right margin holds.
        // Reproduce that clamp from the measured width instead of asserting the
        // un-clamped anchor offset (which would be off-screen).
        final panelWidth = panelBottomRight.dx - panelTopLeft.dx;
        final maxLeft = 800 - tokens.spacing.s3 - panelWidth;
        final expectedLeft = 700.clamp(tokens.spacing.s3, maxLeft).toDouble();
        expect(panelBottomRight.dx, lessThanOrEqualTo(800 - tokens.spacing.s3));
        expect(panelTopLeft.dx, closeTo(expectedLeft, 2));
      },
    );

    testWidgets(
      'short content shrinks to its own height instead of forcing maxHeight',
      (tester) async {
        await tester.pumpWidget(
          _host(
            Stack(
              children: [
                Positioned(
                  left: 100,
                  top: 100,
                  child: Builder(
                    builder: (context) {
                      return ElevatedButton(
                        onPressed: () => StarryActionSurface.show(
                          context: context,
                          anchorRect: const Rect.fromLTRB(100, 100, 148, 148),
                          items: [_leaf('a'), _leaf('b')],
                          onItemSelected: (_) {},
                        ),
                        child: const Text('trigger'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('trigger'));
        await tester.pumpAndSettle();

        // The panel is no longer forced to the 70%-of-viewport maxHeight cap;
        // two short rows render at content height, well below that cap.
        final listSize = tester.getSize(find.byType(StarryActionList));
        expect(listSize.height, lessThan(300));
        expect(listSize.height, greaterThan(0));
      },
    );
  });

  group('single anchored surface', () {
    testWidgets(
      'opening a second panel dismisses the first; panels never stack',
      (tester) async {
        BuildContext? captured;
        await tester.pumpWidget(
          _host(
            Builder(
              builder: (context) {
                captured = context;
                return ElevatedButton(
                  onPressed: () => StarryActionSurface.show(
                    context: context,
                    anchorRect: const Rect.fromLTRB(100, 100, 148, 148),
                    items: [_leaf('root')],
                    onItemSelected: (_) {},
                  ),
                  child: const Text('first'),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('first'));
        await tester.pumpAndSettle();
        expect(find.text('Item root'), findsOneWidget);

        // Programmatic second show (API layer): the open root scrim would
        // swallow a raw button tap, so drive the registry replacement directly
        // instead of claiming a real UI tap through the scrim. The show Future
        // completes only on close, so do NOT await it here (that would deadlock
        // the test before pump/dismiss); capture it and await only after the
        // panel is dismissed.
        final childClosed = StarryActionSurface.show(
          context: captured!,
          anchorRect: const Rect.fromLTRB(300, 100, 348, 148),
          items: [_leaf('child')],
          onItemSelected: (_) {},
        );
        await tester.pumpAndSettle();
        // The prior root panel was removed; only the latest panel survives.
        expect(find.text('Item root'), findsNothing);
        expect(find.text('Item child'), findsOneWidget);
        expect(find.byType(StarryActionList), findsOneWidget);

        // Dismiss the child via its scrim, then drain its completion future.
        await tester.tapAt(const Offset(20, 20));
        await tester.pumpAndSettle();
        await childClosed;
      },
    );

    testWidgets(
      'closing the newer panel never revives the old; reopen keeps one panel',
      (tester) async {
        BuildContext? captured;
        await tester.pumpWidget(
          _host(
            Builder(
              builder: (context) {
                captured = context;
                return ElevatedButton(
                  onPressed: () => StarryActionSurface.show(
                    context: context,
                    anchorRect: const Rect.fromLTRB(100, 100, 148, 148),
                    items: [_leaf('root')],
                    onItemSelected: (_) {},
                  ),
                  child: const Text('first'),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('first'));
        await tester.pumpAndSettle();
        // Capture rather than await the show Future (it completes only on close;
        // awaiting here would deadlock before dismiss).
        final childClosed = StarryActionSurface.show(
          context: captured!,
          anchorRect: const Rect.fromLTRB(300, 100, 348, 148),
          items: [_leaf('child')],
          onItemSelected: (_) {},
        );
        await tester.pumpAndSettle();
        expect(find.text('Item child'), findsOneWidget);

        // Close only the current panel via its scrim; the old panel must not
        // reappear and no stale handle may remove a newer entry.
        await tester.tapAt(const Offset(20, 20));
        await tester.pumpAndSettle();
        expect(find.byType(StarryActionList), findsNothing);
        expect(find.text('Item root'), findsNothing);
        expect(find.text('Item child'), findsNothing);
        await childClosed;

        await tester.tap(find.text('first'));
        await tester.pumpAndSettle();
        expect(find.text('Item root'), findsOneWidget);
        expect(find.text('Item child'), findsNothing);
        expect(find.byType(StarryActionList), findsOneWidget);
      },
    );

    testWidgets(
      'nested non-zero-origin overlay positions panel below the real button '
      'from a true global anchor rect (no zero-origin assumption)',
      (tester) async {
        final nestedKey = GlobalKey<OverlayState>();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Theme(
                data: AppTheme.light(),
                child: Padding(
                  padding: const EdgeInsets.only(left: 100, top: 80),
                  child: SizedBox(
                    width: 500,
                    height: 400,
                    child: Overlay(
                      key: nestedKey,
                      initialEntries: [
                        OverlayEntry(
                          builder: (_) => Positioned(
                            left: 40,
                            top: 40,
                            width: 120,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () {},
                              child: const Text('anchor-btn'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final buttonBox =
            tester.renderObject(find.byType(ElevatedButton)) as RenderBox;
        final buttonRect =
            buttonBox.localToGlobal(Offset.zero) & buttonBox.size;

        // Fire-and-forget: show's Future completes only on close; awaiting it
        // here would deadlock the test before dismiss.
        final closed = StarryActionSurface.show(
          context: tester.element(find.byType(ElevatedButton)),
          anchorRect: buttonRect,
          items: [_leaf('root')],
          onItemSelected: (_) {},
        );
        await tester.pumpAndSettle();

        // Resolve the NESTED overlay through its own GlobalKey; the MaterialApp
        // root overlay would otherwise match and give the wrong origin.
        final overlayBox =
            nestedKey.currentState!.context.findRenderObject() as RenderBox;
        expect(overlayBox.localToGlobal(Offset.zero), isNot(Offset.zero));

        // The surface panel ROOT container (not the inner list with its own
        // padding) gives the true panel bounds.
        final panelRoot = find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration as BoxDecoration).boxShadow != null,
        );
        final panelBox = tester.renderObject(panelRoot.first) as RenderBox;
        final panelTop = panelBox.localToGlobal(Offset.zero).dy;
        final buttonBottom =
            buttonBox.localToGlobal(Offset.zero).dy + buttonBox.size.height;
        final tokens = Theme.of(
          tester.element(find.byType(StarryActionList)),
        ).extension<StarryTokens>()!;
        // Enough room below: panel top lands on button bottom + theme gap.
        expect(panelTop, closeTo(buttonBottom + tokens.spacing.s2, 1.0));
        // Panel is far smaller than the host viewport; no half-screen misplace.
        expect(panelBox.size.width, lessThan(800));
        expect(panelBox.size.height, lessThan(600));

        // Tap a real scrim point INSIDE the nested overlay (global 20,20 sits
        // outside the nested origin and would never hit its scrim).
        final scrimPoint = overlayBox.localToGlobal(const Offset(8, 8));
        await tester.tapAt(scrimPoint);
        await tester.pumpAndSettle();
        await closed;
      },
    );
  });

  group('live items listenable', () {
    testWidgets('refreshes nested children from their actual parent', (
      tester,
    ) async {
      List<StarryActionItem> tree(String leaf) => [
        StarryActionItem(
          id: 'root',
          title: 'Root',
          children: [
            StarryActionItem(
              id: 'nested',
              title: 'Nested',
              children: [StarryActionItem(id: leaf, title: leaf)],
            ),
          ],
        ),
      ];
      final notifier = ValueNotifier<List<StarryActionItem>>(tree('Old leaf'));
      addTearDown(notifier.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => StarryActionSurface.show(
                  context: context,
                  items: notifier.value,
                  anchorRect: const Rect.fromLTWH(120, 120, 80, 40),
                  onItemSelected: (_) {},
                  itemsListenable: notifier,
                ),
                child: const Text('trigger'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('trigger'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Root'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nested'));
      await tester.pumpAndSettle();
      notifier.value = tree('New leaf');
      await tester.pumpAndSettle();
      expect(find.text('Old leaf'), findsNothing);
      expect(find.text('New leaf'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
    });
    testWidgets('refreshes root and open sub-page in place without reopening', (
      tester,
    ) async {
      final notifier = ValueNotifier<List<StarryActionItem>>([
        StarryActionItem(id: 'r1', title: 'Root One'),
        StarryActionItem(
          id: 'sec',
          title: 'Section',
          children: [StarryActionItem(id: 'c1', title: 'Child One')],
        ),
      ]);
      addTearDown(notifier.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => StarryActionSurface.show(
                  context: context,
                  items: notifier.value,
                  anchorRect: const Rect.fromLTWH(120, 120, 80, 40),
                  onItemSelected: (_) {},
                  itemsListenable: notifier,
                ),
                child: const Text('trigger'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('trigger'));
      await tester.pumpAndSettle();

      expect(find.text('Root One'), findsOneWidget);
      expect(find.byType(StarryActionList), findsOneWidget);

      // Open the section sub-page; its children render from the initial list.
      await tester.tap(find.text('Section'));
      await tester.pumpAndSettle();
      expect(find.text('Child One'), findsOneWidget);

      // Live root refresh replaces root in place and re-resolves the open
      // sub-page children; no second panel stacks.
      notifier.value = [
        StarryActionItem(id: 'r2', title: 'Root Two'),
        StarryActionItem(
          id: 'sec',
          title: 'Section',
          children: [StarryActionItem(id: 'c2', title: 'Child Two')],
        ),
      ];
      await tester.pumpAndSettle();
      expect(find.text('Child One'), findsNothing);
      expect(find.text('Child Two'), findsOneWidget);
      expect(find.byType(StarryActionList), findsOneWidget);

      // Back to root: the live refresh replaced root in place with no stack.
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('Root One'), findsNothing);
      expect(find.text('Root Two'), findsOneWidget);
      expect(find.byType(StarryActionList), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(StarryActionList), findsNothing);
    });

    testWidgets('settles a directly opened section sub-page in place', (
      tester,
    ) async {
      final notifier = ValueNotifier<List<StarryActionItem>>([
        StarryActionItem(id: 'r1', title: 'Root One'),
        StarryActionItem(
          id: 'sec',
          title: 'Section',
          children: [StarryActionItem(id: 'c1', title: 'Child One')],
        ),
      ]);
      addTearDown(notifier.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => StarryActionSurface.show(
                  context: context,
                  items: notifier.value,
                  anchorRect: const Rect.fromLTWH(120, 120, 80, 40),
                  onItemSelected: (_) {},
                  itemsListenable: notifier,
                  initialSectionId: 'sec',
                ),
                child: const Text('trigger'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('trigger'));
      await tester.pumpAndSettle();

      expect(find.text('Child One'), findsOneWidget);
      notifier.value = [
        StarryActionItem(id: 'r2', title: 'Root Two'),
        StarryActionItem(
          id: 'sec',
          title: 'Section',
          children: [StarryActionItem(id: 'c2', title: 'Child Two')],
        ),
      ];
      await tester.pumpAndSettle();
      expect(find.text('Child One'), findsNothing);
      expect(find.text('Child Two'), findsOneWidget);
      expect(find.byType(StarryActionList), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
    });

    testWidgets(
      'mutating the notifier after close throws no setState-after-dispose',
      (tester) async {
        final notifier = ValueNotifier<List<StarryActionItem>>([
          StarryActionItem(id: 'r1', title: 'Root One'),
        ]);
        addTearDown(notifier.dispose);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => StarryActionSurface.show(
                    context: context,
                    items: notifier.value,
                    anchorRect: const Rect.fromLTWH(120, 120, 80, 40),
                    onItemSelected: (_) {},
                    itemsListenable: notifier,
                  ),
                  child: const Text('trigger'),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('trigger'));
        await tester.pumpAndSettle();
        expect(find.text('Root One'), findsOneWidget);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(find.byType(StarryActionList), findsNothing);

        notifier.value = [StarryActionItem(id: 'r2', title: 'Root Two')];
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  });
}
