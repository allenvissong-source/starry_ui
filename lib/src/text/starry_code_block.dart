import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../components/starry_surface.dart';
import '../feedback/editor_action_button.dart';
import '../theme/starry_application_tokens.dart';

/// Selectable, wrapping code display. Does not parse, reformat or edit source.
///
/// Supplying [copyLabel] enables copying and requires the other feedback labels.
/// [onCopy] can override the platform clipboard writer (e.g. in an embed).
/// Successful feedback stays until the source changes or copying is retried.
class StarryCodeBlock extends StatefulWidget {
  const StarryCodeBlock({
    required this.code,
    this.title,
    this.language,
    this.maxHeight,
    this.copyLabel,
    this.copyingLabel,
    this.copiedLabel,
    this.copyErrorLabel,
    this.onCopy,
    this.onCopyError,
    super.key,
  }) : assert(
         maxHeight == null || (maxHeight > 0 && maxHeight < double.infinity),
       ),
       assert(
         copyLabel == null ||
             (copyingLabel != null &&
                 copiedLabel != null &&
                 copyErrorLabel != null),
         'Copying requires localized pending, success and failure labels.',
       );

  final String code;
  final String? title;

  /// Display-only language label. Syntax parsing belongs to the caller.
  final String? language;

  /// Optional limit for the code viewport, excluding header and feedback.
  /// A limited viewport scrolls vertically; long source lines always wrap.
  final double? maxHeight;
  final String? copyLabel;
  final String? copyingLabel;
  final String? copiedLabel;
  final String? copyErrorLabel;
  final Future<void> Function(String code)? onCopy;
  final void Function(Object error, StackTrace stackTrace)? onCopyError;

  @override
  State<StarryCodeBlock> createState() => _StarryCodeBlockState();
}

class _StarryCodeBlockState extends State<StarryCodeBlock> {
  bool _copying = false;
  bool _copied = false;
  bool _failed = false;
  int _revision = 0;

  @override
  void didUpdateWidget(StarryCodeBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.code != widget.code) {
      _revision++;
      _copied = false;
      _failed = false;
    }
  }

  Future<void> _copy() async {
    if (_copying) return;
    final revision = _revision;
    final source = widget.code;
    final writer = widget.onCopy;
    final reportError = widget.onCopyError;
    setState(() {
      _copying = true;
      _copied = false;
      _failed = false;
    });
    try {
      if (writer == null) {
        await Clipboard.setData(ClipboardData(text: source));
      } else {
        await writer(source);
      }
      if (!mounted) return;
      setState(() {
        _copying = false;
        _copied = revision == _revision;
      });
    } catch (error, stackTrace) {
      if (mounted) {
        setState(() {
          _copying = false;
          _failed = revision == _revision;
        });
      }
      reportError?.call(error, stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.starryTokens;
    final codeTokens = context.starryApplicationTokens.code;
    final hasHeader =
        widget.title != null ||
        widget.language != null ||
        widget.copyLabel != null;
    Widget source = SelectableText(
      widget.code,
      textDirection: TextDirection.ltr,
      style: t.typography.bodyLarge.textStyle.copyWith(
        color: codeTokens.codeText,
        // Flutter's platform generic family, not a second bundled font palette.
        fontFamily: 'monospace',
      ),
    );
    if (widget.maxHeight != null) {
      source = ConstrainedBox(
        constraints: BoxConstraints(maxHeight: widget.maxHeight!),
        child: SingleChildScrollView(primary: false, child: source),
      );
    }

    return StarrySurface(
      elevated: false,
      color: codeTokens.codeSurface,
      padding: EdgeInsets.all(t.spacing.s4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasHeader) ...[
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: t.spacing.s2,
              runSpacing: t.spacing.s2,
              children: [
                if (widget.title != null || widget.language != null)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.title != null)
                        Text(
                          widget.title!,
                          style: t.typography.titleMedium.textStyle.copyWith(
                            color: codeTokens.codeText,
                          ),
                        ),
                      if (widget.language != null)
                        Text(
                          widget.language!,
                          style: t.typography.labelLarge.textStyle.copyWith(
                            color: codeTokens.copyIdle,
                          ),
                        ),
                    ],
                  ),
                if (widget.copyLabel != null)
                  Semantics(
                    liveRegion: true,
                    child: StarryEditorActionButton(
                      label: _copying
                          ? widget.copyingLabel!
                          : _copied
                          ? widget.copiedLabel!
                          : widget.copyLabel!,
                      icon: _copied ? Icons.check : Icons.copy_outlined,
                      loading: _copying,
                      onPressed: _copy,
                    ),
                  ),
              ],
            ),
            SizedBox(height: t.spacing.s3),
          ],
          source,
          if (_failed && widget.copyLabel != null)
            Padding(
              padding: EdgeInsets.only(top: t.spacing.s2),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  widget.copyErrorLabel!,
                  style: t.typography.bodyMedium.textStyle.copyWith(
                    color: t.semantic.errorStrong,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
