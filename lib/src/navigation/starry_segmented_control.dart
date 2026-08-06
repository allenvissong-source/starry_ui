import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// A connected N-segment control with a shared outer border, rounded ends, and
/// a per-segment selected highlight.
///
/// Generalizes the app's former 3-segment control: [labels] may hold any number
/// of segments (>= 2). All visual dimensions and colors resolve from
/// [StarryTokens]; the selected segment is filled with [selectedColor]
/// (defaults to `semantic.brand`) rather than a gradient. Callers wanting a
/// gradient pass their own [selectedColor]-equivalent via composition — this
/// primitive keeps a single solid-fill contract.
class StarrySegmentedControl extends StatelessWidget {
  const StarrySegmentedControl({
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
    this.height,
    this.borderColor,
    this.separatorColor,
    this.selectedColor,
    this.selectedTextColor,
    this.unselectedTextColor,
  })  : assert(labels.length >= 2, 'labels must have at least 2 segments'),
        assert(
          selectedIndex >= 0 && selectedIndex < labels.length,
          'selectedIndex must be within labels bounds',
        );

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  /// Overall control height. Defaults to `controlMetrics.controlHeight`.
  final double? height;

  /// Outer border color. Defaults to `semantic.brand`.
  final Color? borderColor;

  /// Inter-segment separator color. Defaults to a low-alpha `semantic.brand`.
  final Color? separatorColor;

  /// Fill color of the selected segment. Defaults to `semantic.brand`.
  final Color? selectedColor;

  /// Text color of the selected segment. Defaults to `semantic.onBrand`.
  final Color? selectedTextColor;

  /// Text color of unselected segments. Defaults to `semantic.textSecondary`.
  final Color? unselectedTextColor;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;

    final effectiveHeight = height ?? t.controlMetrics.controlHeight;
    final effectiveBorderColor = borderColor ?? s.brand;
    final effectiveSeparatorColor = separatorColor ??
        s.brand.withValues(alpha: t.opacity.accentSurface);
    final effectiveSelectedColor = selectedColor ?? s.brand;
    final effectiveSelectedTextColor = selectedTextColor ?? s.onBrand;
    final effectiveUnselectedTextColor =
        unselectedTextColor ?? s.textSecondary;
    final textStyle = t.typography.labelMedium.textStyle;

    return Container(
      height: effectiveHeight,
      decoration: ShapeDecoration(
        color: s.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: effectiveBorderColor,
            width: t.controlMetrics.focusBorderWidth,
          ),
          borderRadius: BorderRadius.circular(t.radius.full),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0)
              SizedBox(
                width: 1,
                height: effectiveHeight,
                child: ColoredBox(color: effectiveSeparatorColor),
              ),
            Expanded(
              child: InkWell(
                onTap: () => onChanged(i),
                child: DecoratedBox(
                  decoration: i == selectedIndex
                      ? BoxDecoration(color: effectiveSelectedColor)
                      : const BoxDecoration(),
                  child: Center(
                    child: Text(
                      labels[i],
                      style: textStyle.copyWith(
                        color: i == selectedIndex
                            ? effectiveSelectedTextColor
                            : effectiveUnselectedTextColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
