import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../theme/starry_tokens.dart';
import 'starry_control_shell.dart';

Widget _label(BuildContext context, String text) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Text(
    text,
    style: t.typography.bodyMedium.textStyle.copyWith(
      color: t.semantic.textPrimary,
    ),
  );
}

@UseCase(name: 'All States', type: StarryControlShell)
Widget allStatesStarryControlShell(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: t.controlMetrics.controlHeight,
          child: StarryControlShell(
            padding: StarryControlShell.horizontalPadding(t),
            alignment: Alignment.centerLeft,
            child: _label(context, 'Rest control shell'),
          ),
        ),
        SizedBox(height: t.spacing.s4),
        SizedBox(
          height: t.controlMetrics.controlHeight,
          child: StarryControlShell(
            isActive: true,
            padding: StarryControlShell.horizontalPadding(t),
            alignment: Alignment.centerLeft,
            child: _label(context, 'Active control shell'),
          ),
        ),
        SizedBox(height: t.spacing.s4),
        StarryRoundIconShell(
          onTap: () {},
          semanticsLabel: 'Add',
          child: Icon(Icons.add, color: t.semantic.textPrimary),
        ),
      ],
    ),
  );
}

@UseCase(name: 'Animated', type: StarryAnimatedControlShell)
Widget animatedStarryControlShell(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  final active = context.knobs.boolean(label: 'Active');
  return Center(
    child: SizedBox(
      height: t.controlMetrics.controlHeight,
      child: StarryAnimatedControlShell(
        isActive: active,
        padding: StarryControlShell.horizontalPadding(t),
        alignment: Alignment.centerLeft,
        child: _label(context, active ? 'Active' : 'Rest'),
      ),
    ),
  );
}

@UseCase(name: 'Round Icon', type: StarryRoundIconShell)
Widget roundIconStarryControlShell(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Center(
    child: StarryRoundIconShell(
      isActive: context.knobs.boolean(label: 'Active'),
      onTap: () {},
      semanticsLabel: context.knobs.string(
        label: 'Semantics label',
        initialValue: 'Icon action',
      ),
      child: Icon(Icons.favorite, color: t.semantic.brand),
    ),
  );
}
