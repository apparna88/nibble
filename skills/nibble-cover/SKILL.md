---
name: nibble-cover
description: Add tests for the new feature's behavior using the project's own framework and patterns, then run build, tests, and lint until the tree is green. Covers the slice that was built, not the whole module. Use after nibble-build, before committing a feature.
---

# nibble-cover

Bite 4 of the Nibble build loop (map, plan, build, **cover**, commit). A feature with no test is a feature that regresses silently. Prove the new behavior the way this repo proves behavior, and leave the tree green.

## Procedure

1. Mirror the existing tests. Find the sibling feature's tests (located in nibble-map) and copy their framework, layout, naming, and helpers. Do not introduce a new test tool.
2. Cover the new behavior, not the framework: the main success path, the one or two edge cases a caller will actually hit, and any contract the feature promises. Prefer a few meaningful tests over broad shallow ones.
3. Test at the level the sibling does. Favor fast unit tests for logic; add a higher-level or integration test only where the sibling has one and the wiring is worth proving.
4. Run the project's own commands from nibble-map: tests, then build, then lint if the project uses one. Fix the feature or the test until all pass. Do not weaken an assertion to go green. If a new test fails and reading the feature does not show why, escalate to nibble-debug to pin the cause from the runtime's logs, then return here once nibble-build has applied it.
5. Do not break existing tests. If the feature changed shared behavior, that is a signal from nibble-build to revisit, not a test to delete.

## Language and framework notes

Use the stack's real runner and keep the loop fast, for example:

- **Node/Python/Go/Rust:** the framework already in the repo (Jest/Vitest, pytest, `go test`, `cargo test`), tests beside the sibling's.
- **Android (Java/Kotlin):** put local logic tests under `src/test/` and run `./gradlew testDebugUnitTest` (scope to a module, for example `:app:testDebugUnitTest`, to stay quick); reserve `src/androidTest/` instrumented tests for UI or framework-dependent behavior the sibling also tests that way. Use the repo's existing libraries (JUnit, and whatever is present such as Robolectric, MockK/Mockito, Turbine) rather than adding new ones.

## Output

Write the complete coverage report to `running-docs/nibble-cover.md` at the target repository root, creating `running-docs/` if needed. Replace the previous coverage report on each run. In the conversation, give the saved file path and a one-line status; do not repeat the full report.

- The test files added or extended, and what behavior each covers.
- The exact commands run, and their result (tests, build, lint).
- Anything intentionally left uncovered and why.

## Rules

- Use the project's existing test framework and conventions; add no new test dependency when one is present.
- Cover the slice that was built, not unrelated code.
- Green means the project's own commands pass without weakened assertions or skipped tests.
