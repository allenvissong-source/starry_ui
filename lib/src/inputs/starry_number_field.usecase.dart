import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import '../../starry_ui.dart';

String _errorText(StarryNumberFieldError error) => switch (error) {
  StarryNumberFieldError.required => '请输入整数',
  StarryNumberFieldError.invalidInteger => '请输入有效整数',
  StarryNumberFieldError.belowMin => '数值须大于或等于 0',
  StarryNumberFieldError.aboveMax => '数值须小于或等于 100',
};

@UseCase(name: 'All Variants', type: StarryNumberField)
Widget allVariantsStarryNumberField(BuildContext context) {
  final t = context.starryTokens;
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StarryNumberField(
          value: null,
          label: '可选整数',
          hint: '留空使用默认值',
          min: 0,
          max: 100,
          onChanged: (_) {},
          errorTextBuilder: _errorText,
        ),
        SizedBox(height: t.spacing.s4),
        StarryNumberField(
          value: 101,
          label: '范围错误',
          min: 0,
          max: 100,
          onChanged: (_) {},
          errorTextBuilder: _errorText,
        ),
        SizedBox(height: t.spacing.s4),
        StarryNumberField(
          value: 12,
          label: '只读',
          readOnly: true,
          onChanged: (_) {},
          errorTextBuilder: _errorText,
        ),
        SizedBox(height: t.spacing.s4),
        StarryNumberField(
          value: 12,
          label: '已禁用',
          enabled: false,
          onChanged: (_) {},
          errorTextBuilder: _errorText,
        ),
      ],
    ),
  );
}

@UseCase(name: 'Playground', type: StarryNumberField)
Widget playgroundStarryNumberField(BuildContext context) {
  final t = context.starryTokens;
  return Padding(
    padding: EdgeInsets.all(t.spacing.s6),
    child: StarryNumberField(
      value: 12,
      label: context.knobs.string(label: 'Label', initialValue: '顺序'),
      nullable: context.knobs.boolean(label: 'Nullable', initialValue: true),
      enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
      readOnly: context.knobs.boolean(label: 'Read only', initialValue: false),
      min: 0,
      max: 100,
      onChanged: (_) {},
      errorTextBuilder: _errorText,
    ),
  );
}
