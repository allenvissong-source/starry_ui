import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'starry_tokens.dart';

Color _starryLerpColor(Color a, Color b, double t) => Color.lerp(a, b, t)!;

@immutable
class StarrySurfaceTokens {
  const StarrySurfaceTokens({
    required this.pageBg,
    required this.appUnderlayBg,
    required this.panelBg,
    required this.cardBg,
    required this.surfaceElevated,
    required this.divider,
    required this.border,
    required this.glassBg,
    required this.glassBorder,
    required this.glassGlow,
    required this.inputBg,
    required this.inputBorder,
    required this.inputFocusedBorder,
    required this.shadow,
    required this.scrim,
  });

  factory StarrySurfaceTokens.light(StarryTokens starry) =>
      StarrySurfaceTokens._from(starry);

  factory StarrySurfaceTokens.dark(StarryTokens starry) =>
      StarrySurfaceTokens._from(starry);

  factory StarrySurfaceTokens._from(StarryTokens starry) {
    final s = starry.semantic;
    return StarrySurfaceTokens(
      pageBg: s.background,
      appUnderlayBg: s.background,
      panelBg: s.backgroundSecondary,
      cardBg: s.surface,
      surfaceElevated: s.surfaceVariant,
      divider: s.border,
      border: s.border,
      glassBg: s.surface.withValues(alpha: starry.glass.surfaceOpacity),
      glassBorder: s.onMedia.withValues(alpha: starry.glass.borderOpacity),
      glassGlow: starry.brand.brandGlow,
      inputBg: s.surfaceVariant,
      inputBorder: s.border,
      inputFocusedBorder: s.brandStrong,
      shadow: s.shadow,
      scrim: s.scrim,
    );
  }

  final Color pageBg;
  final Color appUnderlayBg;
  final Color panelBg;
  final Color cardBg;
  final Color surfaceElevated;
  final Color divider;
  final Color border;
  final Color glassBg;
  final Color glassBorder;
  final Color glassGlow;
  final Color inputBg;
  final Color inputBorder;
  final Color inputFocusedBorder;
  final Color shadow;
  final Color scrim;

  StarrySurfaceTokens copyWith({
    Color? pageBg,
    Color? appUnderlayBg,
    Color? panelBg,
    Color? cardBg,
    Color? surfaceElevated,
    Color? divider,
    Color? border,
    Color? glassBg,
    Color? glassBorder,
    Color? glassGlow,
    Color? inputBg,
    Color? inputBorder,
    Color? inputFocusedBorder,
    Color? shadow,
    Color? scrim,
  }) {
    return StarrySurfaceTokens(
      pageBg: pageBg ?? this.pageBg,
      appUnderlayBg: appUnderlayBg ?? this.appUnderlayBg,
      panelBg: panelBg ?? this.panelBg,
      cardBg: cardBg ?? this.cardBg,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      divider: divider ?? this.divider,
      border: border ?? this.border,
      glassBg: glassBg ?? this.glassBg,
      glassBorder: glassBorder ?? this.glassBorder,
      glassGlow: glassGlow ?? this.glassGlow,
      inputBg: inputBg ?? this.inputBg,
      inputBorder: inputBorder ?? this.inputBorder,
      inputFocusedBorder: inputFocusedBorder ?? this.inputFocusedBorder,
      shadow: shadow ?? this.shadow,
      scrim: scrim ?? this.scrim,
    );
  }

  StarrySurfaceTokens lerp(StarrySurfaceTokens? other, double t) {
    if (other is! StarrySurfaceTokens) return this;
    return StarrySurfaceTokens(
      pageBg: _starryLerpColor(pageBg, other.pageBg, t),
      appUnderlayBg: _starryLerpColor(appUnderlayBg, other.appUnderlayBg, t),
      panelBg: _starryLerpColor(panelBg, other.panelBg, t),
      cardBg: _starryLerpColor(cardBg, other.cardBg, t),
      surfaceElevated: _starryLerpColor(
        surfaceElevated,
        other.surfaceElevated,
        t,
      ),
      divider: _starryLerpColor(divider, other.divider, t),
      border: _starryLerpColor(border, other.border, t),
      glassBg: _starryLerpColor(glassBg, other.glassBg, t),
      glassBorder: _starryLerpColor(glassBorder, other.glassBorder, t),
      glassGlow: _starryLerpColor(glassGlow, other.glassGlow, t),
      inputBg: _starryLerpColor(inputBg, other.inputBg, t),
      inputBorder: _starryLerpColor(inputBorder, other.inputBorder, t),
      inputFocusedBorder: _starryLerpColor(
        inputFocusedBorder,
        other.inputFocusedBorder,
        t,
      ),
      shadow: _starryLerpColor(shadow, other.shadow, t),
      scrim: _starryLerpColor(scrim, other.scrim, t),
    );
  }
}

