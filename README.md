# Nibble

**Small, safe bites of change for repos you do not know.**

You just landed in an unfamiliar codebase and you have to change it, whether that is fixing a bug or adding a feature. The temptation is to gulp: read everything, change a lot, hope the tests catch it. Nibble is the opposite habit. It takes one small, well-understood bite at a time, so you can change code you do not own without breaking things you cannot see.

It is not one skill. It is two loops that share the same ends: both start by orienting (**nibble-map**) and finish with one atomic, self-documenting commit (**nibble-commit**). The middle is what differs.

## The loops

Both loops open with **nibble-map** and close with **nibble-commit**.

**Fix a bug**, `map → scan → trace → fix → commit`:

| Bite | Skill | What it does |
|------|-------|--------------|
| 2 | **nibble-scan** | Run a deterministic structural pre-pass, then audit for real defects (security, reliability, performance, dead logic) across any language, each with a concrete failure trigger. Report only. |
| 3 | **nibble-trace** | Pin the true root cause of one issue and draft a minimal fix strategy, without editing anything. |
| 4 | **nibble-fix** | Apply the smallest change that fixes the cause, preserve public contracts and untouched lines, then verify with the project's own commands. |

**Build a feature**, `map → plan → build → cover → commit`:

| Bite | Skill | What it does |
|------|-------|--------------|
| 2 | **nibble-plan** | Find where the feature belongs, the existing feature to mirror, and the conventions to follow. Draft the smallest vertical slice. No code; stops for your approval. |
| 3 | **nibble-build** | Implement that one slice to the repo's own conventions, wire it in (route, DI, navigation, manifest), and keep the tree compiling. |
| 4 | **nibble-cover** | Add tests for the new behavior using the project's own framework, then run build, tests, and lint green. |

When a built slice compiles but behaves wrong, or a new test will not go green and reading the code does not show why, the build loop has one escalation bite: **nibble-debug** diagnoses the cause from the runtime's own logs (`adb logcat` and tombstones on Android, the equivalent for every other stack), adds the minimum temporary logging to confirm one hypothesis, then loops back to **nibble-build** with a root cause and removes its probes. It diagnoses; it never commits.

Run a whole loop, or reach for any one bite on its own.

## Example: a real, open bug in valkey, in five bites

