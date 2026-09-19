import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';
import 'package:starry_ui/src/inputs/input_shell.dart';

/// Structural contract for the input family: every text-entry input renders its
/// frame through [StarryInputShell], so the family's geometry has exactly one
/// definition.
///
/// This is a membership test, not a pixel test. It exists because the second
/// definition it guards against is invisible in a screenshot until the two
/// drift: `StarryTextArea` used to paint its own [OutlineInputBorder] at
/// `radius.md` while the rest of the family sat at `radius.xxl`, and nothing
/// failed. Asserting shell membership is what makes that class of divergence
/// impossible to reintroduce quietly.
///
/// The three non-text inputs are listed here too, with the reason each is out of
/// scope recorded in code rather than left to be rediscovered. If one of them
/// ever grows a text-entry frame, this file is where the decision is revisited.

Widget _host(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(
      body: Center(child: SizedBox(width: 320, child: child)),
    ),
  );
}

void main() {
  group('every text-entry input renders through StarryInputShell', () {
    testWidgets('StarryTextField', (tester) async {
      await tester.pumpWidget(_host(const StarryTextField(hint: 'x')));
      expect(find.byType(StarryInputShell), findsOneWidget);
    });

    testWidgets('StarrySearchInput', (tester) async {
      await tester.pumpWidget(_host(const StarrySearchInput(hint: 'x')));
      expect(find.byType(StarryInputShell), findsOneWidget);
    });

    testWidgets('StarryTextArea', (tester) async {
      await tester.pumpWidget(_host(const StarryTextArea(hint: 'x')));
      expect(
        find.byType(StarryInputShell),
        findsOneWidget,
        reason:
            'StarryTextArea previously built its own OutlineInputBorder via '
            'starryInputBorder, a second definition of the family frame that '
            'had already drifted to radius.md. It goes through the shell now.',
      );
    });

    testWidgets('a text area still accepts input through the shell', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _host(StarryTextArea(label: 'remark', controller: controller)),
      );
      await tester.enterText(find.byType(TextField), 'hello');
      expect(controller.text, 'hello');
      expect(find.text('remark'), findsOneWidget);
    });

    testWidgets('the text area takes the family multi-line corner', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const StarryTextArea(hint: 'x')));
      final shell = tester.widget<StarryInputShell>(
        find.byType(StarryInputShell),
      );
      expect(
        shell.borderRadius,
        StarryTokens.light.radius.xxl,
        reason:
            'A text area is multi-line by definition, so it takes radius.xxl -- '
            'the same corner StarryTextField settles on once it grows past one '
            'line. Not radius.md, which is what the hand-rolled border used.',
      );
    });
  });

  group('the non-text inputs are deliberately outside the shell', () {
    // Recorded per component, because "4 of 6 bypass StarryInputShell" treats
    // these three as a gap. They are not: StarryInputShell is a *text-entry*
    // frame (min height controlHeight, horizontal text padding, fill, focus
    // border, rest->focus elevation lift). None of the three has a text frame
    // to give, and forcing one through the shell would add a 48px-tall filled
    // box around a control that is not a field.

    testWidgets('StarrySwitch is a track, not a framed field', (tester) async {
      await tester.pumpWidget(
        _host(StarrySwitch(value: true, onChanged: (_) {})),
      );
      expect(
        find.byType(StarryInputShell),
        findsNothing,
        reason:
            'A switch has no text frame. Its focus affordance is a stadium ring '
            'around the track, drawn with the SAME shared rule the shell uses '
            '(StarryControlShell.activeBorderSide), so the focus language is '
            'already unified without the frame.',
      );
    });

    testWidgets('StarrySlider is a track, not a framed field', (tester) async {
      await tester.pumpWidget(
        _host(StarrySlider(value: 0.5, onChanged: (_) {})),
      );
      expect(
        find.byType(StarryInputShell),
        findsNothing,
        reason:
            'A slider is a horizontal track plus optional header/labels. '
            'Wrapping it in a text-entry frame would box the track in a '
            'surface-filled 48px control it does not want.',
      );
    });

    testWidgets('StarryDropdown is a surface trigger plus a detached panel', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          StarryDropdown<String>(
            items: const <StarryDropdownItem<String>>[
              StarryDropdownItem<String>(value: 'a', label: 'A'),
            ],
            onSelected: (_) {},
          ),
        ),
      );
      expect(
        find.byType(StarryInputShell),
        findsNothing,
        reason:
            'The dropdown is not one control: it is a tappable trigger and a '
            'separately-animated option panel, both StarrySurface. It already '
            'shares the family height (controlMetrics.controlHeight) and the '
            'same s5 horizontal padding the shell uses, so the geometry is '
            'aligned; what it cannot share is a single-box frame, because the '
            'panel is outside that box.',
      );
      expect(
        find.byType(StarrySurface),
        findsWidgets,
        reason: 'Recorded so "not in the shell" does not read as "unstyled".',
      );
    });
  });
}
