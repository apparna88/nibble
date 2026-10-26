---
name: nibble-plan-review
description: Review a Nibble feature plan against the target repository before implementation. Check scope, architecture, conventions, wiring, and verification, then save evidence-based feedback to Markdown without editing the plan or code.
---

# nibble-plan-review

An optional second pass after `nibble-plan`. Check whether the proposed slice fits the actual repository and is ready for a human to approve before `nibble-build` starts.

## Procedure

1. Read `running-docs/nibble-plan.md` in the target repository. If the user supplies a different plan path, review that file instead.
2. If the plan is missing or unreadable, set the verdict to **Revise**, record that the review could not be completed, and point to `nibble-plan` as the next step. Do not invent a plan to review.
3. Check the plan against relevant repository evidence. Read only the files needed to assess its claims; reuse `running-docs/nibble-map.md` if available, then verify important paths and commands against the repo.
4. Review whether:
   - the feature outcome and scope are clear, and the slice delivers end-to-end behavior;
   - the chosen sibling is a good structural match and the proposed seam includes required layers and wiring;
   - the plan follows repository conventions and handles dependencies through the established mechanism;
   - verification uses real project commands and covers the promised behavior;
   - deferred items are safe to defer and do not hide requirements needed by the slice.
5. Report actionable gaps only. Separate **Blocking gaps** that should be fixed before implementation from **Suggestions** that are useful but not required. For each point, cite the plan section and repository evidence (file and line, command, or configuration) when available, explain the impact, and suggest a concrete correction. Do not report stylistic preferences or repeat sound parts of the plan.
6. Set the verdict to **Revise** when the plan is unavailable or any blocking gap remains. Use **Ready for human approval** only after reviewing an available plan and finding no blockers. Ready means the plan has no identified blockers; it is not approval to implement.

## Output

Write the complete review to `running-docs/nibble-plan-review.md` at the target repository root, creating `running-docs/` if needed. Include the reviewed plan path, verdict, blocking gaps, suggestions, and any limits on what could be verified. If the plan is missing, write that result to the same file. Replace only the previous plan-review report on each run. In the conversation, provide the report path and verdict; do not repeat the full review.

## Rules

- Review only. Do not edit the plan, source code, tests, or configuration.
- Do not run the plan's implementation steps or approve changes on the user's behalf.
- Ground findings in repository evidence. Mark uncertainty instead of guessing.
- Keep the review focused on changes that would materially improve correctness, feasibility, or verification.
