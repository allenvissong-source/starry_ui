import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../buttons/starry_icon_button.dart';
import '../theme/starry_responsive.dart';
import '../theme/starry_tokens.dart';

/// How [StarryMasterDetailLayout] currently presents its navigation pane.
enum StarryMasterDetailMode {
  /// Pane and detail sit next to each other; the pane takes layout space.
  sideBySide,

  /// Detail fills the box and the pane floats above it as a sheet.
  overlay,
}

/// A two-pane master/detail scaffold whose pane visibility is fully controlled
/// by the host.
///
/// The presentation mode is derived from the *constraint* width via
/// [StarryResponsiveBuilder], not the page width: this widget is typically
/// nested inside an app-level rail, so the page width would overstate the space
/// actually available to it.
///
/// * width >= [breakpoint] entry point → [StarryMasterDetailMode.sideBySide]
/// * narrower → [StarryMasterDetailMode.overlay]
///
/// When [paneVisible] is false in `sideBySide` the pane is removed from the
/// tree entirely (no collapsed strip); the host is responsible for surfacing a
/// re-open affordance inside [detail]. In `overlay` the pane is only mounted
/// while [paneVisible] is true, and tapping the scrim reports `false` through
/// [onPaneVisibleChanged].
class StarryMasterDetailLayout extends StatelessWidget {
  const StarryMasterDetailLayout({
    required this.pane,
    required this.detail,
    required this.paneVisible,
    required this.onPaneVisibleChanged,
    super.key,
    this.paneWidth,
    this.breakpoint = StarryWindowSizeClass.expanded,
  });

  /// Navigation pane content.
  final Widget pane;

  /// Primary content region.
  final Widget detail;

  /// Whether the pane is currently shown. Fully controlled by the host.
  final bool paneVisible;

  /// Reports a visibility change requested from inside the layout (scrim tap).
  final ValueChanged<bool> onPaneVisibleChanged;

  /// Pane width in both modes. Defaults to [defaultPaneWidth] (256).
  final double? paneWidth;

  /// Smallest size class that still renders the pane side by side.
  final StarryWindowSizeClass breakpoint;

  /// Focusable close affordance mounted at the top of the overlay sheet.
  static const ValueKey<String> closeKey = ValueKey<String>(
    'starry-master-detail-overlay-close',
  );

  /// Default width of the navigation pane in both [StarryMasterDetailMode]s.
  ///
  /// A component-level design spec (256 = 4 × `spacing.s16`): a navigation
  /// rail has a fixed canonical width, so it does not live on the spacing
  /// scale. Override per instance via [paneWidth].
  static const double defaultPaneWidth = 256;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final width = paneWidth ?? defaultPaneWidth;

    return StarryResponsiveBuilder(
      builder: (context, sizeClass, constraints) {
        final mode = sizeClass.index >= breakpoint.index
            ? StarryMasterDetailMode.sideBySide
            : StarryMasterDetailMode.overlay;

        if (mode == StarryMasterDetailMode.sideBySide) {
          return _buildSideBySide(context, t, width);
        }
        return _buildOverlay(context, t, width);
      },
    );
  }

  Widget _buildSideBySide(BuildContext context, StarryTokens t, double width) {
    if (!paneVisible) return detail;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(width: width, child: pane),
        _Separator(tokens: t),
        Expanded(child: detail),
      ],
    );
  }

  Widget _buildOverlay(BuildContext context, StarryTokens t, double width) {
    final duration = _duration(context, t);
    final barrierDismissLabel = MaterialLocalizations.of(
      context,
    ).modalBarrierDismissLabel;
    final closeLabel = MaterialLocalizations.of(context).closeButtonTooltip;

    return Stack(
      children: [
        // While the sheet is open the backing detail is inert: its semantics
        // are hidden so screen readers never walk it behind the scrim.
        Positioned.fill(
          child: ExcludeSemantics(excluding: paneVisible, child: detail),
        ),
        if (paneVisible) ...[
          Positioned.fill(
            child: Semantics(
              button: true,
              label: barrierDismissLabel,
              child: GestureDetector(
                onTap: () => onPaneVisibleChanged(false),
                child: ColoredBox(
                  color: t.semantic.textPrimary.withValues(
                    alpha: t.opacity.mediaScrim,
                  ),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            top: 0,
            bottom: 0,
            start: 0,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: duration,
              curve: t.motion.easingStandard,
              builder: (context, value, child) => FractionalTranslation(
                translation: Offset(value - 1, 0),
                child: child,
              ),
              child: FocusScope(
                child: CallbackShortcuts(
                  bindings: <ShortcutActivator, VoidCallback>{
                    const SingleActivator(LogicalKeyboardKey.escape): () =>
                        onPaneVisibleChanged(false),
                  },
                  child: Material(
                    color: t.semantic.surface,
                    elevation: 0,
                    child: SizedBox(
                      width: width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Sheet close affordance: reachable by both pointer
                          // and keyboard. The autofocus Focus moves primary
                          // focus here when the sheet mounts, which is what
                          // routes the Escape shortcut above to this subtree.
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: Focus(
                              autofocus: true,
                              child: StarryIconButton(
                                key: closeKey,
                                icon: Icons.close,
                                tooltip: closeLabel,
                                onPressed: () => onPaneVisibleChanged(false),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(child: pane),
                                _Separator(tokens: t),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Duration _duration(BuildContext context, StarryTokens t) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return reduceMotion ? Duration.zero : t.motion.durationMedium;
  }
}

class _Separator extends StatelessWidget {
  const _Separator({required this.tokens});

  final StarryTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tokens.controlMetrics.borderThin,
      color: tokens.semantic.border,
    );
  }
}
