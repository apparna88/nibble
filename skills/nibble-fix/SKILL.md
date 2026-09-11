---
name: nibble-fix
description: Apply the smallest change that fixes the root cause, preserving public contracts and every untouched line, then verify with the project's own commands. Use after the root cause and fix strategy are known, when it is time to actually change code in a repo you want to keep stable.
---

# nibble-fix

Bite 4 of the Nibble loop. Make the change and nothing else. A small bite is safe to ship to a repo you do not own; a big one is not. The measure of a good fix is how little else moves.

## Procedure

1. Change only the lines required by the root-cause fix.
2. Do not reformat neighboring code, rename things, or rewrite tests unless a test is genuinely broken by the fix.
3. Keep signatures, exports, and public contracts unchanged, so nothing downstream breaks.
4. Verify with the project's own commands (from nibble-map): run the tests and the build, and the linter if the project uses one. If a command fails, fix or revert; do not leave the tree red.
5. Report the change plainly: the files and lines touched, and the verification result. Skip introductory fluff.

## Rules

- Prefer the change that touches the fewest lines and the fewest files.
- If the minimal fix would break a public contract, stop and say so rather than widening the blast radius silently.
- Hand off to nibble-commit.