@immutable
class StarryTextColorTokens {
  const StarryTextColorTokens({
    required this.primary,
    required this.secondary,
    required this.muted,
    required this.dim,
    required this.disabled,
    required this.inverse,
    required this.onAccent,
    required this.onMedia,
    required this.link,
    required this.linkHover,
    required this.placeholder,
  });

  factory StarryTextColorTokens.light(StarryTokens starry) {
    final s = starry.semantic;
    return StarryTextColorTokens(
      primary: s.textPrimary,
      secondary: s.textSecondary,
      muted: s.textSecondary,
      dim: s.textTertiary,
      disabled: s.textDisabled,
      inverse: s.onInverseSurface,
      onAccent: s.onBrand,
      onMedia: s.onMedia,
      link: starry.blue.s600,
      linkHover: starry.blue.s700,
      placeholder: s.textTertiary,
    );
  }

  factory StarryTextColorTokens.dark(StarryTokens starry) {
    final s = starry.semantic;
    return StarryTextColorTokens(
      primary: s.textPrimary,
      secondary: s.textSecondary,
      muted: s.textSecondary,
      dim: s.textTertiary,
      disabled: s.textDisabled,
      inverse: s.onInverseSurface,
      onAccent: s.onBrand,
      onMedia: s.onMedia,
      link: starry.blue.s300,
      linkHover: starry.blue.s200,
      placeholder: s.textTertiary,
    );
  }

  final Color primary;
  final Color secondary;
  final Color muted;
  final Color dim;
  final Color disabled;
  final Color inverse;
  final Color onAccent;
  final Color onMedia;
  final Color link;
  final Color linkHover;
  final Color placeholder;

  StarryTextColorTokens copyWith({
    Color? primary,
    Color? secondary,
    Color? muted,
    Color? dim,
    Color? disabled,
    Color? inverse,
    Color? onAccent,
    Color? onMedia,
    Color? link,
    Color? linkHover,
    Color? placeholder,
  }) {
    return StarryTextColorTokens(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      muted: muted ?? this.muted,
      dim: dim ?? this.dim,
      disabled: disabled ?? this.disabled,
      inverse: inverse ?? this.inverse,
      onAccent: onAccent ?? this.onAccent,
      onMedia: onMedia ?? this.onMedia,
      link: link ?? this.link,
      linkHover: linkHover ?? this.linkHover,
      placeholder: placeholder ?? this.placeholder,
    );
  }

  StarryTextColorTokens lerp(StarryTextColorTokens? other, double t) {
    if (other is! StarryTextColorTokens) return this;
    return StarryTextColorTokens(
      primary: _starryLerpColor(primary, other.primary, t),
      secondary: _starryLerpColor(secondary, other.secondary, t),
      muted: _starryLerpColor(muted, other.muted, t),
      dim: _starryLerpColor(dim, other.dim, t),
      disabled: _starryLerpColor(disabled, other.disabled, t),
      inverse: _starryLerpColor(inverse, other.inverse, t),
      onAccent: _starryLerpColor(onAccent, other.onAccent, t),
      onMedia: _starryLerpColor(onMedia, other.onMedia, t),
      link: _starryLerpColor(link, other.link, t),
      linkHover: _starryLerpColor(linkHover, other.linkHover, t),
      placeholder: _starryLerpColor(placeholder, other.placeholder, t),
    );
  }
}

class StarryInteractionStateTokens {
  const StarryInteractionStateTokens({
    required this.fg,
    required this.bg,
    required this.border,
    required this.icon,
    required this.stateLayer,
    required this.shadow,
  });

  final Color fg;
  final Color bg;
  final Color border;
  final Color icon;
  final Color stateLayer;
  final Color shadow;

  StarryInteractionStateTokens copyWith({
    Color? fg,
    Color? bg,
    Color? border,
    Color? icon,
    Color? stateLayer,
    Color? shadow,
  }) {
    return StarryInteractionStateTokens(
      fg: fg ?? this.fg,
      bg: bg ?? this.bg,
      border: border ?? this.border,
      icon: icon ?? this.icon,
      stateLayer: stateLayer ?? this.stateLayer,
      shadow: shadow ?? this.shadow,
    );
  }

