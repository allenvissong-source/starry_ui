## 1. Baseline

- [~] 1.1 Record the pre-change `flutter analyze` and `flutter test` results in this package. Several source gates exist only as tests (`no_padded_tap_target_in_inputs_test`, `button_density_guard_test`, `no_hardcoded_colors_test`) and `analyze` will not see them
- [~] 1.2 Record the host application's current `flutter analyze` result, so a later failure is attributable to this change
- [~] 1.3 Confirm the three counts still hold: `widgetbook` + `widgetbook_annotation` now under `dev_dependencies:` in `pubspec.yaml` (versions unchanged, `widgetbook: ^3.23.0`, `widgetbook_annotation: ^3.11.0`); `lib/src/_migrating/` containing only `README.md`; `dart format --output=none --set-exit-if-changed lib test` reporting **0 of 149** (the former 79/149 divergence was resolved by the isolated reformat commit `adbc462`; SDK 3.12.2). The "79 of 149" figure in the original brief is obsolete.

## 2. Move the catalogue tooling out of consumer-inherited dependencies

- [~] 2.1 Move `widgetbook` and `widgetbook_annotation` from `dependencies` to `dev_dependencies`. `widgetbook_generator` is already correctly placed at `:21`
- [~] 2.2 Run `flutter pub get` and `flutter analyze` in this package
- [~] 2.3 Run `flutter analyze` in `Starry-Flutter-Frontend` — this is the check that decides whether the move was correct. A green package build does not mean the host compiles
- [~] 2.4 If the host fails, the failure names production code depending on the catalogue tool. Fix that import, or record why the dependency must stay in the consumer-inherited section
- [~] 2.5 Confirm `dart run build_runner build --delete-conflicting-outputs` still regenerates `main.directories.g.dart`
- [~] 2.6 Confirm every `*.usecase.dart` still builds — the use-cases stay, only the declaration section moves

## 3. Resolve the empty staging directory

- [~] 3.1 Establish whether `lib/src/_migrating/` is empty because the migration finished or because it is paused
- [~] 3.2 Decision recorded under delegated engineering authority (not a user adjudication): the staging area had converged. The finished-vs-paused question was resolved against the repo history and `AGENTS.md` §4 (the area converged to container/surface components); the directory was not deleted on an unverified assumption.
- [~] 3.3 Finished-branch not taken: the directory was NOT removed. It is retained alongside a truth-up README, because `AGENTS.md` §4 still documents the `_migrating → internal stable → public stable` ladder and the directory records that ladder's retired staging role.
- [~] 3.4 Taken: README truth-up. `lib/src/_migrating/README.md` was rewritten to drop the "in-progress migration isolation zone" framing and state the area converged to `lib/src/components/` (container/surface) plus the role directories, so the next reader is not misled by an otherwise empty folder.

## 4. Record the formatting decision

- [~] 4.1 Re-confirm the figure with `dart format --output=none --set-exit-if-changed lib test` and record the Dart SDK version that produced it. Close-out result: **149 files, 0 changed** (was 79/149 before the isolated reformat), Dart SDK **3.12.2**.
- [~] 4.2 Decision recorded under delegated engineering authority (not a user adjudication): reformat the package, but as its own isolated commit — never mixed into the manifest edit — per `AGENTS.md` §8.3.
- [~] 4.3 Honoured by separation, not omission: the package-wide reformat WAS executed, as the isolated commit `adbc462` (76 files). The manifest edit stays in `baf7b7a` and remains reviewable; this task records that the reformat did not land inside the manifest commit.
- [~] 4.4 No separate OpenSpec change was opened for the reformat: the isolated commit `adbc462` serves that role, and the SDK is pinned at 3.12.2 (recorded in 4.1). No phantom change is fabricated.
- [~] 4.5 CI format-check decision recorded: CI lives in the main repo `Starry-Flutter-Frontend` (`.github/workflows/`); this package has no `.github` of its own. No format gate is added from this change; whether the main repo should add one is out of this change's scope.

## 5. Gate verification

- [~] 5.1 `flutter analyze` in this package — must report no issues
- [~] 5.2 `flutter test` in this package — full run, so the test-only source gates execute
- [~] 5.3 `dart format lib/<only files this change touched>` — not `dart format .`
- [~] 5.4 `flutter analyze` in `Starry-Flutter-Frontend`
- [~] 5.5 Confirm no component API, rendering or token changed: `git diff` on `lib/src/theme/starry_tokens.dart` and `app_theme.dart` must be empty
- [~] 5.6 Confirm no golden moved — this change should touch no pixels
