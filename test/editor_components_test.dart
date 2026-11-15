import 'dart:ui' show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

Widget _host(
  Widget child, {
  bool dark = false,
  bool reducedMotion = false,
  double width = 480,
  double textScale = 1,
}) => MaterialApp(
  theme: (dark ? AppTheme.dark() : AppTheme.light()).copyWith(
    splashFactory: NoSplash.splashFactory,
  ),
  home: MediaQuery(
    data: MediaQueryData(
      disableAnimations: reducedMotion,
      textScaler: TextScaler.linear(textScale),
    ),
    child: Scaffold(
      body: Center(
        child: SizedBox(width: width, child: child),
      ),
    ),
  ),
);

String _numberError(StarryNumberFieldError error) => error.name;

const _tabs = [
  StarryTab(value: 'a', label: 'Details', icon: Icons.description_outlined),
  StarryTab(value: 'b', label: 'Entries', count: 12),
  StarryTab(value: 'disabled', label: 'Disabled', enabled: false),
  StarryTab(value: 'c', label: 'Media'),
];

const _options = [
  StarryDropdownItem(value: 'a', label: 'Alpha'),
  StarryDropdownItem(value: 'disabled', label: 'Unavailable', enabled: false),
  StarryDropdownItem(value: 'b', label: 'Beta'),
  StarryDropdownItem(value: 'c', label: 'Gamma'),
];

