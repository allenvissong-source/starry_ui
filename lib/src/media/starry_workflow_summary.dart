import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// One real runtime step rendered in the expanded timeline. The component never
/// invents a step: [icon] and [label] are supplied by the caller's real event
/// stream; [icon] may be null and falls back to a neutral dot marker.
class StarryWorkflowStep {
  const StarryWorkflowStep({this.icon, required this.label});

  final IconData? icon;
  final String label;
}

/// Collapsible single-row assistant summary: an optional avatar slot, the author
/// name, a smaller gray already-formatted [elapsedText], and a chevron that
/// expands the caller-provided [steps] timeline.
///
/// The component owns no clock and synthesizes no content: [elapsedText] is
/// already formatted by the caller (wording semantics — "思考 N 秒" only when a
/// real reasoning duration exists; otherwise a generic elapsed label) and
/// [steps] are real events. When [steps] is empty the row is non-interactive and
/// shows no chevron.
class StarryWorkflowSummary extends StatefulWidget {
  const StarryWorkflowSummary({
    required this.name,
    this.elapsedText,
    this.steps = const <StarryWorkflowStep>[],
    this.avatar,
    this.initiallyExpanded = false,
    super.key,
  });

  /// Display / author name shown next to the avatar slot.
  final String name;

  /// Caller-formatted elapsed label; omitted or blank hides the gray suffix.
  final String? elapsedText;

  /// Real runtime steps; empty hides the chevron and collapse affordance.
  final List<StarryWorkflowStep> steps;

  /// Shared avatar slot supplied by the caller; this component never loads an
  /// image itself.
  final Widget? avatar;

  final bool initiallyExpanded;

  @override
  State<StarryWorkflowSummary> createState() => _StarryWorkflowSummaryState();
}

class _StarryWorkflowSummaryState extends State<StarryWorkflowSummary> {
  late bool _expanded = widget.initiallyExpanded;

  bool get _hasSteps => widget.steps.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;

    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        if (widget.avatar != null) ...<Widget>[
          widget.avatar!,
          SizedBox(width: t.spacing.s2),
        ],
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Flexible(
                child: Text(
                  widget.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.typography.labelSmall.textStyle.copyWith(
                    color: s.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (widget.elapsedText != null &&
                  widget.elapsedText!.trim().isNotEmpty) ...<Widget>[
                SizedBox(width: t.spacing.s1),
                Flexible(
                  child: Text(
                    widget.elapsedText!.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.typography.bodySmall.textStyle.copyWith(
                      color: s.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_hasSteps) ...<Widget>[
          SizedBox(width: t.spacing.s1),
          Icon(
            _expanded
                ? Icons.keyboard_arrow_down_rounded
                : Icons.keyboard_arrow_right_rounded,
            size: t.controlMetrics.iconSm,
            color: s.textSecondary,
          ),
        ],
      ],
    );

    final row = _hasSteps
        ? Semantics(
            button: true,
            label: widget.name,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _expanded = !_expanded),
                child: header,
              ),
            ),
          )
        : header;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        row,
        if (_hasSteps && _expanded)
          Padding(
            padding: EdgeInsets.only(left: t.spacing.s2, top: t.spacing.s1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (var i = 0; i < widget.steps.length; i++)
                  _TimelineRow(
                    step: widget.steps[i],
                    isLast: i == widget.steps.length - 1,
                    tokens: t,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.step,
    required this.isLast,
    required this.tokens,
  });

  final StarryWorkflowStep step;
  final bool isLast;
  final StarryTokens tokens;

  @override
  Widget build(BuildContext context) {
    final s = tokens.semantic;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            children: <Widget>[
              Icon(
                step.icon ?? Icons.circle_outlined,
                size: tokens.controlMetrics.iconXs,
                color: s.textSecondary,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: tokens.controlMetrics.borderThin,
                    color: s.border,
                  ),
                ),
            ],
          ),
          SizedBox(width: tokens.spacing.s1),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: tokens.spacing.s1),
              child: Text(
                step.label,
                style: tokens.typography.bodySmall.textStyle.copyWith(
                  color: s.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
