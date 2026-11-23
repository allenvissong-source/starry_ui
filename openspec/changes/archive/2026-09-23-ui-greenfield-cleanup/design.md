## Context

This change is documentation and repository-hygiene cleanup only. No widget, token, or public
API changes. Each item was verified in the tree before being scheduled:

- `git ls-files .diag/` returns `.diag/colors_now.png`; `.gitignore:49` reads `.diag/`. The file
  predates the ignore rule, so ignoring it in the index is the correct fix (the audit's
  `git rm --cached`), not editing the file itself.
- `lib/src/_migrating/` contains exactly one file, `README.md`, which describes itself as
  decommissioned. The staged migration has converged into `lib/src/components/` and the role
  directories (see `AGENTS.md` §4), so the staging directory records nothing live.
- `README.md:3` and `pubspec.yaml:2` are verbatim Flutter `create` template text.
- `openspec/project.md:25-26` states Widgetbook is in `dependencies`; `pubspec.yaml:19-21` places
  `widgetbook`, `widgetbook_annotation`, `widgetbook_generator` under `dev_dependencies:`. The
  archived move (`baf7b7a`) was not reflected in the governance note.

## Goals / Non-Goals

Goals:

- The diagnostic screenshot is untracked but still present on disk.
- The decommissioned staging directory is gone.
- The package describes itself instead of the Flutter template.
- The governance note matches where Widgetbook actually lives.

Non-Goals:

- Changing any component, token, golden, or public API. This change moves no pixels.
- Deciding the fate of `main.directories.g.dart` (needs_decision) or `foundations.dart`
  (needs_decision).
- Touching other "Known governance context" bullets (the 79/149 format figure, the 22 barrel
  widgets) that this change does not make false.

## Decisions

**Decision: untrack, do not delete on disk.** `git rm --cached` removes the index entry while
leaving the working-tree file. That matches the intent of `.gitignore` and loses nothing.

**Decision: remove the whole `_migrating/` directory.** It holds only its tombstone README. The
maturity ladder in `AGENTS.md` §4 still documents the `_migrating` rung, so the directory can be
recreated when there is actual staging work; an empty retired one misleads.

**Decision: update the `_migrating` bullet in project.md as a direct consequence.** Deleting the
directory makes `openspec/project.md:24` ("`lib/src/_migrating/` contains only a README") false.
Leaving it would contradict the change, so the bullet is dropped in the same edit. No other
governance bullets are touched.

## Risks / Trade-offs

- `git rm --cached` shows as a deletion in the index. → Expected: the file stays on disk and is
  ignored going forward. Rollback is `git restore --staged` / re-add if ever needed.
- Removing `_migrating/` loses the convention marker. → The ladder lives in `AGENTS.md` §4; the
  directory is recreated on demand.
- Rewriting `README.md` / `pubspec.yaml` description carries no behavioral risk; `description` is
  metadata only.

## Migration Plan

1. `git rm --cached .diag/colors_now.png`.
2. `git rm -r lib/src/_migrating/`.
3. Rewrite `README.md`; set `pubspec.yaml` `description`.
4. Edit `openspec/project.md` Widgetbook bullet and drop the `_migrating` bullet.
5. Run `flutter analyze` (or `dart analyze` as fallback) to confirm no Dart broke.

Rollback: every edit is a file/content revert; nothing here changes compiled code.

## Open Questions

None. The needs_decision items (`main.directories.g.dart`, `foundations.dart`) are explicitly out
of scope and are not adjudicated here.