  static StarryInteractionStateTokens lerp(
    StarryInteractionStateTokens a,
    StarryInteractionStateTokens b,
    double t,
  ) {
    return StarryInteractionStateTokens(
      fg: _starryLerpColor(a.fg, b.fg, t),
      bg: _starryLerpColor(a.bg, b.bg, t),
      border: _starryLerpColor(a.border, b.border, t),
      icon: _starryLerpColor(a.icon, b.icon, t),
      stateLayer: _starryLerpColor(a.stateLayer, b.stateLayer, t),
      shadow: _starryLerpColor(a.shadow, b.shadow, t),
    );
  }
}

@immutable
class StarryInteractionTokens {
  const StarryInteractionTokens({
    required this.rest,
    required this.hover,
    required this.focus,
    required this.pressed,
    required this.selected,
    required this.disabled,
  });

  factory StarryInteractionTokens.light(StarryTokens starry) =>
      StarryInteractionTokens._from(starry);

  factory StarryInteractionTokens.dark(StarryTokens starry) =>
      StarryInteractionTokens._from(starry);

  factory StarryInteractionTokens._from(StarryTokens starry) {
    final s = starry.semantic;
    final opacity = starry.opacity;
    StarryInteractionStateTokens state({
      required Color fg,
      required Color bg,
      required Color border,
      required Color icon,
      required Color stateLayer,
      required Color shadow,
    }) => StarryInteractionStateTokens(
      fg: fg,
      bg: bg,
      border: border,
      icon: icon,
      stateLayer: stateLayer,
      shadow: shadow,
    );
    return StarryInteractionTokens(
      rest: state(
        fg: s.textPrimary,
        bg: Colors.transparent,
        border: s.border,
        icon: s.textSecondary,
        stateLayer: Colors.transparent,
        shadow: Colors.transparent,
      ),
      hover: state(
        fg: s.textPrimary,
        bg: s.brand.withValues(alpha: opacity.stateHover),
        border: s.brand.withValues(alpha: opacity.accentSurface),
        icon: s.brandStrong,
        stateLayer: s.brand.withValues(alpha: opacity.stateHover),
        shadow: s.shadow,
      ),
      focus: state(
        fg: s.textPrimary,
        bg: s.brand.withValues(alpha: opacity.stateFocus),
        border: s.brandStrong,
        icon: s.brandStrong,
        stateLayer: s.brand.withValues(alpha: opacity.stateFocus),
        shadow: s.shadow,
      ),
      pressed: state(
        fg: s.textPrimary,
        bg: s.brand.withValues(alpha: opacity.statePressed),
        border: s.brandStrong,
        icon: s.brandStrong,
        stateLayer: s.brand.withValues(alpha: opacity.statePressed),
        shadow: s.shadow,
      ),
      selected: state(
        fg: s.brandStrong,
        bg: s.brand.withValues(alpha: opacity.selectedSurface),
        border: s.brandStrong,
        icon: s.brandStrong,
        stateLayer: s.brand.withValues(alpha: opacity.selectedSurface),
        shadow: s.shadow,
      ),
      disabled: state(
        fg: s.textDisabled,
        bg: s.surfaceVariant.withValues(alpha: opacity.disabledContainer),
        border: s.border,
        icon: s.textDisabled,
        stateLayer: Colors.transparent,
        shadow: Colors.transparent,
      ),
    );
  }

  final StarryInteractionStateTokens rest;
  final StarryInteractionStateTokens hover;
  final StarryInteractionStateTokens focus;
  final StarryInteractionStateTokens pressed;
  final StarryInteractionStateTokens selected;
  final StarryInteractionStateTokens disabled;

  StarryInteractionTokens copyWith({
    StarryInteractionStateTokens? rest,
    StarryInteractionStateTokens? hover,
    StarryInteractionStateTokens? focus,
    StarryInteractionStateTokens? pressed,
    StarryInteractionStateTokens? selected,
    StarryInteractionStateTokens? disabled,
  }) {
    return StarryInteractionTokens(
      rest: rest ?? this.rest,
      hover: hover ?? this.hover,
      focus: focus ?? this.focus,
      pressed: pressed ?? this.pressed,
      selected: selected ?? this.selected,
      disabled: disabled ?? this.disabled,
    );
  }

