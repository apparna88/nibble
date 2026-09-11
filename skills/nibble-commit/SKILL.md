---
name: nibble-commit
description: Commit one atomic fix with a structured message that documents root cause, impact, fix strategy, and backwards compatibility. Use to close out a single fix cleanly, so the history explains itself later and reviewers can approve one small bite at a time.
---

# nibble-commit

Bite 5 of the Nibble loop. Record the fix so the next person, or the next you, understands it without archaeology. One bite, one commit.

## Procedure

1. Stage only the files changed for this single fix. Do not fold in unrelated changes.
2. Write the commit message in this shape (adapt the type and scope to the project's convention):

   ```
   fix(<scope>): <short title>

   - Root Cause: <1 sentence>
   - Impact & Severity: <1 sentence>
   - Fix Strategy: <1 to 2 sentences>
   - Backwards Compatibility: <1 sentence>
   ```

3. Use the type that fits (`fix`, `perf`, `refactor`, and so on). Keep the title imperative and under about 70 characters.
4. If the change is not backwards compatible, say so explicitly and note the migration.

## Rules

- One logical fix per commit. If you fixed two things, make two commits.
- Do not stage build artifacts, unrelated formatting, or generated files.
