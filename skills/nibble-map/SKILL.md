---
name: nibble-map
description: Get your bearings in an unfamiliar repo fast, before changing anything. Finds the stack, the exact build and test commands, and the entry points in one pass. Use as the first bite whenever you land in a codebase you do not already know.
---

# nibble-map

Bite 1 of the Nibble loop. Orient before you touch anything. The goal is a short, accurate map, not a full tour.

## Procedure

1. Detect the stack. Read the manifest and lock files at the repo root to identify the language, package manager, and key dependencies. Manifests vary by ecosystem, so check whichever are present, for example:
   - Node: `package.json`
   - Python: `pyproject.toml`, `setup.cfg`, `requirements.txt`
   - Rust: `Cargo.toml`
   - Go: `go.mod`
   - Java or Kotlin: `pom.xml`, `build.gradle`
   - Ruby: `Gemfile`
   - Any: a `Makefile`, `justfile`, `Taskfile`, or CI config often lists the real commands
2. Find the commands that matter. Extract the exact test command, build command, lint command, and run command from the manifest scripts, task runner, or CI config. Do not guess them.
3. Locate entry points and core modules. Look for the conventional roots for the stack (for example `src/`, `app/`, `cmd/`, `lib/`, `server/`, `api/`) and the main executable or server bootstrap.
4. Note the test setup. Identify the test framework and where tests live, so a later bite can verify a change.

## Output

Report only these, tersely:

- Stack: language, package manager, notable dependencies
- Commands: test, build, lint, run (exact strings)
- Entry points: the files or directories that matter
- Tests: framework and location

Keep the whole map under 20 lines. Do not open every file. Do not propose changes here.
