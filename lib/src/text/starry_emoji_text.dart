import 'package:emoji_regex/emoji_regex.dart';
import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// Renders text with emoji glyphs routed to a dedicated emoji font family and
/// all other runs routed to a text font family.
///
/// This guarantees consistent emoji rendering (e.g. Twemoji) regardless of
/// whether the primary text font happens to ship a glyph for that codepoint.
///
/// Font families are parameterized rather than hard-wired to any host app:
/// [textFontFamily] defaults to [StarryTypography.fontFamilyBody] and
/// [emojiFontFamily] defaults to [StarryTypography.fontFamilyEmoji]. Consumers
/// bundle the actual font assets in their application.
class StarryEmojiText extends StatelessWidget {
  const StarryEmojiText(
    this.data, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.softWrap,
    this.textFontFamily,
    this.emojiFontFamily,
  });

  /// The text to render, possibly containing emoji.
  final String data;

  /// Base style. When null the ambient [DefaultTextStyle] is used.
  final TextStyle? style;

  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final bool? softWrap;

  /// Font family applied to non-emoji runs. Defaults to
  /// [StarryTypography.fontFamilyBody].
  final String? textFontFamily;

  /// Font family applied to emoji runs. Defaults to
  /// [StarryTypography.fontFamilyEmoji].
  final String? emojiFontFamily;

  @override
  Widget build(BuildContext context) {
    final base = style ?? DefaultTextStyle.of(context).style;
    return Text.rich(
      buildStarryEmojiAwareSpan(
        data,
        baseStyle: base,
        textFontFamily: textFontFamily ?? StarryTypography.fontFamilyBody,
        emojiFontFamily: emojiFontFamily ?? StarryTypography.fontFamilyEmoji,
      ),
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      softWrap: softWrap,
    );
  }
}

/// Builds an [InlineSpan] that routes emoji runs to [emojiFontFamily] and all
/// other runs to [textFontFamily]. Both families disable the ambient fallback
/// chain so each run resolves to exactly the requested font.
InlineSpan buildStarryEmojiAwareSpan(
  String text, {
  required TextStyle baseStyle,
  required String textFontFamily,
  required String emojiFontFamily,
}) {
  final reg = emojiRegex();
  final spans = <InlineSpan>[];
  var start = 0;

  TextSpan textRun(String value) => TextSpan(
    text: value,
    style: baseStyle.copyWith(
      fontFamily: textFontFamily,
      fontFamilyFallback: const <String>[],
    ),
  );

  for (final match in reg.allMatches(text)) {
    if (match.start > start) {
      spans.add(textRun(text.substring(start, match.start)));
    }
    spans.add(
      TextSpan(
        text: match.group(0),
        style: baseStyle.copyWith(
          fontFamily: emojiFontFamily,
          fontFamilyFallback: const <String>[],
        ),
      ),
    );
    start = match.end;
  }

  if (start < text.length) {
    spans.add(textRun(text.substring(start)));
  }

  return TextSpan(style: baseStyle, children: spans);
}
