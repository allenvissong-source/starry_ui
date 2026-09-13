import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// Desktop visual language supported by [StarryDesktopWindowFrame].
enum StarryDesktopPlatform { windows, macOS, linux }

/// Visual state of the host desktop window.
enum StarryWindowVisualState { normal, maximized, fullscreen }

/// Localized labels used by the desktop window controls.
@immutable
class StarryWindowControlLabels {
  const StarryWindowControlLabels({
    required this.minimize,
    required this.maximize,
    required this.restore,
    required this.close,
  });

  final String minimize;
  final String maximize;
  final String restore;
  final String close;
}

/// Wraps a title-bar region with the host application's native drag behavior.
typedef StarryWindowDragAreaBuilder =
    Widget Function(BuildContext context, Widget child);

/// A complete token-driven desktop window surface.
///
/// The frame owns only presentation and interaction affordances. Native window
/// state, dragging, resizing, and system side effects stay in the host app and
/// are injected through callbacks and [dragAreaBuilder].
class StarryDesktopWindowFrame extends StatelessWidget {
  const StarryDesktopWindowFrame({
    required this.platform,
    required this.visualState,
    required this.isFocused,
    required this.labels,
    required this.onMinimize,
    required this.onToggleMaximize,
    required this.onClose,
    required this.dragAreaBuilder,
    required this.child,
    super.key,
    this.title,
  });

  static const ValueKey<String> frameKey = ValueKey<String>(
    'starry-desktop-window-frame',
  );
  static const ValueKey<String> contentKey = ValueKey<String>(
    'starry-desktop-window-content',
  );
  static const ValueKey<String> titleBarKey = ValueKey<String>(
    'starry-desktop-window-title-bar',
  );
  static const ValueKey<String> minimizeKey = ValueKey<String>(
    'starry-window-minimize',
  );
  static const ValueKey<String> maximizeKey = ValueKey<String>(
    'starry-window-maximize',
  );
  static const ValueKey<String> closeKey = ValueKey<String>(
    'starry-window-close',
  );

  final StarryDesktopPlatform platform;
  final StarryWindowVisualState visualState;
  final bool isFocused;
  final StarryWindowControlLabels labels;
  final VoidCallback onMinimize;
  final VoidCallback onToggleMaximize;
  final VoidCallback onClose;
  final StarryWindowDragAreaBuilder dragAreaBuilder;
  final Widget child;
  final Widget? title;

