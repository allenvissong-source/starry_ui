## Context

Three items, all boundary hygiene rather than component behaviour.

**The dependency placement.** `pubspec.yaml:14-15` puts `widgetbook` and
`widgetbook_annotation` in `dependencies`; `widgetbook_generator` is at `:21` in
`dev_dependencies`. Widgetbook is the component catalogue — it exists to document this package,
not to implement it. The split placement of the three related packages is itself the strongest
evidence this was not deliberate.

Whether any production code actually imports them is the question the move answers: if nothing
does, the move is invisible to consumers; if something does, the build tells us immediately.

**The empty staging directory.** `AGENTS.md` §4 defines the maturity ladder
`_migrating → internal stable → public stable` and reserves `lib/src/_migrating/` for the first
rung. It currently holds only a `README.md`. §4 also records that `components/` has already been
converted from a staging area into a real role-based directory, so the migration this staging
area served appears finished.

**The formatting divergence.** `AGENTS.md` §8.3 already documents this precisely: 79 of 149
files change under Dart 3.12.2's tall style, the repo's CI has no format step, and the guidance
is to format only files you touch and to treat a full reformat as its own project with a pinned
SDK. This change does not overturn that guidance — it asks for the decision to be made rather
than deferred indefinitely.

## Goals / Non-Goals

Goals:

- A consumer of this package does not inherit its catalogue tooling.
- The staging directory either holds work or is gone.
- The formatting question has an answer on the record.

Non-Goals:

- Changing any component's API or rendering. This change must move no pixels.
- Removing Widgetbook use-cases. The `*.usecase.dart` files stay.
- Performing the reformat inside this change.
- Adding a format step to CI — that is a separate decision from whether to reformat.

## Decisions

**Decision: move the two packages and let the build be the proof.**
Rather than auditing imports first and moving second, move them and run the host application's
analyze. If production code depends on them, the failure is immediate, specific and points at
the exact file. An audit that concludes "nothing imports these" is weaker evidence than a
compile.

**Decision: verify against the host application, not just this package.**
`AGENTS.md` §0 is explicit that a green `flutter test` here does not mean the host compiles. A
dependency-graph change is exactly the class of edit that can pass locally and break the
consumer, so the acceptance check runs in `Starry-Flutter-Frontend`.

**Decision: do not reformat in this change.**
§8.3's reasoning stands: a 79-file diff would bury the three-line manifest edit that is the
actual content here. The decision is recorded and, if taken, executed separately with a pinned
SDK version.

**Decision: do not decide the staging directory's fate unilaterally.**
It is empty today, but "empty because finished" and "empty because paused" call for different
actions, and only the user knows which. Recorded as an open question.

## Risks / Trade-offs

- **The move breaks the host build.** → That is the finding, not an accident: it would mean
  production code depends on the catalogue tool, which is precisely the defect. Fix the import
  or record why the dependency must stay.
- **Removing the staging directory loses a convention marker.** → §4 still documents the ladder;
  the directory can be recreated when there is work for it. An empty one that has outlived its
  migration teaches the wrong thing.
- **Deferring the reformat leaves 79 files divergent.** → Already true and already documented.
  This change makes the deferral explicit rather than tacit.
- **Nothing enforces formatting.** → Named as an open question rather than silently accepted.

## Migration Plan

1. Move `widgetbook` and `widgetbook_annotation` from `dependencies` to `dev_dependencies`.
2. Run `flutter pub get` and `flutter analyze` in this package.
3. Run `flutter analyze` in `Starry-Flutter-Frontend` — this is the check that matters.
4. Confirm the Widgetbook use-cases still build and `build_runner` still generates.
5. Resolve `lib/src/_migrating/` once its status is known.
6. Record the formatting decision; if it is to reformat, open a separate change with a pinned
   SDK version.

Rollback: the manifest edit is a two-line revert. Nothing else here changes code.

## Open Questions

- **Is `lib/src/_migrating/` finished or paused?** If finished, remove it. If paused, record
  what it is waiting for so the next reader is not misled.
- **Should the package be reformatted, and under which pinned SDK?** 79 of 149 files, Dart
  3.12.2 tall style. Not decided here.
- **Should a format check be added to CI for this package?** Currently nothing enforces it, so
  the divergence can grow again regardless of what is decided above.
