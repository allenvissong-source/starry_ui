import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// Shared outlined border builder for Starry text inputs.
///
/// Radius comes from [StarryTokens.radius], stroke width from
/// [StarryControlMetrics]. [width] defaults to the rest-state stroke
/// (`restBorderWidth`); pass `focusBorderWidth` for the focused state.
OutlineInputBorder starryInputBorder(
  StarryTokens t,
  Color color, {
  double? width,
}) =>
    OutlineInputBorder(
      borderRadius: BorderRadius.circular(t.radius.md),
      borderSide: BorderSide(
        color: color,
        width: width ?? t.controlMetrics.restBorderWidth,
      ),
    );
