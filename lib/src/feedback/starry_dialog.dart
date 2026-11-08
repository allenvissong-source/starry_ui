import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';
import 'editor_action_button.dart';

enum StarryDialogTone { neutral, info, warning, destructive }

/// A controlled dialog action. The caller owns submission and navigation.
@immutable
class StarryDialogAction {
  const StarryDialogAction({
    required this.label,
    this.onPressed,
    this.primary = false,
    this.destructive = false,
    this.loading = false,
    this.loadingLabel,
  }) : assert(!loading || loadingLabel != null);

  final String label;
  final VoidCallback? onPressed;
  final bool primary;
  final bool destructive;
  final bool loading;
  final String? loadingLabel;
}

/// Token-driven dialog shell with scrollable content and wrapping actions.
/// Supports custom form/selection content without owning business state.
class StarryDialog extends StatelessWidget {
  const StarryDialog({
    required this.title,
    required this.actions,
    this.message,
    this.content,
    this.tone = StarryDialogTone.neutral,
    super.key,
  }) : assert(message == null || content == null),
       assert(actions.length > 0, 'Provide an explicit closing action.');

  final String title;
  final String? message;
  final Widget? content;
  final StarryDialogTone tone;
  final List<StarryDialogAction> actions;

  /// Opens a modal in the selected navigator. The builder's context is inside
  /// that route; use it for Navigator.pop, including with nested navigators.
  ///
  /// [barrierDismissible] controls outside taps and Escape. System back/pop
  /// guards belong to the caller (use PopScope when editing must be protected).
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
  }) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    return showDialog<T>(
      context: context,
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierColor: t.semantic.scrim,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      requestFocus: true,
      traversalEdgeBehavior: TraversalEdgeBehavior.closedLoop,
      animationStyle: AnimationStyle(
        duration: reducedMotion ? Duration.zero : t.motion.durationShort,
        reverseDuration: reducedMotion ? Duration.zero : t.motion.durationShort,
        curve: t.motion.easingStandard,
        reverseCurve: t.motion.easingStandard.flipped,
      ),
    );
  }

  /// Returns true on confirmation, false on the explicit cancel action and
  /// null on route dismissal. Labels are supplied by the application's i18n.
  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    required String confirmLabel,
    required String cancelLabel,
    String? message,
    StarryDialogTone tone = StarryDialogTone.neutral,
    bool barrierDismissible = true,
    bool useRootNavigator = true,
  }) => show<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    useRootNavigator: useRootNavigator,
    builder: (dialogContext) => StarryDialog(
      title: title,
      message: message,
      tone: tone,
      actions: [
        StarryDialogAction(
          label: cancelLabel,
          onPressed: () => Navigator.of(dialogContext).pop(false),
        ),
        StarryDialogAction(
          label: confirmLabel,
          primary: true,
          destructive: tone == StarryDialogTone.destructive,
          onPressed: () => Navigator.of(dialogContext).pop(true),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    assert(
      actions.where((action) => action.primary).length <= 1,
      'A dialog has at most one primary action.',
    );
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;
    final (icon, color) = switch (tone) {
      StarryDialogTone.neutral => (null, s.textPrimary),
      StarryDialogTone.info => (Icons.info_outline, s.infoStrong),
      StarryDialogTone.warning => (
        Icons.warning_amber_rounded,
        s.warningStrong,
      ),
      StarryDialogTone.destructive => (
        Icons.warning_amber_rounded,
        s.errorStrong,
      ),
    };
    final body = message == null ? content : Text(message!);

    return Dialog(
      backgroundColor: s.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(t.radius.xl),
        side: BorderSide(
          color: s.border,
          width: t.controlMetrics.restBorderWidth,
        ),
      ),
      constraints: BoxConstraints(maxWidth: t.breakpoints.compact),
      insetPadding: EdgeInsets.all(t.spacing.s4),
      insetAnimationDuration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : t.motion.durationShort,
      insetAnimationCurve: t.motion.easingStandard,
      child: Padding(
        padding: EdgeInsets.all(t.spacing.s6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The title and body scroll together on short screens, leaving
            // closing actions visible even with an on-screen keyboard.
            Flexible(
              child: SingleChildScrollView(
                primary: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (icon != null) ...[
                          ExcludeSemantics(
                            child: Icon(
                              icon,
                              size: t.controlMetrics.iconXl,
                              color: color,
                            ),
                          ),
                          SizedBox(width: t.spacing.s2),
                        ],
                        Expanded(
                          child: Semantics(
                            namesRoute: true,
                            header: true,
                            child: Text(
                              title,
                              style: t.typography.titleLarge.textStyle.copyWith(
                                color: s.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (body != null) ...[
                      SizedBox(height: t.spacing.s4),
                      DefaultTextStyle.merge(
                        style: t.typography.bodyLarge.textStyle.copyWith(
                          color: s.textPrimary,
                        ),
                        child: body,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: t.spacing.s6),
            Flexible(
              child: SingleChildScrollView(
                primary: false,
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: t.spacing.s2,
                  runSpacing: t.spacing.s2,
                  children: [
                    for (final action in actions)
                      Semantics(
                        liveRegion: action.loading,
                        child: StarryEditorActionButton(
                          label: action.loading
                              ? action.loadingLabel!
                              : action.label,
                          primary: action.primary,
                          destructive: action.destructive,
                          loading: action.loading,
                          onPressed: action.onPressed,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
