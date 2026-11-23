import 'package:flutter/material.dart';

import 'starry_button.dart';

/// Lightweight Starry action for secondary and inline operations.
///
/// A thin, opinionated wrapper over [StarryButton]: it pins the transparent
/// `text` variant and the `radius.md` rounded-rectangle shape (`pill: false`)
/// so call sites express intent ("this is an inline text action") without
/// repeating the `variant / pill` pair. All color / height / density / tap
/// target / typography come from the underlying token-driven [StarryButton]
/// (foreground `brandStrong`, `VisualDensity.standard`, ≥48 `padded` hit
/// target — AGENTS.md §1.5.2/§1.5.6), so this action shares one source of
/// truth with every other Starry button instead of hand-rolling a second
/// `TextButton`.
class StarryTextButton extends StatelessWidget {
  const StarryTextButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.loading = false,
    this.fullWidth = false,
  });

  /// Button text.
  final String label;

  /// Tap callback. When null (or while [loading]) the button is disabled.
  final VoidCallback? onPressed;

  /// Optional leading icon.
  final IconData? icon;

  /// Whether to show the inline loading spinner (also disables the tap).
  final bool loading;

  /// Whether the button fills its slot width. Defaults to false (sizes to
  /// content) for an inline secondary action.
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return StarryButton(
      label: label,
      onPressed: onPressed,
      variant: StarryButtonVariant.text,
      icon: icon,
      loading: loading,
      fullWidth: fullWidth,
      pill: false,
    );
  }
}
