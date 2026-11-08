import 'package:flutter/material.dart';

import '../theme/starry_tokens.dart';

/// A controlled file selection, with expandable folders derived from paths.
/// Reading and validating files belongs to the caller.
class StarryFileTree extends StatefulWidget {
  const StarryFileTree({
    required this.paths,
    required this.selectedPath,
    required this.onSelected,
    required this.label,
    super.key,
  });

  final List<String> paths;
  final String? selectedPath;
  final ValueChanged<String> onSelected;
  final String label;

  @override
  State<StarryFileTree> createState() => _StarryFileTreeState();
}

class _StarryFileTreeState extends State<StarryFileTree> {
  final _collapsed = <String>{};

  List<({String path, String label, int depth, bool folder})> _rows() {
    final rows = <({String path, String label, int depth, bool folder})>[];
    final paths = widget.paths.toSet().toList()..sort();
    void visit(String prefix, int depth) {
      final children = <String, bool>{};
      for (final path in paths.where((path) => path.startsWith(prefix))) {
        final tail = path.substring(prefix.length);
        if (tail.isEmpty) continue;
        final slash = tail.indexOf('/');
        final name = slash < 0 ? tail : tail.substring(0, slash);
        children[name] = slash >= 0;
      }
      final names = children.keys.toList()
        ..sort((a, b) {
          final folderOrder = (children[a]! ? 1 : 0).compareTo(
            children[b]! ? 1 : 0,
          );
          return folderOrder == 0 ? a.compareTo(b) : folderOrder;
        });
      for (final name in names) {
        final folder = children[name]!;
        final path = '$prefix$name${folder ? '/' : ''}';
        rows.add((path: path, label: name, depth: depth, folder: folder));
        if (folder && !_collapsed.contains(path)) visit(path, depth + 1);
      }
    }

    visit('', 0);
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<StarryTokens>()!;
    final rows = _rows();
    return Semantics(
      container: true,
      label: widget.label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final row in rows)
            Padding(
              padding: EdgeInsets.only(bottom: t.spacing.s1),
              child: Semantics(
                button: true,
                label: row.path,
                selected: !row.folder && row.path == widget.selectedPath,
                expanded: row.folder ? !_collapsed.contains(row.path) : null,
                child: Material(
                  color: row.path == widget.selectedPath
                      ? t.semantic.surfaceVariant
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(t.radius.sm),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(t.radius.sm),
                    onTap: () {
                      if (row.folder) {
                        setState(() {
                          if (!_collapsed.remove(row.path)) {
                            _collapsed.add(row.path);
                          }
                        });
                      } else {
                        widget.onSelected(row.path);
                      }
                    },
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: t.controlMetrics.minTouchTarget,
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: t.spacing.s3 + row.depth * t.spacing.s4,
                          end: t.spacing.s3,
                          top: t.spacing.s2,
                          bottom: t.spacing.s2,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              row.folder
                                  ? (_collapsed.contains(row.path)
                                        ? Icons.chevron_right
                                        : Icons.expand_more)
                                  : Icons.description_outlined,
                              size: t.controlMetrics.iconMd,
                              color: row.path == widget.selectedPath
                                  ? t.semantic.brandStrong
                                  : t.semantic.textSecondary,
                            ),
                            SizedBox(width: t.spacing.s2),
                            Expanded(
                              child: Text(
                                row.label,
                                overflow: TextOverflow.ellipsis,
                                style: t.typography.bodyMedium.textStyle
                                    .copyWith(
                                      color: row.path == widget.selectedPath
                                          ? t.semantic.brandStrong
                                          : t.semantic.textPrimary,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
