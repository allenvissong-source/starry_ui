import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../buttons/starry_button.dart';
import '../interactions/starry_state_layer.dart';
import '../theme/starry_tokens.dart';

/// One column shared by the aligned table and its narrow, labelled rows.
class StarryDataColumn<T> {
  const StarryDataColumn({
    required this.label,
    required this.cellBuilder,
    this.flex = 1,
    this.compare,
  }) : assert(flex > 0);

  final String label;
  final Widget Function(BuildContext context, T row) cellBuilder;
  final int flex;
  final Comparator<T>? compare;
}

/// Locally paginated data with stable row identity and keyboard-accessible sort.
///
/// Put this content-sized widget inside the page's scroll view. Filtering and
/// remote loading remain owned by the caller; replacing [rows] resets the page
/// when the row identities change. Narrow layouts retain every cell and action.
class StarryDataTable<T> extends StatefulWidget {
  const StarryDataTable({
    required this.rows,
    required this.columns,
    required this.rowKey,
    required this.empty,
    super.key,
    this.pageSize = 10,
    this.loading = false,
    this.error,
  }) : assert(pageSize > 0),
       assert(columns.length > 0);

  final List<T> rows;
  final List<StarryDataColumn<T>> columns;
  final Object Function(T row) rowKey;
  final int pageSize;
  final Widget empty;
  final bool loading;
  final Widget? error;

  @override
  State<StarryDataTable<T>> createState() => _StarryDataTableState<T>();
}

class _StarryDataTableState<T> extends State<StarryDataTable<T>> {
  int _page = 0;
  int? _sort;
  bool _ascending = true;

  @override
  void didUpdateWidget(StarryDataTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldKeys = oldWidget.rows.map(oldWidget.rowKey).toList();
    final keys = widget.rows.map(widget.rowKey).toList();
    if (oldWidget.pageSize != widget.pageSize ||
        oldKeys.length != keys.length ||
        !Iterable.generate(keys.length).every((i) => keys[i] == oldKeys[i])) {
      _page = 0;
    }
    if (_sort != null &&
        (_sort! >= widget.columns.length ||
            widget.columns[_sort!].compare == null)) {
      _sort = null;
    }
  }

