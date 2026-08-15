import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'masonry_feed_metrics.dart';

/// A sliver-level masonry feed container.
///
/// Owns only the shared *layout* concern: it reads the available cross-axis
/// extent, resolves [MasonryFeedMetrics] (column count / card width / side
/// insets, all derived from the target card width), and renders the masonry
/// grid. Business/data states — loading, empty, error, pagination loaders —
/// stay OUT of this widget and are orchestrated by each page alongside this
/// sliver in its own `CustomScrollView`. Cards are injected via [itemBuilder],
/// so this widget has zero knowledge of any domain type.
class SliverMasonryFeed extends StatelessWidget {
  const SliverMasonryFeed({
    required this.itemCount,
    required this.itemBuilder,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  /// Number of cards to render.
  final int itemCount;

  /// Builds the card at [index]. `(BuildContext, int) -> Widget`.
  final IndexedWidgetBuilder itemBuilder;

  /// Extra business padding (e.g. top/bottom breathing room). The horizontal
  /// side insets required to center the grid are added on top of this.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final metrics = MasonryFeedMetrics.resolve(constraints.crossAxisExtent);

        // Negative-width guard: during shell transitions the cross-axis extent
        // can momentarily collapse, which would otherwise trip a "negative
        // minimum width" assertion inside the masonry grid.
        final childCrossAxisExtent = metrics.columns > 0
            ? (metrics.gridWidth -
                    masonryFeedColumnGap * (metrics.columns - 1)) /
                metrics.columns
            : 0.0;
        if (childCrossAxisExtent <= 0) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        final sideInset = EdgeInsets.symmetric(horizontal: metrics.gridInset);
        final resolvedPadding = padding.resolve(Directionality.of(context));

        return SliverPadding(
          padding: sideInset.add(resolvedPadding),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: metrics.columns,
            mainAxisSpacing: masonryFeedRowGap,
            crossAxisSpacing: masonryFeedColumnGap,
            childCount: itemCount,
            itemBuilder: itemBuilder,
          ),
        );
      },
    );
  }
}
