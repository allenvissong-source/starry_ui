import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../theme/starry_tokens.dart';
import 'starry_count_formatter.dart';

@UseCase(name: 'Compact Examples', type: StarryCountFormatter)
Widget compactExamplesStarryCountFormatter(BuildContext context) =>
    const StarryCountFormatterPreview();

class StarryCountFormatterPreview extends StatelessWidget {
  const StarryCountFormatterPreview({super.key});

  static const _examples = <int>[0, 9999, 12345, 99999, 100000, 1234567];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;

    return SingleChildScrollView(
      padding: EdgeInsets.all(t.spacing.s10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'StarryCountFormatter.compact (feed-card metrics)',
            style: t.typography.bodyMedium.textStyle.copyWith(
              color: s.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: t.spacing.s6),
          for (final value in _examples) ...<Widget>[
            _FormatterExampleRow(
              value: value,
              formatted: StarryCountFormatter.compact(value),
            ),
            SizedBox(height: t.spacing.s2),
          ],
          SizedBox(height: t.spacing.s8),
          Text(
            'StarryCountFormatter.grouped (exact counts)',
            style: t.typography.bodyMedium.textStyle.copyWith(
              color: s.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: t.spacing.s6),
          for (final value in _examples) ...<Widget>[
            _FormatterExampleRow(
              value: value,
              formatted: StarryCountFormatter.grouped(value),
            ),
            SizedBox(height: t.spacing.s2),
          ],
        ],
      ),
    );
  }
}

class _FormatterExampleRow extends StatelessWidget {
  const _FormatterExampleRow({required this.value, required this.formatted});

  final int value;
  final String formatted;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: 72,
          child: Text(
            '$value',
            style: t.typography.bodySmall.textStyle.copyWith(
              color: s.textSecondary,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
        ),
        Text(
          '→',
          style: t.typography.bodySmall.textStyle.copyWith(
            color: s.textTertiary,
          ),
        ),
        SizedBox(width: t.spacing.s2),
        Text(
          formatted,
          style: t.typography.bodySmall.textStyle.copyWith(
            color: s.textPrimary,
            fontWeight: FontWeight.w700,
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
