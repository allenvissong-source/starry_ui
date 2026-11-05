import 'package:flutter/material.dart';

import '../buttons/starry_icon_button.dart';
import '../components/starry_card.dart';
import '../theme/starry_tokens.dart';

/// 受控媒体添加面板，需放在具有明确高度的父级内。
///
/// 上方是预览区：空态为虚线添加区，已有媒体时默认展示宫格总览；点击下方
/// 缩略图切换为单张预览，点击宫格入口可回到总览。
/// 下方横条顺序固定为：相机、相册、宫格、媒体 1..N。
///
/// 组件只负责显示与交互，不依赖文件路径、网络、平台选择器或上传服务。
class StarryMediaPicker extends StatefulWidget {
  const StarryMediaPicker({
    required this.itemCount,
    required this.mediaBuilder,
    required this.addLabel,
    required this.cameraLabel,
    required this.galleryLabel,
    required this.gridLabel,
    required this.removeLabel,
    required this.editLabel,
    required this.onAddFromCamera,
    required this.onAddFromGallery,
    super.key,
    this.description,
    this.maxItems = 9,
    this.onRemove,
    this.onEdit,
    this.canEditItem,
    this.enabled = true,
    this.loading = false,
  }) : assert(itemCount >= 0),
       assert(maxItems > 0);

  final int itemCount;
  final int maxItems;
  final IndexedWidgetBuilder mediaBuilder;

  /// Empty-state panel label.
  final String addLabel;
  final String cameraLabel;
  final String galleryLabel;
  final String gridLabel;
  final String? description;
  final String removeLabel;
  final String editLabel;
  final VoidCallback? onAddFromCamera;
  final VoidCallback? onAddFromGallery;
  final ValueChanged<int>? onRemove;
  final ValueChanged<int>? onEdit;
  final bool Function(int index)? canEditItem;
  final bool enabled;
  final bool loading;

  @override
  State<StarryMediaPicker> createState() => _StarryMediaPickerState();
}

class _StarryMediaPickerState extends State<StarryMediaPicker> {
  int _selectedIndex = 0;
  bool _showGrid = true;

