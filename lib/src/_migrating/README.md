# _migrating — 迁移中隔离区

从主项目迁入、但**尚未稳定、尚未纳入公共 API** 的组件暂存于此。

成熟度状态机:`_migrating -> internal stable -> public stable`。

规则:
- 本目录内组件**不得**出现在 `lib/starry_ui.dart` barrel 中,消费方不可直接 import。
- 组件达到 internal stable 后移出本目录进入 `lib/src/<category>/`;达到 public stable 后再加入 barrel 导出。
- 每次晋升伴随库侧独立提交,验收标准见 `docs/migration/`。
