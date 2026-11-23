import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import 'starry_action_item.dart';
import 'starry_action_surface.dart';

/// Interactive demo: opens the anchored action surface from a trigger
/// button, including a second-level sub-page inside the same panel.
class StarryActionSurfaceDemo extends StatefulWidget {
  const StarryActionSurfaceDemo({
    super.key,
    this.includeSubPage = true,
    this.showRootFilter = true,
  });

  /// Whether the demo items contain a second-level entry.
  final bool includeSubPage;

  /// Whether the root list shows its built-in filter field.
  final bool showRootFilter;

  @override
  State<StarryActionSurfaceDemo> createState() =>
      _StarryActionSurfaceDemoState();
}

class _StarryActionSurfaceDemoState extends State<StarryActionSurfaceDemo> {
  String? _selection;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  final box = context.findRenderObject()! as RenderBox;
                  StarryActionSurface.show(
                    context: context,
                    anchorRect: box.localToGlobal(Offset.zero) & box.size,
                    title: 'Actions',
                    showFilter: widget.showRootFilter,
                    items: [
                      if (widget.includeSubPage)
                        StarryActionItem(
                          id: 'runtime',
                          title: 'Runtime',
                          onActivate: () {},
                          children: [
                            StarryActionItem(
                              id: 'model-a',
                              title: 'Model A',
                              selected: true,
                              onActivate: () {},
                            ),
                            StarryActionItem(
                              id: 'model-b',
                              title: 'Model B',
                              onActivate: () {},
                            ),
                          ],
                        ),
                      StarryActionItem(
                        id: 'new',
                        title: 'New chat',
                        onActivate: () {},
                      ),
                      StarryActionItem(
                        id: 'web',
                        title: 'Web search',
                        group: 'Tools',
                        onActivate: () {},
                      ),
                    ],
                    onItemSelected: (item) =>
                        setState(() => _selection = item.id),
                  );
                },
                child: const Text('Open action surface'),
              );
            },
          ),
          const SizedBox(height: 16),
          Text('Last selection: ${_selection ?? 'none'}'),
        ],
      ),
    );
  }
}

@UseCase(name: 'Anchored With Sub-page', type: StarryActionSurfaceDemo)
Widget anchoredStarryActionSurface(BuildContext context) {
  return const StarryActionSurfaceDemo();
}

@UseCase(name: 'Playground', type: StarryActionSurfaceDemo)
Widget playgroundStarryActionSurface(BuildContext context) {
  return StarryActionSurfaceDemo(
    includeSubPage: context.knobs.boolean(
      label: 'Include sub-page',
      initialValue: true,
    ),
    showRootFilter: context.knobs.boolean(
      label: 'Root filter',
      initialValue: true,
    ),
  );
}
