import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import '../../starry_ui.dart';

@UseCase(name: 'All Variants', type: StarryContentSection)
Widget allVariantsStarryContentSection(BuildContext context) {
  final t = context.starryTokens;
  return SingleChildScrollView(
    padding: EdgeInsets.all(t.spacing.s6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const StarryContentSection(
          title: '基础信息',
          subtitle: 'BASIC INFO',
          icon: Icons.info_outline,
          child: Text('使用语义色和正文排版的内容区块。'),
        ),
        SizedBox(height: t.spacing.s4),
        StarryContentSection(
          title: '角色 Skill',
          subtitle: 'SKILLS',
          trailing: StarryIconButton(
            icon: Icons.more_horiz,
            tooltip: '更多操作',
            onPressed: () {},
          ),
          child: const StarryExpandableCard(
            embedded: true,
            initiallyExpanded: true,
            header: Text('角色演绎'),
            children: [Text('展开内容平铺在区块内，不添加第二层卡片。')],
          ),
        ),
        SizedBox(height: t.spacing.s4),
        const StarryContentSection(child: Text('不需要标题的内容。')),
        SizedBox(height: t.spacing.s4),
        SizedBox(
          height: t.controlMetrics.controlHeight * 4,
          child: const StarryAmbientBackground(
            child: Center(
              child: StarryContentSection(
                variant: StarryContentSectionVariant.frosted,
                title: '磨砂内容区块',
                subtitle: 'FROSTED',
                child: Text('复用玻璃模糊与半透明表面，文字保持不透明。'),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

@UseCase(name: 'Playground', type: StarryContentSection)
Widget playgroundStarryContentSection(BuildContext context) {
  return Padding(
    padding: EdgeInsets.all(context.starryTokens.spacing.s6),
    child: StarryContentSection(
      variant: context.knobs.object.dropdown(
        label: 'Material',
        options: StarryContentSectionVariant.values,
        initialOption: StarryContentSectionVariant.solid,
      ),
      title: context.knobs.string(label: 'Title', initialValue: '基础信息'),
      subtitle: context.knobs.string(
        label: 'Subtitle',
        initialValue: 'BASIC INFO',
      ),
      icon: context.knobs.boolean(label: 'Icon', initialValue: true)
          ? Icons.info_outline
          : null,
      child: Text(
        context.knobs.string(label: 'Content', initialValue: '角色正文与说明。'),
      ),
    ),
  );
}
