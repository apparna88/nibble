---
name: nibble-map
description: Get your bearings in an unfamiliar repo fast, before changing anything. Finds the stack, the exact build and test commands, and the entry points in one pass. Use as the first bite whenever you land in a codebase you do not already know.
---

# nibble-map

Bite 1 of both Nibble loops: the first step whether you are about to fix a bug (scan, trace, fix) or build a feature (plan, build, cover). Orient before you touch anything. The goal is a short, accurate map, not a full tour.

## Procedure

1. Detect the stack. Read the manifest and lock files at the repo root to identify the language, package manager, and key dependencies. Manifests vary by ecosystem, so check whichever are present, for example:
   - Node: `package.json`
   - Python: `pyproject.toml`, `setup.cfg`, `requirements.txt`
   - Rust: `Cargo.toml`
   - Go: `go.mod`
   - Java or Kotlin (Maven): `pom.xml`
   - Java, Kotlin, or Android (Gradle): `build.gradle`, `build.gradle.kts`, `settings.gradle(.kts)`, `gradle/libs.versions.toml` version catalog, and a `gradlew` wrapper. Android adds `AndroidManifest.xml` and per-module `build.gradle` under module roots like `app/`.
   - Ruby: `Gemfile`
   - Any: a `Makefile`, `justfile`, `Taskfile`, or CI config often lists the real commands
2. Find the commands that matter. Extract the exact test command, build command, lint command, and run command from the manifest scripts, task runner, or CI config. Do not guess them. When a `gradlew` wrapper is present, prefer it over a system `gradle`, and read the real task names rather than assuming:
   - Build: `./gradlew build`, or for Android `./gradlew assembleDebug`.
   - Unit tests: `./gradlew test`, or for Android `./gradlew testDebugUnitTest`; instrumented tests `./gradlew connectedAndroidTest`.
   - Lint: `./gradlew lint`, `ktlintCheck`, or `detekt` if configured.
   - A single module scopes as `./gradlew :app:testDebugUnitTest`.
3. Locate entry points and core modules. Look for the conventional roots for the stack (for example `src/`, `app/`, `cmd/`, `lib/`, `server/`, `api/`). For Gradle/Android, note the modules in `settings.gradle` and each module's source root (`src/main/java`, `src/main/kotlin`, `res/`, `AndroidManifest.xml`), plus the app entry (the launcher `Activity`, or `Application` subclass). Find the main executable or server bootstrap.
4. Note the test setup. Identify the test framework and where tests live, so a later bite can verify a change. For the JVM/Android world distinguish local unit tests (`src/test/`, JUnit) from instrumented tests (`src/androidTest/`).

## Output

Write the complete map to `running-docs/nibble-map.md` at the target repository root, creating `running-docs/` if needed. Replace the previous map on each run. In the conversation, give the saved file path and a one-line status; do not repeat the full map.

Report only these, tersely:

- Stack: language, package manager, notable dependencies
- Commands: test, build, lint, run (exact strings)
- Entry points: the files or directories that matter
- Tests: framework and location

Keep the whole map under 20 lines. Do not open every file. Do not propose changes here.

For the build loop, the same map is what nibble-plan reads to find where a new feature belongs; note the module boundaries and source roots so the next bite can mirror an existing feature rather than guess.
