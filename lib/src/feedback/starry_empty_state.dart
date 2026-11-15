import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../media/starry_illustration.dart';
import '../theme/starry_tokens.dart';

/// Starry UI empty-state placeholder.
///
/// Shown when a list / page has no data. All spacing, colors and typography
/// resolve from [StarryTokens]; the default icon is [Icons.inbox_outlined].
class StarryEmptyState extends StatelessWidget {
  const StarryEmptyState({
    super.key,
    this.icon,
    this.illustration,
    this.title,
    this.message,
    this.action,
  }) : assert(icon == null || illustration == null),
       assert(illustration == null || title != null || message != null);

  /// Custom leading icon. When null a default [Icons.inbox_outlined] is shown.
  final Widget? icon;

  /// Decorative artwork for a genuine empty-content state.
  ///
  /// Mutually exclusive with [icon]. The host must supply [title] or [message]
  /// so the meaning remains visible below the image and accessible to readers.
  final StarryIllustration? illustration;

  /// Primary title line.
  final String? title;

  /// Secondary description line.
  final String? message;

  /// Optional call-to-action rendered below the message.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    if (illustration == null) {
      return Center(child: _buildContent(context));
    }
    final t = Theme.of(context).extension<StarryTokens>()!;
    // Keep intrinsic measurement available for SliverFillRemaining. The image
    // shrinks to its parent's width, while short viewports can scroll the copy.
    final maxSide = t.breakpoints.compact / 2;
    return Center(
      child: SingleChildScrollView(
        child: _buildContent(
          context,
          visual: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxSide,
              maxHeight: math.min(
                maxSide,
                MediaQuery.sizeOf(context).height / 2,
              ),
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.asset(
                illustration!.assetPath,
                package: StarryIllustration.packageName,
                fit: BoxFit.contain,
                excludeFromSemantics: true,
                frameBuilder: (context, child, frame, synchronouslyLoaded) =>
                    frame != null || synchronouslyLoaded
                    ? child
                    : const SizedBox.expand(),
                errorBuilder: (context, error, stackTrace) {
                  FlutterError.reportError(
                    FlutterErrorDetails(
                      exception: error,
                      stack: stackTrace,
                      library: 'starry_ui',
                      context: ErrorDescription('loading bundled illustration'),
                    ),
                  );
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, {Widget? visual}) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;

    return Padding(
      padding: EdgeInsets.all(t.spacing.s4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (visual != null)
            visual
          else if (icon != null)
            IconTheme(
              data: IconThemeData(color: s.textTertiary, size: t.spacing.s16),
              child: icon!,
            )
          else
            Icon(
              Icons.inbox_outlined,
              size: t.spacing.s16,
              color: s.textTertiary,
            ),
          SizedBox(height: t.spacing.s4),
          if (title != null)
            Text(
              title!,
              style: t.typography.titleMedium.textStyle.copyWith(
                color: s.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          if (message != null) ...<Widget>[
            SizedBox(height: t.spacing.s2),
            Text(
              message!,
              style: t.typography.bodySmall.textStyle.copyWith(
                color: s.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...<Widget>[
            SizedBox(height: t.spacing.s6),
            action!,
          ],
        ],
      ),
    );
  }
}
