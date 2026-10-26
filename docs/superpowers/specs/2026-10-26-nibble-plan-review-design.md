# Nibble Plan Review Design

## Intent

Add a standalone skill that critiques a plan produced by `nibble-plan` before implementation. Save its verdict and actionable feedback to `running-docs/nibble-plan-review.md` in the target repository so the plan author can review it as a file.

## Goals

- Review plan fit against the target repository, not just prose quality.
- Check scope, sibling choice, integration points, conventions, verification, and deferred work.
- Preserve the original plan and make no code changes.
- Expose the skill through Nibble's installer and README.

## Non-goals

- Make plan review a required loop step.
- Rewrite or approve the plan automatically, or implement its recommendations.
- Add a new dependency or change the existing `nibble-plan` behavior.

## Approach

Add a standalone `nibble-plan-review` skill. It reads `.nibble/nibble-plan.md`, checks claims against relevant repository files, then writes a `Ready` or `Revise` verdict with evidence-based blockers and suggestions to `running-docs/nibble-plan-review.md` in the target repository. It replaces only its own previous report. Integrate the skill in the installer and README.

## Constraints

- The review report is a regular, visible Markdown file in the target repository.
- The skill does not edit the plan or source code.
- If no plan file exists, the skill reports that clearly, sets the verdict to `Revise`, and points to `nibble-plan`.
