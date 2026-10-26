---
name: nibble-debug
description: Diagnose a feature you just built that compiles but behaves wrong, or whose new tests will not go green, by reading the runtime's own logs and adding the minimum temporary logging to confirm one cause. Report the cause and the fix location, then remove the probes. Use inside the build loop when nibble-build or nibble-cover produces behavior that does not match the plan.
---

# nibble-debug

Escalation bite of the Nibble build loop (map, plan, build, cover, commit). It is not a step you always take: reach for it only when the slice you just built compiles but behaves wrong at runtime, or `nibble-cover`'s new tests will not go green and reading the code has not shown why. It diagnoses; it does not fix. It loops **back** to nibble-build with a cause, never forward to commit.

This is the build loop's counterpart to nibble-trace, but for your own fresh code. You know the intent, so you can state expected versus observed exactly and drive straight to the gap, instead of reconstructing someone else's reasoning.

## Procedure

1. State expected versus observed for the one slice, in one line each. The gap between them is the whole target. If you cannot state the expected behavior precisely, go back to the plan, not the debugger.
2. Reproduce it deterministically, using the verification path from nibble-plan (the failing test, the exact request, or the exact tap sequence on device). An intermittent repro is the first thing to pin down; a bug you cannot trigger on demand you cannot confirm you fixed.
3. Read the logs the runtime already gives you before adding any. The stack trace, the test runner's failure output, and the app's existing structured logs usually name the layer. Read those first.
4. Add the minimum temporary logging to confirm or kill one hypothesis, not to trace everything. Log the one value or the one branch that decides between two explanations, reproduce, read it, then form the next hypothesis. One probe, one question.
5. Localize to a layer. Decide whether the fault is the wiring (the route, DI binding, navigation, or manifest entry is never reached), the data (wrong or missing input), or the logic (reached with the right input, wrong output). The three need different fixes, so name which one before handing off.
6. Hand nibble-build a one-line root cause and the exact fix location. Then remove every probe you added so the tree is exactly as nibble-build left it, minus the bug. Temporary logging never reaches nibble-commit.

## Language and framework notes

Use the runtime's own observability; the method is identical, only the log source differs:

- **Android (Java/Kotlin):** `adb logcat` filtered by tag or pid (for example `adb logcat --pid=$(adb shell pidof -s com.example.app)`) for app logs and uncaught exceptions; tombstones under `/data/tombstones` and `adb bugreport` for native (NDK) crashes; the ANR traces in `/data/anr/` when the UI freezes; Layout Inspector or `uiautomator dump` when a screen renders wrong but does not crash. Prefer a failing `testDebugUnitTest` to reproduce logic faults off-device; reserve device/logcat debugging for wiring and framework behavior a unit test cannot see.
- **Node:** `DEBUG=` namespaces, `--inspect` with a breakpoint, and the full stack from an unhandled rejection or `process.on('unhandledRejection')`.
- **Python:** the `logging` module at `DEBUG`, `pdb`/`breakpoint()`, and `faulthandler` for native crashes and hangs.
- **Go:** `log`/`slog`, `delve` for stepping, and the panic goroutine dump.
- **Rust:** `RUST_LOG` with `tracing`/`env_logger`, and `RUST_BACKTRACE=1` for the panic backtrace.
- **Any:** the test runner's own failure output and the feature's existing structured logs come first; add new logging only when they do not name the cause.

## Output

Write the complete diagnosis to `.nibble/nibble-debug.md` at the target repository root, creating `.nibble/` if needed. Replace the previous debug report on each run. In the conversation, give the saved file path and a one-line status; do not repeat the full diagnosis.

- Expected versus observed, in one line each.
- The deterministic repro (the command, request, or tap sequence).
- The confirmed root cause and the layer it lives in (wiring, data, or logic).
- The exact file and location for nibble-build to change.
- Confirmation that every temporary probe has been removed.

## Rules

- Diagnose only. nibble-debug finds the cause; nibble-build applies the fix and nibble-cover re-verifies.
- One hypothesis at a time. Add the smallest logging that decides it, not broad tracing.
- Every probe you add is temporary. Remove all of it before handing back; it never lands in a commit.
- No repro, no confirmed fix. If you cannot trigger the bug on demand, pin that down before changing anything.
