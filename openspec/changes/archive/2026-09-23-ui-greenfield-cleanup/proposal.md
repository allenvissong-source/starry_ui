# Starry UI Greenfield Cleanup

## Why

Direct-fix items left by the 2026-09-23 greenfield audit, each verified against the tree:

- `.diag/colors_now.png` is tracked even though `.gitignore:49` excludes `.diag/`. It was
  committed in `d6c458c` ("as-is snapshot before starry_ui library restructure") before the
  ignore rule existed, so the ignore line never took effect on it.
- `lib/src/_migrating/` holds only a decommissioned README. The README itself states the staging
  area has converged and no migration is in flight, so the directory is a tombstone with no
  purpose.
- `README.md` and `pubspec.yaml` still ship the Flutter `create` scaffold text
  ("A new Flutter project.") instead of describing this design-system package.
- `openspec/project.md` still claims Widgetbook sits in `dependencies`, but it has been in
  `dev_dependencies` since the archived change `2026-09-22-fix-package-boundary-and-migration-residue`
  (`pubspec.yaml:19-21`).

## What Changes

- `git rm --cached .diag/colors_now.png` so the diagnostic screenshot stops being tracked. The
  file stays on disk; only the index entry is removed, and `.gitignore` already covers it.
- Delete `lib/src/_migrating/` entirely (it contains only its tombstone README).
- Replace `README.md` with a real package description and set `pubspec.yaml` `description` to
  match.
- Correct the Widgetbook bullet in `openspec/project.md` to `dev_dependencies`, and drop the now
  false `lib/src/_migrating/` bullet that this change removes.

## Out of Scope

- Whether `lib/main.directories.g.dart` (build_runner output) should be committed
  (UI-AUDIT-005, needs_decision).
- The 1751-line `lib/src/foundations/foundations.dart` Widgetbook showcase (UI-AUDIT-007,
  needs_decision).
