import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../theme/starry_tokens.dart';
import 'starry_text_field.dart';

@UseCase(name: 'All States', type: StarryTextField)
Widget allStatesStarryTextField(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const StarryTextField(label: 'Default', hint: 'Enter text'),
        SizedBox(height: t.spacing.s4),
        const StarryTextField(
          label: 'Success',
          helperText: 'Looks good',
          validationState: StarryTextFieldState.success,
        ),
        SizedBox(height: t.spacing.s4),
        const StarryTextField(
          label: 'Warning',
          helperText: 'Check this value',
          validationState: StarryTextFieldState.warning,
        ),
        SizedBox(height: t.spacing.s4),
        const StarryTextField(
          label: 'Error',
          errorText: 'Please correct this field',
          validationState: StarryTextFieldState.error,
        ),
        SizedBox(height: t.spacing.s4),
        const StarryTextField(label: 'Disabled', enabled: false),
      ],
    ),
  );
}

@UseCase(name: 'Slots & Multiline', type: StarryTextField)
Widget slotsStarryTextField(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const StarryTextField(
          label: 'Leading + trailing',
          hint: 'Search or type',
          prefixIcon: Icons.person_outline,
          suffixIcon: Icons.info_outline,
        ),
        SizedBox(height: t.spacing.s4),
        StarryTextField(
          label: 'Clearable',
          hint: 'Type to reveal clear',
          controller: TextEditingController(text: 'Clear me'),
          showClearButton: true,
          clearTooltip: 'Clear text',
        ),
        SizedBox(height: t.spacing.s4),
        const StarryTextField(
          label: 'Counter',
          hint: 'Max 20 chars',
          maxLength: 20,
          showCounter: true,
        ),
        SizedBox(height: t.spacing.s4),
        const StarryTextField(
          label: 'Multiline (auto-grow)',
          hint: 'Grows up to 5 lines',
          minLines: 1,
          maxLines: 5,
        ),
        SizedBox(height: t.spacing.s4),
        const StarryTextField(
          label: 'Digits only',
          hint: '0-9 only',
          keyboardType: TextInputType.number,
        ),
      ],
    ),
  );
}

@UseCase(name: 'Playground', type: StarryTextField)
Widget playgroundStarryTextField(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  final clearable = context.knobs.boolean(label: 'Clear button');
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: StarryTextField(
      label: context.knobs.string(label: 'Label', initialValue: 'Name'),
      hint: context.knobs.string(label: 'Hint', initialValue: 'Enter name'),
      enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
      prefixIcon: context.knobs.boolean(label: 'Leading icon')
          ? Icons.person_outline
          : null,
      maxLines: context.knobs.boolean(label: 'Multiline') ? 5 : 1,
      inputFormatters: context.knobs.boolean(label: 'Digits only')
          ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]
          : null,
      validationState: context.knobs.object.dropdown<StarryTextFieldState>(
        label: 'Validation',
        options: StarryTextFieldState.values,
        labelBuilder: (value) => value.name,
      ),
      showClearButton: clearable,
      clearTooltip: clearable ? 'Clear text' : null,
    ),
  );
}
