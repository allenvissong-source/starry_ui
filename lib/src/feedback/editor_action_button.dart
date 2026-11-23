import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// Shared accessible action for code feedback and dialog footers.
/// Kept internal; consumers use the owning component's semantic parameters.
class StarryEditorActionButton extends StatelessWidget {
  const StarryEditorActionButton({
    required this.label,
    this.onPressed,
    this.primary = false,
    this.destructive = false,
    this.loading = false,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool primary;
  final bool destructive;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;
    // Dark-theme errorStrong is a pale red; onError's white would not meet
    // text contrast. The existing deep error surface provides readable ink.
    final onDanger = Theme.of(context).brightness == Brightness.dark
        ? s.errorBg
        : s.onError;
    final foreground = primary
        ? (destructive ? onDanger : s.onBrand)
        : (destructive ? s.errorStrong : s.textSecondary);
    final background = primary
        ? (destructive ? s.errorStrong : s.brand)
        : Colors.transparent;
    final disabled = loading || onPressed == null;

    return TextButton(
      onPressed: disabled ? null : onPressed,
      style: ButtonStyle(
        visualDensity: VisualDensity.standard,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: WidgetStatePropertyAll(
          Size(
            t.controlMetrics.minTouchTarget,
            t.controlMetrics.minTouchTarget,
          ),
        ),
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(
            horizontal: t.spacing.s4,
            vertical: t.spacing.s2,
          ),
        ),
        textStyle: WidgetStatePropertyAll(t.typography.labelLarge.textStyle),
        foregroundColor: WidgetStatePropertyAll(
          disabled && !loading ? s.textDisabled : foreground,
        ),
        backgroundColor: WidgetStatePropertyAll(
          disabled && !loading && primary ? s.surfaceVariant : background,
        ),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return foreground.withValues(alpha: t.opacity.statePressed);
          }
          if (states.contains(WidgetState.focused)) {
            return foreground.withValues(alpha: t.opacity.stateFocus);
          }
          if (states.contains(WidgetState.hovered)) {
            return foreground.withValues(alpha: t.opacity.stateHover);
          }
          return Colors.transparent;
        }),
        side: WidgetStateProperty.resolveWith(
          (states) => BorderSide(
            color: states.contains(WidgetState.focused)
                ? s.brandStrong
                : Colors.transparent,
            width: t.controlMetrics.focusBorderWidth,
          ),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(t.radius.md),
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (loading || icon != null) ...[
            ExcludeSemantics(
              child: loading && !MediaQuery.disableAnimationsOf(context)
                  ? SizedBox.square(
                      dimension: t.controlMetrics.iconMd,
                      child: CircularProgressIndicator(
                        strokeWidth: t.controlMetrics.borderThick,
                        color: foreground,
                      ),
                    )
                  : Icon(
                      loading ? Icons.hourglass_empty : icon,
                      size: t.controlMetrics.iconMd,
                    ),
            ),
            SizedBox(width: t.spacing.s2),
          ],
          Flexible(child: Text(label, textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}
