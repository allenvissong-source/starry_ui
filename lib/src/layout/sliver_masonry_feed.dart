import 'dart:math' as math;

import 'package:flutter/foundation.dart' show precisionErrorTolerance;
import 'package:flutter/rendering.dart' show SliverConstraints, SliverGeometry;
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'masonry_feed_metrics.dart';
import 'masonry_feed_scope.dart';

/// A sliver-level masonry feed container.
///
/// Owns only the shared *layout* concern: it reads the available cross-axis
/// extent, resolves [MasonryFeedMetrics] (column count / card width / side
/// insets, all derived from the target card width), and renders the masonry
/// grid. Business/data states — loading, empty, error, pagination loaders —
/// stay OUT of this widget and are orchestrated by each page alongside this
/// sliver in its own `CustomScrollView`. Cards are injected via [itemBuilder],
/// so this widget has zero knowledge of any domain type.
class SliverMasonryFeed extends StatefulWidget {
  const SliverMasonryFeed({
    required this.itemCount,
    required this.itemBuilder,
    this.padding = EdgeInsets.zero,
    this.wideCrossAxisInset = 0,
    this.minimumColumns = 2,
    this.maximumColumns = 5,
    super.key,
  }) : assert(wideCrossAxisInset >= 0 && wideCrossAxisInset < double.infinity);

  /// Number of cards to render.
  final int itemCount;

  /// Builds the card at [index]. `(BuildContext, int) -> Widget`.
  final IndexedWidgetBuilder itemBuilder;

  /// Extra business padding (e.g. top/bottom breathing room). The horizontal
  /// side insets required to center the grid are added on top of this.
  final EdgeInsetsGeometry padding;

  /// Extra inset per side, growing from zero to this value as the feed widens.
  final double wideCrossAxisInset;
  final int minimumColumns, maximumColumns;

  /// Decode width in physical pixels for a cover in this feed. Sized for the
  /// widest supported card so live resizing can reuse the same decoded frame.
  static int? coverCacheWidthOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<MasonryFeedScope>() == null
      ? null
      : (masonryFeedTargetCardWidth * MediaQuery.devicePixelRatioOf(context))
            .ceil();

  @override
  State<SliverMasonryFeed> createState() => _SliverMasonryFeedState();
}

class _SliverMasonryFeedState extends State<SliverMasonryFeed> {
  double? _crossAxisExtent;
  Axis? _axis;
  Widget? _sliver;
  SliverChildBuilderDelegate? _delegate;

  @override
  void didUpdateWidget(covariant SliverMasonryFeed oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sliver = null;
    if (oldWidget.itemBuilder != widget.itemBuilder ||
        oldWidget.itemCount != widget.itemCount) {
      _delegate = null;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sliver = null;
  }

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        // Scroll offsets change these constraints on every layout. Keep the
        // child delegate intact unless its data or cross-axis geometry changes.
        if (_sliver != null &&
            _crossAxisExtent == constraints.crossAxisExtent &&
            _axis == constraints.axis) {
          return _sliver!;
        }
        _crossAxisExtent = constraints.crossAxisExtent;
        _axis = constraints.axis;
        final metrics = MasonryFeedMetrics.resolve(
          constraints.crossAxisExtent,
          minimumColumns: widget.minimumColumns,
          maximumColumns: widget.maximumColumns,
        );

        // Negative-width guard: during shell transitions the cross-axis extent
        // can momentarily collapse, which would otherwise trip a "negative
        // minimum width" assertion inside the masonry grid.
        if (metrics.cardWidth <= 0 || widget.itemCount == 0) {
          return _sliver = const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        final axis = constraints.axis;
        final extraInset = widget.wideCrossAxisInset * metrics.densityProgress;
        final resolvedPadding = widget.padding
            .resolve(Directionality.of(context))
            .add(_crossAxisInsets(axis, extraInset));
        final businessCrossAxisPadding = axis == Axis.vertical
            ? resolvedPadding.horizontal
            : resolvedPadding.vertical;
        final paddedCardWidth =
            metrics.cardWidth - businessCrossAxisPadding / metrics.columns;
        if (paddedCardWidth <= 0) {
          return _sliver = const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        // Center only the occupied columns, without enlarging their cards.
        // Keeping one sliver and delegate also preserves mounted cards when a
        // single row becomes a multi-row grid (or vice versa).
        final columns = math.min(metrics.columns, widget.itemCount);
        final emptyWidth =
            (metrics.columns - columns) * (paddedCardWidth + metrics.columnGap);
        final sideInset = _crossAxisInsets(
          axis,
          metrics.gridInset + emptyWidth / 2,
        );
        return _sliver = SliverPadding(
          padding: sideInset.add(resolvedPadding),
          sliver: MasonryFeedScope(
            cardRadius: metrics.cardRadius,
            child: _MasonryGrid(
              gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
              ),
              mainAxisSpacing: metrics.rowGap,
              crossAxisSpacing: metrics.columnGap,
              delegate: _delegate ??= SliverChildBuilderDelegate(
                widget.itemBuilder,
                childCount: widget.itemCount,
              ),
            ),
          ),
        );
      },
    );
  }

  static EdgeInsets _crossAxisInsets(Axis axis, double inset) =>
      axis == Axis.vertical
      ? EdgeInsets.symmetric(horizontal: inset)
      : EdgeInsets.symmetric(vertical: inset);
}

