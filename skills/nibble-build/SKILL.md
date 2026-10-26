---
name: nibble-build
description: Implement one approved feature slice to the repo's own conventions, wire it in, and keep the tree compiling. Mirror the sibling feature from the plan instead of inventing patterns, and touch only what the slice needs. Use after nibble-plan, when it is time to write the feature code.
---

# nibble-build

Bite 3 of the Nibble build loop (map, plan, **build**, cover, commit). Build the one slice the plan approved, the way this repo already builds that kind of thing. New code is safest when it looks like the code already around it.

## Procedure

1. Build only the slice from nibble-plan. Do not expand scope mid-build; anything new goes on the Deferred list, not into this change.
2. Mirror the sibling. Follow its structure, naming, layering, and error handling. Copy the shape, not the specifics.
3. Wire it in. A feature is not done when the code exists; it is done when it is reachable. Register the route/command/screen, add the dependency injection binding, update navigation, and add any manifest/config entry the sibling has. An unwired feature is dead code.
4. Respect public contracts. Add new surface rather than changing existing signatures, exports, schemas, or behavior that other code depends on. If the slice genuinely requires a breaking change, stop and flag it.
5. Declare dependencies the repo's way. If a new library is truly needed, add it through the existing manifest or version catalog and the lock file, matching the surrounding style. Prefer what is already present.
6. Keep it compiling. Build after each meaningful step using the command from nibble-map, so the tree never drifts far from green. Leave testing to nibble-cover, but do not hand off a tree that does not build. If the slice compiles but behaves wrong at runtime and reading the code does not show why, escalate to nibble-debug to find the cause, then come back here to apply it.

## Language and framework notes

Same slice discipline everywhere; wire it in the way the stack expects, for example:

- **Web/API (any language):** add the handler and register it in the existing router; keep request/response shapes consistent with sibling endpoints.
- **Android (Java/Kotlin):** put sources under the module's `src/main/java` or `src/main/kotlin`, mirror the sibling's `ViewModel`/repository split, add the Hilt/Dagger binding in the right module, register the screen in navigation, and add the `res/` layouts or Compose and `AndroidManifest.xml` entries (for example a new `Activity`) that the sibling has. Build with the module-scoped Gradle task (for example `./gradlew :app:assembleDebug`) to stay fast.

## Output

Report plainly:

- The files added and the files touched, and the one-line purpose of each.
- Where the feature is wired in (route, binding, navigation, manifest).
- Any new dependency added, and why.
- Build result from the project's own command.

## Rules

- Smallest footprint that delivers the slice: fewest files, fewest touched lines, no drive-by refactors or reformatting.
- No new patterns or dependencies when an existing one fits.
- Do not change public contracts to make the feature easier; adapt the feature.
- Hand nibble-cover a tree that compiles.
