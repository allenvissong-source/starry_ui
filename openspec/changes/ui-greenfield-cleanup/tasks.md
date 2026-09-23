## 1. Untrack the diagnostic screenshot

- [ ] 1.1 `git rm --cached .diag/colors_now.png`; confirm `git ls-files .diag/` returns empty and the file still exists on disk
- [ ] 1.2 Confirm `.gitignore` still covers `.diag/` (line 49) so the file does not get re-tracked

## 2. Remove the decommissioned staging directory

- [ ] 2.1 `git rm -r lib/src/_migrating/`; confirm the directory no longer exists in the index or on disk

## 3. Replace Flutter template scaffolding text

- [ ] 3.1 Rewrite `README.md` with a real package description (no "A new Flutter project." residue)
- [ ] 3.2 Set `pubspec.yaml` `description` to a real package description

## 4. Correct stale governance notes

- [ ] 4.1 Update the Widgetbook bullet in `openspec/project.md`: Widgetbook lives in `dev_dependencies`, not `dependencies`
- [ ] 4.2 Drop the now-false `lib/src/_migrating/` bullet from `openspec/project.md` (the directory was removed in 2.1)

## 5. Gate verification

- [ ] 5.1 `flutter analyze` in this package (fallback: `dart analyze`) — no new issues introduced
