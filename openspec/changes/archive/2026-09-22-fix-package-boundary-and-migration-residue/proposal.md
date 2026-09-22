## Why

Three items, each verified in the tree.

- **`widgetbook` and `widgetbook_annotation` sit in `dependencies`, not `dev_dependencies`** (`pubspec.yaml:14-15`). Every consumer of this package therefore inherits a catalogue/documentation tool as a transitive production dependency. `widgetbook_generator` is correctly placed at `:21`, which makes the other two look like an oversight rather than a decision.
- **`lib/src/_migrating/` contains only a `README.md`** and no Dart source. An empty staging directory reads as work in flight when there is none.
- **Formatting 79 of 149 files would change them.** Running `dart format` across the package is a decision, not a chore: it rewrites more than half the package in one diff, and this repo's CI does not check this package's formatting, so nothing forces the question either way.

## What Changes

- Move `widgetbook` and `widgetbook_annotation` out of `dependencies`, so a consumer does not
  inherit them — or record why they must stay.
- Resolve `lib/src/_migrating/`: finish it, remove it, or record what it is waiting for.
- Decide the formatting question explicitly rather than leaving 79 files permanently divergent.

## Capabilities

### New Capabilities

- `package-dependency-boundary` — what a shared package may impose on the applications that
  depend on it, and how a staging area must declare its own status.

## Impact

- Moving the two packages to `dev_dependencies` changes the dependency graph of every consumer.
  If any production code path imports them, the build breaks — which is exactly the check that
  proves the move was correct.
- A whole-package format would produce a 79-file diff that buries any real change alongside it.
- Files: `pubspec.yaml`, `lib/src/_migrating/`, and potentially every Dart file in the package.

## Non-goals

- Changing any component's public API or behaviour.
- Adding formatting enforcement to CI for this package — that is a separate decision from
  whether to format now.
- Removing Widgetbook usage itself; the `.usecase.dart` files stay.
