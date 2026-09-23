# Starry UI

Shared Flutter design-system package for the Starry product family.

## Boundary

- Owns every `Starry*` public widget and the `StarryTokens` theme extension family.
- Consumed by `Starry-Flutter-Frontend` through a `path: ../starry_ui` dependency.
- Has a strict one-way dependency rule: this package must never import `package:starry/`.

## Conventions

- Colors, spacing, radius, motion and opacity come from tokens; literals are gated by
  `custom_lint` rules plus the repo checkers in the host application.
- Every public widget is expected to have a Widgetbook use-case covering its main variants.
- Tests: `flutter test` in this package must stay green before the host application is updated.

## Known governance context (2026-09-19)

- `dart format .` reports 79 of 149 files as changed; formatting the package is an open decision,
  not an accepted task.
- 22 barrel-exported public widgets currently have zero production consumption in the host app;
  5 of them are still instantiated inside the package.
- Widgetbook (`widgetbook`, `widgetbook_annotation`, `widgetbook_generator`) sits in
  `dev_dependencies`, so it is not a transitive dependency of the host application.
  (`lib/src/_migrating/` was removed in `ui-greenfield-cleanup`; the migration it staged has
  converged into `lib/src/components/` and the role directories.)