  void _sortBy(int index) => setState(() {
    _ascending = _sort == index ? !_ascending : true;
    _sort = index;
    _page = 0;
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final localizations = MaterialLocalizations.of(context);
    final rows = [...widget.rows];
    if (_sort case final int index) {
      final compare = widget.columns[index].compare!;
      final positions = {
        for (var i = 0; i < widget.rows.length; i++)
          widget.rowKey(widget.rows[i]): i,
      };
      rows.sort((a, b) {
        final result = _ascending ? compare(a, b) : compare(b, a);
        return result != 0
            ? result
            : positions[widget.rowKey(a)]!.compareTo(
                positions[widget.rowKey(b)]!,
              );
      });
    }
    final lastPage = rows.isEmpty ? 0 : (rows.length - 1) ~/ widget.pageSize;
    final page = _page.clamp(0, lastPage);
    final start = page * widget.pageSize;
    final visible = rows.skip(start).take(widget.pageSize);
    final rowHeight = math.max(
      t.controlMetrics.heightXl,
      MediaQuery.textScalerOf(
                context,
              ).scale(t.typography.bodySmall.lineHeight) *
              2 +
          t.spacing.s2,
    );

    Widget columnRow(List<Widget> cells) => SizedBox(
      height: rowHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < cells.length; i++)
            Expanded(
              flex: widget.columns[i].flex,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: t.spacing.s4),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: cells[i],
                ),
              ),
            ),
        ],
      ),
    );

    Widget header(int i) {
      final column = widget.columns[i];
      final style = t.typography.bodySmall.textStyle.copyWith(
        color: t.semantic.textSecondary,
        fontWeight: FontWeight.w600,
      );
      if (column.compare == null) return Text(column.label, style: style);
      return Semantics(
        sortKey: OrdinalSortKey(i.toDouble()),
        child: _TableControl(
          style: style,
          onPressed: widget.loading ? null : () => _sortBy(i),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  column.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: t.spacing.s2),
              Icon(
                _sort == i
                    ? (_ascending ? Icons.arrow_upward : Icons.arrow_downward)
                    : Icons.unfold_more,
                size: t.controlMetrics.iconSm,
              ),
            ],
          ),
        ),
      );
    }

    return DefaultTextStyle(
      style: t.typography.bodySmall.textStyle.copyWith(
        color: t.semantic.textPrimary,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < t.breakpoints.medium;
          final divider = Divider(
            height: t.controlMetrics.borderThin,
            thickness: t.controlMetrics.borderThin,
            color: t.semantic.border,
          );
          return Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: t.semantic.surface,
              border: Border.all(color: t.semantic.border),
              borderRadius: BorderRadius.circular(t.radius.lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  color: t.semantic.backgroundSecondary,
                  child: compact
                      ? Padding(
                          padding: EdgeInsets.all(t.spacing.s3),
                          child: Wrap(
                            spacing: t.spacing.s4,
                            children: [
                              for (var i = 0; i < widget.columns.length; i++)
                                if (widget.columns[i].compare != null)
                                  header(i),
                            ],
                          ),
                        )
                      : columnRow([
                          for (var i = 0; i < widget.columns.length; i++)
                            header(i),
                        ]),
                ),
                if (widget.loading) const LinearProgressIndicator(),
                if (widget.error != null)
                  Padding(
                    padding: EdgeInsets.all(t.spacing.s6),
                    child: widget.error,
                  )
                else if (!widget.loading && rows.isEmpty)
                  Padding(
                    padding: EdgeInsets.all(t.spacing.s6),
                    child: widget.empty,
                  )
                else
                  for (final row in visible) ...[
                    divider,
                    Container(
                      key: ValueKey(widget.rowKey(row)),
                      child: compact
                          ? Padding(
                              padding: EdgeInsets.all(t.spacing.s4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for (final column in widget.columns)
                                    Padding(
                                      padding: EdgeInsets.only(
                                        bottom: t.spacing.s3,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            column.label,
                                            style: t
                                                .typography
                                                .labelSmall
                                                .textStyle
                                                .copyWith(
                                                  color:
                                                      t.semantic.textSecondary,
                                                ),
                                          ),
                                          SizedBox(height: t.spacing.s1),
                                          column.cellBuilder(context, row),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            )
                          : columnRow([
                              for (final column in widget.columns)
                                column.cellBuilder(context, row),
                            ]),
                    ),
                  ],
                divider,
                Padding(
                  padding: EdgeInsets.all(t.spacing.s3),
                  child: Wrap(
                    spacing: t.spacing.s2,
                    runSpacing: t.spacing.s2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.end,
                    children: [
                      Text(
                        localizations.pageRowsInfoTitle(
                          rows.isEmpty ? 0 : start + 1,
                          (start + widget.pageSize).clamp(0, rows.length),
                          rows.length,
                          false,
                        ),
                      ),
                      StarryButton(
                        label: localizations.previousPageTooltip,
                        variant: StarryButtonVariant.text,
                        onPressed: page > 0 && !widget.loading
                            ? () => setState(() => _page = page - 1)
                            : null,
                      ),
                      StarryButton(
                        label: localizations.nextPageTooltip,
                        variant: StarryButtonVariant.text,
                        onPressed: page < lastPage && !widget.loading
                            ? () => setState(() => _page = page + 1)
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Inline row action whose label aligns with the table's cell content.
///
/// The visual padding is zero; the focusable hit target remains at least the
/// standard control size. Destructive actions use the semantic error color.
class StarryDataTableAction extends StatelessWidget {
  const StarryDataTableAction({
    required this.label,
    required this.onPressed,
    this.destructive = false,
    super.key,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    return Tooltip(
      message: label,
      child: _TableControl(
        onPressed: onPressed,
        style: t.typography.bodySmall.textStyle.copyWith(
          color: destructive ? t.semantic.errorStrong : t.semantic.brandStrong,
          fontWeight: FontWeight.w500,
        ),
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class _TableControl extends StatelessWidget {
  const _TableControl({
    required this.style,
    required this.child,
    required this.onPressed,
  });
  final TextStyle style;
  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        alignment: AlignmentDirectional.centerStart,
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        minimumSize: WidgetStatePropertyAll(
          Size.square(t.controlMetrics.minTouchTarget),
        ),
        visualDensity: VisualDensity.standard,
        tapTargetSize: MaterialTapTargetSize.padded,
        textStyle: WidgetStatePropertyAll(style),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? t.semantic.textDisabled
              : style.color,
        ),
        overlayColor: StarryStateLayer.overlayColor(t, base: style.color),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(t.radius.sm),
          ),
        ),
        side: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.focused)
              ? BorderSide(
                  color: t.semantic.brand,
                  width: t.controlMetrics.focusBorderWidth,
                )
              : BorderSide.none,
        ),
      ),
      child: child,
    );
  }
}
