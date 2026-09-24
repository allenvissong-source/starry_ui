# Barrel export audit — public surface decisions

Measured 2026-09-24 on the current workspace with:

```powershell
python D:\Starry-1.07\_agent_logs\g3p3_twin_census.py `
  D:\Starry-1.07\starry `
  D:\Starry-1.07\starry_ui --barrel
```

This document records the decision boundary rather than treating every name with
no direct app reference as dead code.

## Method

A *consumer* is a reference outside the declaring file. Import/export/part
statements and line comments do not count. The census keeps these scopes apart:

| Scope | Question answered |
| --- | --- |
| main app `lib/` | Does the application name this API directly? |
| `starry_ui/lib/` outside the declaring file | Does another package component compose it? |
| declaring file | Is the type required by its own public fields, switches, or extensions? |

A zero in the first scope is not sufficient evidence for deletion. Token types,
parameter enums, extension names, and lower-level primitives can be load-bearing
without being named by the app.

## Current result

| Measure | Count |
| --- | ---: |
| barrel export directives | 54 |
| public names reachable through the barrel | 121 |
| names with zero direct main-app references | 26 |
| of those, composed elsewhere in `starry_ui/lib` | 8 |
| of those, with no cross-file reference | 18 |
| deletable after declaring-file inspection | **0** |

The 18 cross-file-zero names are required inside their declaring files: examples
include token classes stored by `StarryTokens`, enum values exhaustively switched
by their component, builder typedefs used by public fields, and
`StarryApplicationTokensContext`, whose extension getters are the API even though
the extension name itself is never referenced.

## Swipe public boundary

`StarrySwipeAction` remains public because the main app and public composite
widgets construct action lists with it. `StarrySwipeable` is an implementation
primitive used by `StarryMessageList` and `StarrySlidableDrawer`; it is no longer
exported from `lib/starry_ui.dart` and is imported relatively by those internal
components.

This keeps the action data contract public while preventing callers from binding
to the lower-level drag/settle implementation.

## Decision

- Keep the current 121 public names; this audit found no name safe to remove.
- Do not infer deletability from direct app-consumer counts alone.
- Re-run the census after any barrel change and inspect declaring-file use before
  removing a zero-consumer name.
