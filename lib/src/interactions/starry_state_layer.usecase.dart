import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../theme/starry_tokens.dart';
import 'starry_state_layer.dart';

Widget _swatch(BuildContext context, String label, Widget layer) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      SizedBox(width: 96, height: 64, child: layer),
      SizedBox(height: t.spacing.s2),
      Text(label, style: t.typography.labelSmall.textStyle),
    ],
  );
}

@UseCase(name: 'All States', type: StarryStateLayer)
Widget allStatesStarryStateLayer(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  Widget base(Widget child) => DecoratedBox(
        decoration: BoxDecoration(
          color: t.semantic.surface,
          borderRadius: BorderRadius.circular(t.radius.md),
          border: Border.all(color: t.semantic.border),
        ),
        child: child,
      );
  return Padding(
    padding: EdgeInsets.all(t.spacing.s10),
    child: Wrap(
      spacing: t.spacing.s10,
      runSpacing: t.spacing.s10,
      children: <Widget>[
        _swatch(context, 'rest', const StarryStateLayer(child: SizedBox.expand())),
        _swatch(
          context,
          'hover',
          base(const StarryStateLayer(hovered: true, child: SizedBox.expand())),
        ),
        _swatch(
          context,
          'focus',
          base(const StarryStateLayer(focused: true, child: SizedBox.expand())),
        ),
        _swatch(
          context,
          'pressed',
          base(const StarryStateLayer(pressed: true, child: SizedBox.expand())),
        ),
        _swatch(
          context,
          'dragged',
          base(const StarryStateLayer(dragged: true, child: SizedBox.expand())),
        ),
        _swatch(
          context,
          'selected+hover',
          base(
            const StarryStateLayer(
              selected: true,
              hovered: true,
              child: SizedBox.expand(),
            ),
          ),
        ),
        _swatch(
          context,
          'disabled',
          base(
            const StarryStateLayer(
              disabled: true,
              pressed: true,
              child: SizedBox.expand(),
            ),
          ),
        ),
      ],
    ),
  );
}

@UseCase(name: 'Playground', type: StarryStateLayer)
Widget playgroundStarryStateLayer(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  final hovered = context.knobs.boolean(label: 'Hovered', initialValue: false);
  final focused = context.knobs.boolean(label: 'Focused', initialValue: false);
  final pressed = context.knobs.boolean(label: 'Pressed', initialValue: false);
  final dragged = context.knobs.boolean(label: 'Dragged', initialValue: false);
  final disabled = context.knobs.boolean(label: 'Disabled', initialValue: false);
  final selected = context.knobs.boolean(label: 'Selected', initialValue: false);
  return Center(
    child: SizedBox(
      width: 120,
      height: 80,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.semantic.surface,
          borderRadius: BorderRadius.circular(t.radius.md),
          border: Border.all(color: t.semantic.border),
        ),
        child: StarryStateLayer(
          hovered: hovered,
          focused: focused,
          pressed: pressed,
          dragged: dragged,
          disabled: disabled,
          selected: selected,
          borderRadius: BorderRadius.circular(t.radius.md),
          child: const SizedBox.expand(),
        ),
      ),
    ),
  );
}