class _MasonryGrid extends SliverMasonryGrid {
  const _MasonryGrid({
    required super.delegate,
    required super.gridDelegate,
    required super.mainAxisSpacing,
    required super.crossAxisSpacing,
  });

  @override
  double? estimateMaxScrollOffset(
    SliverConstraints? constraints,
    int firstIndex,
    int lastIndex,
    double leadingScrollOffset,
    double trailingScrollOffset,
  ) {
    // Reverse layout permits a slight negative origin from floating-point
    // subtraction. When the last item is laid out, Flutter's default estimate
    // is the trailing offset, but the grid requires at least the measured span.
    if (lastIndex + 1 == delegate.estimatedChildCount &&
        leadingScrollOffset < 0 &&
        leadingScrollOffset >= -precisionErrorTolerance) {
      return trailingScrollOffset - leadingScrollOffset;
    }
    return super.estimateMaxScrollOffset(
      constraints,
      firstIndex,
      lastIndex,
      leadingScrollOffset,
      trailingScrollOffset,
    );
  }

  @override
  RenderSliverMasonryGrid createRenderObject(BuildContext context) =>
      _RenderMasonryGrid(
        childManager: context as SliverMultiBoxAdaptorElement,
        gridDelegate: gridDelegate,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
      );
}

class _RenderMasonryGrid extends RenderSliverMasonryGrid {
  _RenderMasonryGrid({
    required super.childManager,
    required super.gridDelegate,
    required super.mainAxisSpacing,
    required super.crossAxisSpacing,
  });

  final _deletedColumnEnds = <int, double>{};
  double? _crossAxisExtent;
  int? _columns;
  Axis? _axis;
  double? _rowGap;
  double? _columnGap;
  double? _completeExtent;
  int? _completeChildCount;

  @override
  void markNeedsLayout() {
    _completeExtent = null;
    super.markNeedsLayout();
  }

