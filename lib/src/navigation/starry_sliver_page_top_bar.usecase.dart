import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import 'starry_page_top_bar.dart';
import 'starry_sliver_page_top_bar.dart';

const List<Color> _demoGradient = <Color>[
  Color(0xFF3A2E6E), // hardcode-allow: 画廊演示用的沉浸式渐变背板,仅展示 expandedBackground 折叠效果,非被消费的组件配色
  Color(0xFF1B1533), // hardcode-allow: 画廊演示用的沉浸式渐变背板,仅展示 expandedBackground 折叠效果,非被消费的组件配色
];

@UseCase(name: 'Pinned', type: StarrySliverPageTopBar)
Widget pinnedStarrySliverPageTopBar(BuildContext context) {
  return Scaffold(
    body: CustomScrollView(
      slivers: <Widget>[
        StarrySliverPageTopBar(
          titleText: '收藏夹',
          subtitleText: '128 个项目',
          showDivider: true,
          leftActions: <StarryTopBarActionItem>[
            StarryTopBarActionItem(
              icon: const Icon(Icons.arrow_back_ios_new),
              tooltip: '返回',
              motion: StarryTopBarIconMotion.backHoverShift,
              onPressed: () {},
            ),
          ],
          rightActions: <StarryTopBarActionItem>[
            StarryTopBarActionItem(
              icon: const Icon(Icons.add),
              tooltip: '新增',
              motion: StarryTopBarIconMotion.plusHoverRotate,
              onPressed: () {},
            ),
          ],
        ),
        SliverList.builder(
          itemCount: 30,
          itemBuilder: (context, index) =>
              ListTile(title: Text('列表项 ${index + 1}')),
        ),
      ],
    ),
  );
}

@UseCase(name: 'Expandable Background', type: StarrySliverPageTopBar)
Widget expandableStarrySliverPageTopBar(BuildContext context) {
  return _expandableBackgroundBody(context);
}

@UseCase(name: 'Default Back', type: StarrySliverPageTopBar)
Widget defaultBackStarrySliverPageTopBar(BuildContext context) {
  // Hosted on a pushed route so `Navigator.canPop()` is true and the built-in
  // back affordance (showDefaultBack) is injected by the component itself,
  // rather than a hand-written leftAction with an empty onPressed.
  return Navigator(
    onGenerateInitialRoutes: (navigator, initialRoute) => <Route<void>>[
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const _DefaultBackDemo()),
              ),
              child: const Text('打开可返回页面'),
            ),
          ),
        ),
      ),
    ],
  );
}

class _DefaultBackDemo extends StatelessWidget {
  const _DefaultBackDemo();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          const StarrySliverPageTopBar(
            titleText: '详情页',
            subtitleText: '内建返回键',
            showDefaultBack: true,
            showDivider: true,
          ),
          SliverList.builder(
            itemCount: 30,
            itemBuilder: (context, index) =>
                ListTile(title: Text('列表项 ${index + 1}')),
          ),
        ],
      ),
    );
  }
}

Widget _expandableBackgroundBody(BuildContext context) {
  return Scaffold(
    body: CustomScrollView(
      slivers: <Widget>[
        StarrySliverPageTopBar(
          titleText: 'STARRY',
          subtitleText: '沉浸式头部',
          showDivider: true,
          expandedHeight: 220,
          leftActions: <StarryTopBarActionItem>[
            StarryTopBarActionItem(
              icon: const Icon(Icons.arrow_back_ios_new),
              tooltip: '返回',
              motion: StarryTopBarIconMotion.backHoverShift,
              onPressed: () {},
            ),
          ],
          expandedBackground: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _demoGradient,
              ),
            ),
          ),
        ),
        SliverList.builder(
          itemCount: 30,
          itemBuilder: (context, index) =>
              ListTile(title: Text('列表项 ${index + 1}')),
        ),
      ],
    ),
  );
}

@UseCase(name: 'Playground', type: StarrySliverPageTopBar)
Widget playgroundStarrySliverPageTopBar(BuildContext context) {
  final title = context.knobs.string(label: 'Title', initialValue: '页面标题');
  final subtitle = context.knobs.string(label: 'Subtitle', initialValue: '副标题');
  final showDivider = context.knobs.boolean(
    label: 'Show Divider',
    initialValue: true,
  );
  final pinned = context.knobs.boolean(label: 'Pinned', initialValue: true);
  final expandable = context.knobs.boolean(
    label: 'Expandable Background',
    initialValue: false,
  );
  return Scaffold(
    body: CustomScrollView(
      slivers: <Widget>[
        StarrySliverPageTopBar(
          titleText: title,
          subtitleText: subtitle.isEmpty ? null : subtitle,
          showDivider: showDivider,
          pinned: pinned,
          leftActions: <StarryTopBarActionItem>[
            StarryTopBarActionItem(
              icon: const Icon(Icons.arrow_back_ios_new),
              tooltip: '返回',
              motion: StarryTopBarIconMotion.backHoverShift,
              onPressed: () {},
            ),
          ],
          expandedBackground: expandable
              ? const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _demoGradient,
                    ),
                  ),
                )
              : null,
        ),
        SliverList.builder(
          itemCount: 30,
          itemBuilder: (context, index) =>
              ListTile(title: Text('列表项 ${index + 1}')),
        ),
      ],
    ),
  );
}
