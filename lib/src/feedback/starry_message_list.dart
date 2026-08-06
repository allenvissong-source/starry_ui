import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';
import '../components/starry_surface.dart';
import '../interactions/starry_swipeable.dart';

/// A single swipe action attached to a [StarryMessageListItemData].
///
/// Alias of the shared [StarrySwipeAction] primitive so message-list rows and
/// [StarrySwipeable]-based widgets speak the same action model.
typedef StarryMessageListAction = StarrySwipeAction;

/// Data model for one row in a [StarryMessageList].
class StarryMessageListItemData {
  const StarryMessageListItemData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    this.avatarText,
    this.avatarImageUrl,
    this.unread = false,
    this.actions = const <StarryMessageListAction>[],
    this.onTap,
  });

  final Object id;
  final String title;
  final String subtitle;
  final String timeLabel;
  final String? avatarText;
  final String? avatarImageUrl;
  final bool unread;
  final List<StarryMessageListAction> actions;
  final VoidCallback? onTap;
}

/// Starry UI message / notification list with swipe-to-reveal row actions.
///
/// Design tokens are resolved from [StarryTokens]; each row supports a
/// horizontal swipe that reveals per-item actions.
class StarryMessageList extends StatelessWidget {
  const StarryMessageList({
    required this.items,
    required this.emptyLabel,
    super.key,
    this.title,
    this.badgeLabel,
    this.maxHeight,
  });

  final String? title;
  final String? badgeLabel;
  final String emptyLabel;
  final List<StarryMessageListItemData> items;

  /// When set, the list scrolls internally within [maxHeight] and rows are
  /// lazily built ([ListView.builder]) for large data sets. When null the
  /// card hugs its content (all rows built eagerly).
  final double? maxHeight;

  /// Empty-state placeholder glyph extent. Larger than any `controlMetrics`
  /// icon tier (max `iconXl` = 24) by design: this is a decorative empty-state
  /// illustration, not a control glyph.
  static const double _kEmptyStateIconSize = 32;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;
    return StarrySurface(
      padding: EdgeInsets.all(t.spacing.s6),
      borderColor: s.surfaceVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (title != null || badgeLabel != null) ...<Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                if (title != null)
                  Expanded(
                    child: Text(
                      title!,
                      style: t.typography.bodySmall.textStyle.copyWith(
                        color: s.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  const Spacer(),
                if (badgeLabel != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: t.spacing.s2,
                      vertical: t.spacing.s1 / 2,
                    ),
                    decoration: BoxDecoration(
                      color: s.infoBg,
                      borderRadius: BorderRadius.circular(t.radius.sm),
                    ),
                    child: Text(
                      badgeLabel!,
                      style: t.typography.labelSmall.textStyle.copyWith(
                        color: s.infoStrong,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: t.spacing.s4),
          ],
          if (items.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: t.spacing.s8),
              child: Center(
                child: Column(
                  children: <Widget>[
                    Icon(
                      Icons.inbox,
                      color: s.border,
                      size: StarryMessageList._kEmptyStateIconSize,
                    ),
                    SizedBox(height: t.spacing.s2),
                    Text(
                      emptyLabel,
                      style: t.typography.bodySmall.textStyle.copyWith(
                        color: s.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (maxHeight != null)
            // Large data sets: constrained, lazily-built scrolling list.
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight!),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (_, _) => SizedBox(height: t.spacing.s3),
                itemBuilder: (context, index) =>
                    _StarrySwipeableItem(item: items[index]),
              ),
            )
          else
            Column(
              children: <Widget>[
                for (var index = 0; index < items.length; index++) ...<Widget>[
                  _StarrySwipeableItem(item: items[index]),
                  if (index < items.length - 1) SizedBox(height: t.spacing.s3),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _StarrySwipeableItem extends StatelessWidget {
  const _StarrySwipeableItem({required this.item});

  final StarryMessageListItemData item;

  /// Avatar-fallback initial glyph size. No typography token matches this
  /// exact size (nearest `titleLarge` is 22), so it stays a named local
  /// constant for this single call site.
  static const double _kAvatarFallbackFontSize = 20;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;

    return StarrySwipeable(
      // Edge-to-edge action blocks (message-list style): no action padding, no
      // per-action rounding — the row's own clip provides the rounded edge.
      actions: item.actions,
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(t.radius.lg),
      // Keep the clip underlay identical to the closed row surface. A
      // contrasting underlay creates a one-pixel fringe where the rounded edge
      // is anti-aliased; a row-level shadow also leaks into the parent card's
      // right padding. The parent card already owns elevation.
      backgroundColor: s.surface,
      child: SizedBox(
        height: t.spacing.s16 + t.spacing.s3,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: t.spacing.s4),
          color: s.surface,
          child: Row(
            children: <Widget>[
              _buildAvatar(context),
              SizedBox(width: t.spacing.s4),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.typography.bodyMedium.textStyle.copyWith(
                              color: s.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(width: t.spacing.s3),
                        Text(
                          item.timeLabel,
                          style: t.typography.labelSmall.textStyle.copyWith(
                            color: s.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: t.spacing.s1),
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.typography.bodySmall.textStyle.copyWith(
                        color: s.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (item.actions.isNotEmpty) _buildOverflowMenu(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Visible, keyboard-focusable alternative to the swipe gesture: exposes the
  /// same per-item actions through a standard overflow menu so the actions are
  /// discoverable and reachable without a horizontal drag.
  Widget _buildOverflowMenu(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;
    return PopupMenuButton<int>(
      icon: Icon(
        Icons.more_vert,
        size: t.controlMetrics.iconLg,
        color: s.textSecondary,
      ),
      tooltip: 'Actions',
      splashRadius: t.controlMetrics.iconLg,
      itemBuilder: (context) => <PopupMenuEntry<int>>[
        for (var index = 0; index < item.actions.length; index++)
          PopupMenuItem<int>(
            value: index,
            child: Row(
              children: <Widget>[
                Icon(
                  item.actions[index].icon,
                  size: t.controlMetrics.iconMd,
                  color: item.actions[index].backgroundColor,
                ),
                SizedBox(width: t.spacing.s2),
                Text(item.actions[index].label),
              ],
            ),
          ),
      ],
      onSelected: (index) => item.actions[index].onTap(),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final s = t.semantic;
    final avatarSize = t.controlMetrics.minTouchTarget;
    final avatarImageUrl = item.avatarImageUrl?.trim() ?? '';
    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        color: s.surfaceVariant,
        shape: BoxShape.circle,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Center(
            child: ClipOval(
              child: avatarImageUrl.isNotEmpty
                  ? Image.network(
                      avatarImageUrl,
                      width: avatarSize,
                      height: avatarSize,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) =>
                          progress == null ? child : _buildAvatarFallback(),
                      errorBuilder: (_, _, _) => _buildAvatarFallback(),
                    )
                  : _buildAvatarFallback(),
            ),
          ),
          if (item.unread)
            Positioned(
              right: 0,
              top: 0,
              child: Semantics(
                label: 'Unread',
                child: Container(
                  width: t.indicator.dotMd,
                  height: t.indicator.dotMd,
                  decoration: BoxDecoration(
                    color: s.info,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: s.surface,
                      width: t.controlMetrics.borderThick,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback() {
    final avatarText = item.avatarText?.trim();
    final displayText = (avatarText != null && avatarText.isNotEmpty)
        ? avatarText
        : (item.title.isNotEmpty ? item.title.substring(0, 1) : '·');
    return Center(
      child: Text(
        displayText,
        style: const TextStyle(fontSize: _kAvatarFallbackFontSize),
      ),
    );
  }
}
