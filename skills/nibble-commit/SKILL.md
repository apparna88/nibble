---
name: nibble-commit
description: Commit one atomic change with a structured message that documents why it exists, its impact, the approach, and backwards compatibility. Closes out a single fix or a single feature slice cleanly, so the history explains itself later and reviewers can approve one small bite at a time.
---

# nibble-commit

Bite 5 of both Nibble loops, the one that lands a fix or a feature slice. Record the change so the next person, or the next you, understands it without archaeology. One bite, one commit.

## Procedure

1. Stage only the files changed for this single fix or feature slice. Do not fold in unrelated changes.
2. Write the commit message in this shape (adapt the type and scope to the project's convention). For a fix, the first line is the root cause; for a feature, it is what the slice adds and why:

   ```
   <type>(<scope>): <short title>

   - Root Cause / Motivation: <1 sentence>
   - Impact: <1 sentence>
   - Strategy: <1 to 2 sentences>
   - Backwards Compatibility: <1 sentence>
   ```

3. Use the type that fits (`feat` for a new feature, `fix`, `perf`, `refactor`, and so on). Keep the title imperative and under about 70 characters.
4. If the change is not backwards compatible, say so explicitly and note the migration.

## Rules

- One logical change per commit. If you did two things, make two commits.
- Do not stage build artifacts, unrelated formatting, or generated files.