  @override
  Widget build(BuildContext context) {
    if (visualState == StarryWindowVisualState.fullscreen) {
      return child;
    }

    final tokens = Theme.of(context).extension<StarryTokens>()!;
    final isNormal = visualState == StarryWindowVisualState.normal;
    // Kept close to the OS corner rounding. The compositor rounds the window
    // itself, so a larger radius here would cut a second, tighter arc inside
    // that one and expose the transparent window background as a nick at each
    // corner; matching it keeps the two arcs coincident.
    final radius = isNormal ? tokens.radius.sm : tokens.radius.none;
    final borderWidth = isNormal
        ? tokens.controlMetrics.borderThin
        : tokens.spacing.s0;

    // The chrome is one continuous surround: the title bar is part of the
    // frame, not the first row of the app. The app is inset on all four sides
    // and clipped to its own smaller radius, so it reads as a picture inside a
    // mat rather than a pane bolted under a strip.
    final inset = tokens.spacing.s2;
    final contentRadius = tokens.radius.xs;

    final content = DecoratedBox(
      key: contentKey,
      decoration: BoxDecoration(
        color: tokens.semantic.surface,
        borderRadius: BorderRadius.circular(contentRadius),
        border: Border.all(
          color: tokens.semantic.border,
          width: tokens.controlMetrics.borderThin,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(contentRadius),
        child: child,
      ),
    );

    // `foregroundDecoration` carries the border deliberately: the clipped
    // `ColoredBox` below fills the whole box and would paint straight over a
    // hairline drawn by the background `decoration`, leaving the frame with no
    // visible edge of its own. Painting it in the foreground keeps the border
    // on top of the subtree.
    //
    // No `boxShadow` here either. The window background is transparent and the
    // frame now sits flush against the window bounds, so any shadow would fall
    // outside the window and be clipped away by the compositor.
    final frame = Container(
      key: frameKey,
      decoration: BoxDecoration(
        // The surround carries its own tone so the inset app surface reads as
        // recessed into it. Uses the tertiary step rather than the secondary
        // one: against a white app surface the secondary step is too close to
        // read as a frame at all.
        color: tokens.semantic.backgroundTertiary,
        borderRadius: BorderRadius.circular(radius),
      ),
      foregroundDecoration: isNormal
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: isFocused
                    ? tokens.semantic.borderStrong
                    : tokens.semantic.border,
                width: borderWidth,
              ),
            )
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: ColoredBox(
          color: tokens.semantic.backgroundTertiary,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: tokens.controlMetrics.heightLg,
                child: Overlay.wrap(
                  // Mounted above the app navigator, the title bar needs its
                  // own bounded overlay for tooltips. Application content must
                  // stay outside the overlay boundary so it keeps resolving
                  // the navigator overlay and the root View used by EditableText.
                  child: _DesktopTitleBar(
                    platform: platform,
                    visualState: visualState,
                    isFocused: isFocused,
                    labels: labels,
                    onMinimize: onMinimize,
                    onToggleMaximize: onToggleMaximize,
                    onClose: onClose,
                    dragAreaBuilder: dragAreaBuilder,
                    title: title,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: inset,
                    right: inset,
                    bottom: inset,
                  ),
                  child: content,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Deliberately unpadded. An outer gutter over a transparent window
    // background is not empty space, it is a hole: the desktop shows straight
    // through it, which reads as a detached ring around the app.
    return frame;
  }
}

class _DesktopTitleBar extends StatelessWidget {
  const _DesktopTitleBar({
    required this.platform,
    required this.visualState,
    required this.isFocused,
    required this.labels,
    required this.onMinimize,
    required this.onToggleMaximize,
    required this.onClose,
    required this.dragAreaBuilder,
    required this.title,
  });

  final StarryDesktopPlatform platform;
  final StarryWindowVisualState visualState;
  final bool isFocused;
  final StarryWindowControlLabels labels;
  final VoidCallback onMinimize;
  final VoidCallback onToggleMaximize;
  final VoidCallback onClose;
  final StarryWindowDragAreaBuilder dragAreaBuilder;
  final Widget? title;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<StarryTokens>()!;
    final isMaximized = visualState == StarryWindowVisualState.maximized;
    final controls = switch (platform) {
      StarryDesktopPlatform.windows => <Widget>[
        _WindowsControlButton(
          key: StarryDesktopWindowFrame.minimizeKey,
          kind: _WindowControlKind.minimize,
          tooltip: labels.minimize,
          onPressed: onMinimize,
        ),
        _WindowsControlButton(
          key: StarryDesktopWindowFrame.maximizeKey,
          kind: isMaximized
              ? _WindowControlKind.restore
              : _WindowControlKind.maximize,
          tooltip: isMaximized ? labels.restore : labels.maximize,
          onPressed: onToggleMaximize,
        ),
        _WindowsControlButton(
          key: StarryDesktopWindowFrame.closeKey,
          kind: _WindowControlKind.close,
          tooltip: labels.close,
          onPressed: onClose,
        ),
      ],
      StarryDesktopPlatform.macOS => <Widget>[
        _MacControlButton(
          key: StarryDesktopWindowFrame.closeKey,
          kind: _WindowControlKind.close,
          tooltip: labels.close,
          onPressed: onClose,
        ),
        _MacControlButton(
          key: StarryDesktopWindowFrame.minimizeKey,
          kind: _WindowControlKind.minimize,
          tooltip: labels.minimize,
          onPressed: onMinimize,
        ),
        _MacControlButton(
          key: StarryDesktopWindowFrame.maximizeKey,
          kind: isMaximized
              ? _WindowControlKind.restore
              : _WindowControlKind.maximize,
          tooltip: isMaximized ? labels.restore : labels.maximize,
          onPressed: onToggleMaximize,
        ),
      ],
      StarryDesktopPlatform.linux => const <Widget>[],
    };

    final controlsRow = Padding(
      // Keeps the controls off the rounded outer edge of the surround.
      padding: EdgeInsets.symmetric(horizontal: tokens.spacing.s1),
      child: Row(mainAxisSize: MainAxisSize.min, children: controls),
    );
    final titleStyle = tokens.typography.labelMedium.textStyle.copyWith(
      color: isFocused
          ? tokens.semantic.textSecondary
          : tokens.semantic.textTertiary,
      fontWeight: FontWeight.w600,
    );

    return SizedBox(
      key: StarryDesktopWindowFrame.titleBarKey,
      height: tokens.controlMetrics.heightLg,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // No fill and no bottom divider: the strip is part of the continuous
          // surround, so painting either would visually cut the frame in two.
          dragAreaBuilder(
            context,
            Center(
              child: DefaultTextStyle(
                style: titleStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                child: title ?? const SizedBox.shrink(),
              ),
            ),
          ),
          if (controls.isNotEmpty)
            Align(
              alignment: platform == StarryDesktopPlatform.macOS
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: controlsRow,
            ),
        ],
      ),
    );
  }
}

enum _WindowControlKind { minimize, maximize, restore, close }

