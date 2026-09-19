import 'package:flutter/material.dart';

import '../interactions/starry_press_scale.dart';
import '../tags/starry_tag.dart';
import '../theme/starry_tokens.dart';

/// A horizontal "referenced resource" row: a leading media/icon thumbnail, a
/// title with an optional type tag, a one-line description, and an optional
/// top-right remove badge.
///
/// The leading thumbnail resolves in priority order: [coverImage] (an
/// `ImageProvider`), then [coverUrl] (network), then the [leadingIcon]
/// placeholder. The type tag uses [StarryTag] with [StarryTagStatus.accent].
class StarryReferenceCard extends StatelessWidget {
  const StarryReferenceCard({
    required this.title,
    required this.description,
    super.key,
    this.coverUrl,
    this.coverImage,
    this.typeLabel,
    this.leadingIcon = Icons.insert_drive_file_outlined,
    this.onTap,
    this.onRemove,
  }) : assert(
         coverUrl == null || coverImage == null,
         'Provide either coverUrl or coverImage, not both.',
       );

  final String title;
  final String description;
  final String? coverUrl;
  final ImageProvider<Object>? coverImage;
  final String? typeLabel;
  final IconData leadingIcon;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;
    final radius = BorderRadius.circular(t.radius.xl);
    final leadingSize = t.controlMetrics.heightMd;

    final card = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: t.elevation.level2,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Material(
          color: s.surface,
          child: InkWell(
            onTap: onTap,
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.all(t.spacing.s2),
              child: Row(
                children: <Widget>[
                  _buildLeading(context, size: leadingSize),
                  SizedBox(width: t.spacing.s2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: t.typography.labelMedium.textStyle
                                    .copyWith(
                                      color: s.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                            if ((typeLabel ?? '').trim().isNotEmpty) ...[
                              SizedBox(width: t.spacing.s1),
                              StarryTag(
                                label: typeLabel!,
                                status: StarryTagStatus.accent,
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: t.spacing.s1),
                        Text(
                          description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.typography.labelSmall.textStyle.copyWith(
                            color: s.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final tappableCard = onTap == null
        ? card
        : StarryPressScale(onTap: onTap, child: card);

    if (onRemove == null) return tappableCard;

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        tappableCard,
        Positioned(
          top: -8,
          right: -8,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(t.radius.full),
              onTap: onRemove,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: s.surface,
                  borderRadius: BorderRadius.circular(t.radius.full),
                  boxShadow: t.elevation.level2,
                ),
                child: Padding(
                  padding: EdgeInsets.all(t.spacing.s1),
                  child: Icon(
                    Icons.close,
                    size: t.spacing.s3,
                    color: s.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeading(BuildContext context, {required double size}) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;
    Widget child;
    if (coverImage != null) {
      child = Image(image: coverImage!, fit: BoxFit.cover);
    } else if ((coverUrl ?? '').trim().isNotEmpty) {
      child = Image.network(
        coverUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            Icon(leadingIcon, color: s.brand, size: t.spacing.s6),
      );
    } else {
      child = Icon(leadingIcon, color: s.brand, size: t.spacing.s6);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: s.brand.withValues(alpha: t.opacity.selectedSurface),
        borderRadius: BorderRadius.circular(t.radius.lg),
        border: Border.all(
          color: s.brand.withValues(alpha: t.opacity.accentSurface),
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: child,
    );
  }
}
