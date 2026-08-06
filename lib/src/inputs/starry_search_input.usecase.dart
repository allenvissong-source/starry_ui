import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../theme/starry_tokens.dart';
import 'starry_search_input.dart';

@UseCase(name: 'Variants', type: StarrySearchInput)
Widget variantsStarrySearchInput(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        StarrySearchInput(
          hint: 'Search characters',
          semanticLabel: 'Search characters',
          onChanged: (_) {},
        ),
        SizedBox(height: t.spacing.s4),
        StarrySearchInput(
          hint: 'Search with button',
          semanticLabel: 'Search with button',
          searchButtonText: 'Search',
          onSearch: () {},
        ),
        SizedBox(height: t.spacing.s4),
        StarrySearchInput(
          controller: TextEditingController(text: 'Prefilled query'),
          hint: 'Clearable',
          onChanged: (_) {},
        ),
        SizedBox(height: t.spacing.s4),
        const StarrySearchInput(hint: 'Disabled', enabled: false),
      ],
    ),
  );
}

@UseCase(name: 'Playground', type: StarrySearchInput)
Widget playgroundStarrySearchInput(BuildContext context) {
  final t = Theme.of(context).extension<StarryTokens>()!;
  final withButton = context.knobs.boolean(label: 'Search button');
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: StarrySearchInput(
      hint: context.knobs.string(label: 'Hint', initialValue: 'Search'),
      enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
      showClearButton:
          context.knobs.boolean(label: 'Clear button', initialValue: true),
      debounceMs: context.knobs.doubleOrNull.slider(
            label: 'Debounce (ms)',
            initialValue: 300,
            min: 0,
            max: 1000,
          )?.round() ??
          300,
      searchButtonText: withButton ? 'Search' : null,
      onSearch: withButton ? () {} : null,
      onChanged: (_) {},
    ),
  );
}
