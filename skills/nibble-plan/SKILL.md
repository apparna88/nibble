---
name: nibble-plan
description: Plan a new feature as the smallest vertical slice that fits the repo you are in. Find where it belongs, the existing feature to mirror, and the conventions to follow, then draft the slice and its wiring without writing code. Use as the first design bite when adding a feature to a codebase you want to keep coherent.
---

# nibble-plan

Bite 2 of the Nibble build loop (map, **plan**, build, cover, commit). A feature added against the grain of a codebase is a feature that will be rewritten. Before any code, find the seam the feature fits into and the smallest slice worth shipping. Understand before you build.

## Procedure

1. Restate the feature in one or two sentences: the behavior a user or caller gets that they do not have today. If the request is vague, name the one concrete capability you will build first.
2. Find the sibling. Locate an existing feature in this repo that is shaped like the one you are adding (an analogous endpoint, screen, command, job, or model). It is your template for structure, naming, and wiring. Mirroring what is there beats inventing a new pattern.
3. Find the seam. Identify where the feature plugs in: the extension point, interface, router, registry, or DI graph the sibling uses. Note every layer a real slice must touch (for example: data, logic, interface, and wiring/registration).
4. Read the conventions, do not assume them. How this repo structures a feature (layering, module boundaries, error handling, naming), and how it declares dependencies (a package manifest, a DI module, a version catalog).
5. Choose the smallest vertical slice: the thinnest end-to-end path that delivers real behavior and can be tested, rather than a broad horizontal layer that does nothing on its own. Defer everything not needed for that slice to an explicit "later" list.
6. Decide how it will be verified before you build it, using the commands and test framework from nibble-map.

## Language and framework notes

The slice is defined the same way everywhere; only the seams differ. Mirror the sibling in whatever stack you are in, for example:

- **Web/API (any language):** a new route or handler registered in the existing router, its service/controller, and the data access it needs.
- **CLI:** a new subcommand registered in the existing command table.
- **Android (Java/Kotlin):** a feature usually spans a screen (`Activity`/`Fragment` or a Compose screen), a `ViewModel` or presenter, a data source/repository, dependency wiring (Hilt/Dagger module or a manual factory), navigation registration, and the `res/` + `AndroidManifest.xml` entries the sibling screen has. The smallest slice is one screen or one use-case wired end to end, not every screen the feature will eventually have.

## Output

Write the complete plan to `running-docs/nibble-plan.md` at the target repository root, creating `running-docs/` if needed. Replace the previous plan on each run. In the conversation, give the saved file path and a one-line status; do not repeat the full plan.

- **Feature:** one or two sentences.
- **Sibling to mirror:** the existing file(s)/feature this one copies in shape.
- **Slice:** the smallest end-to-end change, as a short ordered list of the files to add or touch and what each does.
- **Conventions to follow:** layering, naming, dependency wiring that the slice must respect.
- **Verification:** the exact build/test/lint commands that will prove the slice works.
- **Deferred:** what is intentionally out of this slice.

Keep it tight. Write no code in this bite.

## Rules

- One slice. If the feature is large, plan only the first shippable slice and list the rest under Deferred.
- Mirror the repo's existing patterns over introducing new ones or new dependencies; call out any genuinely new dependency and why it is needed.
- Stop after the plan. The plan is for the human to approve before nibble-build writes any code.