  @override
  void didUpdateWidget(covariant StarryMediaPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.itemCount != oldWidget.itemCount) {
      _selectedIndex = _selectedIndex.clamp(
        0,
        widget.itemCount == 0 ? 0 : widget.itemCount - 1,
      );
      if (widget.itemCount == 0) {
        _showGrid = true;
      } else if (widget.itemCount > oldWidget.itemCount) {
        // 新增图片后回到宫格总览，避免停在旧图上看不到新加入的内容。
        _showGrid = true;
      }
    }
    if (_selectedIndex >= widget.itemCount && widget.itemCount > 0) {
      _selectedIndex = widget.itemCount - 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final available = widget.enabled && !widget.loading;
    final canAdd = available && widget.itemCount < widget.maxItems;
    final camera = canAdd ? widget.onAddFromCamera : null;
    final gallery = canAdd ? widget.onAddFromGallery : null;
    return StarryCard(
      elevated: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildStage(context, t, available)),
          SizedBox(height: t.spacing.s2),
          SizedBox(
            height: t.spacing.s16,
            child: _buildStrip(context, t, available, camera, gallery),
          ),
        ],
      ),
    );
  }

  Widget _buildStage(BuildContext context, StarryTokens t, bool available) {
    if (widget.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (widget.itemCount == 0) {
      return _AddMediaPanel(
        label: widget.addLabel,
        description: widget.description,
        onTap: available && widget.onAddFromGallery != null
            ? widget.onAddFromGallery
            : null,
      );
    }
    if (_showGrid) {
      return GridView.builder(
        key: const ValueKey('StarryMediaPicker.grid'),
        primary: false,
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: t.spacing.s2,
          mainAxisSpacing: t.spacing.s2,
        ),
        itemCount: widget.itemCount,
        itemBuilder: (context, index) {
          final selected = index == _selectedIndex;
          return ClipRRect(
            borderRadius: BorderRadius.circular(t.radius.md),
            child: Material(
              color: t.semantic.backgroundSecondary,
              child: InkWell(
                onTap: available
                    ? () => setState(() {
                        _selectedIndex = index;
                        _showGrid = false;
                      })
                    : null,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    widget.mediaBuilder(context, index),
                    if (selected)
                      DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(t.radius.md),
                          border: Border.all(
                            color: t.semantic.brand,
                            width: t.controlMetrics.focusBorderWidth,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
    return _SelectedMediaPreview(
      key: const ValueKey('StarryMediaPicker.preview'),
      index: _selectedIndex,
      mediaBuilder: widget.mediaBuilder,
      removeLabel: widget.removeLabel,
      editLabel: widget.editLabel,
      onRemove: available && widget.onRemove != null
          ? () => widget.onRemove!(_selectedIndex)
          : null,
      showEdit:
          widget.onEdit != null &&
          (widget.canEditItem?.call(_selectedIndex) ?? true),
      onEdit: available && widget.onEdit != null
          ? () => widget.onEdit!(_selectedIndex)
          : null,
    );
  }

  Widget _buildStrip(
    BuildContext context,
    StarryTokens t,
    bool available,
    VoidCallback? camera,
    VoidCallback? gallery,
  ) {
    final children = <Widget>[
      _StripActionTile(
        key: const ValueKey('StarryMediaPicker.cameraTile'),
        icon: Icons.photo_camera_outlined,
        label: widget.cameraLabel,
        onTap: camera,
      ),
      _StripActionTile(
        key: const ValueKey('StarryMediaPicker.galleryTile'),
        icon: Icons.photo_library_outlined,
        label: widget.galleryLabel,
        onTap: gallery,
      ),
      _GridTile(
        key: const ValueKey('StarryMediaPicker.gridTile'),
        label: widget.gridLabel,
        itemCount: widget.itemCount,
        mediaBuilder: widget.mediaBuilder,
        selected: widget.itemCount > 0 && _showGrid,
        onTap: available && widget.itemCount > 0
            ? () => setState(() => _showGrid = true)
            : null,
      ),
    ];
    if (widget.itemCount > 0) {
      for (var index = 0; index < widget.itemCount; index += 1) {
        children.add(
          _MediaTile(
            key: ValueKey('StarryMediaPicker.thumb.$index'),
            index: index,
            mediaBuilder: widget.mediaBuilder,
            selected: !_showGrid && index == _selectedIndex,
            onTap: available
                ? () => setState(() {
                    _selectedIndex = index;
                    _showGrid = false;
                  })
                : null,
          ),
        );
      }
    } else {
      // 空态保留可用槽位，明确“最多可加几张”。
      for (var index = 1; index < widget.maxItems; index += 1) {
        children.add(
          _EmptyTile(key: ValueKey('StarryMediaPicker.empty.$index')),
        );
      }
    }
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.zero,
      itemCount: children.length,
      separatorBuilder: (_, _) => SizedBox(width: t.spacing.s2),
      itemBuilder: (_, index) =>
          SizedBox.square(dimension: t.spacing.s16, child: children[index]),
    );
  }
}

class _SelectedMediaPreview extends StatelessWidget {
  const _SelectedMediaPreview({
    required super.key,
    required this.index,
    required this.mediaBuilder,
    required this.removeLabel,
    required this.editLabel,
    required this.onRemove,
    required this.showEdit,
    required this.onEdit,
  });

  final int index;
  final IndexedWidgetBuilder mediaBuilder;
  final String removeLabel;
  final String editLabel;
  final VoidCallback? onRemove;
  final bool showEdit;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final radius = BorderRadius.circular(t.radius.md);
    return ClipRRect(
      borderRadius: radius,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: t.semantic.backgroundSecondary,
            child: mediaBuilder(context, index),
          ),
          PositionedDirectional(
            top: t.spacing.s2,
            end: t.spacing.s2,
            child: StarryIconButton(
              key: ValueKey('StarryMediaPicker.remove.$index'),
              icon: Icons.close,
              tooltip: removeLabel,
              variant: StarryIconButtonVariant.filledTonal,
              onPressed: onRemove,
            ),
          ),
          if (showEdit)
            PositionedDirectional(
              bottom: t.spacing.s2,
              start: t.spacing.s2,
              child: StarryIconButton(
                key: ValueKey('StarryMediaPicker.edit.$index'),
                icon: Icons.crop,
                tooltip: editLabel,
                variant: StarryIconButtonVariant.filledTonal,
                onPressed: onEdit,
              ),
            ),
        ],
      ),
    );
  }
}

class _StripActionTile extends StatelessWidget {
  const _StripActionTile({
    required super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final radius = BorderRadius.circular(t.radius.md);
    final enabled = onTap != null;
    return Material(
      color: enabled
          ? t.semantic.surfaceVariant
          : t.semantic.backgroundSecondary,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Semantics(
          button: true,
          enabled: enabled,
          label: label,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: t.controlMetrics.iconLg,
                color: enabled
                    ? t.semantic.brandStrong
                    : t.semantic.textDisabled,
              ),
              SizedBox(height: t.spacing.s1),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.typography.labelSmall.textStyle.copyWith(
                  color: enabled
                      ? t.semantic.brandStrong
                      : t.semantic.textDisabled,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridTile extends StatelessWidget {
  const _GridTile({
    required super.key,
    required this.label,
    required this.itemCount,
    required this.mediaBuilder,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int itemCount;
  final IndexedWidgetBuilder mediaBuilder;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final radius = BorderRadius.circular(t.radius.md);
    final cells = <Widget>[
      for (var index = 0; index < 4; index += 1)
        Expanded(
          child: index < itemCount
              ? mediaBuilder(context, index)
              : ColoredBox(
                  color: t.semantic.brand.withValues(
                    alpha: t.opacity.selectedSurface,
                  ),
                ),
        ),
    ];
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      child: Material(
        color: t.semantic.brand.withValues(alpha: t.opacity.selectedSurface),
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: selected
                  ? Border.all(
                      color: t.semantic.brand,
                      width: t.controlMetrics.focusBorderWidth,
                    )
                  : null,
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        cells[0],
                        SizedBox(width: t.spacing.s1),
                        cells[1],
                      ],
                    ),
                  ),
                  SizedBox(height: t.spacing.s1),
                  Expanded(
                    child: Row(
                      children: [
                        cells[2],
                        SizedBox(width: t.spacing.s1),
                        cells[3],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MediaTile extends StatelessWidget {
  const _MediaTile({
    required super.key,
    required this.index,
    required this.mediaBuilder,
    required this.selected,
    required this.onTap,
  });

  final int index;
  final IndexedWidgetBuilder mediaBuilder;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final radius = BorderRadius.circular(t.radius.md);
    return Material(
      color: t.semantic.backgroundSecondary,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: selected
                ? Border.all(
                    color: t.semantic.brand,
                    width: t.controlMetrics.focusBorderWidth,
                  )
                : null,
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: mediaBuilder(context, index),
          ),
        ),
      ),
    );
  }
}

class _EmptyTile extends StatelessWidget {
  const _EmptyTile({required super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.semantic.brand.withValues(alpha: t.opacity.selectedSurface),
        borderRadius: BorderRadius.circular(t.radius.md),
      ),
    );
  }
}

class _AddMediaPanel extends StatelessWidget {
  const _AddMediaPanel({
    required this.label,
    required this.onTap,
    this.description,
  });

  final String label;
  final String? description;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final radius = BorderRadius.circular(t.radius.md);
    return CustomPaint(
      foregroundPainter: _DashedBorder(
        color: t.semantic.brand.withValues(alpha: t.opacity.disabledContent),
        radius: t.radius.md,
        stroke: t.controlMetrics.borderThin,
        dash: t.spacing.s2,
        gap: t.spacing.s1,
      ),
      child: Material(
        color: t.semantic.brand.withValues(alpha: t.opacity.selectedSurface),
        borderRadius: radius,
        child: Semantics(
          button: true,
          enabled: onTap != null,
          label: label,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Padding(
              padding: EdgeInsets.all(t.spacing.s2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: t.controlMetrics.iconXl,
                    color: t.semantic.brand,
                  ),
                  SizedBox(height: t.spacing.s2),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: t.typography.bodyMedium.textStyle.copyWith(
                      color: t.semantic.textPrimary,
                    ),
                  ),
                  if (description != null) ...[
                    SizedBox(height: t.spacing.s2),
                    Text(
                      description!,
                      textAlign: TextAlign.center,
                      style: t.typography.bodySmall.textStyle.copyWith(
                        color: t.semantic.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorder extends CustomPainter {
  const _DashedBorder({
    required this.color,
    required this.radius,
    required this.stroke,
    required this.dash,
    required this.gap,
  });

  final Color color;
  final double radius;
  final double stroke;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(stroke / 2),
          Radius.circular(radius),
        ),
      );
    for (final metric in path.computeMetrics()) {
      for (double offset = 0; offset < metric.length; offset += dash + gap) {
        canvas.drawPath(
          metric.extractPath(offset, (offset + dash).clamp(0, metric.length)),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorder oldDelegate) =>
      color != oldDelegate.color ||
      radius != oldDelegate.radius ||
      stroke != oldDelegate.stroke ||
      dash != oldDelegate.dash ||
      gap != oldDelegate.gap;
}
