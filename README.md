# Nibble

**Small, safe bites of change for repos you do not know.**

<!-- DEMO: add a screen recording of the loop here, e.g. ![nibble demo](docs/demo.gif) -->

You just landed in an unfamiliar codebase and something needs fixing. The temptation is to gulp: read everything, change a lot, hope the tests catch it. Nibble is the opposite habit. It takes one small, well-understood bite at a time, so you can ship a fix to code you do not own without breaking things you cannot see.

It is not one skill. It is a loop of five, each doing one job and handing off to the next.

## The loop

| Bite | Skill | What it does |
|------|-------|--------------|
| 1 | **nibble-map** | Get your bearings in an unfamiliar repo fast: stack, exact build and test commands, entry points. Orient before you touch anything. |
| 2 | **nibble-scan** | Run a deterministic structural pre-pass, then audit for real defects (security, reliability, performance, dead logic) across any language, each with a concrete failure trigger. Report only. |
| 3 | **nibble-trace** | Pin the true root cause of one issue and draft a minimal fix strategy, without editing anything. |
| 4 | **nibble-fix** | Apply the smallest change that fixes the cause, preserve public contracts and untouched lines, then verify with the project's own commands. |
| 5 | **nibble-commit** | Commit the single fix with a structured message: root cause, impact, strategy, backwards compatibility. |

Run the whole loop, or reach for any one bite on its own.

## Why it is different

There are plenty of bug-finding and commit skills. Nibble is not another single tool competing with them. It is an opinionated **end-to-end habit** for working safely in code you did not write, with one idea running through every step: the best change is the smallest one that holds, and every extra line you touch is a new place to be wrong.

- **Small bites by default.** No premature fixing, no reformatting neighboring code, no touching public contracts, no rewriting tests that are not broken.
- **Understand before you change.** Two full bites are spent understanding the code and the cause before a single line is edited.
- **Deterministic where it counts.** nibble-scan starts with a mechanical scan for structural bugs: a regex baseline that always runs, plus a higher-precision `ast-grep` pass when that tool is installed. The model reviews on top. With no external tools at all it still falls back to a pure review, so it runs anywhere.
- **Low token, high signal.** Each bite has a hard output budget and reports only what matters, and scan keeps a short "deferred findings" list so nothing real is silently dropped.
- **Self-documenting history.** Every fix lands as one atomic commit that explains itself, so a reviewer can approve one small bite at a time.

## Language and agent agnostic

**Any language.** The skills describe patterns, not syntax. nibble-scan reasons about trust boundaries, environment leakage, unsafe parsing, and dead logic, and translates each to whatever language is in front of it, with concrete examples spanning JavaScript, Python, Go, Java, and Rust. nibble-map detects the stack from whatever manifest is present and reads the real commands rather than guessing.

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
    └── nibble-commit/SKILL.md
```

## License

MIT. Use it, fork it, adapt it to your stack.