This is **not** a replay of a known fix. The loop lands on the current `unstable` HEAD of [`valkey-io/valkey`](https://github.com/valkey-io/valkey) (a ~500-file C codebase) and fixes [issue #3483](https://github.com/valkey-io/valkey/issues/3483), a still-open input-validation bug (Coverity CID 901320) where `ZRANGEBYSCORE` accepts a bare `(` as a score. Every line below is real output from the built server.

**Bite 1: nibble-map** orients in one pass:

```
Stack:       C, built with make. One binary: src/valkey-server.
Commands:    build → make -j    test → ./runtest --single unit/type/zset
Entry point: src/t_zset.c, ZRANGEBYSCORE / ZCOUNT via zslParseRange()
```

**Bite 2: nibble-scan** reviews `zslParseRange` and flags an inconsistent boundary: the general float parser (`string2d`) rejects empty input with a `slen == 0` guard, but this function rolls its own parse and omits it.

```
[reliability] t_zset.c:112  zslParseRange parses "(" as valkey_strtod_n(s+1, 0)
  with no empty-length guard. A bare "(" (and "") is silently read as 0.0,
  unlike every other float input in the server. Also a 0-length read (CID 901320).
```

**Bite 3: nibble-trace** proves it against the running HEAD server, no edits yet:

```
ZRANGEBYSCORE zs ( +inf   -> pos1 pos2       # a bare "(" ...
ZRANGEBYSCORE zs (0 +inf  -> pos1 pos2       # ... is silently treated as "(0"
ZRANGEBYSCORE zs '' +inf  -> zero pos1 pos2  # empty score parsed as 0.0
RESULT: BUG - bare "(" silently accepted (issue #3483)
```

Root cause: `valkey_strtod_n(s + 1, len - 1, …)` on a lone `(` parses zero bytes, returns `0.0`, and the `eptr[0] != '\0'` check passes. Fix strategy: reject an empty numeric body, the same guard the robust path already has.

**Bite 4: nibble-fix** adds the missing guard (4 lines in `src/t_zset.c`, applied to both the min and max branches):

```diff
 if (s[0] == '(') {
+    if (len < 2) return C_ERR; /* bare "(" with no score is not a float */
     spec->min = valkey_strtod_n(s + 1, len - 1, &eptr);
     if (eptr[0] != '\0' || isnan(spec->min)) return C_ERR;
     spec->minex = 1;
 } else {
+    if (len == 0) return C_ERR; /* empty score is not a float */
     spec->min = valkey_strtod_n(s, len, &eptr);
```

Rebuild, rerun the exact same trigger, and confirm valid ranges are untouched:

```
ZRANGEBYSCORE zs ( +inf   -> ERR min or max is not a float   # rejected
ZRANGEBYSCORE zs '' +inf  -> ERR min or max is not a float   # rejected
ZRANGEBYSCORE zs (-1 (2    -> zero pos1                       # exclusive still works
ZRANGEBYSCORE zs -inf +inf -> neg2 neg1 zero pos1 pos2        # normal range intact
RESULT: bare "(" is REJECTED (fixed)
```

The guard closes the bug for every command that shares `zslParseRange` (ZCOUNT, ZRANGESTORE, …); no valid input changes behavior.

**Bite 5: nibble-commit** records one atomic, self-documenting commit:

```
fix: reject a bare "(" score in zslParseRange (#3483)

Root cause: zslParseRange parsed the score body with valkey_strtod_n but,
unlike the server's general float parser, never guarded against an empty
body, so "(" and "" were silently read as 0.0.
Impact: ZRANGEBYSCORE / ZCOUNT / ZRANGESTORE returned wrong results for a
malformed range with no error (Coverity CID 901320, a 0-length read).
Fix: reject an empty numeric body in both the min and max branches.
Backwards compatibility: preserved. Every valid inclusive/exclusive score
parses exactly as before; only empty bodies are now refused.
```

Five bites: oriented in an unfamiliar C codebase, found a real open defect, proved it against the running HEAD server, fixed the cause, and wrote history that explains itself.

## Why it is different

There are plenty of bug-finding and commit skills. Nibble is not another single tool competing with them. It is an opinionated **end-to-end habit** for working safely in code you did not write, with one idea running through every step: the best change is the smallest one that holds, and every extra line you touch is a new place to be wrong.

- **Small bites by default.** No premature changes, no reformatting neighboring code, no touching public contracts, no rewriting tests that are not broken. A feature is built as the smallest vertical slice, not a broad rewrite.
- **Understand before you change.** Two full bites go to understanding before a line is edited: the code and the cause when fixing, the seam and the slice to mirror when building.
- **Deterministic where it counts.** nibble-scan starts with a mechanical scan for structural bugs: a regex baseline that always runs, plus a higher-precision `ast-grep` pass when that tool is installed. The model reviews on top. With no external tools at all it still falls back to a pure review, so it runs anywhere.
- **Mirror, don't invent.** New code is built to look like the code already around it: the feature loop finds a sibling feature and copies its shape, wiring, and tests rather than introducing new patterns or dependencies.
- **Self-documenting history.** Every change lands as one atomic commit that explains itself, so a reviewer can approve one small bite at a time.

## Language and agent agnostic

**Any language.** The skills describe patterns, not syntax. nibble-scan reasons about trust boundaries, environment leakage, unsafe parsing, and dead logic, and translates each to whatever language is in front of it, with concrete examples spanning JavaScript, Python, Go, Java, and Rust. The feature loop (nibble-plan, nibble-build, nibble-cover) works the same way: it defines a slice and mirrors an existing feature's structure and wiring in whatever stack is in front of it. nibble-map detects the stack from whatever manifest is present and reads the real commands rather than guessing.

**Including Android.** Java, Kotlin, and Android/Gradle are first-class. nibble-map reads the `gradlew` wrapper, version catalogs, and module layout and uses the project's real tasks (`assembleDebug`, `testDebugUnitTest`, `connectedAndroidTest`, `lint`/`ktlintCheck`/`detekt`); the feature loop mirrors the repo's own screen/`ViewModel`/repository split, DI (Hilt/Dagger), navigation, and `res/` + `AndroidManifest.xml` wiring. When a built screen misbehaves on device, nibble-debug reads `adb logcat`, tombstones, and ANR traces to pin the cause before any further edit.

**Any agent.** The skills are plain Markdown instructions with no tool-specific or model-specific assumptions. They work anywhere a coding agent can read a skill or rules file, including Claude Code and other assistants that accept Markdown skill files. Nothing in them depends on a particular model or vendor.

## Optional dependency

nibble-scan works with no dependencies, but for its highest-precision structural pass, install [`ast-grep`](https://ast-grep.github.io):

```
npm install -g @ast-grep/cli   # or: brew install ast-grep / cargo install ast-grep
```

Without it, the scanner falls back to `ripgrep`, then to `grep`. Nothing else is required.

## Install

### As a Claude Code plugin

Add the marketplace, then install:

```
/plugin marketplace add apparna88/nibble
/plugin install nibble@nibble
```

### As individual skills (any agent)

Clone the repo, then either copy the skill folders yourself or run the installer.

Copy directly (transparent, no script):

```
cp -r skills/nibble-map    ~/.claude/skills/
cp -r skills/nibble-scan   ~/.claude/skills/
cp -r skills/nibble-trace  ~/.claude/skills/
cp -r skills/nibble-fix    ~/.claude/skills/
cp -r skills/nibble-plan   ~/.claude/skills/
cp -r skills/nibble-build  ~/.claude/skills/
cp -r skills/nibble-cover  ~/.claude/skills/
cp -r skills/nibble-debug  ~/.claude/skills/
cp -r skills/nibble-commit ~/.claude/skills/
chmod +x ~/.claude/skills/nibble-scan/scan-repo.sh
```

Or use the bundled installer. Read it first, then run it (it only copies files):

```
less install.sh
./install.sh
```

For another agent, paste the body of any `SKILL.md` into that agent's custom instructions or rules file. The instructions are self-describing and do not need the surrounding structure.

## Repository layout

```
nibble/
├── README.md
├── LICENSE
├── install.sh
├── .claude-plugin/
│   ├── marketplace.json
│   └── plugin.json
└── skills/
    ├── nibble-map/SKILL.md
    ├── nibble-scan/
    │   ├── SKILL.md
    │   └── scan-repo.sh      <- deterministic pre-pass (ast-grep, with fallback)
    ├── nibble-trace/SKILL.md
    ├── nibble-fix/SKILL.md
    ├── nibble-plan/SKILL.md
    ├── nibble-build/SKILL.md
    ├── nibble-cover/SKILL.md
    ├── nibble-debug/SKILL.md
    └── nibble-commit/SKILL.md
```

## License

MIT. Use it, fork it, adapt it to your stack.