  StarryInteractionTokens lerp(StarryInteractionTokens? other, double t) {
    if (other is! StarryInteractionTokens) return this;
    return StarryInteractionTokens(
      rest: StarryInteractionStateTokens.lerp(rest, other.rest, t),
      hover: StarryInteractionStateTokens.lerp(hover, other.hover, t),
      focus: StarryInteractionStateTokens.lerp(focus, other.focus, t),
      pressed: StarryInteractionStateTokens.lerp(pressed, other.pressed, t),
      selected: StarryInteractionStateTokens.lerp(selected, other.selected, t),
      disabled: StarryInteractionStateTokens.lerp(disabled, other.disabled, t),
    );
  }
}

@immutable
class StarryChromeThemeTokens {
  const StarryChromeThemeTokens({
    required this.topBar,
    required this.sideRail,
    required this.dock,
    required this.search,
    required this.header,
    required this.systemOverlay,
  });

  factory StarryChromeThemeTokens.light(StarryTokens starry) =>
      StarryChromeThemeTokens._from(starry);

  factory StarryChromeThemeTokens.dark(StarryTokens starry) =>
      StarryChromeThemeTokens._from(starry);

  factory StarryChromeThemeTokens._from(StarryTokens starry) {
    final s = starry.semantic;
    return StarryChromeThemeTokens(
      topBar: s.surface,
      sideRail: s.surface,
      dock: s.surface,
      search: s.surface,
      header: s.surface,
      systemOverlay: s.background,
    );
  }

  final Color topBar;
  final Color sideRail;
  final Color dock;
  final Color search;
  final Color header;
  final Color systemOverlay;

  SystemUiOverlayStyle systemOverlayStyleFor({
    Color? backgroundColor,
    Color statusBarColor = Colors.transparent,
    Color? systemNavigationBarColor,
  }) {
    return buildStarrySystemOverlayStyleForColor(
      backgroundColor ?? systemOverlay,
      statusBarColor: statusBarColor,
      systemNavigationBarColor: systemNavigationBarColor,
    );
  }

  StarryChromeThemeTokens copyWith({
    Color? topBar,
    Color? sideRail,
    Color? dock,
    Color? search,
    Color? header,
    Color? systemOverlay,
  }) {
    return StarryChromeThemeTokens(
      topBar: topBar ?? this.topBar,
      sideRail: sideRail ?? this.sideRail,
      dock: dock ?? this.dock,
      search: search ?? this.search,
      header: header ?? this.header,
      systemOverlay: systemOverlay ?? this.systemOverlay,
    );
  }

  StarryChromeThemeTokens lerp(StarryChromeThemeTokens? other, double t) {
    if (other is! StarryChromeThemeTokens) return this;
    return StarryChromeThemeTokens(
      topBar: _starryLerpColor(topBar, other.topBar, t),
      sideRail: _starryLerpColor(sideRail, other.sideRail, t),
      dock: _starryLerpColor(dock, other.dock, t),
      search: _starryLerpColor(search, other.search, t),
      header: _starryLerpColor(header, other.header, t),
      systemOverlay: _starryLerpColor(systemOverlay, other.systemOverlay, t),
    );
  }
}

@immutable
class StarryFeedTokens {
  const StarryFeedTokens({required this.avatar, required this.feedPlaceholder});

  factory StarryFeedTokens.light(StarryTokens starry) =>
      StarryFeedTokens._from(starry);

  factory StarryFeedTokens.dark(StarryTokens starry) =>
      StarryFeedTokens._from(starry);

  factory StarryFeedTokens._from(StarryTokens starry) {
    final s = starry.semantic;
    return StarryFeedTokens(
      avatar: s.brand.withValues(alpha: starry.opacity.accentSurface),
      feedPlaceholder: s.surfaceVariant,
    );
  }

  final Color avatar;
  final Color feedPlaceholder;

  StarryFeedTokens copyWith({Color? avatar, Color? feedPlaceholder}) {
    return StarryFeedTokens(
      avatar: avatar ?? this.avatar,
      feedPlaceholder: feedPlaceholder ?? this.feedPlaceholder,
    );
  }

  StarryFeedTokens lerp(StarryFeedTokens? other, double t) {
    if (other is! StarryFeedTokens) return this;
    return StarryFeedTokens(
      avatar: _starryLerpColor(avatar, other.avatar, t),
      feedPlaceholder: _starryLerpColor(
        feedPlaceholder,
        other.feedPlaceholder,
        t,
      ),
    );
  }
}

