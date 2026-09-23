# Implementation Tasks

## 1. AGENTS.md policy update

- [x] 1.1 Add a "Generated files policy" subsection to AGENTS.md documenting: which files are generated (`lib/main.directories.g.dart`), the generation command (`dart run build_runner build --delete-conflicting-outputs`), tracking status (tracked in git), and rationale. Verify by reading the updated section.

## 2. .gitignore comment

- [x] 2.1 Add an explicit comment in .gitignore near the Flutter/Dart section stating that `lib/main.directories.g.dart` is intentionally tracked despite being generated. Verify by reading the comment.

## 3. CI workflow

- [x] 3.1 Create `.github/workflows/generated-files-check.yml` with steps: checkout, setup Flutter, `flutter pub get`, `dart run build_runner build --delete-conflicting-outputs`, `git diff --exit-code`. Verify the YAML is syntactically valid.

## 4. Verification

- [x] 4.1 Run `dart run build_runner build --delete-conflicting-outputs` and then `git diff --exit-code` — verify exit code 0 (no drift).
- [x] 4.2 Run `dart analyze` — verify zero errors.
- [x] 4.3 Run `dart test` — verify all tests pass.
