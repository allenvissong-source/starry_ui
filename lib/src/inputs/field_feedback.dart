import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// Shared, readable inline validation/help and optional counter for editors.
class StarryFieldFeedback extends StatelessWidget {
  const StarryFieldFeedback({
    this.message,
    this.hasError = false,
    this.counter,
    super.key,
  });

  final String? message;
  final bool hasError;
  final Widget? counter;

  @override
  Widget build(BuildContext context) {
    if (message == null && counter == null) return const SizedBox.shrink();
    final t = Theme.of(context).extension<StarryTokens>()!;
    return Padding(
      padding: EdgeInsets.only(top: t.spacing.s2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message != null)
            Expanded(
              child: Semantics(
                liveRegion: hasError,
                child: Text(
                  message!,
                  style: t.typography.labelLarge.textStyle.copyWith(
                    color: hasError
                        ? t.semantic.errorStrong
                        : t.semantic.textSecondary,
                  ),
                ),
              ),
            )
          else
            const Spacer(),
          if (counter != null) ...[
            if (message != null) SizedBox(width: t.spacing.s2),
            counter!,
          ],
        ],
      ),
    );
  }
}