@immutable
class StarryMediaTokens {
  const StarryMediaTokens({
    required this.mediaStageBg,
    required this.mediaFrameBorder,
    required this.mediaPlaceholderBg,
    required this.mediaPlaceholderIcon,
    required this.mediaScrim,
    required this.mediaLabelBg,
    required this.mediaLabelText,
    required this.dominantTintBlend,
    required this.blurRadius,
  });

  factory StarryMediaTokens.light(StarryTokens starry) =>
      StarryMediaTokens._from(starry);

  factory StarryMediaTokens.dark(StarryTokens starry) =>
      StarryMediaTokens._from(starry);

  factory StarryMediaTokens._from(StarryTokens starry) {
    final s = starry.semantic;
    return StarryMediaTokens(
      mediaStageBg: s.backgroundSecondary,
      mediaFrameBorder: s.border,
      mediaPlaceholderBg: s.surfaceVariant,
      mediaPlaceholderIcon: s.brand,
      mediaScrim: s.mediaOverlayEnd,
      mediaLabelBg: s.mediaOverlayEnd,
      mediaLabelText: s.onMedia,
      dominantTintBlend: s.brand.withValues(
        alpha: starry.opacity.accentSurface,
      ),
      blurRadius: starry.glass.blurSigma,
    );
  }

  final Color mediaStageBg;
  final Color mediaFrameBorder;
  final Color mediaPlaceholderBg;
  final Color mediaPlaceholderIcon;
  final Color mediaScrim;
  final Color mediaLabelBg;
  final Color mediaLabelText;
  final Color dominantTintBlend;
  final double blurRadius;

  StarryMediaTokens copyWith({
    Color? mediaStageBg,
    Color? mediaFrameBorder,
    Color? mediaPlaceholderBg,
    Color? mediaPlaceholderIcon,
    Color? mediaScrim,
    Color? mediaLabelBg,
    Color? mediaLabelText,
    Color? dominantTintBlend,
    double? blurRadius,
  }) {
    return StarryMediaTokens(
      mediaStageBg: mediaStageBg ?? this.mediaStageBg,
      mediaFrameBorder: mediaFrameBorder ?? this.mediaFrameBorder,
      mediaPlaceholderBg: mediaPlaceholderBg ?? this.mediaPlaceholderBg,
      mediaPlaceholderIcon: mediaPlaceholderIcon ?? this.mediaPlaceholderIcon,
      mediaScrim: mediaScrim ?? this.mediaScrim,
      mediaLabelBg: mediaLabelBg ?? this.mediaLabelBg,
      mediaLabelText: mediaLabelText ?? this.mediaLabelText,
      dominantTintBlend: dominantTintBlend ?? this.dominantTintBlend,
      blurRadius: blurRadius ?? this.blurRadius,
    );
  }

  StarryMediaTokens lerp(StarryMediaTokens? other, double t) {
    if (other is! StarryMediaTokens) return this;
    return StarryMediaTokens(
      mediaStageBg: _starryLerpColor(mediaStageBg, other.mediaStageBg, t),
      mediaFrameBorder: _starryLerpColor(
        mediaFrameBorder,
        other.mediaFrameBorder,
        t,
      ),
      mediaPlaceholderBg: _starryLerpColor(
        mediaPlaceholderBg,
        other.mediaPlaceholderBg,
        t,
      ),
      mediaPlaceholderIcon: _starryLerpColor(
        mediaPlaceholderIcon,
        other.mediaPlaceholderIcon,
        t,
      ),
      mediaScrim: _starryLerpColor(mediaScrim, other.mediaScrim, t),
      mediaLabelBg: _starryLerpColor(mediaLabelBg, other.mediaLabelBg, t),
      mediaLabelText: _starryLerpColor(mediaLabelText, other.mediaLabelText, t),
      dominantTintBlend: _starryLerpColor(
        dominantTintBlend,
        other.dominantTintBlend,
        t,
      ),
      blurRadius: lerpDouble(blurRadius, other.blurRadius, t)!,
    );
  }
}

@immutable
class StarryCodeTokens {
  const StarryCodeTokens({
    required this.codeSurface,
    required this.codeText,
    required this.inlineCode,
    required this.lineNumber,
    required this.diffAdded,
    required this.diffRemoved,
    required this.diffChanged,
    required this.diffMarker,
    required this.copyIdle,
    required this.copySuccess,
  });

  factory StarryCodeTokens.light(StarryTokens starry) =>
      StarryCodeTokens._from(starry);