  @override
  void performLayout() {
    final columns = gridDelegate.getCrossAxisCount(
      constraints,
      crossAxisSpacing,
    );
    final count = childManager.childCount;
    final geometryChanged =
        _crossAxisExtent != constraints.crossAxisExtent ||
        _columns != columns ||
        _axis != constraints.axis ||
        _rowGap != mainAxisSpacing ||
        _columnGap != crossAxisSpacing;
    if (geometryChanged) {
      _deletedColumnEnds.clear();
      _completeExtent = null;
    }
    final extent = _completeExtent;
    if (extent != null &&
        _completeChildCount == count &&
        constraints.scrollOffset >= extent) {
      // Keep an already measured offscreen grid dormant. Its children still
      // invalidate this extent when content or image geometry changes.
      childManager.didStartLayout();
      childManager.setDidUnderflow(true);
      geometry = SliverGeometry(
        scrollExtent: extent,
        maxPaintExtent: extent,
        cacheExtent: calculateCacheOffset(constraints, from: 0, to: extent),
      );
      childManager.didFinishLayout();
      return;
    }
    if (firstChild == null) {
      _deletedColumnEnds.clear();
      _seedFirstRow(columns);
    } else if (!geometryChanged && indexOf(firstChild!) > 0) {
      _restoreColumnAnchors(columns);
    }
    _crossAxisExtent = constraints.crossAxisExtent;
    _columns = columns;
    _axis = constraints.axis;
    _rowGap = mainAxisSpacing;
    _columnGap = crossAxisSpacing;
    super.performLayout();
    if (lastChild != null &&
        indexOf(lastChild!) == count - 1 &&
        geometry?.scrollOffsetCorrection == null) {
      _completeExtent = geometry!.scrollExtent;
      _completeChildCount = count;
    }
  }

  BoxConstraints _childConstraints(int columns) => constraints.asBoxConstraints(
    crossAxisExtent:
        (constraints.crossAxisExtent + crossAxisSpacing) / columns -
        crossAxisSpacing,
  );

  void _seedFirstRow(int columns) {
    if (!addInitialChild()) return;
    final childConstraints = _childConstraints(columns);
    var child = firstChild!;
    child.layout(childConstraints, parentUsesSize: true);
    // A restored viewport or shortened data set can start beyond this grid.
    // Seed all initial columns so reverse layout has finite starting offsets.
    for (var column = 1; column < columns; column++) {
      final next = insertAndLayoutChild(
        childConstraints,
        after: child,
        parentUsesSize: true,
      );
      if (next == null) break;
      final data = next.parentData! as SliverMasonryGridParentData;
      data
        ..crossAxisIndex = column
        ..layoutOffset = 0;
      child = next;
    }
  }

  void _restoreColumnAnchors(int columns) {
    final firstData = firstChild!.parentData! as SliverMasonryGridParentData;
    if (firstData.crossAxisIndex == null || firstData.layoutOffset == null) {
      return;
    }
    final starts = <int, double>{};
    for (var child = firstChild; child != null; child = childAfter(child)) {
      final data = child.parentData! as SliverMasonryGridParentData;
      // Appended/reordered children are positioned by the upstream layout.
      if (data.crossAxisIndex != null && data.layoutOffset != null) {
        starts.putIfAbsent(data.crossAxisIndex!, () => data.layoutOffset!);
      }
    }
    for (var column = 0; column < columns; column++) {
      if (!starts.containsKey(column) &&
          !_deletedColumnEnds.containsKey(column)) {
        return;
      }
    }
    final childConstraints = _childConstraints(columns);
    // The upstream renderer retains only the final child after a grid leaves
    // the cache window. Recreate missing column anchors from their measured
    // ends before its reverse layout mistakes infinity for an earlier offset.
    while (starts.length < columns && indexOf(firstChild!) > 0) {
      final child = insertAndLayoutLeadingChild(
        childConstraints,
        parentUsesSize: true,
      );
      if (child == null) break;
      final data = child.parentData! as SliverMasonryGridParentData;
      final column = data.crossAxisIndex!;
      final end = starts[column] ?? _deletedColumnEnds[column]!;
      data.layoutOffset = end - data.lastMainAxisExtent! - mainAxisSpacing;
      starts[column] = data.layoutOffset!;
    }
  }

  @override
  void collectGarbage(int leadingGarbage, int trailingGarbage) {
    var child = firstChild;
    for (var i = 0; i < leadingGarbage && child != null; i++) {
      final data = child.parentData! as SliverMasonryGridParentData;
      if (data.crossAxisIndex != null && data.layoutOffset != null) {
        _deletedColumnEnds[data.crossAxisIndex!] =
            data.layoutOffset! + paintExtentOf(child) + mainAxisSpacing;
      }
      child = childAfter(child);
    }
    super.collectGarbage(leadingGarbage, trailingGarbage);
  }
}
