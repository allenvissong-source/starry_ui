import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import 'starry_error_widget.dart';

@UseCase(name: 'Default', type: StarryErrorWidget)
Widget defaultStarryErrorWidget(BuildContext context) {
  return StarryErrorWidget(
    title: '出错了',
    message: '加载失败，请稍后重试。',
    retryLabel: '重试',
    onRetry: () {},
  );
}

@UseCase(name: 'No Retry', type: StarryErrorWidget)
Widget noRetryStarryErrorWidget(BuildContext context) {
  return const StarryErrorWidget(
    icon: Icon(Icons.wifi_off),
    title: '网络异常',
    message: '请检查你的网络连接。',
  );
}

@UseCase(name: 'With Details', type: StarryErrorWidget)
Widget withDetailsStarryErrorWidget(BuildContext context) {
  return StarryErrorWidget(
    title: '服务器错误',
    message: '服务暂时不可用。',
    details: 'HTTP 503\nService Unavailable\ntrace_id: 0a1b2c3d',
    showDetails: true,
    retryLabel: '重试',
    onRetry: () {},
  );
}

@UseCase(name: 'Playground', type: StarryErrorWidget)
Widget playgroundStarryErrorWidget(BuildContext context) {
  return StarryErrorWidget(
    title: context.knobs.stringOrNull(label: 'Title', initialValue: '出错了'),
    message: context.knobs.stringOrNull(
      label: 'Message',
      initialValue: '加载失败，请稍后重试。',
    ),
    showDetails: context.knobs.boolean(label: 'Show details'),
    details: 'HTTP 500\nInternal Server Error',
    retryLabel: '重试',
    onRetry: () {},
  );
}