  factory StarryCodeTokens.dark(StarryTokens starry) =>
      StarryCodeTokens._from(starry);

  factory StarryCodeTokens._from(StarryTokens starry) {
    final s = starry.semantic;
    return StarryCodeTokens(
      codeSurface: s.backgroundSecondary,
      codeText: s.textPrimary,
      inlineCode: s.surfaceVariant,
      lineNumber: s.textTertiary,
      diffAdded: s.success.withValues(alpha: starry.opacity.accentSurface),
      diffRemoved: s.error.withValues(alpha: starry.opacity.accentSurface),
      diffChanged: s.warning.withValues(alpha: starry.opacity.accentSurface),
      diffMarker: s.brand,
      copyIdle: s.textSecondary,
      copySuccess: s.success,
    );
  }

  final Color codeSurface;
  final Color codeText;
  final Color inlineCode;
  final Color lineNumber;
  final Color diffAdded;
  final Color diffRemoved;
  final Color diffChanged;
  final Color diffMarker;
  final Color copyIdle;
  final Color copySuccess;

  StarryCodeTokens copyWith({
    Color? codeSurface,
    Color? codeText,
    Color? inlineCode,
    Color? lineNumber,
    Color? diffAdded,
    Color? diffRemoved,
    Color? diffChanged,
    Color? diffMarker,
    Color? copyIdle,
    Color? copySuccess,
  }) {
    return StarryCodeTokens(
      codeSurface: codeSurface ?? this.codeSurface,
      codeText: codeText ?? this.codeText,
      inlineCode: inlineCode ?? this.inlineCode,
      lineNumber: lineNumber ?? this.lineNumber,
      diffAdded: diffAdded ?? this.diffAdded,
      diffRemoved: diffRemoved ?? this.diffRemoved,
      diffChanged: diffChanged ?? this.diffChanged,
      diffMarker: diffMarker ?? this.diffMarker,
      copyIdle: copyIdle ?? this.copyIdle,
      copySuccess: copySuccess ?? this.copySuccess,
    );
  }

  StarryCodeTokens lerp(StarryCodeTokens? other, double t) {
    if (other is! StarryCodeTokens) return this;
    return StarryCodeTokens(
      codeSurface: _starryLerpColor(codeSurface, other.codeSurface, t),
      codeText: _starryLerpColor(codeText, other.codeText, t),
      inlineCode: _starryLerpColor(inlineCode, other.inlineCode, t),
      lineNumber: _starryLerpColor(lineNumber, other.lineNumber, t),
      diffAdded: _starryLerpColor(diffAdded, other.diffAdded, t),
      diffRemoved: _starryLerpColor(diffRemoved, other.diffRemoved, t),
      diffChanged: _starryLerpColor(diffChanged, other.diffChanged, t),
      diffMarker: _starryLerpColor(diffMarker, other.diffMarker, t),
      copyIdle: _starryLerpColor(copyIdle, other.copyIdle, t),
      copySuccess: _starryLerpColor(copySuccess, other.copySuccess, t),
    );
  }
}

@immutable
class StarryMetricTokens {
  const StarryMetricTokens({
    required this.statCard,
    required this.progressTrack,
    required this.progressValue,
    required this.sliderTrack,
    required this.sliderThumb,
    required this.ratioBar,
    required this.statusIndicator,
  });

  factory StarryMetricTokens.light(StarryTokens starry) =>
      StarryMetricTokens._from(starry);

  factory StarryMetricTokens.dark(StarryTokens starry) =>
      StarryMetricTokens._from(starry);

  factory StarryMetricTokens._from(StarryTokens starry) {
    final s = starry.semantic;
    return StarryMetricTokens(
      statCard: s.surface,
      progressTrack: s.border,
      progressValue: s.brandStrong,
      sliderTrack: s.brand.withValues(alpha: starry.opacity.accentSurface),
      sliderThumb: s.brandStrong,
      ratioBar: s.brandStrong,
      statusIndicator: s.success,
    );
  }

  final Color statCard;
  final Color progressTrack;
  final Color progressValue;
  final Color sliderTrack;
  final Color sliderThumb;
  final Color ratioBar;
  final Color statusIndicator;

