## 1. Baseline

- [ ] 1.1 Record the pre-change `flutter analyze` and `flutter test` results in this package. Several source gates exist only as tests (`no_padded_tap_target_in_inputs_test`, `button_density_guard_test`, `no_hardcoded_colors_test`) and `analyze` will not see them
- [ ] 1.2 Record the host application's current `flutter analyze` result, so a later failure is attributable to this change
- [ ] 1.3 Confirm the three counts still hold: `widgetbook` + `widgetbook_annotation` at `pubspec.yaml:14-15`; `lib/src/_migrating/` containing only `README.md`; `dart format .` reporting 79 of 149

## 2. Move the catalogue tooling out of consumer-inherited dependencies

- [ ] 2.1 Move `widgetbook` and `widgetbook_annotation` from `dependencies` to `dev_dependencies`. `widgetbook_generator` is already correctly placed at `:21`
- [ ] 2.2 Run `flutter pub get` and `flutter analyze` in this package
- [ ] 2.3 Run `flutter analyze` in `Starry-Flutter-Frontend` — this is the check that decides whether the move was correct. A green package build does not mean the host compiles
- [ ] 2.4 If the host fails, the failure names production code depending on the catalogue tool. Fix that import, or record why the dependency must stay in the consumer-inherited section
- [ ] 2.5 Confirm `dart run build_runner build --delete-conflicting-outputs` still regenerates `main.directories.g.dart`
- [ ] 2.6 Confirm every `*.usecase.dart` still builds — the use-cases stay, only the declaration section moves

## 3. Resolve the empty staging directory

- [ ] 3.1 Establish whether `lib/src/_migrating/` is empty because the migration finished or because it is paused
- [ ] 3.2 Put that question to the user; do not delete on the assumption it is finished
- [ ] 3.3 If finished: remove the directory. `AGENTS.md` §4 still documents the `_migrating → internal stable → public stable` ladder, so the convention survives the directory
- [ ] 3.4 If paused: record in the README what it is waiting for, so the next reader is not misled by an empty folder

## 4. Record the formatting decision

- [ ] 4.1 Re-confirm the figure with `dart format --output=none --set-exit-if-changed .` and record the Dart SDK version that produced it
- [ ] 4.2 Put the decision to the user: reformat the package, or leave it and keep formatting only touched files per `AGENTS.md` §8.3
- [ ] 4.3 Do NOT reformat inside this change. A 79-file diff would bury the manifest edit that is this change's actual content
- [ ] 4.4 If the decision is to reformat, open a separate change and pin the SDK version in it
- [ ] 4.5 Separately, record whether a format check should be added to CI — nothing enforces it today, so the divergence can regrow regardless

## 5. Gate verification

- [ ] 5.1 `flutter analyze` in this package — must report no issues
- [ ] 5.2 `flutter test` in this package — full run, so the test-only source gates execute
- [ ] 5.3 `dart format lib/<only files this change touched>` — not `dart format .`
- [ ] 5.4 `flutter analyze` in `Starry-Flutter-Frontend`
- [ ] 5.5 Confirm no component API, rendering or token changed: `git diff` on `lib/src/theme/starry_tokens.dart` and `app_theme.dart` must be empty
- [ ] 5.6 Confirm no golden moved — this change should touch no pixels
