import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

Widget _host(Widget child, {bool dark = false, bool reducedMotion = true}) =>
    MaterialApp(
      theme: _theme(dark),
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reducedMotion),
        child: Scaffold(body: child),
      ),
    );

StarryCodeBlock _code({
  String source = '  original\n\t文字\n',
  Future<void> Function(String)? writer,
  void Function(Object, StackTrace)? onError,
  double? maxHeight,
}) => StarryCodeBlock(
  code: source,
  title: 'Code sample',
  language: 'JSON',
  copyLabel: 'Copy',
  copyingLabel: 'Copying',
  copiedLabel: 'Copied',
  copyErrorLabel: 'Copy failed; retry',
  onCopy: writer,
  onCopyError: onError,
  maxHeight: maxHeight,
);

ThemeData _theme(bool dark) {
  final base = dark ? AppTheme.dark() : AppTheme.light();
  final t = base.extension<StarryTokens>()!;
  return base.copyWith(
    extensions: [
      ...base.extensions.values,
      StarryApplicationTokens.from(t, base.brightness),
    ],
  );
}

Widget _launcher(Future<void> Function(BuildContext) open) => Builder(
  builder: (context) =>
      StarryButton(label: 'Open', onPressed: () => open(context)),
);

void main() {
  testWidgets('copy waits, serializes attempts and preserves exact source', (
    tester,
  ) async {
    final pending = Completer<void>();
    final copied = <String>[];
    await tester.pumpWidget(
      _host(
        _code(
          writer: (source) {
            copied.add(source);
            return pending.future;
          },
        ),
      ),
    );
    await tester.tap(find.text('Copy'));
    await tester.pump();
    expect(find.text('Copying'), findsOneWidget);
    expect(find.text('Copied'), findsNothing);
    await tester.tap(find.text('Copying'));
    expect(copied, ['  original\n\t文字\n']);
    pending.complete();
    await tester.pumpAndSettle();
    expect(find.text('Copied'), findsOneWidget);
  });

  testWidgets('default clipboard receives unchanged source', (tester) async {
    final writes = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          writes.add((call.arguments as Map)['text'] as String);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.pumpWidget(_host(_code()));
    await tester.tap(find.text('Copy'));
    await tester.pumpAndSettle();
    expect(writes, ['  original\n\t文字\n']);
    expect(find.text('Copied'), findsOneWidget);
  });

  testWidgets('failure is visible, reported and retryable', (tester) async {
    var attempts = 0;
    Object? reported;
    await tester.pumpWidget(
      _host(
        _code(
          writer: (_) async {
            if (attempts++ == 0) throw StateError('Clipboard denied');
          },
          onError: (error, _) => reported = error,
        ),
      ),
    );
    await tester.tap(find.text('Copy'));
    await tester.pumpAndSettle();
    expect(reported, isStateError);
    expect(find.text('Copy failed; retry'), findsOneWidget);
    expect(find.text('Copied'), findsNothing);
    await tester.tap(find.text('Copy'));
    await tester.pumpAndSettle();
    expect(find.text('Copied'), findsOneWidget);
    expect(find.text('Copy failed; retry'), findsNothing);
  });

  testWidgets(
    'late copy feedback is invalidated even after source changes back',
    (tester) async {
      final pending = Completer<void>();
      var source = 'a';
      late StateSetter rebuild;
      await tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (_, setState) {
              rebuild = setState;
              return _code(source: source, writer: (_) => pending.future);
            },
          ),
        ),
      );
      await tester.tap(find.text('Copy'));
      await tester.pump();
      rebuild(() => source = 'b');
      await tester.pump();
      rebuild(() => source = 'a');
      await tester.pump();
      pending.complete();
      await tester.pumpAndSettle();
      expect(find.text('Copied'), findsNothing);
      expect(find.text('Copy'), findsOneWidget);
    },
  );

  testWidgets('copy completion after disposal does not update dead state', (
    tester,
  ) async {
    final pending = Completer<void>();
    await tester.pumpWidget(_host(_code(writer: (_) => pending.future)));
    await tester.tap(find.text('Copy'));
    await tester.pump();
    await tester.pumpWidget(_host(const SizedBox()));
    pending.complete();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'long code wraps within a bounded viewport and stays selectable',
    (tester) async {
      await tester.pumpWidget(
        _host(
          Center(
            child: SizedBox(
              width: 300,
              child: _code(
                source: List.filled(
                  80,
                  'Long_unbroken_source_' * 10,
                ).join('\n'),
                maxHeight: 160,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(SelectableText), findsOneWidget);
      final scroll = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(scroll.scrollDirection, Axis.vertical);
      expect(
        tester.getSize(find.byType(SingleChildScrollView)).height,
        lessThanOrEqualTo(160),
      );
      expect(tester.getSize(find.byType(SelectableText)).width, lessThan(300));
    },
  );

  testWidgets('confirm, explicit cancel and dismissal have distinct results', (
    tester,
  ) async {
    final results = <bool?>[];
    await tester.pumpWidget(
      _host(
        _launcher((context) async {
          results.add(
            await StarryDialog.confirm(
              context: context,
              title: 'Remove entry?',
              message: 'Cannot undo',
              confirmLabel: 'Remove',
              cancelLabel: 'Cancel',
              tone: StarryDialogTone.destructive,
            ),
          );
        }),
      ),
    );
    for (final label in ['Remove', 'Cancel']) {
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(2, 2));
    await tester.pumpAndSettle();
    expect(results, [true, false, null]);
  });

  testWidgets('non-dismissible dialog blocks outside taps and Escape', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        _launcher((context) async {
          await StarryDialog.confirm(
            context: context,
            title: 'Protected',
            confirmLabel: 'Save',
            cancelLabel: 'Continue',
            barrierDismissible: false,
          );
        }),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(2, 2));
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Protected'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Protected'), findsNothing);
  });

  testWidgets(
    'custom actions return their value through the selected navigator',
    (tester) async {
      String? result;
      final nested = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        _host(
          Navigator(
            key: nested,
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              builder: (_) => _launcher((context) async {
                result = await StarryDialog.show<String>(
                  context: context,
                  useRootNavigator: false,
                  builder: (dialogContext) => StarryDialog(
                    title: 'Unsaved edits',
                    actions: [
                      for (final label in ['Edit', 'Discard', 'Draft', 'Save'])
                        StarryDialogAction(
                          label: label,
                          primary: label == 'Save',
                          destructive: label == 'Discard',
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(label),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Draft'));
      await tester.pumpAndSettle();
      expect(result, 'Draft');
      expect(nested.currentState!.canPop(), isFalse);
      expect(find.text('Open'), findsOneWidget);
    },
  );

  testWidgets(
    'dialog scrolls long content, wraps localized actions and fits keyboard',
    (tester) async {
      tester.view.physicalSize = const Size(375, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: _launcher((context) async {
            await StarryDialog.show<void>(
              context: context,
              builder: (context) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  viewInsets: const EdgeInsets.only(bottom: 260),
                  textScaler: const TextScaler.linear(1.3),
                  disableAnimations: true,
                ),
                child: StarryDialog(
                  title: '修改尚未保存',
                  message: List.filled(40, '请先确认当前修改，再继续操作。').join('\n'),
                  actions: [
                    StarryDialogAction(
                      label: '继续编辑当前内容',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    StarryDialogAction(
                      label: '保存所有修改并返回',
                      primary: true,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        tester
            .getBottomRight(
              find
                  .descendant(
                    of: find.byType(Dialog),
                    matching: find.byType(Material),
                  )
                  .first,
            )
            .dy,
        lessThanOrEqualTo(440),
      );
      expect(
        tester
            .getRect(find.text('继续编辑当前内容'))
            .overlaps(tester.getRect(find.text('保存所有修改并返回'))),
        isFalse,
      );
      await tester.tap(find.text('继续编辑当前内容'));
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'four actions remain reachable in a very short keyboard viewport',
    (tester) async {
      tester.view.physicalSize = const Size(375, 600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var saved = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: _theme(false),
          home: _launcher((context) async {
            await StarryDialog.show<void>(
              context: context,
              builder: (dialogContext) => MediaQuery(
                data: MediaQuery.of(dialogContext).copyWith(
                  viewInsets: const EdgeInsets.only(bottom: 360),
                  textScaler: const TextScaler.linear(1.3),
                  disableAnimations: true,
                ),
                child: StarryDialog(
                  title: '尚有未保存的修改',
                  message: '请选择下一步操作。',
                  actions: [
                    for (final label in [
                      '继续编辑当前内容',
                      '放弃当前修改',
                      '存为草稿',
                      '保存所有修改',
                    ])
                      StarryDialogAction(
                        label: label,
                        primary: label == '保存所有修改',
                        onPressed: () {
                          saved = label == '保存所有修改';
                          Navigator.of(dialogContext).pop();
                        },
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final footer = find
          .descendant(
            of: find.byType(StarryDialog),
            matching: find.byType(SingleChildScrollView),
          )
          .last;
      await tester.drag(footer, const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.tap(find.text('保存所有修改'));
      await tester.pumpAndSettle();
      expect(saved, isTrue);
    },
  );

  testWidgets('input validator prevents submission and focuses error field', (
    tester,
  ) async {
    String? result;
    await tester.pumpWidget(
      _host(
        _launcher((context) async {
          result = await StarryInputDialog.show(
            context: context,
            title: 'Edit',
            fieldLabel: 'Name',
            confirmLabel: 'Save',
            cancelLabel: 'Cancel',
            helperText: 'Name help',
            maxLength: 20,
            validator: (value) => value.trim().isEmpty ? 'Enter a name' : null,
          );
        }),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a name'), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('Enter a name')).style!.color,
      StarryTokens.light.semantic.errorStrong,
    );
    expect(
      tester.widget<Text>(find.text('0/20')).style!.color,
      StarryTokens.light.semantic.textSecondary,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus,
      isTrue,
    );
    await tester.enterText(find.byType(TextField), '  星空  ');
    await tester.pumpAndSettle();
    expect(find.text('Enter a name'), findsNothing);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(result, '  星空  ');
  });

  testWidgets(
    'multiline input inserts newline; empty input is preserved without validator',
    (tester) async {
      String? result = 'not submitted';
      await tester.pumpWidget(
        _host(
          _launcher((context) async {
            result = await StarryInputDialog.show(
              context: context,
              title: 'Edit',
              fieldLabel: 'Description',
              confirmLabel: 'Save',
              cancelLabel: 'Cancel',
              maxLines: 4,
            );
          }),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).textInputAction,
        TextInputAction.newline,
      );
      await tester.testTextInput.receiveAction(TextInputAction.newline);
      await tester.pumpAndSettle();
      expect(find.byType(StarryInputDialog), findsOneWidget);
      await tester.enterText(find.byType(TextField), '');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(result, '');
    },
  );

  testWidgets(
    'busy and disabled actions are non-tappable; focus ring uses tokens',
    (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        _host(
          StarryDialog(
            title: 'Saving',
            actions: [
              const StarryDialogAction(label: 'Disabled'),
              StarryDialogAction(
                label: 'Save',
                loading: true,
                loadingLabel: 'Saving now',
                onPressed: () => calls++,
              ),
              StarryDialogAction(
                label: 'Cancel',
                primary: true,
                onPressed: () => calls++,
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Saving now'));
      await tester.tap(find.text('Disabled'));
      expect(calls, 0);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      final cancel = tester.widget<TextButton>(
        find.ancestor(
          of: find.text('Cancel'),
          matching: find.byType(TextButton),
        ),
      );
      final border = cancel.style!.side!.resolve({WidgetState.focused})!;
      expect(border.color, StarryTokens.light.semantic.brandStrong);
      expect(border.width, StarryTokens.light.controlMetrics.focusBorderWidth);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(calls, 1);
    },
  );

  testWidgets(
    'readable colors, touch targets and dialog route semantics in both themes',
    (tester) async {
      double contrast(Color a, Color b) {
        final x = a.computeLuminance();
        final y = b.computeLuminance();
        return x > y ? (x + 0.05) / (y + 0.05) : (y + 0.05) / (x + 0.05);
      }

      final handle = tester.ensureSemantics();
      for (final dark in [false, true]) {
        final t = dark ? StarryTokens.dark : StarryTokens.light;
        await tester.pumpWidget(_host(_code(), dark: dark));
        expect(
          contrast(t.semantic.textPrimary, t.semantic.backgroundSecondary),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          contrast(t.semantic.textSecondary, t.semantic.backgroundSecondary),
          greaterThanOrEqualTo(4.5),
        );
        final copy = find.ancestor(
          of: find.text('Copy'),
          matching: find.byType(TextButton),
        );
        expect(tester.getSize(copy).height, greaterThanOrEqualTo(48));
        await tester.pumpWidget(
          _host(
            StarryDialog(
              title: 'Dialog title',
              tone: StarryDialogTone.warning,
              message: 'Body',
              actions: [
                StarryDialogAction(label: 'Cancel', onPressed: () {}),
                StarryDialogAction(
                  label: 'Delete',
                  primary: true,
                  destructive: true,
                  onPressed: () {},
                ),
              ],
            ),
            dark: dark,
          ),
        );
        final deleteButton = tester.widget<TextButton>(
          find.ancestor(
            of: find.text('Delete'),
            matching: find.byType(TextButton),
          ),
        );
        expect(
          contrast(
            deleteButton.style!.foregroundColor!.resolve({})!,
            deleteButton.style!.backgroundColor!.resolve({})!,
          ),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          tester
              .getSemantics(find.text('Dialog title'))
              .flagsCollection
              .namesRoute,
          isTrue,
        );
        for (final button in tester.widgetList<TextButton>(
          find.byType(TextButton),
        )) {
          expect(
            button.style!.minimumSize!.resolve({})!.height,
            greaterThanOrEqualTo(48),
          );
        }
      }
      handle.dispose();
    },
  );
}
