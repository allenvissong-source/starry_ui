import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// Default diameter for the inline spinner. Spinner sizes have no matching
/// `controlMetrics` tier (those are control heights, not spinner sizes), so the
/// inline default lives as a named file-local constant — the counterpart of
/// [_kFullScreenSpinnerSize] (48) used by the full-screen state.
const double _kInlineSpinnerSize = 24.0;

/// Starry UI circular loading indicator.
///
/// Color defaults to the brand token; [size] and [strokeWidth] are behavioral
/// parameters kept as plain doubles so callers can size the spinner inline.
class StarryLoadingIndicator extends StatelessWidget {
  const StarryLoadingIndicator({
    super.key,
    this.size = _kInlineSpinnerSize,
    this.color,
    this.strokeWidth = 3.0,
  });

  /// Diameter of the indicator.
  final double size;

  /// Override color. Defaults to `semantic.brand`.
  final Color? color;

  /// Stroke width of the spinner ring.
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;

    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(color ?? t.semantic.brand),
        ),
      ),
    );
  }
}

/// Full-screen centered loading state with an optional message line.
class StarryFullScreenLoadingIndicator extends StatelessWidget {
  const StarryFullScreenLoadingIndicator({super.key, this.message});

  /// Optional message rendered under the spinner.
  final String? message;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const StarryLoadingIndicator(size: _kFullScreenSpinnerSize),
          if (message != null) ...<Widget>[
            SizedBox(height: t.spacing.s4),
            Text(
              message!,
              style: t.typography.bodyMedium.textStyle.copyWith(
                color: t.semantic.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Spinner diameter for the full-screen loading state. Larger than the inline
/// default (24); no `controlMetrics` height tier matches (nearest `heightMd`
/// is 44 / `heightLg` 48 is a control height, not a spinner size), so it is a
/// named file-local constant.
const double _kFullScreenSpinnerSize = 48;