  StarryMetricTokens copyWith({
    Color? statCard,
    Color? progressTrack,
    Color? progressValue,
    Color? sliderTrack,
    Color? sliderThumb,
    Color? ratioBar,
    Color? statusIndicator,
  }) {
    return StarryMetricTokens(
      statCard: statCard ?? this.statCard,
      progressTrack: progressTrack ?? this.progressTrack,
      progressValue: progressValue ?? this.progressValue,
      sliderTrack: sliderTrack ?? this.sliderTrack,
      sliderThumb: sliderThumb ?? this.sliderThumb,
      ratioBar: ratioBar ?? this.ratioBar,
      statusIndicator: statusIndicator ?? this.statusIndicator,
    );
  }

  StarryMetricTokens lerp(StarryMetricTokens? other, double t) {
    if (other is! StarryMetricTokens) return this;
    return StarryMetricTokens(
      statCard: _starryLerpColor(statCard, other.statCard, t),
      progressTrack: _starryLerpColor(progressTrack, other.progressTrack, t),
      progressValue: _starryLerpColor(progressValue, other.progressValue, t),
      sliderTrack: _starryLerpColor(sliderTrack, other.sliderTrack, t),
      sliderThumb: _starryLerpColor(sliderThumb, other.sliderThumb, t),
      ratioBar: _starryLerpColor(ratioBar, other.ratioBar, t),
      statusIndicator: _starryLerpColor(
        statusIndicator,
        other.statusIndicator,
        t,
      ),
    );
  }
}

class StarryStatusColorTokens {
  const StarryStatusColorTokens({
    required this.fg,
    required this.bg,
    required this.border,
    required this.onBg,
  });

  final Color fg;
  final Color bg;
  final Color border;
  final Color onBg;

  StarryStatusColorTokens copyWith({
    Color? fg,
    Color? bg,
    Color? border,
    Color? onBg,
  }) {
    return StarryStatusColorTokens(
      fg: fg ?? this.fg,
      bg: bg ?? this.bg,
      border: border ?? this.border,
      onBg: onBg ?? this.onBg,
    );
  }

  static StarryStatusColorTokens lerp(
    StarryStatusColorTokens a,
    StarryStatusColorTokens b,
    double t,
  ) {
    return StarryStatusColorTokens(
      fg: _starryLerpColor(a.fg, b.fg, t),
      bg: _starryLerpColor(a.bg, b.bg, t),
      border: _starryLerpColor(a.border, b.border, t),
      onBg: _starryLerpColor(a.onBg, b.onBg, t),
    );
  }
}

@immutable
class StarrySemanticStatusTokens {
  const StarrySemanticStatusTokens({
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.brand,
  });

  /// Wired from the single design authority ([StarryTokens]); the fg is the
  /// semantic role and bg/border/onBg are its derived tints.
  factory StarrySemanticStatusTokens.fromStarry({
    required StarryTokens starry,
    required bool isDark,
  }) {
    StarryStatusColorTokens tone(Color fg) => StarryStatusColorTokens(
      fg: fg,
      bg: fg.withValues(alpha: isDark ? 0.16 : 0.12),
      border: fg.withValues(alpha: 0.4),
      onBg: fg,
    );
    return StarrySemanticStatusTokens(
      success: tone(starry.semantic.success),
      warning: tone(starry.semantic.warning),
      error: tone(starry.semantic.error),
      info: tone(starry.semantic.info),
      brand: tone(starry.semantic.brand),
    );
  }
  final StarryStatusColorTokens success;
  final StarryStatusColorTokens warning;
  final StarryStatusColorTokens error;
  final StarryStatusColorTokens info;
  final StarryStatusColorTokens brand;

  StarrySemanticStatusTokens copyWith({
    StarryStatusColorTokens? success,
    StarryStatusColorTokens? warning,
    StarryStatusColorTokens? error,
    StarryStatusColorTokens? info,
    StarryStatusColorTokens? brand,
  }) {
    return StarrySemanticStatusTokens(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      brand: brand ?? this.brand,
    );
  }

  StarrySemanticStatusTokens lerp(StarrySemanticStatusTokens? other, double t) {
    if (other is! StarrySemanticStatusTokens) return this;
    return StarrySemanticStatusTokens(
      success: StarryStatusColorTokens.lerp(success, other.success, t),
      warning: StarryStatusColorTokens.lerp(warning, other.warning, t),
      error: StarryStatusColorTokens.lerp(error, other.error, t),
      info: StarryStatusColorTokens.lerp(info, other.info, t),
      brand: StarryStatusColorTokens.lerp(brand, other.brand, t),
    );
  }
}

