---
name: nibble-scan
description: Audit code for real defects, not style. Runs a deterministic structural pre-pass, then reviews for security, reliability, performance, and dead-logic bugs across any language, each with a concrete failure trigger. Report only, no fixes yet. Use when reviewing unfamiliar code or hunting the cause of a class of failures.
---

# nibble-scan

Bite 2 of the Nibble loop. Review the code the way a senior systems engineer reviews an unfamiliar codebase under a threat model: assume inputs are hostile, environments differ, and the happy path is already covered.

Report genuine defects only. Ignore formatting, naming, and cosmetic lint. Do not write fixes yet.

## Step 0: deterministic pre-pass

Before reviewing by hand, run the bundled scanner from this skill's folder:

```
bash "$(dirname "$0")/scan-repo.sh" .        # or point it at a subpath
```

It always runs a regex baseline (`ripgrep`, or `grep`) that covers every check, and adds a higher-precision `ast-grep` pass on top when that tool is installed, for structural bugs like `eval`, dynamic `RegExp`, wildcard `postMessage`, or unguarded environment globals. The results are candidates, not verdicts: confirm each one in the review below. If the script cannot run at all, skip it and rely on the manual review; the skill still works.

## Diagnostic focus areas

These patterns recur across languages. Translate each to the language in front of you.

- **Environment and global leakage (reliability).** Direct use of environment-specific globals or ambient state without a guard or fallback, in code meant to run in more than one environment. Examples: `window`, `document`, `localStorage`, `process` in JavaScript; `os.environ` or a hard-coded path in Python; a global mutable singleton in Go or Java; assuming a TTY, a filesystem, or a specific OS.
- **Trust boundaries (security).** Unvalidated input crossing a boundary: missing origin or sender checks on messages and callbacks, wildcards on sensitive outbound calls, unsafe dynamic evaluation or command construction, string-built queries (injection), deserialization of untrusted data, cleartext transport for sensitive data, secrets in code or logs.
- **Defensive data handling (reliability).** Deep property or field access on external data without checking for missing or null values. Unchecked array indexing, map lookups assumed to hit, or parsed payloads assumed well formed. Flag the exact access that breaks on malformed input.
- **Parsing and pattern traps (performance, reliability, security).** Unanchored or greedy patterns that match more than intended, user input interpolated into a compiled pattern, catastrophic backtracking, or regex and parser construction inside hot loops.
- **Concurrency and resource hazards (reliability).** Shared state mutated without synchronization, unbounded queues or caches, resources opened and never released, missing timeouts on I/O, and swallowed errors from async work.
- **Dead logic and tautologies (correctness).** Conditions that always evaluate the same way (for example `x == null || x != null`), unreachable branches, suppressed exceptions, and validation that never rejects anything.

## Output format

For each real defect:

**[Severity: High | Medium | Low] file:line — [Category]**
- **Root cause:** why the system fails, concisely and technically.
- **System impact:** what breaks, leaks, or degrades at runtime.
- **Trigger:** a concrete, minimal input, payload, or sequence that reproduces it.

### Deferred findings

If the pass surfaces more than can be fixed now, close with a short list of what is being left for later, one line each: `file:line — [Severity] one-line description`. This keeps the triage decision visible so nothing real is silently dropped, and gives the next pass a starting point.

## Execution rules

- Keep each audit batch under 25 lines, scannable (the deferred list does not count against this).
- Do not generate fixed code. Hand off to nibble-trace, or wait for the user to pick a finding.