class _WindowsControlButton extends StatefulWidget {
  const _WindowsControlButton({
    required this.kind,
    required this.tooltip,
    required this.onPressed,
    super.key,
  });

  final _WindowControlKind kind;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  State<_WindowsControlButton> createState() => _WindowsControlButtonState();
}

class _WindowsControlButtonState extends State<_WindowsControlButton> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<StarryTokens>()!;
    final isClose = widget.kind == _WindowControlKind.close;
    final background = _hovered || _focused
        ? (isClose ? tokens.semantic.error : tokens.semantic.surfaceVariant)
        : Colors.transparent;
    final foreground = isClose && (_hovered || _focused)
        ? tokens.semantic.onError
        : tokens.semantic.textPrimary;

    return Tooltip(
      message: widget.tooltip,
      child: Semantics(
        button: true,
        label: widget.tooltip,
        child: SizedBox.square(
          dimension: tokens.controlMetrics.heightLg,
          child: Material(
            color: background,
            // Rounded so the hover fill sits inside the surround instead of
            // reading as a square notch cut out of it.
            borderRadius: BorderRadius.circular(tokens.radius.sm),
            child: InkWell(
              borderRadius: BorderRadius.circular(tokens.radius.sm),
              onTap: widget.onPressed,
              onHover: (value) => setState(() => _hovered = value),
              onFocusChange: (value) => setState(() => _focused = value),
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              // Pressed feedback only: hover/focus already paint their own
              // opaque fill on the Material above. Scoping the overlay to the
              // pressed state keeps those layers untouched and stacks the MD3
              // pressed step (statePressed) over them instead.
              overlayColor:
                  WidgetStateProperty.resolveWith<Color?>((states) {
                    if (states.contains(WidgetState.pressed)) {
                      return tokens.semantic.textPrimary.withValues(
                        alpha: tokens.opacity.statePressed,
                      );
                    }
                    return Colors.transparent;
                  }),
              child: Icon(
                switch (widget.kind) {
                  _WindowControlKind.minimize => Icons.minimize,
                  _WindowControlKind.maximize => Icons.crop_square,
                  _WindowControlKind.restore => Icons.filter_none,
                  _WindowControlKind.close => Icons.close,
                },
                color: foreground,
                size: tokens.controlMetrics.iconSm,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MacControlButton extends StatefulWidget {
  const _MacControlButton({
    required this.kind,
    required this.tooltip,
    required this.onPressed,
    super.key,
  });

  final _WindowControlKind kind;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  State<_MacControlButton> createState() => _MacControlButtonState();
}

class _MacControlButtonState extends State<_MacControlButton> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<StarryTokens>()!;
    // Reduced motion: mirror StarryMasterDetailLayout._duration so the dot
    // reveal / glyph fade switch state on the next frame instead of animating.
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final duration = reduceMotion ? Duration.zero : tokens.motion.durationShort;
    final fill = switch (widget.kind) {
      _WindowControlKind.close => tokens.semantic.error,
      _WindowControlKind.minimize => tokens.semantic.warning,
      _WindowControlKind.maximize ||
      _WindowControlKind.restore => tokens.semantic.success,
    };
    final showGlyph = _hovered || _focused;

    return Tooltip(
      message: widget.tooltip,
      child: Semantics(
        button: true,
        label: widget.tooltip,
        child: SizedBox.square(
          dimension: tokens.controlMetrics.heightLg,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: widget.onPressed,
              onHover: (value) => setState(() => _hovered = value),
              onFocusChange: (value) => setState(() => _focused = value),
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              overlayColor:
                  WidgetStateProperty.resolveWith<Color?>((states) {
                    if (states.contains(WidgetState.pressed)) {
                      return tokens.semantic.textPrimary.withValues(
                        alpha: tokens.opacity.statePressed,
                      );
                    }
                    return Colors.transparent;
                  }),
              child: Center(
                child: AnimatedContainer(
                  duration: duration,
                  curve: tokens.motion.easingStandard,
                  width: tokens.indicator.dotMd,
                  height: tokens.indicator.dotMd,
                  decoration: BoxDecoration(
                    color: fill,
                    shape: BoxShape.circle,
                    border: _focused
                        ? Border.all(
                            color: tokens.semantic.textPrimary,
                            width: tokens.controlMetrics.borderThin,
                          )
                        : null,
                  ),
                  child: AnimatedOpacity(
                    duration: duration,
                    opacity: showGlyph ? 1 : 0,
                    child: Icon(
                      switch (widget.kind) {
                        _WindowControlKind.close => Icons.close,
                        _WindowControlKind.minimize => Icons.remove,
                        _WindowControlKind.maximize => Icons.add,
                        _WindowControlKind.restore => Icons.unfold_less,
                      },
                      color: tokens.semantic.textPrimary,
                      size: tokens.controlMetrics.iconXs,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