SystemUiOverlayStyle buildStarrySystemOverlayStyleForColor(
  Color backgroundColor, {
  Color statusBarColor = Colors.transparent,
  Color? systemNavigationBarColor,
}) {
  final backgroundBrightness = ThemeData.estimateBrightnessForColor(
    backgroundColor,
  );
  final iconBrightness = backgroundBrightness == Brightness.light
      ? Brightness.dark
      : Brightness.light;
  final statusBarBrightness = iconBrightness == Brightness.light
      ? Brightness.dark
      : Brightness.light;
  return SystemUiOverlayStyle(
    statusBarColor: statusBarColor,
    statusBarIconBrightness: iconBrightness,
    statusBarBrightness: statusBarBrightness,
    systemNavigationBarColor: systemNavigationBarColor ?? statusBarColor,
    systemNavigationBarIconBrightness: iconBrightness,
  );
}

@immutable
class StarryApplicationTokens extends ThemeExtension<StarryApplicationTokens> {
  const StarryApplicationTokens({
    required this.surface,
    required this.text,
    required this.interaction,
    required this.chrome,
    required this.feed,
    required this.media,
    required this.code,
    required this.metric,
    required this.status,
  });

  factory StarryApplicationTokens.from(
    StarryTokens starry,
    Brightness brightness,
  ) {
    final isDark = brightness == Brightness.dark;
    return StarryApplicationTokens(
      surface: isDark
          ? StarrySurfaceTokens.dark(starry)
          : StarrySurfaceTokens.light(starry),
      text: isDark
          ? StarryTextColorTokens.dark(starry)
          : StarryTextColorTokens.light(starry),
      interaction: isDark
          ? StarryInteractionTokens.dark(starry)
          : StarryInteractionTokens.light(starry),
      chrome: isDark
          ? StarryChromeThemeTokens.dark(starry)
          : StarryChromeThemeTokens.light(starry),
      feed: isDark
          ? StarryFeedTokens.dark(starry)
          : StarryFeedTokens.light(starry),
      media: isDark
          ? StarryMediaTokens.dark(starry)
          : StarryMediaTokens.light(starry),
      code: isDark
          ? StarryCodeTokens.dark(starry)
          : StarryCodeTokens.light(starry),
      metric: isDark
          ? StarryMetricTokens.dark(starry)
          : StarryMetricTokens.light(starry),
      status: StarrySemanticStatusTokens.fromStarry(
        starry: starry,
        isDark: isDark,
      ),
    );
  }

  final StarrySurfaceTokens surface;
  final StarryTextColorTokens text;
  final StarryInteractionTokens interaction;
  final StarryChromeThemeTokens chrome;
  final StarryFeedTokens feed;
  final StarryMediaTokens media;
  final StarryCodeTokens code;
  final StarryMetricTokens metric;
  final StarrySemanticStatusTokens status;

  @override
  StarryApplicationTokens copyWith({
    StarrySurfaceTokens? surface,
    StarryTextColorTokens? text,
    StarryInteractionTokens? interaction,
    StarryChromeThemeTokens? chrome,
    StarryFeedTokens? feed,
    StarryMediaTokens? media,
    StarryCodeTokens? code,
    StarryMetricTokens? metric,
    StarrySemanticStatusTokens? status,
  }) => StarryApplicationTokens(
    surface: surface ?? this.surface,
    text: text ?? this.text,
    interaction: interaction ?? this.interaction,
    chrome: chrome ?? this.chrome,
    feed: feed ?? this.feed,
    media: media ?? this.media,
    code: code ?? this.code,
    metric: metric ?? this.metric,
    status: status ?? this.status,
  );

  @override
  StarryApplicationTokens lerp(
    ThemeExtension<StarryApplicationTokens>? other,
    double t,
  ) {
    if (other is! StarryApplicationTokens) return this;
    return StarryApplicationTokens(
      surface: surface.lerp(other.surface, t),
      text: text.lerp(other.text, t),
      interaction: interaction.lerp(other.interaction, t),
      chrome: chrome.lerp(other.chrome, t),
      feed: feed.lerp(other.feed, t),
      media: media.lerp(other.media, t),
      code: code.lerp(other.code, t),
      metric: metric.lerp(other.metric, t),
      status: status.lerp(other.status, t),
    );
  }
}

extension StarryApplicationTokensContext on BuildContext {
  StarryTokens get starryTokens => Theme.of(this).extension<StarryTokens>()!;

  StarryApplicationTokens get starryApplicationTokens =>
      Theme.of(this).extension<StarryApplicationTokens>()!;
}
