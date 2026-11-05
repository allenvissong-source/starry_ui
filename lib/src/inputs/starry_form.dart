import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// Form lifecycle with validation that reveals and focuses the first error.
class StarryForm extends StatefulWidget {
  const StarryForm({required this.child, super.key, this.onChanged});
  final Widget child;
  final VoidCallback? onChanged;

  @override
  StarryFormState createState() => StarryFormState();
}

class StarryFormState extends State<StarryForm> {
  final _form = GlobalKey<FormState>();

  bool validate() {
    final invalid = _form.currentState!.validateGranularly();
    if (invalid.isEmpty) return true;
    final first = invalid.first;
    if (first is StarryFormFieldState) first.fieldFocusNode?.requestFocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !first.mounted) return;
      final t = Theme.of(context).extension<StarryTokens>()!;
      Scrollable.ensureVisible(
        first.context,
        alignment: 1,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : t.motion.durationMedium,
      );
    });
    return false;
  }

  void save() => _form.currentState!.save();
  void reset() => _form.currentState!.reset();

  @override
  Widget build(BuildContext context) =>
      Form(key: _form, onChanged: widget.onChanged, child: widget.child);
}

/// A labelled field that works with any Starry input through [builder].
///
/// Call `state.didChange(value)` from the input's change callback. The caller
/// owns an optional [focusNode] and the input/controller lifecycle.
class StarryFormField<T> extends FormField<T> {
  StarryFormField({
    required String label,
    required FormFieldBuilder<T> builder,
    super.key,
    super.initialValue,
    super.validator,
    super.onSaved,
    super.onReset,
    super.enabled,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.focusNode,
    String? helperText,
  }) : super(
         builder: (state) {
           final t = Theme.of(state.context).extension<StarryTokens>()!;
           return Column(
             crossAxisAlignment: CrossAxisAlignment.stretch,
             mainAxisSize: MainAxisSize.min,
             children: [
               Text(
                 label,
                 style: t.typography.labelLarge.textStyle.copyWith(
                   color: t.semantic.textPrimary,
                 ),
               ),
               SizedBox(height: t.spacing.s2),
               builder(state),
               if (state.errorText != null || helperText != null) ...[
                 SizedBox(height: t.spacing.s1),
                 Semantics(
                   liveRegion: state.hasError,
                   child: Text(
                     state.errorText ?? helperText!,
                     style: t.typography.bodySmall.textStyle.copyWith(
                       color: state.hasError
                           ? t.semantic.errorStrong
                           : t.semantic.textSecondary,
                     ),
                   ),
                 ),
               ],
             ],
           );
         },
       );

  final FocusNode? focusNode;

  @override
  StarryFormFieldState<T> createState() => StarryFormFieldState<T>();
}

class StarryFormFieldState<T> extends FormFieldState<T> {
  FocusNode? get fieldFocusNode => (widget as StarryFormField<T>).focusNode;
}

/// An unboxed group of related fields with consistent vertical rhythm.
class StarryFormSection extends StatelessWidget {
  const StarryFormSection({
    required this.title,
    required this.children,
    this.description,
    super.key,
  });
  final String title;
  final String? description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    return Padding(
      padding: EdgeInsets.only(bottom: t.spacing.s6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: t.typography.titleMedium.textStyle.copyWith(
                color: t.semantic.textPrimary,
              ),
            ),
          ),
          if (description != null) ...[
            SizedBox(height: t.spacing.s1),
            Text(
              description!,
              style: t.typography.bodySmall.textStyle.copyWith(
                color: t.semantic.textSecondary,
              ),
            ),
          ],
          for (final child in children) ...[
            SizedBox(height: t.spacing.s4),
            child,
          ],
        ],
      ),
    );
  }
}
