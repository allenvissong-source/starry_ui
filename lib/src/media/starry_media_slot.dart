import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../buttons/starry_button.dart';
import '../components/starry_surface.dart';
import '../theme/starry_tokens.dart';

/// A single media field. The app owns loading, picking, uploading and removal;
/// this widget owns the empty/preview/status layout and independent actions.
/// Removal callbacks should perform the app's confirmation when required.
class StarryMediaSlot extends StatelessWidget {
  const StarryMediaSlot({
    required this.label,
    required this.emptyLabel,
    this.preview,
    this.emptyIcon = Icons.image_outlined,
    this.aspectRatio = 1,
    this.onAdd,
    this.addLabel,
    this.onReplace,
    this.replaceLabel,
    this.onRemove,
    this.removeLabel,
    this.readOnly = false,
    this.loading = false,
    this.loadingLabel,
    this.errorText,
    super.key,
  }) : assert(aspectRatio > 0),
       assert(onAdd == null || addLabel != null),
       assert(onReplace == null || replaceLabel != null),
       assert(onRemove == null || removeLabel != null),
       assert(!loading || loadingLabel != null);

  final String label;
  final String emptyLabel;
  final Widget? preview;
  final IconData emptyIcon;
  final double aspectRatio;
  final VoidCallback? onAdd;
  final String? addLabel;
  final VoidCallback? onReplace;
  final String? replaceLabel;
  final VoidCallback? onRemove;
  final String? removeLabel;
  final bool readOnly;
  final bool loading;
  final String? loadingLabel;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final innerRadius = math.max(
      0.0,
      t.radius.xxl - t.spacing.s3 - t.controlMetrics.borderThin,
    );
    final actions = <Widget>[
      if (preview == null && onAdd != null)
        StarryButton(
          label: addLabel!,
          icon: Icons.add,
          variant: StarryButtonVariant.tonal,
          onPressed: loading ? null : onAdd,
        ),
      if (preview != null && onReplace != null)
        StarryButton(
          label: replaceLabel!,
          icon: Icons.swap_horiz,
          variant: StarryButtonVariant.tonal,
          onPressed: loading ? null : onReplace,
        ),
      if (preview != null && onRemove != null)
        StarryButton(
          label: removeLabel!,
          icon: Icons.delete_outline,
          variant: StarryButtonVariant.destructive,
          onPressed: loading ? null : onRemove,
        ),
    ];
    return StarrySurface(
      elevated: false,
      borderRadius: BorderRadius.circular(t.radius.xxl),
      padding: EdgeInsets.all(t.spacing.s3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: t.typography.labelLarge.textStyle.copyWith(
              color: t.semantic.textPrimary,
            ),
          ),
          SizedBox(height: t.spacing.s3),
          ClipRRect(
            borderRadius: BorderRadius.circular(innerRadius),
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: ColoredBox(
                color: t.semantic.backgroundSecondary,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (preview != null)
                      preview!
                    else
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(t.spacing.s3),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                emptyIcon,
                                size: t.controlMetrics.iconXl,
                                color: t.semantic.textTertiary,
                              ),
                              SizedBox(height: t.spacing.s2),
                              Text(
                                emptyLabel,
                                textAlign: TextAlign.center,
                                style: t.typography.bodyMedium.textStyle
                                    .copyWith(color: t.semantic.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (loading)
                      ColoredBox(
                        color: t.semantic.surface.withValues(
                          alpha: t.opacity.disabledContent,
                        ),
                        child: Center(
                          child: MediaQuery.disableAnimationsOf(context)
                              ? Icon(
                                  Icons.hourglass_empty,
                                  size: t.controlMetrics.iconXl,
                                  color: t.semantic.brandStrong,
                                )
                              : SizedBox.square(
                                  dimension: t.controlMetrics.iconXl,
                                  child: CircularProgressIndicator(
                                    color: t.semantic.brandStrong,
                                    strokeWidth: t.controlMetrics.borderThick,
                                  ),
                                ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (loading || errorText != null) ...[
            SizedBox(height: t.spacing.s2),
            Semantics(
              liveRegion: true,
              child: Text(
                errorText ?? loadingLabel!,
                style: t.typography.bodySmall.textStyle.copyWith(
                  color: errorText != null
                      ? t.semantic.errorStrong
                      : t.semantic.textSecondary,
                ),
              ),
            ),
          ],
          if (!readOnly && actions.isNotEmpty) ...[
            SizedBox(height: t.spacing.s3),
            Wrap(
              spacing: t.spacing.s2,
              runSpacing: t.spacing.s2,
              children: actions,
            ),
          ],
        ],
      ),
    );
  }
}
