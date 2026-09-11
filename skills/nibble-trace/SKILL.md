---
name: nibble-trace
description: Pin the root cause of a single issue or file and draft a minimal fix strategy, without editing anything. Low token, focused. Use once a specific bug or failing case has been chosen and you need the true cause before changing code.
---

# nibble-trace

Bite 3 of the Nibble loop. Narrow to one problem and find why it actually fails, at the system level, before any code is touched.

## Procedure

1. Read only the specified file, function, or failing case. Do not wander the codebase.
2. Identify the root cause: the underlying reason it fails, not the surface symptom. Distinguish the true cause from the place the error surfaces.
3. Confirm the mechanism in one or two sentences: the input or state, the faulty step, the wrong result.
4. Draft a minimal fix strategy in 1 to 3 lines. Name what changes and what must stay the same (signatures, public behavior, adjacent code).

## Output

- **Root cause:** one or two sentences.
- **Fix strategy:** 1 to 3 lines, minimal by design.

Keep total output under 15 lines. Do not edit files. Hand off to nibble-fix.
