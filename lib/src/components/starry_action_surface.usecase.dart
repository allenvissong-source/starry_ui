import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import 'starry_action_item.dart';
import 'starry_action_surface.dart';

/// Interactive demo: opens the anchored action surface from a trigger
/// button, including a second-level sub-page inside the same panel.
class StarryActionSurfaceDemo extends StatefulWidget {
  const StarryActionSurfaceDemo({super.key});

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
                    items: [
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
