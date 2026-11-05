import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../buttons/starry_button.dart';
import '../theme/starry_tokens.dart';
import 'starry_form.dart';
import 'starry_text_field.dart';

@UseCase(name: 'All Variants', type: StarryForm)
Widget allStarryForm(BuildContext context) => const _FormDemo();

@UseCase(name: 'Playground', type: StarryForm)
Widget playgroundStarryForm(BuildContext context) => _FormDemo(
  enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
);

@UseCase(name: 'All Variants', type: StarryFormField)
Widget allStarryFormField(BuildContext context) => const _FormDemo();

@UseCase(name: 'Playground', type: StarryFormField)
Widget playgroundStarryFormField(BuildContext context) =>
    playgroundStarryForm(context);

@UseCase(name: 'All Variants', type: StarryFormSection)
Widget allStarryFormSection(BuildContext context) => const _FormDemo();

@UseCase(name: 'Playground', type: StarryFormSection)
Widget playgroundStarryFormSection(BuildContext context) =>
    playgroundStarryForm(context);

class _FormDemo extends StatefulWidget {
  const _FormDemo({this.enabled = true});
  final bool enabled;
  @override
  State<_FormDemo> createState() => _FormDemoState();
}

class _FormDemoState extends State<_FormDemo> {
  final _form = GlobalKey<StarryFormState>();
  final _name = TextEditingController();
  final _focus = FocusNode();
  bool _saved = false;
  @override
  void dispose() {
    _name.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    return SingleChildScrollView(
      padding: EdgeInsets.all(t.spacing.s6),
      child: StarryForm(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StarryFormSection(
              title: 'Basic information',
              description: 'A name makes your application easy to recognize.',
              children: [
                StarryFormField<String>(
                  label: 'Name',
                  focusNode: _focus,
                  validator: (value) =>
                      value?.trim().isNotEmpty == true ? null : 'Enter a name',
                  builder: (field) => StarryTextField(
                    controller: _name,
                    focusNode: _focus,
                    enabled: widget.enabled,
                    onChanged: field.didChange,
                    validationState: field.hasError
                        ? StarryTextFieldState.error
                        : StarryTextFieldState.none,
                  ),
                ),
              ],
            ),
            StarryButton(
              label: 'Save',
              onPressed: widget.enabled
                  ? () {
                      if (_form.currentState!.validate()) {
                        setState(() => _saved = true);
                      }
                    }
                  : null,
            ),
            if (_saved) const Text('Saved'),
          ],
        ),
      ),
    );
  }
}