void main() {
  testWidgets('editor state text meets 4.5 contrast in both themes', (
    tester,
  ) async {
    double contrast(Color foreground, Color background) {
      final a = foreground.computeLuminance();
      final b = background.computeLuminance();
      return a > b ? (a + 0.05) / (b + 0.05) : (b + 0.05) / (a + 0.05);
    }

    for (final dark in [false, true]) {
      final t = dark ? StarryTokens.dark : StarryTokens.light;
      await tester.pumpWidget(
        _host(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StarryTabBar(tabs: _tabs, value: 'b', onChanged: (_) {}),
              StarryNumberField(
                value: 101,
                max: 100,
                onChanged: (_) {},
                errorTextBuilder: (_) => 'Number error',
              ),
              const StarryTextArea(
                helperText: 'Description help',
                showCounter: true,
                maxLength: 10,
              ),
            ],
          ),
          dark: dark,
        ),
      );
      await tester.pumpAndSettle();
      for (final entry in [
        ('Entries', t.semantic.surfaceVariant),
        ('Number error', t.semantic.background),
        ('Description help', t.semantic.background),
        ('0/10', t.semantic.background),
      ]) {
        final text = tester.widget<Text>(find.text(entry.$1));
        expect(
          contrast(text.style!.color!, entry.$2),
          greaterThanOrEqualTo(4.5),
          reason: '${entry.$1}, dark=$dark',
        );
      }
    }
  });

  testWidgets(
    'tabs select by stable values and skip disabled tabs by keyboard',
    (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      var value = 'a';
      await tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (_, setState) => StarryTabBar(
              tabs: _tabs,
              value: value,
              onChanged: (next) => setState(() => value = next),
            ),
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(value, 'b');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(value, 'c');
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(value, 'a');
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(value, 'c');
      final semantics = tester.getSemantics(find.bySemanticsLabel('Media'));
      expect(
        semantics,
        matchesSemantics(
          label: 'Media',
          isButton: true,
          isSelected: true,
          hasSelectedState: true,
          hasEnabledState: true,
          isEnabled: true,
          isInMutuallyExclusiveGroup: true,
          isFocusable: true,
          isFocused: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      semanticsHandle.dispose();
    },
  );

  for (final width in [240.0, 375.0, 768.0]) {
    for (final dark in [false, true]) {
      testWidgets('tabs fit width $width, dark=$dark at large text', (
        tester,
      ) async {
        await tester.pumpWidget(
          _host(
            StarryTabBar(tabs: _tabs, value: 'b', onChanged: (_) {}),
            width: width,
            dark: dark,
            textScale: 1.5,
          ),
        );
        expect(tester.takeException(), isNull);
        final bounds = tester.getRect(find.byType(StarryTabBar<String>));
        for (final button in find.byType(InkWell).evaluate()) {
          final box = button.renderObject! as RenderBox;
          final rect = box.localToGlobal(Offset.zero) & box.size;
          expect(rect.height, greaterThanOrEqualTo(48));
          expect(rect.left, greaterThanOrEqualTo(bounds.left));
          expect(rect.right, lessThanOrEqualTo(bounds.right));
        }
      });
    }
  }

  testWidgets(
    'underline tabs keep semantics, keyboard and the 48dp touch target',
    (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      var value = 'a';
      await tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (_, setState) => StarryTabBar(
              variant: StarryTabBarVariant.underline,
              tabs: _tabs,
              value: value,
              onChanged: (next) => setState(() => value = next),
            ),
          ),
          width: 360,
          textScale: 1.5,
        ),
      );
      expect(tester.takeException(), isNull);
      final bounds = tester.getRect(find.byType(StarryTabBar<String>));
      for (final button in find.byType(InkWell).evaluate()) {
        final box = button.renderObject! as RenderBox;
        final rect = box.localToGlobal(Offset.zero) & box.size;
        expect(rect.height, greaterThanOrEqualTo(48));
        expect(rect.left, greaterThanOrEqualTo(bounds.left));
        expect(rect.right, lessThanOrEqualTo(bounds.right));
      }
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(value, 'b');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(value, 'c');
      final semantics = tester.getSemantics(find.bySemanticsLabel('Media'));
      expect(
        semantics,
        matchesSemantics(
          label: 'Media',
          isButton: true,
          isSelected: true,
          hasSelectedState: true,
          hasEnabledState: true,
          isEnabled: true,
          isInMutuallyExclusiveGroup: true,
          isFocusable: true,
          isFocused: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      semanticsHandle.dispose();
    },
  );

  testWidgets('tab reorder and external selection keep identities', (
    tester,
  ) async {
    final selected = <String>[];
    await tester.pumpWidget(
      _host(StarryTabBar(tabs: _tabs, value: 'a', onChanged: selected.add)),
    );
    await tester.pumpWidget(
      _host(
        StarryTabBar(
          tabs: _tabs.reversed.toList(),
          value: 'c',
          onChanged: selected.add,
        ),
      ),
    );
    await tester.tap(find.text('Entries'));
    expect(selected, ['b']);
    await tester.tap(find.text('Disabled'));
    expect(selected, ['b']);
  });

  testWidgets(
    'integer edits report invalid results without clamping or reverting',
    (tester) async {
      final results = <StarryNumberFieldResult>[];
      await tester.pumpWidget(
        _host(
          StarryNumberField(
            value: 5,
            min: -10,
            max: 10,
            label: 'Order',
            onChanged: results.add,
            errorTextBuilder: _numberError,
          ),
        ),
      );
      final field = find.byType(TextField);
      for (final text in [
        '-',
        '1.5',
        '0x10',
        'abc',
        '9007199254740993',
        '99999999999999999999999999',
      ]) {
        await tester.enterText(field, text);
        await tester.pump();
        expect(results.last.isValid, isFalse);
        expect(results.last.value, isNull);
        expect(results.last.text, text);
        expect(find.text('invalidInteger'), findsOneWidget);
        expect(tester.widget<TextField>(field).controller!.text, text);
      }
      await tester.enterText(field, '11');
      await tester.pump();
      expect(results.last.error, StarryNumberFieldError.aboveMax);
      await tester.enterText(field, '-11');
      await tester.pump();
      expect(results.last.error, StarryNumberFieldError.belowMin);
      await tester.enterText(field, '-10');
      await tester.pump();
      expect(results.last.isValid, isTrue);
      expect(results.last.value, -10);
      await tester.enterText(field, '');
      await tester.pump();
      expect(results.last.isValid, isTrue);
      expect(results.last.value, isNull);
    },
  );

  testWidgets(
    'number externally resets invalid edits and validates required null',
    (tester) async {
      final results = <StarryNumberFieldResult>[];
      Widget input(int? value, {bool nullable = true}) => _host(
        StarryNumberField(
          value: value,
          nullable: nullable,
          onChanged: results.add,
          errorTextBuilder: _numberError,
        ),
      );
      await tester.pumpWidget(input(5));
      await tester.enterText(find.byType(TextField), '-');
      await tester.pumpWidget(input(null));
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '',
      );
      await tester.pumpWidget(input(null, nullable: false));
      expect(find.text('required'), findsOneWidget);
      expect(results.last.error, StarryNumberFieldError.required);
      await tester.pumpWidget(input(8));
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '8',
      );
    },
  );

  testWidgets('number value echoes preserve the caret and leading zero edit', (
    tester,
  ) async {
    var value = 5;
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (_, setState) => StarryNumberField(
            value: value,
            onChanged: (result) {
              if (result.isValid && result.value != null) {
                setState(() => value = result.value!);
              }
            },
            errorTextBuilder: _numberError,
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), '007');
    await tester.pump();
    expect(value, 7);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '007',
    );
  });

  testWidgets('number read only and disabled preserve the editing contract', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        StarryNumberField(
          value: 5,
          readOnly: true,
          enabled: false,
          onChanged: (_) => fail('Disabled field changed'),
          errorTextBuilder: _numberError,
        ),
      ),
    );
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.enabled, isFalse);
    expect(field.readOnly, isTrue);
  });

  for (final maintain in [false, true]) {
    testWidgets(
      'disclosure preserves editor state only when maintainState=$maintain',
      (tester) async {
        await tester.pumpWidget(
          _host(
            StarryExpandableCard(
              header: const Text('Editor'),
              initiallyExpanded: true,
              maintainState: maintain,
              children: const [StarryTextField(label: 'Draft')],
            ),
          ),
        );
        await tester.enterText(find.byType(TextField), 'Unsaved draft');
        await tester.tap(find.text('Editor'));
        await tester.pumpAndSettle();
        expect(find.byType(TextField), findsNothing);
        expect(
          find.byType(TextField, skipOffstage: false),
          maintain ? findsOneWidget : findsNothing,
        );
        await tester.tap(find.text('Editor'));
        await tester.pumpAndSettle();
        final text = tester
            .widget<TextField>(find.byType(TextField))
            .controller!
            .text;
        expect(text, maintain ? 'Unsaved draft' : '');
      },
    );
  }

  testWidgets(
    'controlled disclosure waits for owner and isolates header actions',
    (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      final requests = <bool>[];
      var actions = 0;
      Widget card(bool expanded) => _host(
        StarryExpandableCard(
          expanded: expanded,
          header: const Text('Section'),
          onExpansionChanged: requests.add,
          headerActions: StarryIconButton(
            icon: Icons.more_horiz,
            tooltip: 'More',
            onPressed: () => actions++,
          ),
          children: const [Text('Revealed')],
        ),
        reducedMotion: true,
      );
      await tester.pumpWidget(card(false));
      await tester.tap(find.byTooltip('More'));
      expect(actions, 1);
      expect(requests, isEmpty);
      await tester.tap(find.text('Section'));
      await tester.pump();
      expect(requests, [true]);
      expect(find.text('Revealed'), findsNothing);
      await tester.pumpWidget(card(true));
      expect(find.text('Revealed'), findsOneWidget);
      expect(tester.binding.transientCallbackCount, 0);
      final semantics = tester.getSemantics(find.bySemanticsLabel('Section'));
      expect(semantics.flagsCollection.isExpanded.toBoolOrNull(), isTrue);
      semanticsHandle.dispose();
    },
  );

  testWidgets(
    'dropdown keyboard selects enabled rows and restores trigger focus',
    (tester) async {
      String? value;
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (_, setState) => StarryDropdown(
              hint: 'Choose',
              value: value,
              valueIsControlled: true,
              focusNode: focus,
              items: _options,
              onSelected: (next) => setState(() => value = next),
            ),
          ),
        ),
      );
      focus.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(value, 'b');
      expect(focus.hasFocus, isTrue);
      expect(find.text('Alpha'), findsNothing);
      expect(find.text('Beta'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(focus.hasFocus, isTrue);
      expect(value, 'b');
    },
  );

  testWidgets(
    'dropdown controlled empty value, expansion and disabled semantics',
    (tester) async {
      final selections = <String>[];
      final expansion = <bool>[];
      Widget input(String? value, bool expanded, {bool enabled = true}) =>
          _host(
            StarryDropdown(
              value: value,
              valueIsControlled: true,
              expanded: expanded,
              enabled: enabled,
              hint: 'Choose',
              items: _options,
              onSelected: selections.add,
              onExpansionChanged: expansion.add,
            ),
            reducedMotion: true,
          );
      await tester.pumpWidget(input('a', true));
      await tester.tap(find.text('Beta'));
      await tester.pump();
      expect(selections, ['b']);
      expect(expansion, [false]);
      expect(find.text('Gamma'), findsOneWidget);
      await tester.pumpWidget(input(null, false));
      expect(find.text('Choose'), findsOneWidget);
      expect(find.text('Alpha'), findsNothing);
      await tester.pumpWidget(input(null, true, enabled: false));
      await tester.tap(find.text('Beta'), warnIfMissed: false);
      await tester.pump();
      expect(selections, ['b']);
    },
  );

  testWidgets('escape cancels pending selection collapse before reopening', (
    tester,
  ) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      _host(
        StarryDropdown(
          hint: 'Choose',
          focusNode: focus,
          initiallyExpanded: true,
          items: _options,
          onSelected: (_) {},
        ),
      ),
    );
    await tester.tap(find.text('Beta'));
    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(find.text('Gamma'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'long dropdown lazily builds rows and End reveals the last option',
    (tester) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);
      int? value;
      await tester.pumpWidget(
        _host(
          StarryDropdown(
            hint: 'Choose',
            focusNode: focus,
            items: [
              for (var i = 0; i < 100; i++)
                StarryDropdownItem(value: i, label: 'Option $i'),
            ],
            onSelected: (next) => value = next,
          ),
        ),
      );
      focus.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pumpAndSettle();
      expect(find.text('Option 99'), findsOneWidget);
      expect(find.text('Option 50'), findsNothing);
      expect(find.byType(InkWell).evaluate().length, lessThan(30));
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(value, 99);
      expect(focus.hasFocus, isTrue);
    },
  );

  testWidgets('disclosure keyboard and semantic activation request expansion', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      _host(
        StarryExpandableCard(
          header: const Text('Advanced'),
          focusNode: focus,
          children: const [Text('Extra content')],
        ),
        reducedMotion: true,
      ),
    );
    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(find.text('Extra content'), findsOneWidget);
    final node = tester.getSemantics(find.bySemanticsLabel('Advanced'));
    expect(node.flagsCollection.isExpanded.toBoolOrNull(), isTrue);
    node.owner!.performAction(node.id, SemanticsAction.tap);
    await tester.pump();
    expect(find.text('Extra content'), findsNothing);
    handle.dispose();
  });

  testWidgets(
    'textarea preserves selectable read only text, error and grapheme count',
    (tester) async {
      final controller = TextEditingController(text: '👨‍👩‍👧‍👦abc');
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _host(
          StarryTextArea(
            controller: controller,
            readOnly: true,
            maxLength: 10,
            showCounter: true,
            label: 'Description',
            validationState: StarryTextFieldState.error,
            errorText: 'Fix description',
            helperText: 'Hidden help',
          ),
        ),
      );
      expect(tester.widget<TextField>(find.byType(TextField)).readOnly, isTrue);
      expect(find.text('4/10'), findsOneWidget);
      expect(find.text('Fix description'), findsOneWidget);
      expect(find.text('Hidden help'), findsNothing);
      controller.text = 'hello';
      await tester.pump();
      expect(find.text('5/10'), findsOneWidget);
    },
  );

  testWidgets(
    'ordinary textarea enforces maxLength and retains owned controllers',
    (tester) async {
      await tester.pumpWidget(
        _host(
          const StarryTextArea(
            label: 'Description',
            maxLength: 3,
            showCounter: true,
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'abcdef');
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'abc',
      );
      expect(find.text('3/3'), findsOneWidget);
    },
  );

  testWidgets(
    'media slot keeps add replace remove independent of preview taps',
    (tester) async {
      var add = 0;
      var replace = 0;
      var remove = 0;
      Widget slot({
        Widget? preview,
        bool readOnly = false,
        bool loading = false,
      }) => _host(
        StarryMediaSlot(
          label: 'Cover',
          emptyLabel: 'No cover',
          preview: preview,
          onAdd: () => add++,
          addLabel: 'Add',
          onReplace: () => replace++,
          replaceLabel: 'Replace',
          onRemove: () => remove++,
          removeLabel: 'Remove',
          readOnly: readOnly,
          loading: loading,
          loadingLabel: 'Loading',
        ),
        width: 240,
        reducedMotion: true,
      );
      await tester.pumpWidget(slot());
      await tester.tap(find.text('Add'));
      expect(add, 1);
      expect(find.text('Replace'), findsNothing);
      await tester.pumpWidget(slot(preview: const Text('Preview')));
      await tester.tap(find.text('Preview'));
      expect(replace, 0);
      await tester.tap(find.text('Replace'));
      await tester.tap(find.text('Remove'));
      expect(replace, 1);
      expect(remove, 1);
      await tester.pumpWidget(
        slot(preview: const Text('Preview'), loading: true),
      );
      await tester.tap(find.text('Replace'));
      await tester.pump();
      expect(replace, 1);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Loading'), findsOneWidget);
      await tester.pumpWidget(
        slot(preview: const Text('Preview'), readOnly: true),
      );
      expect(find.byType(StarryButton), findsNothing);
      expect(find.text('Preview'), findsOneWidget);
    },
  );

  testWidgets('avatar clips app media and rejects two image sources', (
    tester,
  ) async {
    const mediaKey = Key('app-media');
    await tester.pumpWidget(
      _host(
        const StarryAvatar(
          media: SizedBox.expand(key: mediaKey, child: Text('App image')),
          shape: StarryAvatarShape.rounded,
          bordered: true,
        ),
      ),
    );
    expect(tester.getSize(find.byKey(mediaKey)), const Size(40, 40));
    expect(
      find.ancestor(of: find.byKey(mediaKey), matching: find.byType(ClipRRect)),
      findsOneWidget,
    );
    expect(
      () => StarryAvatar(
        imageProvider: const AssetImage('image.png'),
        media: const Text('Conflicting source'),
      ),
      throwsAssertionError,
    );
  });

  testWidgets(
    'tag leading uses status ink and icon metrics without button semantics',
    (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          const StarryTag(
            label: 'Enabled',
            status: StarryTagStatus.success,
            leading: Icon(Icons.check),
          ),
          dark: true,
        ),
      );
      final iconContext = tester.element(find.byIcon(Icons.check));
      final theme = IconTheme.of(iconContext);
      expect(theme.size, StarryTokens.dark.controlMetrics.iconXs);
      expect(theme.color, StarryTokens.dark.semantic.successStrong);
      expect(
        tester.getSemantics(find.text('Enabled')).flagsCollection.isButton,
        isFalse,
      );
      semanticsHandle.dispose();
    },
  );
}
