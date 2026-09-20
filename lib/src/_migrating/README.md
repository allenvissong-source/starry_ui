# _migrating

原「迁移中隔离区」已随迁移收敛完成而停用,不再作为活动暂存区使用。

现状:

- 组件不再经此暂存,而是按角色直接归位到 `lib/src/` 下的专属目录(见 `AGENTS.md` §4)。
- 容器 / 表面类组件(card、surface、control shell、expandable / masonry /
  action option card 等)统一位于 `lib/src/components/`。
- 其余组件按族归入 `buttons/`、`inputs/`、`tags/`、`feedback/`、`layout/`、
  `navigation/`、`media/`、`interactions/`、`text/` 等目录。

本目录当前仅保留本说明文件,无迁移中的组件滞留。若未来重启迁移暂存流程,
以 `AGENTS.md` §4 的成熟度阶梯与 `docs/migration/` 为准。
