## 1. Untrack the diagnostic screenshot

- [x] 1.1 `git rm --cached .diag/colors_now.png`; confirm `git ls-files .diag/` returns empty and the file still exists on disk
- [x] 1.2 Confirm `.gitignore` still covers `.diag/` (line 49) so the file does not get re-tracked

## 2. Remove the decommissioned staging directory

- [x] 2.1 `git rm -r lib/src/_migrating/`; confirm the directory no longer exists in the index or on disk

## 3. Replace Flutter template scaffolding text

- [x] 3.1 Rewrite `README.md` with a real package description (no "A new Flutter project." residue)
- [x] 3.2 Set `pubspec.yaml` `description` to a real package description

## 4. Correct stale governance notes

- [x] 4.1 Update the Widgetbook bullet in `openspec/project.md`: Widgetbook lives in `dev_dependencies`, not `dependencies`
- [x] 4.2 Drop the now-false `lib/src/_migrating/` bullet from `openspec/project.md` (the directory was removed in 2.1)

## 5. Gate verification

- [x] 5.1 `flutter analyze` in this package (fallback: `dart analyze`) — no new issues introduced
