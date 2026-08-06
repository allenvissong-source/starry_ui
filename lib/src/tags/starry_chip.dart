import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// Visual variant of a [StarryChip].
enum StarryChipVariant { filled, outlined, tonal }

/// Compact chip for tags, filters and single-selection.
///
/// Colors resolve from [StarryTokens]; pass [color] to tint selected / tonal
/// states. When [onDelete] is set, [deleteTooltip] is required for a11y.
class StarryChip extends StatelessWidget {
  const StarryChip({
    required this.label,
    super.key,
    this.selected = false,
    this.onTap,
    this.onDelete,
    this.deleteTooltip,
    this.leading,
    this.trailing,
    this.variant = StarryChipVariant.outlined,
    this.enabled = true,
    this.pill = true,
  }) : assert(
         onDelete == null || deleteTooltip != null,
         'When onDelete is provided, deleteTooltip MUST be provided for accessibility.',
       );

  /// Chip text.
  final String label;

  /// Selected state (uses the accent fill).
  final bool selected;

  /// Tap callback; when null the chip is non-interactive.
  final VoidCallback? onTap;

  /// Delete callback; shows a trailing close button.
  final VoidCallback? onDelete;

  /// Tooltip for the delete button (required when [onDelete] is set).
  final String? deleteTooltip;

  /// Optional leading widget (e.g. an icon).
  final Widget? leading;

  /// Optional trailing widget (e.g. a chevron for a dropdown-style chip). Sized
  /// to `iconSm` and tinted with the chip foreground, it renders after the
  /// label. Independent of [onDelete]; when both are set the trailing widget
  /// precedes the delete affordance.
  final Widget? trailing;

  /// Style variant.
  final StarryChipVariant variant;

  /// Enabled state.
  final bool enabled;

  /// Whether the chip is a full capsule (semicircular ends, the default) or a
  /// [StarryRadius.md] rounded rectangle. Set false for a non-capsule chip such
  /// as a boxy country-code / dropdown chip. Defaults to true so existing chips
  /// keep their capsule shape.
  final bool pill;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;

    // Visible pill height (compact) vs. the minimum tap target (§1.5.6). The
    // colored pill always reads [visualHeight]; when a delete affordance is
    // present its *hit region* must be ≥44×44 (repo standard = 48 via
    // `minTouchTarget`). A hit box can exceed the visible icon, but Flutter
    // clips hit testing to every ancestor's own size, so a 48-tall hit box
    // needs a 48-tall layout host — the interactive footprint grows to
    // [hitTarget] while the pill stays painted at [visualHeight], centered.
    final visualHeight = t.controlMetrics.heightXs;
    final hitTarget = t.controlMetrics.minTouchTarget;

    // Corner radius: a full capsule (semicircle ends, height-independent) by
    // default, or the token `radius.md` rounded rectangle when [pill] is false.
    final double chipRadius = pill ? visualHeight / 2 : t.radius.md;

    final (bgColor, fgColor, borderColor) = _resolveColors(t);

    final pillDecoration = BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(chipRadius),
      border: borderColor != null ? Border.all(color: borderColor) : null,
    );

    final labelRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (leading != null) ...<Widget>[
          IconTheme(
            data: IconThemeData(size: t.controlMetrics.iconSm, color: fgColor),
            child: leading!,
          ),
          SizedBox(width: t.spacing.s1),
        ],
        Text(
          label,
          style: t.typography.bodySmall.textStyle.copyWith(
            color: fgColor,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        if (trailing != null) ...<Widget>[
          SizedBox(width: t.spacing.s1),
          IconTheme(
            data: IconThemeData(size: t.controlMetrics.iconSm, color: fgColor),
            child: trailing!,
          ),
        ],
      ],
    );

    Widget content;

    if (onDelete == null) {
      // No delete affordance: the chip is exactly the compact [visualHeight]
      // pill (unchanged layout footprint).
      content = Container(
        height: visualHeight,
        padding: EdgeInsets.symmetric(horizontal: t.spacing.s3),
        decoration: pillDecoration,
        child: labelRow,
      );
    } else {
      // Delete affordance: decouple the 48-tall hit host from the
      // [visualHeight] pill. The InkResponse's own box is [hitTarget] square
      // (real ≥44 hit region, §1.5.6); the close icon is centered inside it.
      final delete = Tooltip(
        message: deleteTooltip!,
        child: Semantics(
          button: true,
          label: deleteTooltip,
          child: InkResponse(
            onTap: enabled ? onDelete : null,
            radius: hitTarget / 2,
            customBorder: const CircleBorder(),
            child: SizedBox.square(
              dimension: hitTarget,
              child: Center(
                child: Icon(
                  Icons.close,
                  size: t.controlMetrics.iconSm,
                  color: fgColor,
                ),
              ),
            ),
          ),
        ),
      );

      // The content row drives the host height to [hitTarget]; the pill
      // background is painted behind it, spanning the full width and inset
      // vertically so it renders at [visualHeight], centered.
      final vInset = (hitTarget - visualHeight) / 2;
      content = Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned(
            left: 0,
            right: 0,
            top: vInset,
            bottom: vInset,
            child: DecoratedBox(decoration: pillDecoration),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: t.spacing.s3),
                child: labelRow,
              ),
              delete,
            ],
          ),
        ],
      );
    }

    if (onTap != null && enabled) {
      content = InkWell(
        borderRadius: BorderRadius.circular(chipRadius),
        onTap: onTap,
        child: content,
      );
    }

    // A Material ancestor is required for the InkWell (tap) and the delete
    // InkResponse (ripple + focus + hover cursor). Provide it whenever the
    // chip has any ink-based interaction.
    if ((onTap != null && enabled) || onDelete != null) {
      content = Material(type: MaterialType.transparency, child: content);
    }

    return content;
  }

  (Color?, Color, Color?) _resolveColors(StarryTokens t) {
    final s = t.semantic;

    if (!enabled) {
      return (null, s.textDisabled, s.border);
    }

    if (selected) {
      return (s.brand, s.onBrand, null);
    }

    switch (variant) {
      case StarryChipVariant.filled:
        return (s.surfaceVariant, s.textPrimary, null);

      case StarryChipVariant.outlined:
        return (null, s.textSecondary, s.border);

      case StarryChipVariant.tonal:
        return (s.surfaceVariant, s.brandStrong, null);
    }
  }
}
