import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../theme/starry_tokens.dart';
import 'starry_desktop_window_frame.dart';

const _labels = StarryWindowControlLabels(
  minimize: '最小化',
  maximize: '最大化',
  restore: '还原',
  close: '关闭窗口',
);

@UseCase(name: 'All Variants', type: StarryDesktopWindowFrame)
Widget allVariantsStarryDesktopWindowFrame(BuildContext context) {
  final tokens = Theme.of(context).extension<StarryTokens>()!;
  return SingleChildScrollView(
    padding: EdgeInsets.all(tokens.spacing.s6),
    child: Column(
      children: <Widget>[
        _preview(
          platform: StarryDesktopPlatform.windows,
          visualState: StarryWindowVisualState.normal,
          isFocused: true,
        ),
        SizedBox(height: tokens.spacing.s6),
        _preview(
          platform: StarryDesktopPlatform.windows,
          visualState: StarryWindowVisualState.maximized,
          isFocused: false,
        ),
        SizedBox(height: tokens.spacing.s6),
        _preview(
          platform: StarryDesktopPlatform.macOS,
          visualState: StarryWindowVisualState.normal,
          isFocused: true,
        ),
        SizedBox(height: tokens.spacing.s6),
        _preview(
          platform: StarryDesktopPlatform.macOS,
          visualState: StarryWindowVisualState.maximized,
          isFocused: false,
        ),
        SizedBox(height: tokens.spacing.s6),
        // Linux carries no host control buttons: the chrome is the bare
        // surround, so the preview shows the same surface without controls.
        _preview(
          platform: StarryDesktopPlatform.linux,
          visualState: StarryWindowVisualState.normal,
          isFocused: true,
        ),
        SizedBox(height: tokens.spacing.s6),
        // Fullscreen drops the frame entirely: only application content shows.
        _preview(
          platform: StarryDesktopPlatform.windows,
          visualState: StarryWindowVisualState.fullscreen,
          isFocused: true,
        ),
      ],
    ),
  );
}

@UseCase(name: 'Playground', type: StarryDesktopWindowFrame)
Widget playgroundStarryDesktopWindowFrame(BuildContext context) {
  final platform = context.knobs.object.dropdown<StarryDesktopPlatform>(
    label: 'Platform',
    options: StarryDesktopPlatform.values,
    labelBuilder: (value) => value.name,
  );
  final visualState = context.knobs.object.dropdown<StarryWindowVisualState>(
    label: 'Window state',
    options: StarryWindowVisualState.values,
    labelBuilder: (value) => value.name,
  );
  final isFocused = context.knobs.boolean(label: 'Focused', initialValue: true);
  final title = context.knobs.string(label: 'Title', initialValue: 'Starry');

  return _preview(
    platform: platform,
    visualState: visualState,
    isFocused: isFocused,
    title: title,
  );
}

Widget _preview({
  required StarryDesktopPlatform platform,
  required StarryWindowVisualState visualState,
  required bool isFocused,
  String title = 'Starry',
}) {
  return SizedBox(
    height: StarrySpacingTokens.s16 * 5,
    child: StarryDesktopWindowFrame(
      platform: platform,
      visualState: visualState,
      isFocused: isFocused,
      labels: _labels,
      onMinimize: () {},
      onToggleMaximize: () {},
      onClose: () {},
      dragAreaBuilder: (context, child) => child,
      title: Text(title),
      child: Builder(
        builder: (context) {
          final tokens = Theme.of(context).extension<StarryTokens>()!;
          return ColoredBox(
            color: tokens.semantic.backgroundSecondary,
            child: const Center(child: Text('APPLICATION CONTENT')),
          );
        },
      ),
    ),
  );
}
